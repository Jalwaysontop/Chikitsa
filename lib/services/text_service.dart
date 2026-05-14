import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/protobuf_zstd_helper.dart';

class SmsService {
  static const String API_ENDPOINT =
      'https://abcll.free.beeceptor.com/send-medical-data';

  static Future<SmsSendResult> sendWithBestCompression({
    required String phoneNumber,
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await ProtobufZstdHelper.encodeData(data);

      print('Original JSON: ${result.originalJsonSize} bytes');
      print('Protobuf only: ${result.protobufSize} bytes');
      print('Final packet: ${result.compressedSize} bytes');
      print('Compressed: ${result.wasCompressed ? "YES" : "NO"}');
      print(
          'Savings: ${result.bytesSaved} bytes (${result.compressionRatio}%)');

      final base64Payload = result.base64Encoded;

      final bytes = result.compressedBytes;
      print('Total Bytes: ${bytes.length}');
      print('Base64 String: ${base64Encode(bytes)}');

      String hexString = bytes
          .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
          .join(', ');
      print('Hex Dump: [$hexString]');

      final response = await http.post(
        Uri.parse(API_ENDPOINT),
        headers: {
          'Content-Type': 'application/octet-stream',
          'Content-Encoding': 'protobuf-zstd',
          'X-Patient-ID': data['patient_id'].toString(),
          'X-Original-Size': result.originalJsonSize.toString(),
          'X-Compression-Method': 'Protobuf+Zstd',
        },
        body: result.compressedBytes,
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return SmsSendResult(
          success: true,
          phoneNumber: phoneNumber,
          dataSentBytes: result.compressedSize,
          base64Length: base64Payload.length,
          compressionRatio: result.compressionRatio,
          originalJsonSize: result.originalJsonSize,
          base64Payload: base64Payload,
          message: 'Data sent successfully!\n'
              'Saved: ${result.bytesSaved} bytes',
          compressionMethod: 'Protobuf+Zstd',
          httpStatusCode: response.statusCode,
          serverResponse: response.body,
          bytesSentOverNetwork: result.compressedSize,
        );
      } else {
        return SmsSendResult(
          success: false,
          phoneNumber: phoneNumber,
          dataSentBytes: 0,
          base64Length: 0,
          compressionRatio: '0',
          originalJsonSize: 0,
          base64Payload: '',
          message: 'Server error: ${response.statusCode}',
          compressionMethod: 'None',
          httpStatusCode: response.statusCode,
          serverResponse: response.body,
          bytesSentOverNetwork: 0,
        );
      }
    } catch (e) {
      print('Error: $e');
      return SmsSendResult(
        success: false,
        phoneNumber: phoneNumber,
        dataSentBytes: 0,
        base64Length: 0,
        compressionRatio: '0',
        originalJsonSize: 0,
        base64Payload: '',
        message: 'Error: ${e.toString()}',
        compressionMethod: 'None',
        httpStatusCode: 0,
        serverResponse: e.toString(),
        bytesSentOverNetwork: 0,
      );
    }
  }

  static Future<Map<String, dynamic>> receiveData({
    required String base64Data,
  }) async {
    try {
      final bytes = ProtobufZstdHelper.base64ToBytes(base64Data);
      return await ProtobufZstdHelper.decodeData(bytes);
    } catch (e) {
      print('Error decompressing: $e');
      rethrow;
    }
  }
}

class SmsSendResult {
  final bool success;
  final String phoneNumber;
  final int dataSentBytes;
  final int base64Length;
  final String compressionRatio;
  final int originalJsonSize;
  final String base64Payload;
  final String message;
  final String compressionMethod;
  final int httpStatusCode;
  final String serverResponse;
  final int bytesSentOverNetwork;

  SmsSendResult({
    required this.success,
    required this.phoneNumber,
    required this.dataSentBytes,
    required this.base64Length,
    required this.compressionRatio,
    required this.originalJsonSize,
    required this.base64Payload,
    required this.message,
    required this.compressionMethod,
    required this.httpStatusCode,
    required this.serverResponse,
    required this.bytesSentOverNetwork,
  });

  int get bytesSaved => originalJsonSize - dataSentBytes;
}
