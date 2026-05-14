"""
GS1 Verified by GS1 — Barcode Lookup (Playwright)
===================================================
Uses Playwright's bundled Chromium to avoid the Windows Chrome/Selenium
GetHandleVerifier crash.
Requirements (auto-installed on first run):
    pip install playwright
    playwright install chromium
Usage:
    python gs1_lookup.py                    # batch from output.json
    python gs1_lookup.py 8903228312134      # single GTIN
    # If blocked by CAPTCHA, add --show to solve it manually in the browser:
    python gs1_lookup.py 8903228312134 --show
"""
import sys, json, re, time
try:
    from playwright.sync_api import sync_playwright, TimeoutError as PwTimeout
except ImportError:
    import subprocess
    print("Installing playwright …")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "playwright", "-q"])
    subprocess.check_call([sys.executable, "-m", "playwright", "install", "chromium"])
    from playwright.sync_api import sync_playwright, TimeoutError as PwTimeout
try:
    from playwright_stealth import stealth_sync
except ImportError:
    stealth_sync = None
SEARCH_URL   = "https://www.gs1.org/services/verified-by-gs1/results"
TERMS_COOKIE = "gsone_verified_search_terms_1_2"
WAIT_MS_HEADLESS = 12_000
WAIT_MS_VISIBLE  = 60_000
def _parse_page_text(text: str) -> dict:
    """Extract structured fields from the visible page text."""
    def _grab(pattern: str, text: str) -> str:
        m = re.search(pattern, text, re.I | re.S)
        if m:
            val = m.group(1).strip()
            val = re.split(r'\n(?=Address|License|GLN|Product|Website|Global Location)', val)[0]
            val = val.replace('\t', ' ').strip()
            return val[:300]
        return ""
    return {
        "company":       _grab(r"Company\s+Name\t(.+)", text),
        "address":       _grab(r"Address\t(.+)", text),
        "gln":           _grab(r"\bGLN\b[\t\n]+([\d]+)", text),
        "license_key":   _grab(r"License\s+Key\t([\w/\-]+)", text),
        "license_type":  _grab(r"License\s+Type\t(.+)", text),
        "gs1_mo":        _grab(r"Licensing\s+GS1\s+MO\t(.+)", text),
        "product_info":  _grab(r"Product\s+Info(?:rmation)?\t(.+)", text),
    }
def lookup_gtin(gtin: str, headless: bool = True) -> dict:
    """Look up a single GTIN on GS1 Verified by GS1 via a headless browser."""
    with sync_playwright() as pw:
        user_data_dir = "playwright_profile"
        ctx = pw.chromium.launch_persistent_context(
            user_data_dir,
            headless=headless,
            user_agent=(
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/124.0.0.0 Safari/537.36"
            )
        )
        try:
            page = ctx.new_page()
            if stealth_sync:
                stealth_sync(page)
            page.goto(SEARCH_URL, wait_until="domcontentloaded", timeout=30_000)
            ctx.add_cookies([{
                "name":   TERMS_COOKIE,
                "value":  "1",
                "domain": "www.gs1.org",
                "path":   "/",
            }])
            try:
                page.click("#onetrust-accept-btn-handler", timeout=3000)
            except Exception:
                pass
            page.fill("#gtin", gtin)
            page.click("button[name='gtin_submit']")
            page.wait_for_timeout(2000)
            if "complete the CAPTCHA" in page.inner_text("body"):
                if not headless:
                    print("\n\n[!!!] GS1 CAPTCHA DETECTED [!!!]")
                    print("1. Go to the open browser window.")
                    print("2. Solve the CAPTCHA image puzzle.")
                    print("3. Once the product result loads on the screen:")
                    input("--> Press ENTER here in the terminal to continue the pipeline...\n")
            try:
                page.click("button:has-text('Accept')", timeout=5000)
            except Exception:
                pass
            try:
                page.wait_for_selector("#product-content, .vbgs1-result, dl dt",
                                       timeout=WAIT_MS_HEADLESS if headless else WAIT_MS_VISIBLE)
            except PwTimeout:
                pass
            body_text = page.inner_text("body")
            fields    = _parse_page_text(body_text)
            registered = (
                bool(re.search(r"This number is registered to|Company information", body_text, re.I))
                or bool(fields.get("company"))
            )
            not_found = bool(re.search(r"not\s+found|invalid\s+gtin|barcode.*?not\s+registered", body_text, re.I))
            captcha_blocked = "complete the CAPTCHA" in body_text
            error_msg = ""
            if captcha_blocked:
                error_msg = "Blocked by GS1 CAPTCHA."
            return {
                "gtin":         gtin,
                "registered":   registered and not not_found,
                "error":        error_msg,
                **fields,
            }
        except Exception as exc:
            return {"gtin": gtin, "registered": None, "error": str(exc)[:300]}
        finally:
            if 'page' in locals():
                page.close()
            ctx.close()
def batch_lookup(input_json: str = "output.json",
                 output_json: str = "gs1_results.json",
                 delay: float = 2.0,
                 headless: bool = True):
    """Look up all barcodes in *input_json* and save to *output_json*."""
    with open(input_json, encoding="utf-8") as f:
        medicines = json.load(f)
    barcodes = list(medicines.keys())
    print(f"GS1 lookup for {len(barcodes)} barcode(s) …\n")
    all_results = {}
    with sync_playwright() as pw:
        user_data_dir = "playwright_profile"
        ctx = pw.chromium.launch_persistent_context(
            user_data_dir,
            headless=headless,
            user_agent=(
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/124.0.0.0 Safari/537.36"
            )
        )
        ctx.add_cookies([{
            "name":   TERMS_COOKIE,
            "value":  "1",
            "domain": "www.gs1.org",
            "path":   "/",
        }])
        for barcode in barcodes:
            print(f"  {barcode} … ", end="", flush=True)
            try:
                page = ctx.new_page()
                if stealth_sync:
                    stealth_sync(page)
                page.goto(SEARCH_URL, wait_until="domcontentloaded", timeout=30_000)
                try:
                    page.click("#onetrust-accept-btn-handler", timeout=2000)
                except Exception:
                    pass
                page.fill("#gtin", barcode)
                page.click("button[name='gtin_submit']")
                page.wait_for_timeout(2000)
                if "complete the CAPTCHA" in page.inner_text("body"):
                    if not headless:
                        print("\n\n[!!!] GS1 CAPTCHA DETECTED [!!!]")
                        print("1. Go to the open browser window.")
                        print("2. Solve the CAPTCHA image puzzle.")
                        print("3. Once the product result loads on the screen:")
                        input("--> Press ENTER here in the terminal to continue the pipeline...\n")
                    else:
                        print(" [CAPTCHA Blocked] ", end="")
                try:
                    page.click("button:has-text('Accept')", timeout=4000)
                except Exception:
                    pass
                try:
                    page.wait_for_selector("#product-content, dl dt",
                                           timeout=WAIT_MS_HEADLESS if headless else WAIT_MS_VISIBLE)
                except PwTimeout:
                    pass
                body_text = page.inner_text("body")
                fields    = _parse_page_text(body_text)
                registered = (
                    bool(re.search(r"This number is registered to|Company information", body_text, re.I))
                    or bool(fields.get("company"))
                )
                not_found = bool(re.search(r"not\s+found|invalid\s+gtin|barcode.*?not\s+registered", body_text, re.I))
                captcha_blocked = "complete the CAPTCHA" in body_text
                error_msg = "Blocked by GS1 CAPTCHA." if captcha_blocked else ""
                res = {"gtin": barcode, "registered": registered and not not_found, "error": error_msg, **fields}
                page.close()
            except Exception as exc:
                res = {"gtin": barcode, "registered": None, "error": str(exc)[:300]}
            all_results[barcode] = res
            if res.get("error"):
                icon = f"⚠️  ERROR: {res.get('error','')[:60]}"
            elif res.get("registered") is True:
                icon = "✅ REGISTERED"
            else:
                icon = "❌ NOT REGISTERED"
            print(icon)
            if res.get("company"):  print(f"     Company : {res['company']}")
            if res.get("address"):  print(f"     Address : {res['address'][:80]}")
            if res.get("gs1_mo"):   print(f"     GS1 MO  : {res['gs1_mo']}")
            print()
            if len(barcodes) > 1:
                time.sleep(delay)
        ctx.close()
    with open(output_json, "w", encoding="utf-8") as f:
        json.dump(all_results, f, indent=2, ensure_ascii=False)
    print(f"Saved to '{output_json}'")
    return all_results
if __name__ == "__main__":
    args = sys.argv[1:]
    show_browser = "--show" in args
    if show_browser:
        args.remove("--show")
    if len(args) == 1 and not args[0].endswith(".json"):
        r = lookup_gtin(args[0], headless=not show_browser)
        print(json.dumps(r, indent=2, ensure_ascii=False))
    else:
        in_f  = args[0] if args else "output.json"
        out_f = args[1] if len(args) > 1 else "gs1_results.json"
        batch_lookup(in_f, out_f, headless=not show_browser)
