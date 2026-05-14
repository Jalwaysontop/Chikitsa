// This is a generated file - do not edit.
//
// Generated from abha.proto.

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

@$core.Deprecated('Use abhaProfileDescriptor instead')
const AbhaProfile$json = {
  '1': 'AbhaProfile',
  '2': [
    {'1': 'abha_id', '3': 1, '4': 1, '5': 9, '10': 'abhaId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'gender', '3': 3, '4': 1, '5': 9, '10': 'gender'},
    {'1': 'date_of_birth', '3': 4, '4': 1, '5': 9, '10': 'dateOfBirth'},
    {'1': 'address', '3': 5, '4': 1, '5': 9, '10': 'address'},
    {'1': 'photo_webp', '3': 6, '4': 1, '5': 12, '10': 'photoWebp'},
    {'1': 'state_name', '3': 7, '4': 1, '5': 9, '10': 'stateName'},
    {'1': 'district_name', '3': 8, '4': 1, '5': 9, '10': 'districtName'},
    {'1': 'pincode', '3': 9, '4': 1, '5': 9, '10': 'pincode'},
    {'1': 'mobile', '3': 10, '4': 1, '5': 9, '10': 'mobile'},
  ],
};

/// Descriptor for `AbhaProfile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List abhaProfileDescriptor = $convert.base64Decode(
    'CgtBYmhhUHJvZmlsZRIXCgdhYmhhX2lkGAEgASgJUgZhYmhhSWQSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRIWCgZnZW5kZXIYAyABKAlSBmdlbmRlchIiCg1kYXRlX29mX2JpcnRoGAQgASgJUgtkYXRl'
    'T2ZCaXJ0aBIYCgdhZGRyZXNzGAUgASgJUgdhZGRyZXNzEh0KCnBob3RvX3dlYnAYBiABKAxSCX'
    'Bob3RvV2VicBIdCgpzdGF0ZV9uYW1lGAcgASgJUglzdGF0ZU5hbWUSIwoNZGlzdHJpY3RfbmFt'
    'ZRgIIAEoCVIMZGlzdHJpY3ROYW1lEhgKB3BpbmNvZGUYCSABKAlSB3BpbmNvZGUSFgoGbW9iaW'
    'xlGAogASgJUgZtb2JpbGU=');

@$core.Deprecated('Use authSessionDescriptor instead')
const AuthSession$json = {
  '1': 'AuthSession',
  '2': [
    {'1': 'txn_id', '3': 1, '4': 1, '5': 9, '10': 'txnId'},
    {'1': 'otp_status', '3': 2, '4': 1, '5': 9, '10': 'otpStatus'},
    {'1': 'error_message', '3': 3, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `AuthSession`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authSessionDescriptor = $convert.base64Decode(
    'CgtBdXRoU2Vzc2lvbhIVCgZ0eG5faWQYASABKAlSBXR4bklkEh0KCm90cF9zdGF0dXMYAiABKA'
    'lSCW90cFN0YXR1cxIjCg1lcnJvcl9tZXNzYWdlGAMgASgJUgxlcnJvck1lc3NhZ2U=');
