// // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // class DepartmentModel {
// //   final String id;
// //   final String name;
// //   final String? faculty;
// //   final String staff;
// //   final String? schoolId;
// //   final DateTime timestamp;
// //
// //   DepartmentModel({
// //     required this.id,
// //     required this.name,
// //     required this.staff,
// //     this.schoolId,
// //     this.faculty,
// //     DateTime? timestamp,
// //   }) : timestamp = timestamp ?? DateTime.now();
// //
// //   // Convert to Map for storage
// //   Map<String, dynamic> toMap() {
// //     return {
// //       'id': id,
// //       'name': name,
// //       'faculty': faculty,
// //       'staff': staff,
// //       'schoolId': schoolId,
// //       'timestamp': Timestamp.fromDate(timestamp),
// //     };
// //   }
// //
// //
// //   factory DepartmentModel.fromMap(Map<String, dynamic> map, String docId) {
// //     DateTime parsedTime;
// //
// //     final ts = map['timestamp'];
// //     if (ts is Timestamp) {
// //       parsedTime = ts.toDate();
// //     } else if (ts is DateTime) {
// //       parsedTime = ts;
// //     } else if (ts is String) {
// //       parsedTime = DateTime.tryParse(ts) ?? DateTime.now();
// //     } else {
// //       parsedTime = DateTime.now();
// //     }
// //
// //     return DepartmentModel(
// //       id: docId,
// //       name: map['name'] ?? '',
// //       staff: map['staff'] ?? '',
// //       faculty: map['faculty'],
// //       schoolId: map['companyid'],
// //       timestamp: parsedTime,
// //     );
// //   }
// // }
//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class DepartmentModel {
//   final String id;
//   final String name;
//   final String? faculty;
//   final String staff;
//   final String? schoolId;
//   final DateTime timestamp;
//   final int? minCreditHours;
//   final int? maxCreditHours;
//
//   DepartmentModel({
//     required this.id,
//     required this.name,
//     required this.staff,
//     this.schoolId,
//     this.faculty,
//     DateTime? timestamp,
//     this.minCreditHours,
//     this.maxCreditHours,
//   }) : timestamp = timestamp ?? DateTime.now();
//
//   // Convert to Map for storage
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'faculty': faculty,
//       'staff': staff,
//       'schoolId': schoolId,
//       'timestamp': Timestamp.fromDate(timestamp),
//       'minCreditHours': minCreditHours,
//       'maxCreditHours': maxCreditHours,
//     };
//   }
//
//   factory DepartmentModel.fromMap(Map<String, dynamic> map, String docId) {
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
//     return DepartmentModel(
//       id: docId,
//       name: map['name'] ?? '',
//       staff: map['staff'] ?? '',
//       faculty: map['faculty'],
//       schoolId: map['schoolId'],
//       timestamp: parsedTime,
//       minCreditHours: map['minCreditHours'],
//       maxCreditHours: map['maxCreditHours'],
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String id;
  final String name;
  final String? faculty;
  final String? facultyid;
  final String staff;
  final String? schoolId;
  final DateTime timestamp;
  final int? minCreditHours;
  final int? maxCreditHours;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.staff,
    this.schoolId,
    this.faculty,
    this.facultyid,
    DateTime? timestamp,
    this.minCreditHours,
    this.maxCreditHours,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'faculty': faculty,
      'facultyid': facultyid,
      'staff': staff,
      'schoolId': schoolId,
      'timestamp': Timestamp.fromDate(timestamp),
      'minCreditHours': minCreditHours,
      'maxCreditHours': maxCreditHours,
    };
  }

  factory DepartmentModel.fromMap(Map<String, dynamic> map, String docId) {
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

    return DepartmentModel(
      id: docId,
      name: map['name'] ?? '',
      staff: map['staff'] ?? '',
      faculty: map['faculty'],
      facultyid: map['facultyid'],
      schoolId: map['schoolId'],
      timestamp: parsedTime,
      minCreditHours: map['minCreditHours'],
      maxCreditHours: map['maxCreditHours'],
    );
  }
}