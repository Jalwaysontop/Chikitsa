//
//  Generated code. Do not modify.
//  source: file_upload.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class FileChunk extends $pb.GeneratedMessage {
  factory FileChunk({
    $core.String? sessionId,
    $core.int? chunkIndex,
    $core.int? totalChunks,
    $core.String? fileHash,
    $core.List<$core.int>? data,
    $core.String? fileType,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (chunkIndex != null) {
      $result.chunkIndex = chunkIndex;
    }
    if (totalChunks != null) {
      $result.totalChunks = totalChunks;
    }
    if (fileHash != null) {
      $result.fileHash = fileHash;
    }
    if (data != null) {
      $result.data = data;
    }
    if (fileType != null) {
      $result.fileType = fileType;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  FileChunk._() : super();
  factory FileChunk.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FileChunk.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FileChunk', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'chunkIndex', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'totalChunks', $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'fileHash')
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(6, _omitFieldNames ? '' : 'fileType')
    ..aInt64(7, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FileChunk clone() => FileChunk()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FileChunk copyWith(void Function(FileChunk) updates) => super.copyWith((message) => updates(message as FileChunk)) as FileChunk;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileChunk create() => FileChunk._();
  FileChunk createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileChunk getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileChunk>(create);
  static FileChunk? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get chunkIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set chunkIndex($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChunkIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearChunkIndex() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalChunks => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalChunks($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTotalChunks() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalChunks() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get fileHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set fileHash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFileHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearFileHash() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get data => $_getN(4);
  @$pb.TagNumber(5)
  set data($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasData() => $_has(4);
  @$pb.TagNumber(5)
  void clearData() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get fileType => $_getSZ(5);
  @$pb.TagNumber(6)
  set fileType($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasFileType() => $_has(5);
  @$pb.TagNumber(6)
  void clearFileType() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get timestamp => $_getI64(6);
  @$pb.TagNumber(7)
  set timestamp($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTimestamp() => $_has(6);
  @$pb.TagNumber(7)
  void clearTimestamp() => clearField(7);
}

class UploadStatus extends $pb.GeneratedMessage {
  factory UploadStatus({
    $core.String? sessionId,
    $core.Iterable<$core.int>? receivedChunks,
    $core.bool? isComplete,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (receivedChunks != null) {
      $result.receivedChunks.addAll(receivedChunks);
    }
    if (isComplete != null) {
      $result.isComplete = isComplete;
    }
    return $result;
  }
  UploadStatus._() : super();
  factory UploadStatus.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UploadStatus.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UploadStatus', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'receivedChunks', $pb.PbFieldType.KU3)
    ..aOB(3, _omitFieldNames ? '' : 'isComplete')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UploadStatus clone() => UploadStatus()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UploadStatus copyWith(void Function(UploadStatus) updates) => super.copyWith((message) => updates(message as UploadStatus)) as UploadStatus;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadStatus create() => UploadStatus._();
  UploadStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadStatus getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UploadStatus>(create);
  static UploadStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get receivedChunks => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get isComplete => $_getBF(2);
  @$pb.TagNumber(3)
  set isComplete($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsComplete() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsComplete() => clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
