// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ClassModel {
//   final String id;
//   final String name;
//   final String staff;
//   final String? schoolId;
//   final String? department;
//   final String? faculty;
//   final String? status;
//   final DateTime timestamp;
//   final String? schoolType;
//
//   ClassModel({
//     required this.id,
//     required this.name,
//     required this.staff,
//     this.schoolId,
//     this.department,
//     this.faculty,
//     this.status,
//     this.schoolType,
//     DateTime? timestamp,
//   }) : timestamp = timestamp ?? DateTime.now();
//
//   // Convert to Map for storage
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'staff': staff,
//       'status': status,
//       'schoolId': schoolId,
//       'department': department,
//       'faculty': faculty,
//       'schoolType': schoolType,
//       'timestamp': Timestamp.fromDate(timestamp),
//     };
//   }
//
//   // Create from Map (when reading data)
//   factory ClassModel.fromMap(Map<String, dynamic> map, String docId) {
//     DateTime parsedTime;
//
//     final ts = map['timestamp'];
//     if (ts is Timestamp) {
//       parsedTime = ts.toDate();
//     } else if (ts is DateTime) {
//       parsedTime = ts;
//     } else if (ts is String) {
//       parsedTime = DateTime.tryParse(ts) ?? DateTime.now();
//     } else {
//       parsedTime = DateTime.now();
//     }
//
//     return ClassModel(
//       id: docId,
//       name: map['name'] ?? '',
//       staff: map['staff'] ?? '',
//       status: map['status'] ?? '',
//       schoolId: map['schoolId'],
//       department: map['department'],
//       schoolType: map['schoolType'],
//       faculty: map['faculty'],
//       timestamp: parsedTime,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final String staff;
  final String? schoolId;
  final String? department;
  final String? departmentid;
  final String? faculty;
  final String? facultyid;
  final String? status;
  final DateTime timestamp;
  final String? schoolType;

  ClassModel({
    required this.id,
    required this.name,
    required this.staff,
    this.schoolId,
    this.department,
    this.departmentid,
    this.faculty,
    this.facultyid,
    this.status,
    this.schoolType,
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
      'departmentid': departmentid,
      'faculty': faculty,
      'facultyid': facultyid,
      'schoolType': schoolType,
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
      departmentid: map['departmentid'],
      schoolType: map['schoolType'],
      faculty: map['faculty'],
      facultyid: map['facultyid'],
      timestamp: parsedTime,
    );
  }
}