//
//  Generated code. Do not modify.
//  source: file_upload.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use fileChunkDescriptor instead')
const FileChunk$json = {
  '1': 'FileChunk',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'chunk_index', '3': 2, '4': 1, '5': 13, '10': 'chunkIndex'},
    {'1': 'total_chunks', '3': 3, '4': 1, '5': 13, '10': 'totalChunks'},
    {'1': 'file_hash', '3': 4, '4': 1, '5': 9, '10': 'fileHash'},
    {'1': 'data', '3': 5, '4': 1, '5': 12, '10': 'data'},
    {'1': 'file_type', '3': 6, '4': 1, '5': 9, '10': 'fileType'},
    {'1': 'timestamp', '3': 7, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `FileChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileChunkDescriptor = $convert.base64Decode(
    'CglGaWxlQ2h1bmsSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEh8KC2NodW5rX2luZG'
    'V4GAIgASgNUgpjaHVua0luZGV4EiEKDHRvdGFsX2NodW5rcxgDIAEoDVILdG90YWxDaHVua3MS'
    'GwoJZmlsZV9oYXNoGAQgASgJUghmaWxlSGFzaBISCgRkYXRhGAUgASgMUgRkYXRhEhsKCWZpbG'
    'VfdHlwZRgGIAEoCVIIZmlsZVR5cGUSHAoJdGltZXN0YW1wGAcgASgDUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use uploadStatusDescriptor instead')
const UploadStatus$json = {
  '1': 'UploadStatus',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'received_chunks', '3': 2, '4': 3, '5': 13, '10': 'receivedChunks'},
    {'1': 'is_complete', '3': 3, '4': 1, '5': 8, '10': 'isComplete'},
  ],
};

/// Descriptor for `UploadStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadStatusDescriptor = $convert.base64Decode(
    'CgxVcGxvYWRTdGF0dXMSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEicKD3JlY2Vpdm'
    'VkX2NodW5rcxgCIAMoDVIOcmVjZWl2ZWRDaHVua3MSHwoLaXNfY29tcGxldGUYAyABKAhSCmlz'
    'Q29tcGxldGU=');

