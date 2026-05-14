// This is a generated file - do not edit.
//
// Generated from abha.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class AbhaProfile extends $pb.GeneratedMessage {
  factory AbhaProfile({
    $core.String? abhaId,
    $core.String? name,
    $core.String? gender,
    $core.String? dateOfBirth,
    $core.String? address,
    $core.List<$core.int>? photoWebp,
    $core.String? stateName,
    $core.String? districtName,
    $core.String? pincode,
    $core.String? mobile,
  }) {
    final result = create();
    if (abhaId != null) result.abhaId = abhaId;
    if (name != null) result.name = name;
    if (gender != null) result.gender = gender;
    if (dateOfBirth != null) result.dateOfBirth = dateOfBirth;
    if (address != null) result.address = address;
    if (photoWebp != null) result.photoWebp = photoWebp;
    if (stateName != null) result.stateName = stateName;
    if (districtName != null) result.districtName = districtName;
    if (pincode != null) result.pincode = pincode;
    if (mobile != null) result.mobile = mobile;
    return result;
  }

  AbhaProfile._();

  factory AbhaProfile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AbhaProfile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AbhaProfile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'abha'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'abhaId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'gender')
    ..aOS(4, _omitFieldNames ? '' : 'dateOfBirth')
    ..aOS(5, _omitFieldNames ? '' : 'address')
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'photoWebp', $pb.PbFieldType.OY)
    ..aOS(7, _omitFieldNames ? '' : 'stateName')
    ..aOS(8, _omitFieldNames ? '' : 'districtName')
    ..aOS(9, _omitFieldNames ? '' : 'pincode')
    ..aOS(10, _omitFieldNames ? '' : 'mobile')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbhaProfile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbhaProfile copyWith(void Function(AbhaProfile) updates) =>
      super.copyWith((message) => updates(message as AbhaProfile))
          as AbhaProfile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AbhaProfile create() => AbhaProfile._();
  @$core.override
  AbhaProfile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AbhaProfile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AbhaProfile>(create);
  static AbhaProfile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get abhaId => $_getSZ(0);
  @$pb.TagNumber(1)
  set abhaId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAbhaId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAbhaId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get gender => $_getSZ(2);
  @$pb.TagNumber(3)
  set gender($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGender() => $_has(2);
  @$pb.TagNumber(3)
  void clearGender() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get dateOfBirth => $_getSZ(3);
  @$pb.TagNumber(4)
  set dateOfBirth($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDateOfBirth() => $_has(3);
  @$pb.TagNumber(4)
  void clearDateOfBirth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get address => $_getSZ(4);
  @$pb.TagNumber(5)
  set address($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAddress() => $_has(4);
  @$pb.TagNumber(5)
  void clearAddress() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get photoWebp => $_getN(5);
  @$pb.TagNumber(6)
  set photoWebp($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPhotoWebp() => $_has(5);
  @$pb.TagNumber(6)
  void clearPhotoWebp() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get stateName => $_getSZ(6);
  @$pb.TagNumber(7)
  set stateName($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStateName() => $_has(6);
  @$pb.TagNumber(7)
  void clearStateName() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get districtName => $_getSZ(7);
  @$pb.TagNumber(8)
  set districtName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDistrictName() => $_has(7);
  @$pb.TagNumber(8)
  void clearDistrictName() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get pincode => $_getSZ(8);
  @$pb.TagNumber(9)
  set pincode($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPincode() => $_has(8);
  @$pb.TagNumber(9)
  void clearPincode() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get mobile => $_getSZ(9);
  @$pb.TagNumber(10)
  set mobile($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMobile() => $_has(9);
  @$pb.TagNumber(10)
  void clearMobile() => $_clearField(10);
}

class AuthSession extends $pb.GeneratedMessage {
  factory AuthSession({
    $core.String? txnId,
    $core.String? otpStatus,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (txnId != null) result.txnId = txnId;
    if (otpStatus != null) result.otpStatus = otpStatus;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  AuthSession._();

  factory AuthSession.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AuthSession.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuthSession',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'abha'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txnId')
    ..aOS(2, _omitFieldNames ? '' : 'otpStatus')
    ..aOS(3, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthSession clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthSession copyWith(void Function(AuthSession) updates) =>
      super.copyWith((message) => updates(message as AuthSession))
          as AuthSession;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthSession create() => AuthSession._();
  @$core.override
  AuthSession createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AuthSession getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AuthSession>(create);
  static AuthSession? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txnId => $_getSZ(0);
  @$pb.TagNumber(1)
  set txnId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxnId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxnId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get otpStatus => $_getSZ(1);
  @$pb.TagNumber(2)
  set otpStatus($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOtpStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearOtpStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get errorMessage => $_getSZ(2);
  @$pb.TagNumber(3)
  set errorMessage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasErrorMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorMessage() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
