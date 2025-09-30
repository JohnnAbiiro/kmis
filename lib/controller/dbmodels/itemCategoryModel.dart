import 'package:cloud_firestore/cloud_firestore.dart';

class itemCategoryModel {
  final String name;
  final String staff;
  final String? schoolId;
  final DateTime timestamp;

  itemCategoryModel( {
    required this.name,
    required this.staff,
    required this.schoolId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'staff': staff,
      'name': name,
      'schoolId': schoolId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create from Map (when reading data)
  factory itemCategoryModel.fromMap(Map<String, dynamic> map) {
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

    return itemCategoryModel(
      staff: map['staff'] ?? '',
      name: map['name'] ?? '',
      schoolId: map['schoolId'],
      timestamp: parsedTime,
    );
  }
}
