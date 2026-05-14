utf-8import cv2 as cv
import re
import numpy as np
from paddleocr import PaddleOCR
import json
ocr = PaddleOCR(use_angle_cls=True, lang='en')
def extract_medicine_data(result):
    i=0
    text=[]
    try:
        if result and result[0]:
            while i < len(result[0]) and result[0][i]:
                text.append(result[0][i][1][0])
                i+=1
    except IndexError:
        pass
    full_blob = " | ".join(text)
    stoppers = r"(VILLAGE|PLOT|DISTT|TEH|ROAD|CUSTOMER CARE|EMAIL|REGD|OFFICE)"
    data = {
        "barcode": "NOT_FOUND",
        "mfg_license": "NOT_FOUND",
        "manufacturer": "NOT_FOUND",
        "net_qty": "NOT_FOUND",
        "is_verified_format": False
    }
    barcode_match = re.search(r'\b\d{13}\b', full_blob)
    if barcode_match:
        data["barcode"] = barcode_match.group()
    lic_match = re.search(r'M\.L\.\s*No\.?\s*[:\-]?\s*([^|]+)', full_blob, re.IGNORECASE)
    if lic_match:
        data["mfg_license"] = lic_match.group(1).strip()
    qty_match = re.search(r'(\d+\s*(ml|g|ltr|mg|tablets|capsules))', full_blob, re.IGNORECASE)
    if qty_match:
        data["net_qty"] = qty_match.group(1)
    mfg_pattern = rf"(?:Manufactured\s+in\s+India\s+by|Manufactured\s+by|Mfg\s+by)\s*[:\-]?\s*(.*?(?={stoppers}))"
    mfg_match = re.search(mfg_pattern, full_blob, re.IGNORECASE)
    if mfg_match:
        raw_name = mfg_match.group(1)
        data["manufacturer"] = raw_name.replace("|", "").replace("  ", " ").strip()
    if data["barcode"] != "NOT_FOUND" and data["manufacturer"] != "NOT_FOUND":
        data["is_verified_format"] = True
    return data
def process_image(img_numpy):
    """
    Main function for the API.
    Takes OpenCV image loaded from API, runs OCR, returns parsed dictionary.
    """
    if img_numpy.dtype != 'uint8':
        img_numpy = cv.normalize(img_numpy, None, 0, 255, cv.NORM_MINMAX, dtype=cv.CV_8U)
    result = ocr.ocr(img_numpy)
    if not result or not result[0]:
        return extract_medicine_data([])
    return extract_medicine_data(result)
