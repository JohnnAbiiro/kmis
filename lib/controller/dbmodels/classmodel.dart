import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final String staff;
  final String? schoolId;
  final String? department;
  final String? status;
  final DateTime timestamp;

  ClassModel({
    required this.id,
    required this.name,
    required this.staff,
    this.schoolId,
    this.department,
    this.status,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'staff': staff,
      'status': status,
      'schoolId': schoolId,
      'department': department,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create from Map (when reading data)
  factory ClassModel.fromMap(Map<String, dynamic> map, String docId) {
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

    return ClassModel(
      id: docId,
      name: map['name'] ?? '',
      staff: map['staff'] ?? '',
      status: map['status'] ?? '',
      schoolId: map['schoolId'],
      department: map['department'],
      timestamp: parsedTime,
    );
  }
}
