import 'package:flutter/material.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  static LanguageService get current => _instance;

  LanguageService._internal();

  final ValueNotifier<Locale> localeNotifier =
      ValueNotifier(const Locale('en', 'US'));

  bool get isHindi => localeNotifier.value.languageCode == 'hi';

  void toggleLanguage() {
    if (isHindi) {
      localeNotifier.value = const Locale('en', 'US');
    } else {
      localeNotifier.value = const Locale('hi', 'IN');
    }
  }

  // Translation Database
  final Map<String, String> _hindiStrings = {
    // Home Screen
    'BRAND': 'चिकित्सा',
    'HEADLINE': 'देखभाल\nका भविष्य।',
    'TAGLINE': 'स्वास्थ्य बुद्धिमत्ता',
    'SUBHEAD':
        'हम प्रगतिशील व्यक्तियों को रणनीतिक स्वास्थ्य निगरानी के माध्यम से स्थायी प्रभाव पैदा करने के लिए सशक्त बनाते हैं।',
    'CTA_START': 'मूल्यांकन शुरू करें',
    'CARD_MEDS': 'दवा\nट्रैकर',
    'CARD_REMINDERS': 'स्मार्ट\nरिमाइंडर्स',
    'CARD_GENERIC': 'जेनेरिक\nविकल्प',
    'CARD_RX': 'पर्ची\nस्कैनर',
    'CARD_ABHA': 'आभा\nस्कैनर',
    'CTA_RESCAN_ABHA': 'आभा आईडी फिर से स्कैन करें / नए विवरण सिंक करें',
    'CARD_SURVEILLANCE': 'रोग\nनिगरानी',

    // Assessment Screen
    'TITLE_ASSESSMENT': 'नया मूल्यांकन',
    'SECTION_PATIENT': 'रोगी विवरण',
    'LABEL_NAME': 'रोगी का नाम',
    'HINT_NAME': 'पूरा नाम दर्ज करें',
    'LABEL_PHONE': 'फ़ोन नंबर',
    'HINT_PHONE': '१० अंकों का नंबर',
    'LABEL_AGE': 'उम्र',
    'HINT_AGE': 'उम्र (वर्षों में)',
    'LABEL_GENDER': 'लिंग',
    'OPT_MALE': 'पुरुष',
    'OPT_FEMALE': 'महिला',
    'OPT_OTHER': 'अन्य',

    'SECTION_VITALS': 'स्वास्थ्य संकेत और लक्षण',
    'LABEL_SYMPTOMS': 'लक्षण',
    'HINT_SYMPTOMS': 'लक्षण बोलकर या लिखकर दर्ज करें',
    'SIM_SYMPTOMS': 'बुखार और सिरदर्द',
    'LABEL_BP': 'रक्तचाप (BP)',
    'HINT_BP': 'जैसे १२०/८०',
    'SIM_BP': '१२०/८०',
    'LABEL_TEMP': 'तापमान',
    'HINT_TEMP': '९८.६ आदि',
    'SIM_TEMP': '९८.६',
    'LABEL_WEIGHT': 'वजन',
    'HINT_WEIGHT': 'किग्रा',
    'SIM_WEIGHT': '६५',

    'HEADER_PHOTO': 'बीमारी की तस्वीर', // IMAGE OF AILMENT
    'BTN_UPLOAD': 'फोटो अपलोड करें', // UPLOAD PHOTO
    'STATUS_ATTACHED': 'फोटो संलग्न',
    'STATUS_MANDATORY': '(अनिवार्य)',
    'STATUS_READY': 'जमा करने के लिए तैयार',

    'BTN_SUBMIT': 'महत्वपूर्ण संकेत जमा करें',
    'ERR_PHOTO_REQ': 'आपको पहले एक चिकित्सा फोटो अपलोड करना होगा।',

    // Image Upload Screen
    'TITLE_IMAGE': 'मेडिकल इमेजिंग',
    'BTN_CAMERA': 'कैमरा',
    'BTN_GALLERY': 'गैलरी',
    'BTN_UPLOAD_SECURE': 'सुरक्षित रूप से अपलोड करें',
    'STATUS_SELECT': 'एक्स-रे या रिपोर्ट चुनें',

    // History
    'TITLE_HISTORY': 'गतिविधि इतिहास',
    'NO_RECORDS': 'कोई रिकॉर्ड नहीं मिला',
    'BTN_CLEAR': 'साफ़ करें',
    'BTN_CANCEL': 'रद्द करें',
    'MSG_CLEAR_CONFIRM': 'क्या आप सभी इतिहास साफ़ करना चाहते हैं?',
    'LABEL_PATIENT_DATA': 'रोगी डेटा',
    'LABEL_VITALS': 'महत्वपूर्ण संकेत',
    'LABEL_TRANSMISSION': 'संप्रेषण स्थिति',
    'STATUS_SUCCESS': 'सफल',
    'STATUS_FAILED': 'विफल',
    'MSG_NO_HISTORY': 'कोई इतिहास उपलब्ध नहीं',

    // Reminders
    'TITLE_REMINDERS': 'रिमाइंडर्स',
    'BTN_ADD_REMINDER': 'रिमाइंडर जोड़ें',
    'MSG_NO_REMINDERS': 'कोई रिमाइंडर सेट नहीं',
    'LABEL_MEDICINE_NAME': 'दवा का नाम',
    'HINT_MEDICINE_NAME': 'जैसे, पेरासिटामोल',
    'LABEL_DOSAGE': 'खुराक',
    'HINT_DOSAGE': 'जैसे, 500mg, 1 गोली',
    'LABEL_TIME': 'समय',
    'LABEL_FREQUENCY': 'आवृत्ति',
    'BTN_SAVE_REMINDER': 'रिमाइंडर सहेजें',
    'MSG_DELETE_CONFIRM': 'क्या आप इसे हटाना चाहते हैं?',
    'MSG_REMINDER_DELETED': 'रिमाइंडर हटाया गया',
    'BTN_UNDO': 'पूर्ववत करें',

    // Rx Scanner
    'RX_TITLE': 'दवा की जांच',
    'RX_INSTRUCTION': 'प्रामाणिकता की जांच के लिए बारकोड स्कैन करें।',
    'RX_BTN_SCAN': 'दवा स्कैन करें',
    'RX_VERIFYING': 'निर्माता का सत्यापन हो रहा है...',
    'RX_BTN_SCAN_AGAIN': 'दूसरा स्कैन करें',

    // Medication Tracker
    'MED_TRACKER_TITLE': 'दवा ट्रैकर',
    'MED_ADHERENCE_LABEL': 'आज का अनुपालन',
    'MED_TODAY_SCHEDULE': 'आज की अनुसूची',
    'MED_LOW_STOCK': 'कम स्टॉक',
    'MED_LEFT': 'गोलियां बची हैं',
    'MED_BTN_ADD': 'दवा जोड़ें',

    // Generic Alts
    'GENERIC_TITLE': 'जेनेरिक विकल्प',
    'GENERIC_SEARCH_HINT': 'दवा खोजें...',
    'GENERIC_SAVE': 'बचत',
    'GENERIC_BRAND': 'महंगी ब्रांडेड',
    'GENERIC_ALT': 'किफायती जेनेरिक',
    'GENERIC_RECENT': 'हाल की खोजें',
  };

  // English fallback (keys themselves are usually English identifiers/defaults,
  // but explicit English map is good for structure if keys are abstract)
  final Map<String, String> _englishStrings = {
    'BRAND': 'CHIKITSA',
    'HEADLINE': 'FUTURE\nOF CARE.',
    'TAGLINE': 'HEALTH INTELLIGENCE',
    'SUBHEAD':
        'We empower progressive individuals to create lasting impact through strategic health monitoring.',
    'CTA_START': 'START ASSESSMENT',
    'CARD_MEDS': 'MEDICATION\nTRACKER',
    'CARD_REMINDERS': 'SMART\nREMINDERS',
    'CARD_GENERIC': 'GENERIC\nALTS',
    'CARD_RX': 'RX\nSCANNER',
    'CARD_ABHA': 'ABHA\nSCANNER',
    'CTA_RESCAN_ABHA': 'Rescan ABHA ID / Sync New Details',
    'CARD_SURVEILLANCE': 'DISEASE\nSURVEILLANCE',
    'TITLE_ASSESSMENT': 'New Entry',
    'SECTION_PATIENT': 'Patient Details',
    'LABEL_NAME': 'Patient Name',
    'HINT_NAME': 'Enter full name',
    'LABEL_PHONE': 'Phone Number',
    'HINT_PHONE': '10-digit number',
    'LABEL_AGE': 'Age',
    'HINT_AGE': 'Age in years',
    'LABEL_GENDER': 'Gender',
    'OPT_MALE': 'Male',
    'OPT_FEMALE': 'Female',
    'OPT_OTHER': 'Other',
    'SECTION_VITALS': 'Vitals & Symptoms',
    'LABEL_SYMPTOMS': 'Symptoms',
    'HINT_SYMPTOMS': 'Speak or type symptoms...',
    'SIM_SYMPTOMS': 'Fever and headache',
    'LABEL_BP': 'Blood Pressure',
    'HINT_BP': 'e.g., 120/80',
    'SIM_BP': '120/80',
    'LABEL_TEMP': 'Temperature',
    'HINT_TEMP': '98.6 etc.',
    'SIM_TEMP': '98.6',
    'LABEL_WEIGHT': 'Weight',
    'HINT_WEIGHT': 'kg',
    'SIM_WEIGHT': '65',
    'HEADER_PHOTO': 'IMAGE OF AILMENT',
    'BTN_UPLOAD': 'UPLOAD PHOTO',
    'STATUS_ATTACHED': 'PHOTO ATTACHED',
    'STATUS_MANDATORY': '(Mandatory)',
    'STATUS_READY': 'Ready for submission',
    'BTN_SUBMIT': 'SUBMIT VITALS',
    'ERR_PHOTO_REQ': 'You must upload a medical photo first.',
    'TITLE_IMAGE': 'Medical Imaging',
    'BTN_CAMERA': 'Camera',
    'BTN_GALLERY': 'Gallery',
    'BTN_UPLOAD_SECURE': 'UPLOAD SECURELY',
    'STATUS_SELECT': 'SELECT X-RAY OR REPORT',
    'TITLE_HISTORY': 'Activity History',
    'NO_RECORDS': 'No records found',
    'BTN_CLEAR': 'Clear',
    'BTN_CANCEL': 'Cancel',
    'MSG_CLEAR_CONFIRM':
        'Are you sure you want to clear all assessment history?',
    'LABEL_PATIENT_DATA': 'Patient Data',
    'LABEL_VITALS': 'Vitals',
    'LABEL_TRANSMISSION': 'Transmission Status',
    'STATUS_SUCCESS': 'Success',
    'STATUS_FAILED': 'Failed',
    'MSG_NO_HISTORY': 'No history available',
    'TITLE_REMINDERS': 'Reminders',
    'BTN_ADD_REMINDER': 'Add Reminder',
    'MSG_NO_REMINDERS': 'No reminders set',
    'LABEL_MEDICINE_NAME': 'Medicine Name',
    'HINT_MEDICINE_NAME': 'e.g., Paracetamol',
    'LABEL_DOSAGE': 'Dosage',
    'HINT_DOSAGE': 'e.g., 500mg, 1 tablet',
    'LABEL_TIME': 'Time',
    'LABEL_FREQUENCY': 'Frequency',
    'BTN_SAVE_REMINDER': 'Save Reminder',
    'MSG_DELETE_CONFIRM': 'Are you sure you want to delete this reminder?',
    'MSG_REMINDER_DELETED': 'Reminder deleted',
    'BTN_UNDO': 'Undo',
    'RX_TITLE': 'Rx Verification',
    'RX_INSTRUCTION':
        'Align medicine package or barcode within the frame to verify authenticity.',
    'RX_BTN_SCAN': 'SCAN MEDICINE',
    'RX_VERIFYING': 'Verifying Manufacturer...',
    'RX_BTN_SCAN_AGAIN': 'SCAN ANOTHER',
    'MED_TRACKER_TITLE': 'Medication Tracker',
    'MED_ADHERENCE_LABEL': 'Today\'s Adherence',
    'MED_TODAY_SCHEDULE': 'Today\'s Schedule',
    'MED_LOW_STOCK': 'Low Stock',
    'MED_LEFT': 'pills left',
    'MED_BTN_ADD': 'Add Medicine',
    'GENERIC_TITLE': 'Generic Alternatives',
    'GENERIC_SEARCH_HINT': 'Search medicine...',
    'GENERIC_SAVE': 'Save',
    'GENERIC_BRAND': 'EXPENSIVE BRAND',
    'GENERIC_ALT': 'AFFORDABLE GENERIC',
    'GENERIC_RECENT': 'Recent Searches',
  };

  String get(String key) {
    if (isHindi) {
      return _hindiStrings[key] ?? key;
    }
    return _englishStrings[key] ?? key;
  }
}
