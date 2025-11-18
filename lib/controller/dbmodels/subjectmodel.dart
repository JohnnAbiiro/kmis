import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String name;
  final String? schoolId;
  final String? code;
  final String? level;
  final String? staff;
  final DateTime timestamp;

  SubjectModel({
    required this.id,
    required this.name,
    this.schoolId,
    this.code,
    this.staff,
    this.level,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'schoolId': schoolId,
      'code': code,
      'staff': staff,
      'level': level,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create from Map (when reading data)
  factory SubjectModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedTime;

    final ts = map['timestamp'];
    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    } else if (ts is DateTime) {
      parsedTime = ts;
    } else if (ts is String) {
      parsedTime = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    return SubjectModel(
      id: docId,
      name: map['name'] ?? '',
      schoolId: map['schoolId'],
      code: map['code'],
      staff: map['staff'],
      level: map['level'],
      timestamp: parsedTime,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,

    };
  }
}

