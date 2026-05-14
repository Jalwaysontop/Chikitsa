import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class MedicalAssessmentService {
  static const String _triageUrl =
      'https://medicalanalysissystem-q5qi.onrender.com/api/triage';

  /// Sends symptoms to the real triage API and returns the parsed assessment.
  static Future<Map<String, dynamic>> sendAssessment({
    required String symptoms,
    String? imagePath, // null = symptoms-only request
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(_triageUrl));
    request.fields['symptoms'] = symptoms;

    // Attach image only when a real path is provided
    if (imagePath != null && imagePath.isNotEmpty) {
      final ext = imagePath.split('.').last.toLowerCase();
      final mimeType = switch (ext) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        _ => 'image/jpeg', // safe default for camera shots
      };

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          filename: File(imagePath).uri.pathSegments.last,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['success'] == true && body['assessment'] != null) {
        return body['assessment'] as Map<String, dynamic>;
      } else {
        throw Exception('API returned success=false or missing assessment');
      }
    } else {
      throw Exception(
          'Triage API error: ${response.statusCode} — ${response.body}');
    }
  }
}
