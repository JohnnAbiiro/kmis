import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String name;
  final String schoolId;
  final String drAccount;
  final String crAccount;
  final String crAccountClass;
  final String drAccountClass;
  final String drAccountSubClass;
  final String crAccountSubClass;
  final String staff;
  final DateTime? dateCreated;

  ActivityModel({
    required this.id,
    required this.name,
    required this.schoolId,
    required this.drAccount,
    required this.crAccount,
    required this.staff,
    required this.crAccountClass,
    required this.drAccountClass,
    required this.crAccountSubClass,
    required this.drAccountSubClass,
    required this.dateCreated,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      crAccountSubClass: map['crAccountSubClass'] ?? '',
      drAccountSubClass: map['drAccountSubClass'] ?? '',
      staff: map['staff'] ?? '',
      crAccountClass: map['crAccountClass'] ?? '',
      drAccountClass: map['drAccountClass'] ?? '',
      name: map['name'] ?? '',
      drAccount: map['drAccount'] ?? '',
      schoolId: map['schoolId'] ?? '',
      crAccount: map['crAccount']?.toString() ?? '0',
      dateCreated: map['dateCreated'] != null ? (map['dateCreated'] as Timestamp).toDate() : null, id: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "crAccountSubClass": crAccountSubClass,
      "drAccountSubClass": drAccountSubClass,
      "crAccountClass": crAccountClass,
      "drAccountClass": drAccountClass,
      "staff": staff,
      "name": name,
      "drAccount": drAccount,
      "schoolId": schoolId,
      "crAccount": crAccount,
      "dateCreated": dateCreated != null
          ? Timestamp.fromDate(dateCreated!)
          : FieldValue.serverTimestamp(),
    };
  }
}
