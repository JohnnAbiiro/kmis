import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class BilledModel {
  final String level;
  final String yeargroup;
  final String feeName;
  final  String amount;
  final String activityType;
  final String term;
  final String schoolId;
  final String ledgerid;
  final String? staff;
  final String? staffId;
  final List<String> excludedStudents;
  final Map<String, String> customAmounts;
  final DateTime? dateCreated;
  BilledModel({
    required this.level,
    required this.yeargroup,
    required this.amount,
    required this.activityType,
    required this.term,
    required this.schoolId,
    required this.feeName,
    required this.ledgerid,
    this.staff,
    this.staffId,
    this.excludedStudents = const [],
    this.customAmounts = const {},
    required this.dateCreated,
  });
  factory BilledModel.fromMap(Map<String, dynamic> map) {
    return BilledModel(
      ledgerid: map['ledgerid'] ?? '',
      staff: map['staff'],
      staffId: map['staffId'] ?? map['staffid'],
      level: map['level'] ?? '',
      feeName: map['feeName'] ?? '',
      yeargroup: map['yeargroup'] ?? '',
      schoolId: map['schoolId'] ?? '',
      activityType: map['activityType'] ?? '',
      term: map['term'] ?? '',
      amount: map['amount']?.toString() ?? '0',
      excludedStudents: List<String>.from(map['excludedStudents'] ?? []),
      customAmounts: Map<String, String>.from(map['customAmounts'] ?? {}),
      dateCreated: map['dateCreated'] != null ? (map['dateCreated'] as Timestamp).toDate() : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "ledgerid": ledgerid,
      "staff": staff,
      "staffId": staffId,
      "level": level,
      "feeName": feeName,
      "yeargroup": yeargroup,
      "schoolId": schoolId,
      "activityType": activityType,
      "term": term,
      "amount": amount,
      "excludedStudents": excludedStudents,
      "customAmounts": customAmounts,
      "dateCreated": dateCreated != null
          ? Timestamp.fromDate(dateCreated!)
          : FieldValue.serverTimestamp(),
    };
  }


}
