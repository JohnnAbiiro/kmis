import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String name;
  final String? schoolId;
  final String? code;
  final String? level;
  final String? staff;
  final String? complete;
  final String? department;
  final double weight;
  final double creditHours;
  final double creditHourMin;
  final double creditHourMax;
  final String type;
  final String scope;
  final DateTime timestamp;

  SubjectModel({
    required this.id,
    required this.name,
    this.schoolId,
    this.code,
    this.level,
    this.staff,
    this.complete = 'no',
    this.department,
    this.weight = 1,
    this.creditHours = 0,
    this.creditHourMin = 0,
    this.creditHourMax = 30,
    this.type = 'Core',
    this.scope = 'Single department',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'schoolId': schoolId,
    'code': code,
    'staff': staff,
    'complete': complete,
    'level': level,
    'department': department,
    'weight': weight,
    'creditHours': creditHours,
    'creditHourMin': creditHourMin,
    'creditHourMax': creditHourMax,
    'type': type,
    'scope': scope,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory SubjectModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawTimestamp = map['timestamp'];
    final timestamp = rawTimestamp is Timestamp
        ? rawTimestamp.toDate()
        : rawTimestamp is DateTime
        ? rawTimestamp
        : DateTime.tryParse(rawTimestamp?.toString() ?? '') ?? DateTime.now();
    return SubjectModel(
      id: docId,
      name: map['name']?.toString() ?? '',
      schoolId: map['schoolId']?.toString(),
      code: map['code']?.toString(),
      staff: map['staff']?.toString(),
      complete: map['complete']?.toString(),
      level: map['level']?.toString(),
      department: map['department']?.toString(),
      weight: (map['weight'] as num?)?.toDouble() ?? 1,
      creditHours: (map['creditHours'] as num?)?.toDouble() ?? 0,
      creditHourMin: (map['creditHourMin'] as num?)?.toDouble() ?? 0,
      creditHourMax: (map['creditHourMax'] as num?)?.toDouble() ?? 30,
      type: map['type']?.toString() ?? 'Core',
      scope: map['scope']?.toString() ?? 'Single department',
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
