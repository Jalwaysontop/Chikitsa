# Fake Medicine Detection API

A robust backend pipeline to detect counterfeit or unregistered medicines by cross-referencing OCR data and global barcodes against both the GS1 Global Registry and the CDSCO (Central Drugs Standard Control Organisation) database.

## 🚀 Features

- **FastAPI Endpoints**: Designed to directly ingest label images from frontend clients (like Flutter) via a `POST /verify` endpoint.
- **Intelligent OCR Parsing**: Extracts critical identifying parameters such as 13-digit GS1 barcodes and claimed manufacturer names.
- **GS1 Barcode Validation**: Automates lookups via Playwright headless browsers against the official GS1 registry to extract the true, legally registered manufacturer for a barcode.
- **Advanced Bot & CAPTCHA Bypass**: Uses persistent context profiles and `playwright-stealth` to massively reduce friction with GS1 CAPTCHAs, only requiring a single manual solve per session.
- **CDSCO Government Matching**: Uses fuzzy logic scoring (`fuzzywuzzy`) to cross-reference extracted names against an offline, RAM-loaded CDSCO approved drug database for instant lookups.
- **AI Assessment Engine**: A rules-based decision engine that compares the printed label data against the validated GS1 database and government registries to flag suspicious activity.

## 📂 Repository Structure

The core pipeline consists of the following critical files:

- `api.py`: The entry point for the FastAPI server.
- `verify_medicine.py`: The master CLI execution script and batch verifier.
- `Image_preprocessing.py`: The OCR pipeline.
- `gs1_lookup.py`: Web scraper that powers the GS1 barcode check. 
- `medicine_matcher.py`: The fuzzy search engine against the CDSCO directory.
- `cdsco_approved_drugs.csv`: Local offline dictionary of all approved government drugs.
- `requirements.txt`: Python package dependencies.

## ⚙️ Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Jalwaysontop/Chikitsa
   cd Fake_Medicine
   ```

2. **Install dependencies:**
   Ensure you have Python 3.8+ installed.
   ```bash
   pip install -r requirements.txt
   ```

3. **Install Playwright Browsers:**
   Playwright is required to safely scrape the GS1 dataset.
   ```bash
   playwright install chromium
   ```

## 🛠️ Usage

### Running the API (For App Backends)

Simply run the API server. This will also load the massive CDSCO index directly into RAM so it processes requests instantly.

```bash
python api.py
```
*The server will expose a public ngrok tunnel on port 8000 and provide a `POST /verify` route for image uploads.*

### Running the Verification CLI (Batch Mode)

You can run individual lookups directly via the terminal by processing a pre-populated `output.json`:

```bash
python verify_medicine.py
```

### 🔒 Note on CAPTCHAs
The GS1 Registry actively tries to block bots. When you run the script for the first time, you may see the browser open and ask you to solve a Turnstile CAPTCHA. **Solve it manually once.** Because this project uses Playwright's persistent local profiles (`playwright_profile/`), your authenticated session will be saved locally, and subsequent script executions will cleanly bypass the CAPTCHAs.

## 📄 License
This project is open-source.
