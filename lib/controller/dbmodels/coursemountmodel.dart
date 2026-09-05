// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class CourseMountModel {
//   final String id;
//   final String schoolId;
//   final String schoolType;
//   final String facultyId;
//   final String departmentId;
//   final String classOrLevel;
//   final String academicYear;
//   final String termOrSemester;
//   final List<String> coreCourseCodes;
//   final List<String> electiveCourseCodes;
//   final double totalCredits;
//   final String status;
//   final String? startDate;
//   final String? endDate;
//
//   CourseMountModel({
//     required this.id,
//     required this.schoolId,
//     required this.schoolType,
//     required this.facultyId,
//     required this.departmentId,
//     required this.classOrLevel,
//     required this.academicYear,
//     required this.termOrSemester,
//     required this.coreCourseCodes,
//     required this.electiveCourseCodes,
//     required this.totalCredits,
//     this.status = 'active',
//     this.startDate,
//     this.endDate,
//   });
//
//   List<String> get allCourseCodes => [
//     ...coreCourseCodes,
//     ...electiveCourseCodes,
//   ];
//
//   Map<String, dynamic> toMap() => {
//     'id': id,
//     'schoolId': schoolId,
//     'schoolType': schoolType,
//     'facultyId': facultyId,
//     'departmentId': departmentId,
//     'classOrLevel': classOrLevel,
//     'academicYear': academicYear,
//     'termOrSemester': termOrSemester,
//     'coreCourseCodes': coreCourseCodes,
//     'electiveCourseCodes': electiveCourseCodes,
//     'courseCodes': allCourseCodes,
//     'totalCredits': totalCredits,
//     'status': status,
//     'startDate': startDate,
//     'endDate': endDate,
//     'updatedAt': FieldValue.serverTimestamp(),
//   };
//
//   factory CourseMountModel.fromMap(Map<String, dynamic> map) =>
//       CourseMountModel(
//         id: map['id']?.toString() ?? '',
//         schoolId: map['schoolId']?.toString() ?? '',
//         schoolType: map['schoolType']?.toString() ?? '',
//         facultyId: map['facultyId']?.toString() ?? '',
//         departmentId: map['departmentId']?.toString() ?? '',
//         classOrLevel: map['classOrLevel']?.toString() ?? '',
//         academicYear: map['academicYear']?.toString() ?? '',
//         termOrSemester: map['termOrSemester']?.toString() ?? '',
//         coreCourseCodes: List<String>.from(
//           map['coreCourseCodes'] ?? const [],
//         ),
//         electiveCourseCodes: List<String>.from(
//           map['electiveCourseCodes'] ?? const [],
//         ),
//         totalCredits: (map['totalCredits'] as num?)?.toDouble() ?? 0.0,
//         status: map['status']?.toString() ?? 'active',
//         startDate: map['startDate']?.toString(),
//         endDate: map['endDate']?.toString(),
//       );
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class CourseMountModel {
  final String id;
  final String schoolId;
  final String schoolType;
  final String facultyId;
  final String departmentId;
  final String classOrLevel;
  final String academicYear;
  final String termOrSemester;
  final List<String> coreCourseCodes;
  final List<String> electiveCourseCodes;
  final double totalCredits;
  final String status;
  final DateTime? regStartDate;
  final DateTime? regEndDate;

  CourseMountModel({
    required this.id,
    required this.schoolId,
    required this.schoolType,
    required this.facultyId,
    required this.departmentId,
    required this.classOrLevel,
    required this.academicYear,
    required this.termOrSemester,
    required this.coreCourseCodes,
    required this.electiveCourseCodes,
    required this.totalCredits,
    this.status = 'active',
    this.regStartDate,
    this.regEndDate,
  });

  List<String> get allCourseCodes => [...coreCourseCodes, ...electiveCourseCodes];

  /// True when there is no window set, or "now" falls within [regStartDate, regEndDate].
  bool get isRegistrationOpen {
    final now = DateTime.now();
    if (regStartDate != null && now.isBefore(regStartDate!)) return false;
    if (regEndDate != null && now.isAfter(regEndDate!)) return false;
    return true;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'schoolId': schoolId,
    'schoolType': schoolType,
    'facultyId': facultyId,
    'departmentId': departmentId,
    'classOrLevel': classOrLevel,
    'academicYear': academicYear,
    'termOrSemester': termOrSemester,
    'coreCourseCodes': coreCourseCodes,
    'electiveCourseCodes': electiveCourseCodes,
    'courseCodes': allCourseCodes,
    'totalCredits': totalCredits,
    'status': status,
    'regStartDate': regStartDate != null ? Timestamp.fromDate(regStartDate!) : null,
    'regEndDate': regEndDate != null ? Timestamp.fromDate(regEndDate!) : null,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory CourseMountModel.fromMap(Map<String, dynamic> map) => CourseMountModel(
    id: map['id']?.toString() ?? '',
    schoolId: map['schoolId']?.toString() ?? '',
    schoolType: map['schoolType']?.toString() ?? '',
    facultyId: map['facultyId']?.toString() ?? '',
    departmentId: map['departmentId']?.toString() ?? '',
    classOrLevel: map['classOrLevel']?.toString() ?? '',
    academicYear: map['academicYear']?.toString() ?? '',
    termOrSemester: map['termOrSemester']?.toString() ?? '',
    coreCourseCodes: List<String>.from(map['coreCourseCodes'] ?? const []),
    electiveCourseCodes: List<String>.from(map['electiveCourseCodes'] ?? const []),
    totalCredits: (map['totalCredits'] as num?)?.toDouble() ?? 0.0,
    status: map['status']?.toString() ?? 'active',
    regStartDate: _parseDate(map['regStartDate']),
    regEndDate: _parseDate(map['regEndDate']),
  );
}