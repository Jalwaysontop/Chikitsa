# Chikitsa

Chikitsa is a comprehensive rural healthcare diagnostics application developed using Flutter. It is operates efficiently within low-bandwidth environments, such as 2G networks. Provides features such as collection and transmission of patient diagnostic data, medical imagery, and medication tracking, ABHA ID integration , generic alternatives to branded drugs, disease tracking in a region

## Core Capabilities & Features

###  Medical Assessment & Diagnostics
* **Advanced Triage Service:** Simulates medical assessments to provide triage feedback, evaluate symptoms, and output diagnostic data.
* **Resilient Data Transmission:** Utilizes efficient data encoding (`ProtobufZstdHelper`) and compression to minimize payload size for rapid transmission.
* **Structured Data Serialization:** Uses Protocol Buffers (Protobuf) for strongly typed and efficient serialization of patient data (e.g., demographics, vitals, geolocation).

### Medication Management
* **Rx Scanner:** Prototype feature that scans medicine packages to quickly verify their authenticity and details.
* **Medication Tracker:** Helps users track their medication adherence, dosage, and inventory levels to prevent missed doses.
* **Generic Alternatives:** A unique feature allowing users to search and compare branded medicines with their generic equivalents, calculating potential healthcare savings.
* **Medical Reminders:** An integrated `NotificationService` that manages and delivers timely medication reminders.

### Image Processing Pipeline
* **Compression:** Large images are compressed to WebP format with a high-quality setting and resized to save bandwidth.
* **Chunking & Retry Mechanisms:** Files are broken down into 64KB chunks to prevent request timeouts, complete with an exponential backoff retry mechanism to gracefully handle network interruptions.

### Localization & Accessibility
* **Multi-language Support:** The application includes a `LanguageService` that dynamically supports multiple languages (English, Hindi, Bengali, Tamil, Telugu), complete with comprehensive Hindi translations for accessibility in rural India.

## Data Models

* **Patient Demographics:** ID, Name, Age, Gender, Phone.
* **Vitals:** Temperature, Blood Pressure, Heart Rate.
* **Metadata:** Geolocation (Latitude/Longitude), Unix Timestamps, and Symptoms list.

