// This is a generated file - do not edit.
//
// Generated from patient.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'patient.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'patient.pbenum.dart';

class Location extends $pb.GeneratedMessage {
  factory Location({
    $core.double? lat,
    $core.double? lng,
  }) {
    final result = create();
    if (lat != null) result.lat = lat;
    if (lng != null) result.lng = lng;
    return result;
  }

  Location._();

  factory Location.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Location.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Location',
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'lat')
    ..aD(2, _omitFieldNames ? '' : 'lng')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Location clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Location copyWith(void Function(Location) updates) =>
      super.copyWith((message) => updates(message as Location)) as Location;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Location create() => Location._();
  @$core.override
  Location createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Location getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Location>(create);
  static Location? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get lat => $_getN(0);
  @$pb.TagNumber(1)
  set lat($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLat() => $_has(0);
  @$pb.TagNumber(1)
  void clearLat() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get lng => $_getN(1);
  @$pb.TagNumber(2)
  set lng($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLng() => $_has(1);
  @$pb.TagNumber(2)
  void clearLng() => $_clearField(2);
}

class PatientData extends $pb.GeneratedMessage {
  factory PatientData({
    $core.int? patientId,
    $core.String? patientName,
    $core.int? age,
    PatientData_Gender? gender,
    $fixnum.Int64? phone,
    $core.Iterable<$core.String>? symptoms,
    $core.double? temperature,
    $core.String? bloodPressure,
    $core.int? heartRate,
    $fixnum.Int64? timestampUnixMs,
    Location? location,
  }) {
    final result = create();
    if (patientId != null) result.patientId = patientId;
    if (patientName != null) result.patientName = patientName;
    if (age != null) result.age = age;
    if (gender != null) result.gender = gender;
    if (phone != null) result.phone = phone;
    if (symptoms != null) result.symptoms.addAll(symptoms);
    if (temperature != null) result.temperature = temperature;
    if (bloodPressure != null) result.bloodPressure = bloodPressure;
    if (heartRate != null) result.heartRate = heartRate;
    if (timestampUnixMs != null) result.timestampUnixMs = timestampUnixMs;
    if (location != null) result.location = location;
    return result;
  }

  PatientData._();

  factory PatientData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PatientData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PatientData',
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'patientId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'patientName')
    ..aI(3, _omitFieldNames ? '' : 'age', fieldType: $pb.PbFieldType.OU3)
    ..aE<PatientData_Gender>(4, _omitFieldNames ? '' : 'gender',
        enumValues: PatientData_Gender.values)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'phone', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPS(6, _omitFieldNames ? '' : 'symptoms')
    ..aD(7, _omitFieldNames ? '' : 'temperature', fieldType: $pb.PbFieldType.OF)
    ..aOS(8, _omitFieldNames ? '' : 'bloodPressure')
    ..aI(9, _omitFieldNames ? '' : 'heartRate', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(10, _omitFieldNames ? '' : 'timestampUnixMs')
    ..aOM<Location>(11, _omitFieldNames ? '' : 'location',
        subBuilder: Location.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PatientData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PatientData copyWith(void Function(PatientData) updates) =>
      super.copyWith((message) => updates(message as PatientData))
          as PatientData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PatientData create() => PatientData._();
  @$core.override
  PatientData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PatientData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PatientData>(create);
  static PatientData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get patientId => $_getIZ(0);
  @$pb.TagNumber(1)
  set patientId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPatientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPatientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get patientName => $_getSZ(1);
  @$pb.TagNumber(2)
  set patientName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPatientName() => $_has(1);
  @$pb.TagNumber(2)
  void clearPatientName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get age => $_getIZ(2);
  @$pb.TagNumber(3)
  set age($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAge() => $_has(2);
  @$pb.TagNumber(3)
  void clearAge() => $_clearField(3);

  @$pb.TagNumber(4)
  PatientData_Gender get gender => $_getN(3);
  @$pb.TagNumber(4)
  set gender(PatientData_Gender value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasGender() => $_has(3);
  @$pb.TagNumber(4)
  void clearGender() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get phone => $_getI64(4);
  @$pb.TagNumber(5)
  set phone($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPhone() => $_has(4);
  @$pb.TagNumber(5)
  void clearPhone() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get symptoms => $_getList(5);

  @$pb.TagNumber(7)
  $core.double get temperature => $_getN(6);
  @$pb.TagNumber(7)
  set temperature($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTemperature() => $_has(6);
  @$pb.TagNumber(7)
  void clearTemperature() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get bloodPressure => $_getSZ(7);
  @$pb.TagNumber(8)
  set bloodPressure($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBloodPressure() => $_has(7);
  @$pb.TagNumber(8)
  void clearBloodPressure() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get heartRate => $_getIZ(8);
  @$pb.TagNumber(9)
  set heartRate($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHeartRate() => $_has(8);
  @$pb.TagNumber(9)
  void clearHeartRate() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get timestampUnixMs => $_getI64(9);
  @$pb.TagNumber(10)
  set timestampUnixMs($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTimestampUnixMs() => $_has(9);
  @$pb.TagNumber(10)
  void clearTimestampUnixMs() => $_clearField(10);

  @$pb.TagNumber(11)
  Location get location => $_getN(10);
  @$pb.TagNumber(11)
  set location(Location value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasLocation() => $_has(10);
  @$pb.TagNumber(11)
  void clearLocation() => $_clearField(11);
  @$pb.TagNumber(11)
  Location ensureLocation() => $_ensure(10);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
