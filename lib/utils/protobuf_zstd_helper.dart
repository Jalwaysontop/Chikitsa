import 'dart:convert';
import 'dart:typed_data';
import 'package:fixnum/fixnum.dart';
import 'package:zstandard/zstandard.dart';

import '../proto/patient.pb.dart';

class ProtobufZstdHelper {
  static bool _isInitialized = false;
  static Zstandard? _zstd;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _zstd = Zstandard();
    _isInitialized = true;
  }

  static Future<ProtobufCompressionResult> encodeData(
      Map<String, dynamic> data) async {
    if (!_isInitialized || _zstd == null) {
      await initialize();
    }

    final patient = PatientData()
      ..patientId = int.tryParse(data['patient_id'].toString()) ?? 0
      ..patientName = data['patient_name'].toString()
      ..age = data['age'] as int? ?? 0
      ..gender = _mapGender(data['gender'].toString())
      ..phone = Int64(_parsePhone(data['phone'].toString()))
      ..symptoms.addAll((data['symptoms'] as List).cast<String>())
      ..temperature = (data['temperature'] as num?)?.toDouble() ?? 0.0
      ..bloodPressure = data['blood_pressure'].toString()
      ..heartRate = data['heart_rate'] as int? ?? 0
      ..timestampUnixMs = Int64(_toUnixMs(data['timestamp'].toString()))
      ..location = (Location()
        ..lat = (data['location']['lat'] as num).toDouble()
        ..lng = (data['location']['lng'] as num).toDouble());

    final protobufBytes = patient.writeToBuffer();
    final protobufSize = protobufBytes.length;

    final compressed = await _zstd!.compress(protobufBytes, 3);

    final compressedSize = compressed!.length;
    final useCompression = compressedSize > 0 && compressedSize < protobufSize;

    final finalPayload = useCompression
        ? Uint8List.fromList([0x01, ...compressed])
        : Uint8List.fromList([0x00, ...protobufBytes]);

    final jsonString = jsonEncode(data);
    final jsonSize = utf8.encode(jsonString).length;
    final compressionRatio =
        ((jsonSize - finalPayload.length) / jsonSize * 100).toStringAsFixed(1);

    return ProtobufCompressionResult(
      compressedBytes: finalPayload,
      compressedSize: finalPayload.length,
      protobufSize: protobufSize,
      originalJsonSize: jsonSize,
      compressionRatio: compressionRatio,
      wasCompressed: useCompression,
      originalData: data,
    );
  }

  static Future<Map<String, dynamic>> decodeData(Uint8List packetBytes) async {
    if (!_isInitialized || _zstd == null) {
      await initialize();
    }
    if (packetBytes.isEmpty) throw Exception('Empty packet');

    final flag = packetBytes[0];
    final payload = packetBytes.sublist(1);

    Uint8List protobufBytes;
    if (flag == 0x01) {
      final decoded = await _zstd!.decompress(payload);
      protobufBytes = Uint8List.fromList(decoded ?? []);
    } else if (flag == 0x00) {
      protobufBytes = payload;
    } else {
      throw Exception('Unknown flag: $flag');
    }

    final patient = PatientData.fromBuffer(protobufBytes);

    return {
      'patient_id': patient.patientId.toString(),
      'patient_name': patient.patientName,
      'age': patient.age,
      'gender': _unmapGender(patient.gender),
      'phone': patient.phone.toString(),
      'symptoms': patient.symptoms.toList(),
      'temperature': patient.temperature,
      'blood_pressure': patient.bloodPressure,
      'heart_rate': patient.heartRate,
      'timestamp': _fromUnixMs(patient.timestampUnixMs.toInt()),
      'location': {
        'lat': patient.location.lat,
        'lng': patient.location.lng,
      },
    };
  }

  static String bytesToBase64(Uint8List bytes) => base64Encode(bytes);
  static Uint8List base64ToBytes(String base64String) =>
      base64Decode(base64String);

  static PatientData_Gender _mapGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return PatientData_Gender.GENDER_MALE;
      case 'female':
        return PatientData_Gender.GENDER_FEMALE;
      case 'other':
        return PatientData_Gender.GENDER_OTHER;
      default:
        return PatientData_Gender.GENDER_UNKNOWN;
    }
  }

  static String _unmapGender(PatientData_Gender gender) {
    switch (gender) {
      case PatientData_Gender.GENDER_MALE:
        return 'Male';
      case PatientData_Gender.GENDER_FEMALE:
        return 'Female';
      case PatientData_Gender.GENDER_OTHER:
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  static int _parsePhone(String phone) =>
      int.tryParse(phone.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

  static int _toUnixMs(String isoString) {
    try {
      return DateTime.parse(isoString).millisecondsSinceEpoch;
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  static String _fromUnixMs(int unixMs) =>
      DateTime.fromMillisecondsSinceEpoch(unixMs).toIso8601String();
}

class ProtobufCompressionResult {
  final Uint8List compressedBytes;
  final int compressedSize;
  final int protobufSize;
  final int originalJsonSize;
  final String compressionRatio;
  final bool wasCompressed;
  final Map<String, dynamic> originalData;

  ProtobufCompressionResult({
    required this.compressedBytes,
    required this.compressedSize,
    required this.protobufSize,
    required this.originalJsonSize,
    required this.compressionRatio,
    required this.wasCompressed,
    required this.originalData,
  });

  int get bytesSaved => originalJsonSize - compressedSize;
  String get base64Encoded => base64Encode(compressedBytes);
}
