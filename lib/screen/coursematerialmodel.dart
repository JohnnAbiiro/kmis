import 'package:cloud_firestore/cloud_firestore.dart';

class CourseMaterialModel {
  final String id;
  final String schoolId;
  final String courseCode;
  final String courseName;
  final String departmentId;
  final String classOrLevel;
  final String academicYear;
  final String termOrSemester;
  final String staffId;
  final String staffName;
  final String title;
  final String fileName;
  final String fileUrl;
  final int sizeBytes;
  final DateTime timestamp;

  CourseMaterialModel({
    required this.id,
    required this.schoolId,
    required this.courseCode,
    required this.courseName,
    required this.departmentId,
    required this.classOrLevel,
    required this.academicYear,
    required this.termOrSemester,
    required this.staffId,
    required this.staffName,
    required this.title,
    required this.fileName,
    required this.fileUrl,
    required this.sizeBytes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'schoolId': schoolId,
        'courseCode': courseCode,
        'courseName': courseName,
        'departmentId': departmentId,
        'classOrLevel': classOrLevel,
        'academicYear': academicYear,
        'termOrSemester': termOrSemester,
        'staffId': staffId,
        'staffName': staffName,
        'title': title,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'sizeBytes': sizeBytes,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory CourseMaterialModel.fromMap(Map<String, dynamic> map) {
    final ts = map['timestamp'];
    final parsed = ts is Timestamp
        ? ts.toDate()
        : ts is DateTime
            ? ts
            : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();
    return CourseMaterialModel(
      id: map['id']?.toString() ?? '',
      schoolId: map['schoolId']?.toString() ?? '',
      courseCode: map['courseCode']?.toString() ?? '',
      courseName: map['courseName']?.toString() ?? '',
      departmentId: map['departmentId']?.toString() ?? '',
      classOrLevel: map['classOrLevel']?.toString() ?? '',
      academicYear: map['academicYear']?.toString() ?? '',
      termOrSemester: map['termOrSemester']?.toString() ?? '',
      staffId: map['staffId']?.toString() ?? '',
      staffName: map['staffName']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      fileName: map['fileName']?.toString() ?? '',
      fileUrl: map['fileUrl']?.toString() ?? '',
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      timestamp: parsed,
    );
  }
}
