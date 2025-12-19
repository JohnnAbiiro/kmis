import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class SupplierModel {
  final String? id;
  final String name;
  final String phone;
  final  String staff;
  final String schoolId;
  final DateTime? dateCreated;
  SupplierModel({
    this.id,
    required this.name,
    required this.phone,
    required this.staff,
    required this.schoolId,
    required this.dateCreated,
  });
  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      name: map['name'] ?? '',
      staff: map['staff'] ?? '',
      phone: map['phone'] ?? '',
      schoolId: map['schoolId'] ?? '',
      dateCreated: map['dateCreated'] != null ? (map['dateCreated'] as Timestamp).toDate() : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
      "staff": staff,
      "schoolId": schoolId,
      "dateCreated": dateCreated != null
          ? Timestamp.fromDate(dateCreated!)
          : FieldValue.serverTimestamp(),
    };
  }
}
