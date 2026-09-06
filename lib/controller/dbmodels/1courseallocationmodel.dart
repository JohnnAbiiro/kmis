class CourseAllocationModel {
  final String id;
  final String schoolId;
  final String staffId;
  final String facultyId;
  final String departmentId;
  final String courseCode;
  final String courseName;
  final String classOrLevel;
  final String academicYear;
  final String termOrSemester;

  const CourseAllocationModel({
    required this.id,
    required this.schoolId,
    required this.staffId,
    required this.facultyId,
    required this.departmentId,
    required this.courseCode,
    required this.courseName,
    required this.classOrLevel,
    required this.academicYear,
    required this.termOrSemester,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'schoolId': schoolId,
        'staffId': staffId,
        'facultyId': facultyId,
        'departmentId': departmentId,
        'courseCode': courseCode,
        'courseName': courseName,
        'classOrLevel': classOrLevel,
        'academicYear': academicYear,
        'termOrSemester': termOrSemester,
      };

  factory CourseAllocationModel.fromMap(Map<String, dynamic> map) => CourseAllocationModel(
        id: map['id']?.toString() ?? '',
        schoolId: map['schoolId']?.toString() ?? '',
        staffId: map['staffId']?.toString() ?? '',
        facultyId: map['facultyId']?.toString() ?? '',
        departmentId: map['departmentId']?.toString() ?? '',
        courseCode: map['courseCode']?.toString() ?? '',
        courseName: map['courseName']?.toString() ?? '',
        classOrLevel: map['classOrLevel']?.toString() ?? '',
        academicYear: map['academicYear']?.toString() ?? '',
        termOrSemester: map['termOrSemester']?.toString() ?? '',
      );
}
