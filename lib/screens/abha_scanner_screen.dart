import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../proto/abha.pb.dart';
import '../widgets/abha_card_widget.dart';

class AbhaScannerScreen extends StatefulWidget {
  const AbhaScannerScreen({super.key});

  @override
  State<AbhaScannerScreen> createState() => _AbhaScannerScreenState();
}

class _AbhaScannerScreenState extends State<AbhaScannerScreen> {
  AbhaProfile? _scannedProfile;
  final MobileScannerController controller = MobileScannerController();

  void _onDetect(BarcodeCapture capture) {
    if (_scannedProfile != null) return; // Ignore incoming captures if already scanned
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        try {
          // Parse the ABHA Govt App QR Code (Typically formatted as JSON)
          final Map<String, dynamic> data = jsonDecode(barcode.rawValue!);
          
          debugPrint('\n===== ABHA SCANNED QR JSON =====');
          debugPrint(barcode.rawValue!);
          debugPrint('================================\n');

          String parsedPincode = data['pincode']?.toString() ?? data['pin_code']?.toString() ?? data['pc']?.toString() ?? data['pin']?.toString() ?? '';
          String physicalAddress = data['address'] ?? '';
          
          if (parsedPincode.isEmpty && physicalAddress.isNotEmpty) {
            final match = RegExp(r'\b\d{6}\b').firstMatch(physicalAddress);
            if (match != null) {
              parsedPincode = match.group(0) ?? '';
            }
          }

          final profile = AbhaProfile()
            ..abhaId = data['hidn'] ?? data['healthIdNumber'] ?? data['ABHANumber'] ?? 'Unknown ABHA ID'
            ..name = data['name'] ?? data['firstName'] ?? 'Unknown Name'
            ..gender = data['gender'] ?? 'U'
            ..dateOfBirth = data['dob'] ?? data['dateOfBirth'] ?? '${data['yearOfBirth'] ?? 'XXXX'}'
            ..address = physicalAddress
            ..stateName = data['stateName'] ?? data['state_name'] ?? data['state name'] ?? data['state'] ?? data['st'] ?? ''
            ..districtName = data['districtName'] ?? data['district_name'] ?? data['dist'] ?? data['district'] ?? ''
            ..pincode = parsedPincode
            ..mobile = data['mobile'] ?? data['mobileNumber'] ?? data['phone'] ?? '';

          setState(() {
            _scannedProfile = profile;
          });
          controller.stop();
          break; // Stop parsing after first successfully mapped profile
        } catch (e) {
          debugPrint('Failed to parse ABHA Profile from QR JSON: $e');
        }
      }
    }
  }

  Future<void> _scanFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      if (capture != null) {
        _onDetect(capture);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No QR code found in the selected image.')),
        );
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14141E), // Deep space matching app theme
      appBar: AppBar(
        title: const Text('Scan ABHA QR', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_scannedProfile == null)
            IconButton(
              icon: const Icon(Icons.photo_library),
              tooltip: 'Scan from Gallery',
              onPressed: _scanFromGallery,
            ),
        ],
      ),
      body: Stack(
        children: [
          // The background scanner
          if (_scannedProfile == null)
            MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            ),
            
          // Finder View overlay
          if (_scannedProfile == null)
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Align Govt ABHA QR here',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
            
          // Post Scan Result UI
          if (_scannedProfile != null)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AbhaCardWidget(profile: _scannedProfile!),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text(
                        'Confirm and Proceed',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('abha_name', _scannedProfile!.name);
                        await prefs.setString('abha_address', _scannedProfile!.abhaId);
                        await prefs.setString('abha_physical_address', _scannedProfile!.address);
                        await prefs.setString('abha_gender', _scannedProfile!.gender);
                        await prefs.setString('abha_dob', _scannedProfile!.dateOfBirth);
                        await prefs.setString('abha_state_name', _scannedProfile!.stateName);
                        await prefs.setString('abha_district_name', _scannedProfile!.districtName);
                        await prefs.setString('abha_pincode', _scannedProfile!.pincode);
                        await prefs.setString('abha_mobile', _scannedProfile!.mobile);
                        if (!mounted) return;
                        Navigator.pop(context, _scannedProfile);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, color: Colors.white60),
                      label: const Text('Scan Again', style: TextStyle(color: Colors.white60)),
                      onPressed: () {
                        setState(() {
                          _scannedProfile = null;
                        });
                        controller.start();
                      },
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
