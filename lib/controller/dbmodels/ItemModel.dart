import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String name;
  final String schoolId;
  final String accountType;
  final String subType;
  final DateTime? dateCreated;

  ItemModel({
    required this.name,
    required this.schoolId,
    required this.accountType,
    required this.subType,
    this.dateCreated,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      name: map['name'] ?? '',
      subType: map['subType'] ?? '',
      schoolId: map['schoolId'] ?? '',
      accountType: map['accountType']?.toString() ?? '0',
      dateCreated: map['dateCreated'] != null
          ? (map['dateCreated'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "subType": subType,
      "schoolId": schoolId,
      "accountType": accountType,
      "dateCreated": dateCreated != null
          ? Timestamp.fromDate(dateCreated!)
          : FieldValue.serverTimestamp(),
    };
  }
}
