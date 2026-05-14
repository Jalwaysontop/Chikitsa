import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:fixnum/src/int64.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../proto/file_upload.pb.dart';
import 'dart:async';
import 'package:fixnum/fixnum.dart';

class ImageUploadService {
  static const int _targetSize = 1920;
  static const int _quality = 90;
  static const int _chunkSize = 64 * 1024;
  static const int _maxRetries = 3;

  static const String _uploadUrl = 'http://192.168.1.12:8080/upload';

  Future<void> processAndUpload(File originalFile,
      {Function(double)? onProgress}) async {
    try {
      print("Compressing image...");
      final Uint8List? webpBytes = await _compressImage(originalFile);
      if (webpBytes == null) throw Exception("Compression failed");

      final String sessionId = const Uuid().v4();
      final String fullFileHash = sha256.convert(webpBytes).toString();
      final int totalSize = webpBytes.length;
      final int totalChunks = (totalSize / _chunkSize).ceil();

      print(
          "Starting upload: $totalChunks chunks, ${totalSize ~/ 1024}KB total");
      print("Session ID: ${sessionId.substring(0, 8)}...");

      for (int i = 0; i < totalChunks; i++) {
        int start = i * _chunkSize;
        int end = min(start + _chunkSize, totalSize);
        final chunkData = webpBytes.sublist(start, end);

        final chunkProto = FileChunk()
          ..sessionId = sessionId
          ..chunkIndex = i
          ..totalChunks = totalChunks
          ..fileHash = fullFileHash
          ..fileType = 'image/webp'
          ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
          ..data = chunkData;

        await _uploadChunkWithRetry(chunkProto);

        if (onProgress != null) {
          onProgress((i + 1) / totalChunks);
        }
      }

      print("Upload complete!");
    } catch (e) {
      print("Upload failed: $e");
      rethrow;
    }
  }

  Future<Uint8List?> _compressImage(File file) async {
    return await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: _targetSize,
      minHeight: _targetSize,
      quality: _quality,
      format: CompressFormat.webp,
    );
  }

  Future<void> _uploadChunkWithRetry(FileChunk chunk) async {
    int attempt = 0;

    while (attempt < _maxRetries) {
      try {
        print("Sending ${chunk.writeToBuffer().length} bytes to $_uploadUrl");

        final response = await http
            .post(
              Uri.parse(_uploadUrl),
              headers: {
                'Content-Type': 'application/x-protobuf',
                'ngrok-skip-browser-warning': 'true',
              },
              body: chunk.writeToBuffer(),
            )
            .timeout(const Duration(seconds: 30));

        print("Status: ${response.statusCode}");
        print("Body: ${response.body}");

        if (response.statusCode == 200) {
          print("✓ Chunk ${chunk.chunkIndex + 1}/${chunk.totalChunks}");
          return;
        } else {
          throw Exception("HTTP ${response.statusCode}: ${response.body}");
        }
      } on TimeoutException catch (e) {
        print("Timeout: $e");
        attempt++;
      } on SocketException catch (e) {
        print("Network error: $e");
        attempt++;
      } catch (e) {
        print("Error: $e");
        attempt++;
      }

      if (attempt >= _maxRetries) {
        throw Exception("Failed after $_maxRetries attempts");
      }

      final delay = Duration(seconds: pow(2, attempt - 1).toInt());
      print("Chunk ${chunk.chunkIndex} retry in ${delay.inSeconds}s...");
      await Future.delayed(delay);
    }
  }
}
