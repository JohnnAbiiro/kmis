import 'package:cloud_firestore/cloud_firestore.dart';

class CourseAllocationModel {
  final String id;
  final String schoolId;
  final String staffId;
  final String staffName;
  final String facultyId;
  final String departmentId;
  final String classOrLevel;
  final String academicYear;
  final String termOrSemester;
  final String courseCode;
  final String courseName;
  final String? staffemail;
  CourseAllocationModel({
    required this.id,
    required this.schoolId,
    required this.staffId,
    required this.staffName,
    required this.facultyId,
    required this.departmentId,
    required this.classOrLevel,
    required this.academicYear,
    required this.termOrSemester,
    required this.courseCode,
    required this.courseName,
     this.staffemail,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'schoolId': schoolId,
    'staffId': staffId,
    'staffName': staffName,
    'facultyId': facultyId,
    'departmentId': departmentId,
    'classOrLevel': classOrLevel,
    'academicYear': academicYear,
    'termOrSemester': termOrSemester,
    'courseCode': courseCode,
    'courseName': courseName,
    'staffemail': staffemail,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory CourseAllocationModel.fromMap(Map<String, dynamic> map) => CourseAllocationModel(
    id: map['id']?.toString() ?? '',
    schoolId: map['schoolId']?.toString() ?? '',
    staffId: map['staffId']?.toString() ?? '',
    staffName: map['staffName']?.toString() ?? '',
    facultyId: map['facultyId']?.toString() ?? '',
    departmentId: map['departmentId']?.toString() ?? '',
    classOrLevel: map['classOrLevel']?.toString() ?? '',
    academicYear: map['academicYear']?.toString() ?? '',
    termOrSemester: map['termOrSemester']?.toString() ?? '',
    courseCode: map['courseCode']?.toString() ?? '',
    courseName: map['courseName']?.toString() ?? '',
    staffemail: map['staffemail']?.toString() ?? '',
  );
}