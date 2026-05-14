import 'package:chikitsa/screens/image_upload_screen.dart';
import 'package:chikitsa/services/language_service.dart';
import 'package:chikitsa/services/medicine_verification_service.dart';
import 'package:chikitsa/services/supabase_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RxScannerScreen extends StatefulWidget {
  const RxScannerScreen({super.key});

  @override
  State<RxScannerScreen> createState() => _RxScannerScreenState();
}

class _RxScannerScreenState extends State<RxScannerScreen> {
  bool _isVerifying = false;
  bool _isVerified = false;
  Map<String, dynamic>? _verificationResult;

  Future<void> _handleScan() async {
    // Navigate to Image Upload Screen to simulate scanning
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ImageUploadScreen()),
    );

    // If result is true (simulated success from ImageUploadScreen) or string path
    if (result != null && result is String) {
      setState(() {
        _isVerifying = true;
      });

      final verifyResult = await MedicineVerificationService.verifyMedicine(result);

      if (mounted) {
        setState(() {
          _isVerifying = false;
          if (verifyResult != null) {
            _verificationResult = verifyResult;
            _isVerified = true;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification failed or API error')),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.current;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.get('RX_TITLE')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isVerifying && !_isVerified) ...[
              const Spacer(),
              Icon(
                Icons.qr_code_scanner,
                size: 120,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(height: 32),
              Text(
                lang.get('RX_INSTRUCTION'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _handleScan,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(lang.get('RX_BTN_SCAN')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface,
                    foregroundColor: theme.colorScheme.surface,
                    shape: const RoundedRectangleBorder(), // Brutalist square
                  ),
                ),
              ),
            ] else if (_isVerifying) ...[
              const Spacer(),
              const Center(
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 24),
              Text(
                lang.get('RX_VERIFYING'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
            ] else if (_isVerified) ...[
              _buildResultCard(theme),
              const Spacer(),
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isVerified = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    side: BorderSide(
                        color: theme.colorScheme.onSurface, width: 2),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text(lang.get('RX_BTN_SCAN_AGAIN')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    if (_verificationResult == null) return const SizedBox.shrink();
    
    final status = _verificationResult!['status'] ?? 'UNKNOWN';
    final overallAssessment = _verificationResult!['overall_assessment'] ?? '';
    
    // gs1_verification details
    final gs1 = _verificationResult!['gs1_verification'] ?? {};
    final company = gs1['company'] ?? 'Unknown Company';
    final licenseType = gs1['license_type'] ?? '';

    // ocr details
    final ocr = _verificationResult!['ocr_extracted_label'] ?? {};
    final barcode = ocr['barcode'] ?? _verificationResult!['barcode'] ?? 'N/A';
    final mfgLicense = ocr['mfg_license'] ?? 'N/A';
    
    final isSuccess = status == 'SUCCESS';
    final color = isSuccess ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(isSuccess ? Icons.verified : Icons.error_outline, color: color, size: 64),
              const SizedBox(height: 16),
              Text(
                isSuccess ? 'AUTHENTIC SOURCE' : 'COUNTERFEIT MEDICINE',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const Divider(height: 32, thickness: 1),
              _buildDetailRow('Barcode', barcode),
              _buildDetailRow('Manufacturer', company),
              _buildDetailRow('License Type', licenseType),
              _buildDetailRow('Mfg License', mfgLicense),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: color.withValues(alpha: 0.1),
                child: Text(
                  overallAssessment.isNotEmpty ? overallAssessment : 'Verified via Verification API',
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        if (!isSuccess) ...[
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _showCounterfeitReportDialog(barcode, company),
              icon: const Icon(Icons.report_problem),
              label: const Text('REPORT TO AUTHORITY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showCounterfeitReportDialog(String barcode, String company) async {
    final prefs = await SharedPreferences.getInstance();
    final state = prefs.getString('abha_state_name') ?? 'Delhi';
    final district = prefs.getString('abha_district_name') ?? 'New Delhi';
    final pincode = prefs.getString('abha_pincode') ?? '110001';
    final abhaId = prefs.getString('abha_address');
    final location = '$district, $state - $pincode';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Counterfeit Report'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The following information will be submitted to the Central Drugs Standard Control Organisation (CDSCO):', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            Text('Barcode: $barcode', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Claimed Manufacturer: $company', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Spotted Location: $location', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 16),
            const Text('Your GPS coordinates and device IP will be attached securely.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              await SupabaseSyncService.instance.reportCounterfeit(
                barcode: barcode,
                company: company,
                location: location,
                abhaId: abhaId,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report successfully submitted to concerned authorities.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('SUBMIT REPORT'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
