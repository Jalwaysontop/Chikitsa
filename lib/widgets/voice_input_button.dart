import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String result) onTextReceived;
  final String simulationText;

  const VoiceInputButton({
    super.key,
    required this.onTextReceived,
    this.simulationText = "Test Input", // Default value
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  // removed unused stt variables since we are simulating for now
  bool _isListening = false;
  bool _isTranslating = false;

  final _onDeviceTranslator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.hindi,
    targetLanguage: TranslateLanguage.english,
  );

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleListening() async {
    await _simulateVoiceInput(widget.simulationText);
  }

  Future<void> _simulateVoiceInput(String mockHindiText) async {
    setState(() => _isListening = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isListening = false;
      _isTranslating = true;
    });

    try {
      final String translation =
          await _onDeviceTranslator.translateText(mockHindiText);
      widget.onTextReceived(translation);
    } catch (e) {
      print("Translation Error: $e");
    }

    if (mounted) setState(() => _isTranslating = false);
  }

  @override
  void dispose() {
    _onDeviceTranslator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isTranslating
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFFE8997F)))
          : Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : const Color(0xFFE8997F),
            ),
      onPressed: _toggleListening,
    );
  }
}
