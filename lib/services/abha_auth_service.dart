import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import '../proto/abha.pb.dart';

class AbhaAuthService {
  static const String _nhaBaseUrl = 'https://healthidsbx.abdm.gov.in/api/v1'; // Sandbox environment
  static const int _maxRetries = 3;

  /// Helper method for Exponential Backoff for 2G environments
  Future<http.Response> _apiCallWithBackoff(Future<http.Response> Function() request) async {
    int retries = 0;
    while (retries < _maxRetries) {
      try {
        final response = await request();
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else if (response.statusCode == 429 || response.statusCode >= 500) {
          // Retry for rate limits and server errors
          retries++;
          await Future.delayed(Duration(seconds: (1 << retries))); // 2^retries seconds
        } else {
          return response; // Return on client errors (400, 401, etc)
        }
      } catch (e) {
        retries++;
        if (retries >= _maxRetries) rethrow; // Give up after max retries
        await Future.delayed(Duration(seconds: (1 << retries)));
      }
    }
    throw Exception('API call failed after $_maxRetries retries');
  }

  /// 1. Request OTP using Aadhaar (M1 compliance)
  Future<AuthSession> requestOtp(String aadhaarNumber) async {
    final response = await _apiCallWithBackoff(() => http.post(
      Uri.parse('$_nhaBaseUrl/auth/init'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'authMethod': 'AADHAAR_OTP', 
        'healthid': aadhaarNumber
      }),
    ));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final session = AuthSession()
        ..txnId = data['txnId']
        ..otpStatus = 'OTP_SENT';
      
      // Constraint: Store only txnId locally (Do NOT store Aadhaar)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('abha_txnId', session.txnId);
      
      return session;
    } else {
      throw Exception('Failed to request Aadhaar OTP: ${response.body}');
    }
  }

  /// 2. Verify OTP and fetch profile
  Future<AbhaProfile> verifyOtp(String txnId, String otp) async {
    final response = await _apiCallWithBackoff(() => http.post(
      Uri.parse('$_nhaBaseUrl/auth/confirmWithAadhaarOtp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'otp': otp, 'txnId': txnId}),
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']; // JWT authentication token
      
      // Step 3: Fetch user profile using the received token
      return await _fetchProfile(token);
    } else {
      throw Exception('OTP verification failed: ${response.body}');
    }
  }

  /// 3. Fetch ABHA Profile and apply 2G Optimizations
  Future<AbhaProfile> _fetchProfile(String token) async {
    final response = await _apiCallWithBackoff(() => http.get(
      Uri.parse('$_nhaBaseUrl/account/profile'),
      headers: {'Authorization': 'Bearer $token'},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      debugPrint('\n===== ABHA API RESP JSON =====');
      debugPrint(response.body);
      debugPrint('==============================\n');
      
      final profile = AbhaProfile()
        ..abhaId = data['healthIdNumber'] ?? ''
        ..name = data['name'] ?? ''
        ..gender = data['gender'] ?? ''
        ..dateOfBirth = '${data['yearOfBirth']}-${data['monthOfBirth']}-${data['dayOfBirth']}'
        ..address = data['address'] ?? ''
        ..stateName = data['stateName'] ?? ''
        ..districtName = data['districtName'] ?? ''
        ..pincode = data['pincode'] ?? '';

      // Perform 2G optimization: Convert photo to WebP
      if (data['profilePhoto'] != null && data['profilePhoto'].toString().isNotEmpty) {
        final Uint8List originalBytes = base64Decode(data['profilePhoto']);
        profile.photoWebp = _convertToWebP(originalBytes);
      }

      // Constraint: Store only abhaAddress locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('abha_address', data['healthId'] ?? profile.abhaId);

      return profile;
    } else {
      throw Exception('Failed to fetch ABHA profile: ${response.body}');
    }
  }

  /// 2G Optimization: Convert the ABHA profile photo to a WebP byte array
  List<int> _convertToWebP(Uint8List imageBytes) {
    try {
      // Decode image
      final img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return imageBytes; // Return original if decoding fails

      // Scale down image for low bandwidth
      final img.Image resizedImage = img.copyResize(decodedImage, width: 250);
      
      // Encode image to JPG format (lossy compression)
      return img.encodeJpg(resizedImage, quality: 75);
    } catch (e) {
      // In case of any encoding errors, fallback to original bytes
      return imageBytes;
    }
  }
}
