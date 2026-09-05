import 'package:cloud_firestore/cloud_firestore.dart';

class CourseRegistrationModel {
  final String id;
  final String schoolId;
  final String studentId;
  final String facultyId;
  final String departmentId;
  final String classOrLevel;
  final String academicYear;
  final String termOrSemester;
  final List<String> courseCodes;
  final double totalCredits;
  final String status; // 'registered'
  final DateTime timestamp;

  CourseRegistrationModel({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.facultyId,
    required this.departmentId,
    required this.classOrLevel,
    required this.academicYear,
    required this.termOrSemester,
    required this.courseCodes,
    required this.totalCredits,
    this.status = 'registered',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'schoolId': schoolId,
    'studentId': studentId,
    'facultyId': facultyId,
    'departmentId': departmentId,
    'classOrLevel': classOrLevel,
    'academicYear': academicYear,
    'termOrSemester': termOrSemester,
    'courseCodes': courseCodes,
    'totalCredits': totalCredits,
    'status': status,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory CourseRegistrationModel.fromMap(Map<String, dynamic> map) {
    final ts = map['timestamp'];
    final parsedTime = ts is Timestamp
        ? ts.toDate()
        : ts is DateTime
        ? ts
        : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();
    return CourseRegistrationModel(
      id: map['id']?.toString() ?? '',
      schoolId: map['schoolId']?.toString() ?? '',
      studentId: map['studentId']?.toString() ?? '',
      facultyId: map['facultyId']?.toString() ?? '',
      departmentId: map['departmentId']?.toString() ?? '',
      classOrLevel: map['classOrLevel']?.toString() ?? '',
      academicYear: map['academicYear']?.toString() ?? '',
      termOrSemester: map['termOrSemester']?.toString() ?? '',
      courseCodes: List<String>.from(map['courseCodes'] ?? const []),
      totalCredits: (map['totalCredits'] as num?)?.toDouble() ?? 0.0,
      status: map['status']?.toString() ?? 'registered',
      timestamp: parsedTime,
    );
  }
}