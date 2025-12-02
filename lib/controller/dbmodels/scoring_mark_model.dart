
import 'componentmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectScoring {
  final String id;
  final String studentId;
  final String? remarks;
  final String? attendance;
  final String? reopening;
  final String? nextclass;
  final String? nextfees;
  final String? totalattend;
  final String? yearlytotal;
  final String? average;
  final String? position;
  final String studentName;
  final String academicYear;
  final String term;
  final String level;
  final String department;
  final String region;
  final String schoolId;
  final String school;
  final String photoUrl;
  final String dob;
  final String email;
  final String phone;
  final String sex;
  final String status;
  final String yeargroup;
  final String staff;
  final String classes;
  final Map<String, dynamic> teacher;
  final Map<String, dynamic> scores;
  final Map<String, dynamic> subjectData;
  final DateTime timestamp;

  SubjectScoring({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.academicYear,
    required this.term,
    required this.level,
    required this.department,
    required this.region,
    required this.schoolId,
    required this.school,
    required this.photoUrl,
    required this.dob,
    required this.email,
    required this.phone,
    required this.sex,
    required this.status,
    required this.yeargroup,
    required this.subjectData,
    required this.staff,
    required this.classes,
    required this.teacher,
    required this.scores,
    this.attendance ='',
    this.remarks ='',
    this.reopening ='',
    this.nextclass='',
    this.nextfees ='',
    this.totalattend ='',
    this.yearlytotal = '',
    this.average= '',
    this.position ='',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory for initializing a subject record
  factory SubjectScoring.create({
    required String studentId,
    required String studentName,
    required String attendance,
    required String remarks,
    required String reopening,
    required String nextclass,
    required String nextfees,
    required String totalattend,
    required String yearlytotal,
    required String average,
    required String position,
    required String academicYear,
    required String term,
    required String staff,
    required String classes,
    required Map<String, dynamic> teacher,
    required Map<String, dynamic> scores,
    required String level,
    required String department,
    required String region,
    required String schoolId,
    required String school,
    required String photoUrl,
    required String dob,
    required String email,
    required String phone,
    required String sex,
    required String status,
    required String yeargroup,
    required String subjectId,
    required String subjectName,
    required List<ComponentModel> components,
  }) {
    final id = "${studentId}_${academicYear}_${term}";

    // initialize components with "0" marks
    final Map<String, String> initialScores = {
      for (var c in components) c.name: "0"
    };

    return SubjectScoring(
      id: id,
      studentId: studentId,
      studentName: studentName,
      academicYear: academicYear,
      term: term,
      remarks: remarks,
      attendance: attendance,
      staff: staff,
      reopening: reopening,
      nextclass: nextclass,
      nextfees: nextfees,
      totalattend: totalattend,
      yearlytotal: yearlytotal,
      average: average,
      position: position,
      classes: classes,
      teacher: teacher,
      scores: initialScores,
      level: level,
      department: department,
      region: region,
      schoolId: schoolId,
      school: school,
      photoUrl: photoUrl,
      dob: dob,
      email: email,
      phone: phone,
      sex: sex,
      status: status,
      yeargroup: yeargroup,
      subjectData: {
      subjectId: {
          "subjectId": subjectId,
          "subjectName": subjectName,
          "staff": email,
          "CAtotal": "0",
          "examstotal": "0",
          "CA": "0",
          "Exams": "0",
          "pos": "0",
          "rawCA": "0",
          "rawExams": "0",
          "caw":"0",
          "examsw":"0",
          "maxca":"0",
          "maxexams":"0",
          "totalScore": "0",
          "grade": "",
          "remark": "",
          "status": "pending",
          "scored": "no",
          "total": "0",
          "timestamp": DateTime.now().toIso8601String(),
        }
      },
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "academicYear": academicYear,
      "term": term,
      "attendance": attendance,
      "remarks": remarks,
      "reopening": reopening,
      "nextfees": nextfees,
      "nextclass": nextclass,
      "totalattend": totalattend,
      "yearlytotal": yearlytotal,
      "average": average,
      "position": position,
      "staff": staff,
      "classes": classes,
      "teacher": teacher,
      "scores": scores,
      "studentId": studentId,
      "studentName": studentName,
      "level": level,
      "department": department,
      "schoolId": schoolId,
      "school": school,
      "photoUrl": photoUrl,
      "dob": dob,
      "email": email,
      "phone": phone,
      "sex": sex,
      "status": status,
      "yeargroup": yeargroup,
      "region": region,
      "subjectData": subjectData,
      "timestamp": Timestamp.fromDate(timestamp),
    };
  }

  /// Create model from Firestore JSON
  factory SubjectScoring.fromJson(Map<String, dynamic> json, String docId) {
    DateTime parsedTime;

    final ts = json["timestamp"];
    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    } else if (ts is String) {
      parsedTime = DateTime.tryParse(ts) ?? DateTime.now();
    } else if (ts is DateTime) {
      parsedTime = ts;
    } else {
      parsedTime = DateTime.now();
    }

    return SubjectScoring(
      id: docId,
      studentId: json["studentId"] ?? "",
      studentName: json["studentName"] ?? "",
      academicYear: json["academicYear"] ?? "",
      term: json["term"] ?? "",
      staff: json["staff"] ?? "",
      classes: json["classes"] ?? "",
      teacher: (json["teacher"] ?? {}) as Map<String, dynamic>,
      level: json["level"] ?? "",
      department: json["department"] ?? "",
      region: json["region"] ?? "",
      schoolId: json["schoolId"] ?? "",
      school: json["school"] ?? "",
      photoUrl: json["photoUrl"] ?? "",
      dob: json["dob"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      sex: json["sex"] ?? "",
      attendance: json["attendance"] ?? "",
      remarks: json["remarks"] ?? "",
      reopening: json["reopening"] ?? "",
      nextfees: json["nextfees"] ?? "",
      nextclass: json["nextclass"] ?? "",
      totalattend: json["totalattend"] ?? "",
      yearlytotal: json["yearlytotal"] ?? "",
      average: json["average"] ?? "",
      position: json["position"] ?? "",
      status: json["status"] ?? "",
      yeargroup: json["yeargroup"] ?? "",
      subjectData: (json["subjectData"] ?? {}) as Map<String, dynamic>,
      timestamp: parsedTime,
      scores: (json["scores"] ?? {}) as Map<String, dynamic>,
    );
  }
}


