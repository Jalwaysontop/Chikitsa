"""
Medicine Verification API (FastAPI backend for Flutter)
=======================================================
Accepts image uploads from a Flutter app, extracts the medicine label text,
looks up the GS1 barcode data, and cross-references against the CDSCO approved drugs database.
"""
from fastapi import FastAPI, UploadFile, File, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import cv2
import numpy as np
import json
import traceback
import concurrent.futures
import Image_preprocessing
import gs1_lookup
import medicine_matcher
app = FastAPI(title="Fake Medicine Verifier API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
print("Loading CDSCO Approved Drugs Index into RAM...")
CDSCO_CSV = "cdsco_approved_drugs.csv"
cdsco_rows = medicine_matcher.load_cdsco(CDSCO_CSV)
cdsco_index = medicine_matcher.build_index(cdsco_rows)
print(f"Loaded {len(cdsco_rows)} approved medicines.")
@app.post("/verify")
async def verify_medicine_image(file: UploadFile = File(...)):
    print("\n[DEBUG] ============= NEW REQUEST RECEIVED =============")
    try:
        print("[DEBUG] 1. Loading image from upload...")
        contents = await file.read()
        print(f"[DEBUG] Image size read: {len(contents)} bytes")
        nparr = np.frombuffer(contents, np.uint8)
        img_bgr = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if img_bgr is None:
            raise ValueError("Failed to decode image. Was a valid image file sent?")
        print(f"[DEBUG] Image dimensions: {img_bgr.shape}")
        print("[DEBUG] 2. Running OCR on image...")
        label_data = Image_preprocessing.process_image(img_bgr)
        print(f"[DEBUG] OCR output: {label_data}")
        barcode = label_data.get("barcode", "NOT_FOUND")
        claimed_mfr = label_data.get("manufacturer", "Unknown")
        if barcode == "NOT_FOUND":
            return {
                "status": "ERROR",
                "message": "No valid 13-digit GS1 barcode detected in image.",
                "ocr_extracted": label_data
            }
        print(f"[DEBUG] 3. Querying GS1 for barcode: {barcode}...")
        def run_gs1(b):
            return gs1_lookup.lookup_gtin(b, headless=False)
        with concurrent.futures.ThreadPoolExecutor(max_workers=1) as executor:
            future = executor.submit(run_gs1, barcode)
            gs1_data = future.result()
        print(f"[DEBUG] GS1 result: {gs1_data}")
        gs1_company = gs1_data.get("company", "")
        print(f"[DEBUG] 4. Verifying {claimed_mfr} and {gs1_company} against CDSCO...")
        c_status, c_score, c_match = medicine_matcher.match_one(
            claimed_mfr, cdsco_index, cdsco_rows, medicine_matcher.FUZZY_THRESH
        )
        print(f"[DEBUG] Claimed Mfr CDSCO Check: {c_status} (Score {c_score})")
        g_status, g_score, g_match = ("NOT FOUND", 0, None)
        if gs1_company:
            g_status, g_score, g_match = medicine_matcher.match_one(
                gs1_company, cdsco_index, cdsco_rows, medicine_matcher.FUZZY_THRESH
            )
            print(f"[DEBUG] GS1 Owner CDSCO Check: {g_status} (Score {g_score})")
        mfr_consistency_score = 0
        if gs1_company and claimed_mfr and claimed_mfr != "NOT_FOUND":
            mfr_consistency_score = medicine_matcher._token_set_ratio(claimed_mfr, gs1_company)
        print(f"[DEBUG] Manufacturer consistency score (Label vs GS1): {mfr_consistency_score}")
        print("[DEBUG] 5. Generating final assessment...")
        if gs1_data.get("registered") is False:
            warning = "🚨 SUSPICIOUS: Barcode not legally registered on GS1."
        elif gs1_data.get("error"):
             if "CAPTCHA" in gs1_data.get("error"):
                 warning = "⚠️ INCONCLUSIVE: GS1 server rejected request with CAPTCHA block."
             else:
                 warning = f"⚠️ INCONCLUSIVE: GS1 Error ({gs1_data['error']})."
        elif g_status in ("APPROVED", "LIKELY APPROVED"):
            warning = "✅ VERIFIED: GS1 company is a CDSCO approved manufacturer."
        elif c_status in ("APPROVED", "LIKELY APPROVED") and mfr_consistency_score > 70:
            warning = "✅ VERIFIED: Claimed manufacturer is approved and matches GS1 registration."
        elif c_status in ("APPROVED", "LIKELY APPROVED") and mfr_consistency_score <= 70:
            warning = "⚠️ WARNING: Claimed manufacturer is approved, but DOES NOT MATCH the GS1 registered owner."
        else:
            warning = "❌ FAILED: Neither the label manufacturer nor the GS1 owner was found in the CDSCO approved list."
        print("[DEBUG] Finished processing successfully.")
        return {
            "status": "SUCCESS",
            "barcode": barcode,
            "ocr_extracted_label": label_data,
            "gs1_verification": gs1_data,
            "cdsco_checks": {
                "claimed_mfr_check": {
                    "status": c_status,
                    "score": c_score,
                    "matched_firm": c_match.get("Firm Name", "") if c_match else ""
                },
                "gs1_company_check": {
                    "status": g_status,
                    "score": g_score,
                    "matched_firm": g_match.get("Firm Name", "") if g_match else ""
                }
            },
            "mfr_consistency_score": mfr_consistency_score,
            "overall_assessment": warning
        }
    except Exception as e:
        error_trace = traceback.format_exc()
        print(f"[DEBUG FATAL] API crashed:\n{error_trace}")
        return {
            "status": "CRASH",
            "message": f"Internal Server Error: {str(e)}",
            "traceback": error_trace
        }
if __name__ == "__main__":
    import os
    from pyngrok import ngrok
    port = 8000
    print("\n[INFO] Opening Ngrok Tunnel...")
    try:
        public_url = ngrok.connect(port).public_url
        print(f"\n=======================================================")
        print(f"🚀 NGROK PUBLIC API LIVE AT: {public_url}/verify")
        print(f"=======================================================\n")
    except Exception as e:
        print(f"[ERROR] Could not start ngrok: {e}")
        print("Make sure you have authenticated your ngrok account locally if required.")
    uvicorn.run(app, host="0.0.0.0", port=port)
