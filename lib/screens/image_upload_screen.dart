import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/language_service.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _statusMessage = "";

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _statusMessage = "Ready to upload";
          _uploadProgress = 0.0;
        });
      }
    } catch (e) {
      _showSnackBar("Error picking image: $e", isError: true);
    }
  }

  Future<void> _startUpload() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _statusMessage = "Processing...";
      _uploadProgress = 0.0;
    });

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _statusMessage = "Image Selected!";
      _uploadProgress = 1.0;
    });

    // Return the image path to the previous screen
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context, _selectedImage!.path);
      }
    });

    setState(() => _isUploading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.current;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(lang.get('TITLE_IMAGE')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border:
                      Border.all(color: theme.colorScheme.onSurface, width: 2),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.contain)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 64, color: theme.colorScheme.onSurface),
                          const SizedBox(height: 16),
                          Text(
                            lang.get('STATUS_SELECT').toUpperCase(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            if (_isUploading || _uploadProgress > 0) ...[
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.2),
                color: theme.colorScheme.onSurface,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 8),
              Text(
                _statusMessage,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
            ],

            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    label: lang.get('BTN_CAMERA'),
                    onPressed: _isUploading
                        ? null
                        : () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.photo_library_outlined,
                    label: lang.get('BTN_GALLERY'),
                    onPressed: _isUploading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedImage != null && !_isUploading)
                    ? _startUpload
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.surface,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: _isUploading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: theme.colorScheme.surface, strokeWidth: 2))
                    : Text(
                        lang.get('BTN_UPLOAD_SECURE').toUpperCase(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: theme.colorScheme.onSurface, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      icon: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
      label: Text(label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
