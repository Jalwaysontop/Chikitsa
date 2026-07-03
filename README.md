# Chikitsa 🏥

**Rural Healthcare Diagnostics App — Optimized for 2G-3G Networks**

Chikitsa (चिकित्सा) is a comprehensive healthcare diagnostics application built with Flutter, designed to operate efficiently in low-bandwidth environments across rural India. It empowers frontline health workers, ASHA workers, and rural patients with tools for medical assessment, medicine verification, disease surveillance, government scheme access, and medication management — all optimized to work on 2G-3G connections.

---

## ✨ Key Features

### 🩺 Medical Assessment & Triage
- Structured patient data collection: demographics, vitals (temperature, BP, heart rate), symptoms, and geolocation.
- Data serialized using **Protocol Buffers (Protobuf)** and compressed with **Zstandard (Zstd)** for minimal payload size.
- Uses a pre-trained compression dictionary (`patient_dict_32k.zst`) via native FFI bindings for maximum compression on small medical payloads.
- A full patient record can be transmitted even on a 2G-3G connection (~10–20 kbps).

### 💊 Medicine Verification (Rx Scanner)
- Photograph a medicine package using the phone camera.
- **PaddleOCR** extracts text from the image — barcode, manufacturer, manufacturing license, and quantity.
- **GTIN-13 barcode validation** verifies check digit integrity and identifies the country of origin from GS1 prefix tables.
- **CDSCO cross-referencing** matches the claimed manufacturer against a database of **2.3 million government-approved drugs** using exact and fuzzy matching.
- Returns a clear verdict: ✅ **VERIFIED**, ❌ **SUSPICIOUS**, or ⚠️ **INCONCLUSIVE**.
- Suspicious medicines can be **reported to authorities** — the report (barcode, manufacturer, GPS coordinates, ABHA ID) is submitted to Supabase.

### 💰 Generic Alternatives
- Search for branded medicines and discover their **generic equivalents**.
- Calculates potential **cost savings** — critical for patients in rural areas who can't afford branded drugs.
- Works entirely offline using a bundled CSV dataset.

### 🏛️ Government Scheme Matcher
- Matches a patient's profile — age, annual family income, state, family size, and existing conditions — against eligibility rules for central and state health schemes (**Ayushman Bharat PM-JAY**, state-specific RSBY variants, **Janani Suraksha Yojana**, and others).
- Runs entirely **offline** using a bundled scheme-eligibility rules dataset, so it works even with zero connectivity — no different from the last mile it's built for.
- Returns every scheme the patient qualifies for, along with coverage amount, required documents, and the nearest empanelled hospital or enrollment center.
- Closes the "entitlement gap": many eligible rural families never learn a scheme exists for them until it's too late.
- Example: a 45-year-old patient, ₹2 lakh/year household income, family of 5, in Bihar → instantly matched to PM-JAY (₹5 lakh cover) and a relevant state maternal-health scheme.

### 📋 Medication Tracker
- Track medication **adherence, dosage, and inventory levels**.
- Prevents missed doses with structured medication schedules.

### ⏰ Medical Reminders
- Local notification system with **timezone-aware scheduling**.
- Configurable reminders for medication times using `flutter_local_notifications`.

### 🆔 ABHA ID Integration
- Scans and stores **Ayushman Bharat Health Account (ABHA)** QR codes.
- ABHA ID is attached to all medical assessments and counterfeit reports for national health record traceability.

### 🦠 Disease Surveillance
- Tracks disease outbreaks in a region with a local **SQLite database**.
- Visual analytics with **charts and graphs** (fl_chart) for trend monitoring.
- Active alert count displayed on the home screen.
- Data synced to Supabase for centralized surveillance.

### 📷 Medical Image Pipeline
- Images compressed to **WebP format** with quality optimization and resizing.
- Files broken into **64KB chunks** with exponential backoff retry for unreliable connections.
- Designed to handle high-resolution medical imagery over slow networks.

### 🌐 Multi-Language Support
- **5 languages**: English, Hindi, Bengali, Tamil, and Telugu.
- Comprehensive Hindi translations for rural accessibility.
- Real-time language switching across the entire app.

### 🎤 Voice Input
- Speech-to-text input for users who may not be literate or comfortable typing.
- Multi-language voice support via Google ML Kit translation.

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────┐
│              Flutter Mobile App              │
│                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────────┐ │
│  │  Screens  │ │ Services │ │   Widgets    │ │
│  │ (12 UIs)  │ │(12 svcs) │ │  (reusable)  │ │
│  └────┬─────┘ └────┬─────┘ └──────────────┘ │
│       │             │                        │
│  ┌────┴─────────────┴────┐                   │
│  │   Protobuf + Zstd     │   ┌────────────┐ │
│  │   Compression Layer   │   │  SQLite DB  │ │
│  └───────────┬───────────┘   └────────────┘ │
└──────────────┼───────────────────────────────┘
               │ HTTP
┌──────────────┼───────────────────────────────┐
│     Python FastAPI Backend (Port 8000)       │
│              │                               │
│  ┌───────────┴───────────┐                   │
│  │    POST /verify       │                   │
│  └───────────┬───────────┘                   │
│              │                               │
│  ┌───────────┴───────────────────────────┐   │
│  │  PaddleOCR → GTIN Validator → CDSCO   │   │
│  │  (Extract)   (Validate)    (Match)    │   │
│  └───────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
               │
┌──────────────┼───────────────────────────────┐
│          Supabase (Cloud)                    │
│  Patient Records · Counterfeit Reports ·     │
│  Disease Surveillance · Sync                 │
└──────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart), Material Design 3 *[cross-platform single codebase cuts dev/maintenance cost for low-resource deployment; Material 3 gives accessible, high-contrast components by default]* |
| Backend | Python, FastAPI, Uvicorn *[FastAPI's async request handling processes concurrent OCR/verification calls without blocking]* |
| OCR | PaddleOCR (PaddlePaddle) *[strong accuracy on low-quality, low-light phone-camera images of small print — the norm for rural photo conditions]* |
| Serialization | Protocol Buffers + Zstandard (FFI) *[Protobuf yields a smaller binary payload than JSON; Zstd with a pre-trained dictionary compresses small, repetitive medical records further for transmission over 2G-3G]* |
| Cloud Database | Supabase (PostgreSQL) *[managed Postgres gives relational integrity for patient/report data plus built-in realtime sync for surveillance dashboards]* |
| Local Database | SQLite (sqflite), SharedPreferences *[on-device storage that keeps working through zero-connectivity periods]* |
| Barcode Scanning | mobile_scanner *[reads directly via native platform camera APIs for low-latency scans with no server round-trip]* |
| Barcode Validation | GTIN-13 check digit + GS1 prefix tables *[check-digit math and prefix lookups run entirely on-device, so validation works with zero internet]* |
| Drug Database | CDSCO Approved Drugs (2.3M records CSV) *[flat CSV enables offline exact/fuzzy matching without a live database connection]* |
| Scheme Eligibility | Offline scheme-rules dataset (JSON/CSV), rule-based matching engine *[eligibility thresholds are fixed legal criteria, not probabilistic, so a deterministic rule engine gives auditable results without needing connectivity for inference]* |
| Notifications | flutter_local_notifications + timezone *[fires medication alerts correctly on-device even with no network, across time zones]* |
| Charts | fl_chart *[lightweight rendering keeps surveillance dashboards responsive on low-end Android hardware]* |
| Voice Input | speech_to_text, Google ML Kit Translation *[supports low-literacy users; ML Kit translates on-device without server calls]* |
| Image Processing | flutter_image_compress, image_picker *[compresses medical images pre-upload, cutting payload size for slow-network transmission]* |
| Typography | Google Fonts *[bundled fonts render consistently across devices, independent of OS font availability]* |

---

## 📁 Project Structure

```
Chikitsa/
├── lib/
│   ├── main.dart                    # App entry point, theme management
│   ├── screens/
│   │   ├── home_screen.dart         # Main dashboard
│   │   ├── bson_demo_screen.dart    # Medical assessment & triage
│   │   ├── rx_scanner_screen.dart   # Medicine verification UI
│   │   ├── image_upload_screen.dart # Camera/gallery image capture
│   │   ├── generic_alts_screen.dart # Generic alternatives search
│   │   ├── scheme_matcher_screen.dart # Government scheme eligibility UI
│   │   ├── medication_tracker_screen.dart
│   │   ├── medical_reminders_screen.dart
│   │   ├── abha_scanner_screen.dart # ABHA ID scanner
│   │   ├── surveillance_screen.dart # Disease surveillance
│   │   ├── activity_history_screen.dart
│   │   └── splash_screen.dart
│   ├── services/
│   │   ├── medicine_verification_service.dart  # API client
│   │   ├── medical_assessment_service.dart
│   │   ├── generic_alts_service.dart
│   │   ├── scheme_matching_service.dart # Offline scheme eligibility engine
│   │   ├── notification_service.dart
│   │   ├── language_service.dart
│   │   ├── surveillance_service.dart
│   │   ├── surveillance_database.dart
│   │   ├── supabase_sync_service.dart
│   │   ├── abha_auth_service.dart
│   │   ├── image_upload_service.dart
│   │   └── text_service.dart
│   ├── utils/
│   │   └── protobuf_zstd_helper.dart  # Protobuf + Zstd compression
│   ├── widgets/
│   │   ├── abha_card_widget.dart
│   │   └── voice_input_button.dart
│   ├── theme/
│   │   └── app_theme.dart           # Light/dark theme definitions
│   └── proto/                       # Protobuf generated files
│
├── Medicine Verification/           # Python backend
│   ├── api.py                       # FastAPI server
│   ├── Image_preprocessing.py       # PaddleOCR text extraction
│   ├── gtin_validator.py            # Offline GTIN-13 barcode validation
│   ├── medicine_matcher.py          # CDSCO fuzzy matching engine
│   ├── verify_medicine.py           # CLI verification pipeline
│   ├── cdsco_approved_drugs.csv     # 2.3M approved drugs database
│   └── requirements.txt
│
├── assets/
│   ├── images/                      # App logos
│   ├── patient_dict_32k.zst         # Zstd compression dictionary
│   ├── generic_alternative.csv      # Generic drug alternatives
│   └── government_schemes.json      # Scheme eligibility rules dataset
│
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** (≥ 3.0.0)
- **Python 3.10** (for the medicine verification backend)
- **Android device** or emulator
- **ADB** (Android Debug Bridge) — for physical device testing

### 1. Run the Backend

```bash
cd "Medicine Verification"
python -m venv venv
.\venv\Scripts\activate        # Windows
pip install -r requirements.txt
python api.py
```

The API starts at `http://localhost:8000` with two endpoints:
- `POST /verify` — accepts a medicine image, returns verification verdict
- `GET /health` — health check

### 2. Run the Flutter App

```bash
# For physical device (connect via USB first):
adb reverse tcp:8000 tcp:8000
flutter run

# For Android emulator:
flutter run
# (auto-connects to backend via 10.0.2.2)
```

### 3. Test the API Independently

```bash
# Health check
curl http://localhost:8000/health

# Verify a medicine image
curl -X POST http://localhost:8000/verify -F "file=@medicine_photo.jpg"
```

---

## 📊 Medicine Verification Pipeline

The verification pipeline has three stages:

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  PaddleOCR  │ ──▶ │  GTIN Validator  │ ──▶ │  CDSCO Matcher  │
│             │     │                  │     │                 │
│ Extract:    │     │ Validate:        │     │ Cross-ref:      │
│ • Barcode   │     │ • Check digit    │     │ • Exact match   │
│ • Mfr name  │     │ • Country lookup │     │ • Fuzzy match   │
│ • License   │     │ • Format check   │     │ • Score 0-100   │
│ • Quantity  │     │                  │     │                 │
└─────────────┘     └──────────────────┘     └─────────────────┘
                                                      │
                                              ┌───────┴───────┐
                                              │    Verdict     │
                                              │ VERIFIED /     │
                                              │ SUSPICIOUS /   │
                                              │ INCONCLUSIVE   │
                                              └───────────────┘
```

**Verdict Logic:**
- ✅ **VERIFIED** — Valid barcode + manufacturer found in CDSCO approved list
- ❌ **SUSPICIOUS** — Invalid check digit OR manufacturer not in CDSCO for an Indian barcode
- ⚠️ **INCONCLUSIVE** — Valid barcode from a non-Indian origin, manufacturer not in Indian CDSCO database

---

## 🎨 Design Philosophy

- **Offline-first**: Barcode validation, CDSCO matching, generic alternatives, scheme eligibility matching, medication tracking — all work without internet.
- **2G-3G-optimized**: Protobuf + Zstd compression reduces payloads by 80–90%. Image chunking with retry handles flaky connections.
- **No API keys required**: The entire medicine verification pipeline runs locally — no third-party APIs, no billing, no rate limits.
- **Brutalist UI**: Square corners, bold borders, high contrast, heavy typography — intentionally designed for readability on low-end phones in bright outdoor conditions.
- **Accessibility**: Multi-language support (5 Indian languages), voice input, and large touch targets for users of all literacy levels.

---

## 📦 Data Models

| Model | Fields |
|-------|--------|
| Patient Demographics | ID, Name, Age, Gender, Phone |
| Vitals | Temperature, Blood Pressure, Heart Rate |
| Metadata | Geolocation (Lat/Long), Unix Timestamps, Symptoms |
| Medicine Verification | Barcode, Manufacturer, License, CDSCO Match, Verdict |
| Counterfeit Report | Barcode, Company, Location, ABHA ID, Timestamp |
| Scheme Match | Scheme ID, Scheme Name, Income Threshold, Age Range, Coverage Amount, Required Documents, Nearest Empanelled Center |

---

## 📄 License

This project is developed for healthcare accessibility in rural India.
