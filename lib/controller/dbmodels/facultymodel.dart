import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyModel {
  final String id;
  final String name;
  final String staff;
  final String? schoolId;
  final DateTime timestamp;

  FacultyModel({
    required this.id,
    required this.name,
    required this.staff,
    this.schoolId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'staff': staff,
      'schoolId': schoolId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }


  factory FacultyModel.fromMap(Map<String, dynamic> map, String docId) {
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

    return FacultyModel(
      id: docId,
      name: map['name'] ?? '',
      staff: map['staff'] ?? '',
      schoolId: map['companyid'],
      timestamp: parsedTime,
    );
  }
}
