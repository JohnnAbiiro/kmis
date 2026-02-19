
import 'package:cloud_firestore/cloud_firestore.dart';

class ComponentModel {
  final String id;
  final String name;
  final String staff;
  final String schoolId;
  final String totalMark;
  final String type;
  final String level;
  final DateTime dateCreated;

  ComponentModel({
    required this.id,
    required this.name,
    required this.staff,
    required this.schoolId,
    required this.totalMark,
    required this.type,
    required this.level,
    DateTime? dateCreated,
  }) : dateCreated = dateCreated ?? DateTime.now();

  factory ComponentModel.fromMap(Map<String, dynamic> map) {
    return ComponentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      staff: map['staff'] ?? '',
      type: map['type'] ?? '',
      level: map['level'] ?? '',
      schoolId: map['schoolId'] ?? '',
      totalMark: map['totalmark']?.toString() ?? '0',
      dateCreated: map['dateCreated'] != null
          ? (map['dateCreated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "staff": staff,
      "type": type,
      "schoolId": schoolId,
      "totalmark": totalMark,
      "dateCreated": Timestamp.fromDate(dateCreated),
    };
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ComponentModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
