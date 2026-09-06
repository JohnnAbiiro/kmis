import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectScoreEntry {
  final String subjectId;
  final String subjectName;
  final String code;
  double ca;
  double exam;
  String grade;
  bool isRegistered;
  String enteredBy;
  String enteredByName;
  DateTime? enteredAt;

  SubjectScoreEntry({
    required this.subjectId,
    required this.subjectName,
    required this.code,
    this.ca = 0,
    this.exam = 0,
    this.grade = '-',
    this.isRegistered = true,
    this.enteredBy = '',
    this.enteredByName = '',
    this.enteredAt,
  });

  double get total => ca + exam;
  bool get isComplete => ca > 0 || exam > 0;

  Map<String, dynamic> toMap() => {
        'subjectId': subjectId,
        'subjectName': subjectName,
        'code': code,
        'CA': ca.toString(),
        'Exams': exam.toString(),
        'totalScore': total.toStringAsFixed(2),
        'grade': grade,
        'isComplete': isComplete ? 'yes' : 'no',
        'isRegistered': isRegistered,
        'enteredBy': enteredBy,
        'enteredByName': enteredByName,
        'enteredAt': Timestamp.fromDate(enteredAt ?? DateTime.now()),
      };

  factory SubjectScoreEntry.fromMap(Map<String, dynamic> map) {
    final ts = map['enteredAt'];
    return SubjectScoreEntry(
      subjectId: map['subjectId']?.toString() ?? '',
      subjectName: map['subjectName']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      ca: double.tryParse(map['CA']?.toString() ?? '') ?? 0,
      exam: double.tryParse(map['Exams']?.toString() ?? '') ?? 0,
      grade: map['grade']?.toString() ?? '-',
      isRegistered: map['isRegistered'] as bool? ?? true,
      enteredBy: map['enteredBy']?.toString() ?? '',
      enteredByName: map['enteredByName']?.toString() ?? '',
      enteredAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
