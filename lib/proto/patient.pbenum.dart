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

import 'package:protobuf/protobuf.dart' as $pb;

class PatientData_Gender extends $pb.ProtobufEnum {
  static const PatientData_Gender GENDER_UNKNOWN =
      PatientData_Gender._(0, _omitEnumNames ? '' : 'GENDER_UNKNOWN');
  static const PatientData_Gender GENDER_MALE =
      PatientData_Gender._(1, _omitEnumNames ? '' : 'GENDER_MALE');
  static const PatientData_Gender GENDER_FEMALE =
      PatientData_Gender._(2, _omitEnumNames ? '' : 'GENDER_FEMALE');
  static const PatientData_Gender GENDER_OTHER =
      PatientData_Gender._(3, _omitEnumNames ? '' : 'GENDER_OTHER');

  static const $core.List<PatientData_Gender> values = <PatientData_Gender>[
    GENDER_UNKNOWN,
    GENDER_MALE,
    GENDER_FEMALE,
    GENDER_OTHER,
  ];

  static final $core.List<PatientData_Gender?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PatientData_Gender? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PatientData_Gender._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
