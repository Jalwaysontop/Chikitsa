import 'dart:convert';
import 'package:chikitsa/screens/image_upload_screen.dart';
import 'package:chikitsa/services/medical_assessment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/language_service.dart';
import '../services/text_service.dart';
import '../services/surveillance_service.dart';
import '../widgets/voice_input_button.dart';

class BsonDemoScreen extends StatefulWidget {
  const BsonDemoScreen({super.key});

  @override
  State<BsonDemoScreen> createState() => _BsonDemoScreenState();
}

class _BsonDemoScreenState extends State<BsonDemoScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientAgeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();

  bool _isLoading = false;
  bool _isImageUploaded = false;
  String? _uploadedImagePath; // ← real path returned from picker
  Map<String, dynamic>? _assessmentResult;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    _loadPatientProfile();
  }

  /// Load saved patient details from SharedPreferences
  Future<void> _loadPatientProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Prioritize ABHA ID details over generically saved patient details
      _patientIdController.text = prefs.getString('abha_address') ?? prefs.getString('patient_id') ?? '';
      _patientNameController.text = prefs.getString('abha_name') ?? prefs.getString('patient_name') ?? '';
      
      String? gender = prefs.getString('abha_gender') ?? prefs.getString('patient_gender');
      if (gender != null && gender.isNotEmpty) {
        if (gender.toLowerCase().startsWith('m')) _selectedGender = 'Male';
        else if (gender.toLowerCase().startsWith('f')) _selectedGender = 'Female';
        else _selectedGender = 'Other';
      } else {
        _selectedGender = 'Male';
      }

      String? dobStr = prefs.getString('abha_dob');
      if (dobStr != null && dobStr.isNotEmpty && !dobStr.contains('X')) {
        try {
          int? year;
          if (dobStr.contains('-') || dobStr.contains('/')) {
            final parts = dobStr.split(RegExp(r'[-/]'));
            if (parts.first.length == 4) year = int.parse(parts.first);
            else if (parts.last.length == 4) year = int.parse(parts.last);
            else if (parts.length == 3) year = int.parse(parts.last); // e.g. 19-09-2002
          } else if (dobStr.length == 4) {
             year = int.parse(dobStr); // YYYY format alone
          }
          
          if (year != null && year > 1900 && year <= DateTime.now().year) {
            final age = DateTime.now().year - year;
            _patientAgeController.text = age.toString();
          } else {
            _patientAgeController.text = prefs.getString('patient_age') ?? '';
          }
        } catch (_) {
          _patientAgeController.text = prefs.getString('patient_age') ?? '';
        }
      } else {
        _patientAgeController.text = prefs.getString('patient_age') ?? '';
      }

      // Populate phone with mobile
      final mobile = prefs.getString('abha_mobile');
      if (mobile != null && mobile.isNotEmpty) {
        _phoneController.text = mobile;
      } else {
        _phoneController.text = prefs.getString('patient_phone') ?? '';
      }
      
      // Construct native location string
      final String state = prefs.getString('abha_state_name') ?? '';
      final String dist = prefs.getString('abha_district_name') ?? '';
      final String pin = prefs.getString('abha_pincode') ?? '';
      final String physicalAddress = prefs.getString('abha_physical_address') ?? '';
      
      final locationParts = [dist, state, pin].where((e) => e.isNotEmpty).toList();
      if (locationParts.isNotEmpty) {
        _locationController.text = locationParts.join(', ');
      } else if (physicalAddress.isNotEmpty) {
        _locationController.text = physicalAddress;
      }
    });
  }

  /// Save patient details to SharedPreferences for auto-fill
  Future<void> _savePatientProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('patient_id', _patientIdController.text.trim());
    await prefs.setString('patient_name', _patientNameController.text.trim());
    await prefs.setString('patient_age', _patientAgeController.text.trim());
    await prefs.setString('patient_gender', _selectedGender);
    await prefs.setString('patient_phone', _phoneController.text.trim());
  }

  /// Save an assessment to history for the Activity History screen
  Future<void> _saveAssessmentToHistory(
      Map<String, dynamic> patientData, bool sendSuccess) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('assessment_history');

    List<dynamic> history = [];
    if (historyJson != null) {
      history = jsonDecode(historyJson);
    }

    // Add send status to the data
    final assessmentRecord = Map<String, dynamic>.from(patientData);
    assessmentRecord['send_success'] = sendSuccess;

    history.add(assessmentRecord);

    // Keep only the last 50 assessments
    if (history.length > 50) {
      history = history.sublist(history.length - 50);
    }

    await prefs.setString('assessment_history', jsonEncode(history));
  }

  Map<String, dynamic> _getPatientData() {
    List<String> symptoms = [];

    if (_symptomsController.text.trim().isNotEmpty) {
      symptoms = _symptomsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return {
      'patient_id': _patientIdController.text.trim().isNotEmpty
          ? _patientIdController.text.trim()
          : 'P${DateTime.now().millisecondsSinceEpoch}',
      'patient_name': _patientNameController.text.trim(),
      'age': _patientAgeController.text.trim().isNotEmpty
          ? int.tryParse(_patientAgeController.text.trim()) ?? 0
          : 0,
      'gender': _selectedGender,
      'phone': _phoneController.text.trim(),
      'symptoms': symptoms,
      'temperature': _temperatureController.text.trim().isNotEmpty
          ? double.tryParse(_temperatureController.text.trim()) ?? 0.0
          : 0.0,
      'blood_pressure': _bpController.text.trim(),
      'heart_rate': _heartRateController.text.trim().isNotEmpty
          ? int.tryParse(_heartRateController.text.trim()) ?? 0
          : 0,
      'timestamp': DateTime.now().toIso8601String(),
      'location': {'lat': 28.6139, 'lng': 77.2090},
    };
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(value)) {
      return 'Enter a valid phone number (10-13 digits)';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 3) return 'Name is too short';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name must contain only alphabets';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return null; // Age is optional
    final age = int.tryParse(value);
    if (age == null || age < 0 || age > 120) {
      return 'Enter a valid age (0-120)';
    }
    return null;
  }

  Future<void> _sendData() async {
    // strict validation
    if (!_isImageUploaded) {
      _showError(LanguageService.current.get('ERR_PHOTO_REQ'));
      return;
    }

    final phoneError = _validatePhone(_phoneController.text);
    if (phoneError != null) {
      _showError(phoneError);
      return;
    }

    final nameError = _validateName(_patientNameController.text);
    if (nameError != null) {
      _showError(nameError);
      return;
    }

    final ageError = _validateAge(_patientAgeController.text);
    if (ageError != null) {
      _showError(ageError);
      return;
    }

    if (_symptomsController.text.isEmpty) {
      _showError('Please enter at least one symptom');
      return;
    }

    // Vitals validation (Simple range checks)
    if (_temperatureController.text.isNotEmpty) {
      final temp = double.tryParse(_temperatureController.text);
      if (temp == null || temp < 30 || temp > 45) {
        _showError('Temperature must be between 30°C and 45°C');
        return;
      }
    }

    setState(() => _isLoading = true);

    final patientData = _getPatientData();

    // Simulate SMS sending success for prototype
    // final result = await SmsService.sendWithBestCompression(
    //   phoneNumber: _phoneController.text,
    //   data: patientData,
    // );

    // Construct dummy result for prototype consistency
    final result = SmsSendResult(
      success: true,
      phoneNumber: _phoneController.text,
      dataSentBytes: 50,
      base64Length: 20,
      compressionRatio: "50.0",
      originalJsonSize: 100,
      base64Payload: "dummy_payload",
      message: "Data sent successfully",
      compressionMethod: "gzip",
      httpStatusCode: 200,
      serverResponse: "OK",
      bytesSentOverNetwork: 50,
    );

    // setState(() {
    //   _lastResult = result;
    // });

    // Save patient profile for auto-fill on next visit
    if (result.success) {
      await _savePatientProfile();
    }

    // Save assessment to history (regardless of success/failure)
    await _saveAssessmentToHistory(patientData, result.success);

    // Call Real Triage API (with image if available)
    try {
      final assessment = await MedicalAssessmentService.sendAssessment(
        symptoms: _symptomsController.text,
        imagePath: _uploadedImagePath,
      );

      setState(() {
        _assessmentResult = assessment;
      });
    } catch (e) {
      _showError("Assessment failed: $e");
    }

    setState(() {
      _isLoading = false;
    });

    // Fire-and-forget anonymous case recording for disease surveillance 
    if (result.success) {
      final prefs = await SharedPreferences.getInstance();
      final abhaAddress = prefs.getString('abha_address');
      SurveillanceService.instance.recordCaseAndCheck(
        symptoms: _symptomsController.text,
        abhaAddress: abhaAddress,
      ).then((alert) {
        if (alert != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ Outbreak Alert: ${alert.diseaseCategory} spike detected in ${alert.district}, ${alert.state} (${alert.caseCount} cases)',
              ),
              backgroundColor: Colors.deepOrange,
              duration: const Duration(seconds: 6),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.current;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(lang.get('TITLE_ASSESSMENT')),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _sendData,
        backgroundColor: theme.colorScheme.onSurface,
        foregroundColor: theme.colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        label: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child:
                    CircularProgressIndicator(color: theme.colorScheme.surface),
              )
            : Text(lang.get('BTN_SUBMIT').toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        icon: _isLoading ? null : const Icon(Icons.arrow_forward),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Details Section
              Text(
                lang.get('SECTION_PATIENT'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _patientNameController,
                label: lang.get('LABEL_NAME'),
                hint: lang.get('HINT_NAME'),
                simulationText: "अमन",
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                ],
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _phoneController,
                label: lang.get('LABEL_PHONE'),
                hint: lang.get('HINT_PHONE'),
                keyboardType: TextInputType.phone,
                simulationText: "९८७६५४३२१०",
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  LengthLimitingTextInputFormatter(15)
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _patientAgeController,
                      label: lang.get('LABEL_AGE'),
                      hint: lang.get('HINT_AGE'),
                      simulationText: "२५",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGenderDropdown(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _locationController,
                label: 'Location (State / District / PIN)',
                hint: 'Demographic location details',
                simulationText: "Delhi, 110001",
              ),

              const SizedBox(height: 48),

              // Vitals Section
              Text(
                lang.get('SECTION_VITALS'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _symptomsController,
                label: lang.get('LABEL_SYMPTOMS'),
                hint: lang.get('HINT_SYMPTOMS'),
                maxLines: 3,
                simulationText: lang.get('SIM_SYMPTOMS'),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _bpController,
                      label: lang.get('LABEL_BP'),
                      hint: lang.get('HINT_BP'),
                      simulationText: lang.get('SIM_BP'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _temperatureController,
                      label: lang.get('LABEL_TEMP'),
                      hint: lang.get('HINT_TEMP'),
                      keyboardType: TextInputType.number,
                      simulationText: lang.get('SIM_TEMP'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _heartRateController,
                label: 'Heart Rate', // TODO: Add key
                hint: 'BPM',
                keyboardType: TextInputType.number,
                simulationText: "७२",
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3)
                ],
              ),

              const SizedBox(height: 32),

              // Mandatory Image Upload Section
              Text(
                lang.get('HEADER_PHOTO'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () async {
                  final imagePath = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ImageUploadScreen()),
                  );

                  if (imagePath != null) {
                    setState(() {
                      _isImageUploaded = true;
                      _uploadedImagePath = imagePath;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isImageUploaded
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.surface,
                    border: Border.all(
                        color: theme.colorScheme.onSurface, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _isImageUploaded
                            ? Icons.check_circle
                            : Icons.upload_file,
                        size: 40,
                        color: _isImageUploaded
                            ? theme.colorScheme.surface
                            : theme.colorScheme.onSurface,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isImageUploaded
                            ? lang.get('STATUS_ATTACHED')
                            : lang.get('BTN_UPLOAD'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _isImageUploaded
                              ? theme.colorScheme.surface
                              : theme.colorScheme.onSurface,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isImageUploaded
                            ? lang.get('STATUS_READY')
                            : lang.get('STATUS_MANDATORY'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isImageUploaded
                              ? theme.colorScheme.surface.withValues(alpha: 0.7)
                              : theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80), // Space for FAB

              // if (_lastResult != null) _buildResults(_lastResult!),
              if (_assessmentResult != null)
                _buildAssessmentResults(_assessmentResult!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String simulationText,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: Theme.of(context).textTheme.bodyLarge,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: VoiceInputButton(
              simulationText: simulationText,
              onTextReceived: (englishText) {
                if (label.contains('Symptoms') && controller.text.isNotEmpty) {
                  controller.text = "${controller.text}, $englishText";
                } else {
                  controller.text = englishText;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    final lang = LanguageService.current;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.get('LABEL_GENDER'),
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: theme.textTheme.bodyLarge,
          icon: Icon(Icons.arrow_drop_down, color: theme.iconTheme.color),
          dropdownColor: theme.cardColor,
          items: [
            DropdownMenuItem(value: 'Male', child: Text(lang.get('OPT_MALE'))),
            DropdownMenuItem(
                value: 'Female', child: Text(lang.get('OPT_FEMALE'))),
            DropdownMenuItem(
                value: 'Other', child: Text(lang.get('OPT_OTHER'))),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          },
        ),
      ],
    );
  }

  Color _riskColor(String? riskLevel) {
    switch ((riskLevel ?? '').toLowerCase()) {
      case 'critical':
        return const Color(0xFFB71C1C);
      case 'high':
        return const Color(0xFFE53935);
      case 'moderate':
        return const Color(0xFFF57C00);
      case 'low':
        return const Color(0xFF388E3C);
      default:
        return Colors.grey;
    }
  }

  Widget _buildAssessmentResults(Map<String, dynamic> result) {
    final riskLevel = result['risk_level'] as String?;
    final riskScore = result['risk_score'];
    final concerns = (result['potential_concerns'] as List<dynamic>? ?? []);
    final recommendation = result['recommendation'] as String?;
    final seekEmergency = result['seek_emergency_care'] as bool? ?? false;
    final followUp = result['follow_up_timeframe'] as String?;
    final observations = result['general_observations'] as String?;
    final disclaimer = result['disclaimer'] as String?;
    final riskColor = _riskColor(riskLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'Triage Assessment',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        // Emergency Banner
        if (seekEmergency)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFB71C1C),
            child: const Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SEEK EMERGENCY CARE IMMEDIATELY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Main card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
                color: Theme.of(context).colorScheme.onSurface, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Risk level header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: riskColor,
                child: Row(
                  children: [
                    Icon(
                      riskScore != null && (riskScore as num) >= 7
                          ? Icons.warning_amber_rounded
                          : Icons.shield_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'RISK LEVEL: ${(riskLevel ?? 'UNKNOWN').toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    if (riskScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$riskScore / 10',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Potential Concerns
                    if (concerns.isNotEmpty) ...[
                      const Text(
                        'POTENTIAL CONCERNS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: concerns
                            .map((c) => Chip(
                                  label: Text(
                                    c.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: riskColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor:
                                      riskColor.withValues(alpha: 0.1),
                                  side: BorderSide(
                                      color: riskColor.withValues(alpha: 0.4)),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Follow-up timeframe
                    if (followUp != null) ...[
                      const Text(
                        'FOLLOW-UP TIMEFRAME',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            followUp,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: riskColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Recommendation
                    if (recommendation != null) ...[
                      const Text(
                        'RECOMMENDATION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.06),
                          border: Border(
                            left: BorderSide(color: riskColor, width: 3),
                          ),
                        ),
                        child: Text(
                          recommendation,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // General Observations
                    if (observations != null) ...[
                      const Text(
                        'CLINICAL OBSERVATIONS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        observations,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Disclaimer
                    if (disclaimer != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.amber.withValues(alpha: 0.12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline,
                                size: 15, color: Colors.amber),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                disclaimer,
                                style: const TextStyle(
                                  fontSize: 11,
                                  height: 1.4,
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
