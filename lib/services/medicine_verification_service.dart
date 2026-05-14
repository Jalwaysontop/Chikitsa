import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicineVerificationService {
  static const String apiUrl = 'https://beneficently-hyperthermal-laila.ngrok-free.dev/verify';

  static Future<Map<String, dynamic>?> verifyMedicine(String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      
      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        return jsonDecode(respStr) as Map<String, dynamic>;
      } else {
        print('Error uploading image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during verifyMedicine: $e');
      return null;
    }
  }
}
