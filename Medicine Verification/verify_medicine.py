"""
Master Medicine Verification Pipeline
======================================
Integrates both the CDSCO database matcher and the GS1 Barcode lookup.
For each medicine in input.json:
  1. Looks up the barcode in GS1 (using Playwright, bypassing CAPTCHA).
  2. Extracts the GS1 registered company.
  3. Checks the claimed manufacturer (from input.json) against CDSCO.
  4. Checks the verified GS1 company against CDSCO.
  5. Produces a comprehensive JSON report and terminal summary.
Usage:
    python verify_medicine.py                   # defaults to output.json, shows browser
    python verify_medicine.py --headless        # hide browser (may get stuck on CAPTCHA)
"""
import json
import sys
import medicine_matcher
import gs1_lookup
INPUT_JSON = "output.json"
CDSCO_CSV  = "cdsco_approved_drugs.csv"
FINAL_REPORT_JSON = "final_verification_report.json"
def verify_all(input_file=INPUT_JSON, cdsco_csv=CDSCO_CSV, show_browser=True):
    with open(input_file, encoding="utf-8") as f:
        medicines = json.load(f)
    print(f"=== STEP 1: GS1 Barcode Verification ===")
    if show_browser:
        print("Note: Browser will be visible. Please solve any GS1 CAPTCHAs if prompted.")
        print("      (Your session is now saved, so you only need to solve it ONCE!)\n")
    gs1_results = gs1_lookup.batch_lookup(
        input_json=input_file,
        output_json="temp_gs1_results.json",
        delay=2.0,
        headless=not show_browser
    )
    print(f"\n=== STEP 2: CDSCO License Verification ===")
    cdsco_rows = medicine_matcher.load_cdsco(cdsco_csv)
    cdsco_index = medicine_matcher.build_index(cdsco_rows)
    final_report = {}
    print("\n=== FINAL VERIFICATION SUMMARY ===")
    for barcode, label_data in medicines.items():
        claimed_mfr = label_data.get("manufacturer", "Unknown")
        gs1_data = gs1_results.get(barcode, {})
        gs1_company = gs1_data.get("company", "")
        c_status, c_score, c_match = medicine_matcher.match_one(
            claimed_mfr, cdsco_index, cdsco_rows, medicine_matcher.FUZZY_THRESH
        )
        g_status, g_score, g_match = ("NOT FOUND", 0, None)
        if gs1_company:
            g_status, g_score, g_match = medicine_matcher.match_one(
                gs1_company, cdsco_index, cdsco_rows, medicine_matcher.FUZZY_THRESH
            )
        mfr_consistency_score = 0
        if gs1_company and claimed_mfr:
            mfr_consistency_score = medicine_matcher._token_set_ratio(claimed_mfr, gs1_company)
        record = {
            "barcode": barcode,
            "label_data": label_data,
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
            "overall_assessment": ""
        }
        if gs1_data.get("registered") is False:
            warning = "🚨 SUSPICIOUS: Barcode not registered on GS1."
        elif gs1_data.get("error"):
            warning = f"⚠️ INCONCLUSIVE: GS1 Error ({gs1_data['error']})."
        elif g_status in ("APPROVED", "LIKELY APPROVED"):
            warning = "✅ VERIFIED: GS1 company is a CDSCO approved manufacturer."
        elif c_status in ("APPROVED", "LIKELY APPROVED") and mfr_consistency_score > 70:
            warning = "✅ VERIFIED: Claimed manufacturer is approved and matches GS1 registration."
        elif c_status in ("APPROVED", "LIKELY APPROVED") and mfr_consistency_score <= 70:
            warning = "⚠️ WARNING: Claimed manufacturer is approved, but DOES NOT MATCH the GS1 registered owner."
        else:
            warning = "❌ FAILED: Neither the label manufacturer nor the GS1 owner was found in the CDSCO approved list."
        record["overall_assessment"] = warning
        final_report[barcode] = record
        print(f"\nBarcode: {barcode}")
        print(f"  Label Mfr     : {claimed_mfr}")
        print(f"  CDSCO Status  : {c_status} (Score {c_score})")
        print(f"  GS1 Company   : {gs1_company if gs1_company else '<Not Found/Blocked>'}")
        print(f"  GS1->CDSCO    : {g_status} (Score {g_score})")
        print(f"  => {warning}")
    with open(FINAL_REPORT_JSON, "w", encoding="utf-8") as f:
        json.dump(final_report, f, indent=2, ensure_ascii=False)
    print(f"\nDetailed verification report written to: {FINAL_REPORT_JSON}")
if __name__ == "__main__":
    args = sys.argv[1:]
    show_browser = "--headless" not in args
    verify_all(show_browser=show_browser)
