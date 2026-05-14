"""
Medicine Matcher
================
Checks each entry in output.json against the CDSCO approved drugs dataset.
Matching strategy (firm name focus):
  1. Exact match on Firm Name  →  ✅ APPROVED (high confidence)
  2. Fuzzy match (≥ 75 score)  →  ⚠  LIKELY APPROVED (low confidence)
  3. No match                  →  ❌ NOT FOUND / POSSIBLY FAKE
The CDSCO dataset has no license-number column, so we can only match
on manufacturer (Firm Name). Output includes the best CDSCO match found.
Usage:
    python medicine_matcher.py                          # uses defaults below
    python medicine_matcher.py my_meds.json cdsco.csv  # custom paths
"""
import json
import csv
import sys
import unicodedata
import re
INPUT_JSON    = "output.json"
CDSCO_CSV     = "cdsco_approved_drugs.csv"
OUTPUT_JSON   = "match_results.json"
FUZZY_THRESH  = 75
def _normalize(text: str) -> str:
    """Lowercase, strip punctuation/whitespace for robust comparison."""
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    text = text.lower()
    text = re.sub(r"[^a-z0-9 ]", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text
def _token_set_ratio(a: str, b: str) -> int:
    """
    Token-set ratio: compares sorted token sets.
    Returns 0-100 (100 = identical after normalization).
    Uses Levenshtein-like edit distance via difflib.
    """
    import difflib
    a_norm = _normalize(a)
    b_norm = _normalize(b)
    if not a_norm or not b_norm:
        return 0
    seq_ratio = difflib.SequenceMatcher(None, a_norm, b_norm).ratio()
    a_tokens = set(a_norm.split())
    b_tokens = set(b_norm.split())
    intersection = a_tokens & b_tokens
    sorted_inter  = " ".join(sorted(intersection))
    sorted_a_diff = " ".join(sorted(a_tokens - intersection))
    sorted_b_diff = " ".join(sorted(b_tokens - intersection))
    t0 = sorted_inter
    t1 = (sorted_inter + " " + sorted_a_diff).strip()
    t2 = (sorted_inter + " " + sorted_b_diff).strip()
    ratios = [
        difflib.SequenceMatcher(None, t0, t1).ratio(),
        difflib.SequenceMatcher(None, t0, t2).ratio(),
        difflib.SequenceMatcher(None, t1, t2).ratio(),
        seq_ratio,
    ]
    return int(max(ratios) * 100)
def load_input(path: str) -> dict:
    with open(path, encoding="utf-8") as f:
        return json.load(f)
def load_cdsco(path: str) -> list[dict]:
    """Load CDSCO CSV; return list of row dicts."""
    rows = []
    with open(path, newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
    print(f"Loaded {len(rows):,} CDSCO records from '{path}'")
    return rows
def build_index(cdsco_rows: list[dict]) -> dict[str, list]:
    """
    Build a dict:  normalised_firm_name → [list of matching CDSCO rows]
    for O(1) exact lookups.
    """
    index = {}
    for row in cdsco_rows:
        firm = row.get("Firm Name", "")
        key  = _normalize(firm)
        index.setdefault(key, []).append(row)
    return index
def match_one(manufacturer: str, index: dict, cdsco_rows: list[dict], thresh: int):
    """
    Try exact then fuzzy match.
    Returns (status, score, best_match_row | None)
    """
    norm_mfr = _normalize(manufacturer)
    if norm_mfr in index:
        best = index[norm_mfr][0]
        return "APPROVED", 100, best
    best_score = 0
    best_row   = None
    for row in cdsco_rows:
        firm = row.get("Firm Name", "")
        score = _token_set_ratio(manufacturer, firm)
        if score > best_score:
            best_score = score
            best_row   = row
        if score == 100:
            break
    if best_score >= thresh:
        return "LIKELY APPROVED", best_score, best_row
    return "NOT FOUND", best_score, best_row
def run(input_path=INPUT_JSON, cdsco_path=CDSCO_CSV, out_path=OUTPUT_JSON):
    medicines   = load_input(input_path)
    cdsco_rows  = load_cdsco(cdsco_path)
    index       = build_index(cdsco_rows)
    results = {}
    for barcode, info in medicines.items():
        mfr    = info.get("manufacturer", "")
        status, score, match = match_one(mfr, index, cdsco_rows, FUZZY_THRESH)
        result = {
            "barcode":       barcode,
            "manufacturer":  mfr,
            "license_no":    info.get("license_no", ""),
            "net_qty":       info.get("net_qty", ""),
            "status":        status,
            "match_score":   score,
            "cdsco_match": {
                "Drug Name":            match.get("Drug Name", "")            if match else "",
                "Firm Name":            match.get("Firm Name", "")            if match else "",
                "Strength/Composition": match.get("Strength / Composition","") if match else "",
                "Indication":           match.get("Indication", "")           if match else "",
                "Date of Approval":     match.get("Date of Approval", "")     if match else "",
            } if match else None,
        }
        results[barcode] = result
        icon = {"APPROVED": "✅", "LIKELY APPROVED": "⚠️ ", "NOT FOUND": "❌"}[status]
        print(f"{icon}  [{score:3d}]  {barcode}  →  {status}")
        print(f"       Input mfr : {mfr}")
        if match:
            print(f"       CDSCO firm: {match.get('Firm Name','')}")
        print()
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    print(f"Results saved to '{out_path}'")
    return results
if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) == 0:
        run()
    elif len(args) == 2:
        run(args[0], args[1])
    else:
        print("Usage: python medicine_matcher.py [input.json cdsco.csv]")
        sys.exit(1)
