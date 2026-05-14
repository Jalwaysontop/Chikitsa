// This is a generated file - do not edit.
//
// Generated from patient.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use locationDescriptor instead')
const Location$json = {
  '1': 'Location',
  '2': [
    {'1': 'lat', '3': 1, '4': 1, '5': 1, '10': 'lat'},
    {'1': 'lng', '3': 2, '4': 1, '5': 1, '10': 'lng'},
  ],
};

/// Descriptor for `Location`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationDescriptor = $convert.base64Decode(
    'CghMb2NhdGlvbhIQCgNsYXQYASABKAFSA2xhdBIQCgNsbmcYAiABKAFSA2xuZw==');

@$core.Deprecated('Use patientDataDescriptor instead')
const PatientData$json = {
  '1': 'PatientData',
  '2': [
    {'1': 'patient_id', '3': 1, '4': 1, '5': 13, '10': 'patientId'},
    {'1': 'patient_name', '3': 2, '4': 1, '5': 9, '10': 'patientName'},
    {'1': 'age', '3': 3, '4': 1, '5': 13, '10': 'age'},
    {
      '1': 'gender',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.PatientData.Gender',
      '10': 'gender'
    },
    {'1': 'phone', '3': 5, '4': 1, '5': 4, '10': 'phone'},
    {'1': 'symptoms', '3': 6, '4': 3, '5': 9, '10': 'symptoms'},
    {'1': 'temperature', '3': 7, '4': 1, '5': 2, '10': 'temperature'},
    {'1': 'blood_pressure', '3': 8, '4': 1, '5': 9, '10': 'bloodPressure'},
    {'1': 'heart_rate', '3': 9, '4': 1, '5': 13, '10': 'heartRate'},
    {
      '1': 'timestamp_unix_ms',
      '3': 10,
      '4': 1,
      '5': 3,
      '10': 'timestampUnixMs'
    },
    {
      '1': 'location',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.Location',
      '10': 'location'
    },
  ],
  '4': [PatientData_Gender$json],
};

@$core.Deprecated('Use patientDataDescriptor instead')
const PatientData_Gender$json = {
  '1': 'Gender',
  '2': [
    {'1': 'GENDER_UNKNOWN', '2': 0},
    {'1': 'GENDER_MALE', '2': 1},
    {'1': 'GENDER_FEMALE', '2': 2},
    {'1': 'GENDER_OTHER', '2': 3},
  ],
};

/// Descriptor for `PatientData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List patientDataDescriptor = $convert.base64Decode(
    'CgtQYXRpZW50RGF0YRIdCgpwYXRpZW50X2lkGAEgASgNUglwYXRpZW50SWQSIQoMcGF0aWVudF'
    '9uYW1lGAIgASgJUgtwYXRpZW50TmFtZRIQCgNhZ2UYAyABKA1SA2FnZRIrCgZnZW5kZXIYBCAB'
    'KA4yEy5QYXRpZW50RGF0YS5HZW5kZXJSBmdlbmRlchIUCgVwaG9uZRgFIAEoBFIFcGhvbmUSGg'
    'oIc3ltcHRvbXMYBiADKAlSCHN5bXB0b21zEiAKC3RlbXBlcmF0dXJlGAcgASgCUgt0ZW1wZXJh'
    'dHVyZRIlCg5ibG9vZF9wcmVzc3VyZRgIIAEoCVINYmxvb2RQcmVzc3VyZRIdCgpoZWFydF9yYX'
    'RlGAkgASgNUgloZWFydFJhdGUSKgoRdGltZXN0YW1wX3VuaXhfbXMYCiABKANSD3RpbWVzdGFt'
    'cFVuaXhNcxIlCghsb2NhdGlvbhgLIAEoCzIJLkxvY2F0aW9uUghsb2NhdGlvbiJSCgZHZW5kZX'
    'ISEgoOR0VOREVSX1VOS05PV04QABIPCgtHRU5ERVJfTUFMRRABEhEKDUdFTkRFUl9GRU1BTEUQ'
    'AhIQCgxHRU5ERVJfT1RIRVIQAw==');
