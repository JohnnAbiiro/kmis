import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String supplier;
  final String name;
  final String activityType;
  final String term;
  final String schoolId;
  final DateTime dateCreated;
  final String ledgerid;
  final String paymentmethod;
  final String receivedaccount;
  final String note;
  final String staff;
  final String amount;
  final String expenseType;


  ExpenseModel({
    required this.supplier,
    required this.expenseType,
    required this.name,
    required this.activityType,
    required this.term,
    required this.schoolId,
    required this.dateCreated,
    required this.ledgerid,
    required this.paymentmethod,
    required this.receivedaccount,
    required this.note,
    required this.staff,
    required this.amount, // ✅ required now
  });

  Map<String, dynamic> toJson() {
    return {
      "supplier": supplier,
      "expenseType": expenseType,
      "name": name,
      "activityType": activityType,
      "term": term,
      "schoolId": schoolId,
      "dateCreated": dateCreated,
      "ledgerid": ledgerid,
      "paymentmethod": paymentmethod,
      "receivedaccount": receivedaccount,
      "note": note,
      "staff": staff,
      "fees": amount,
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      supplier: json["supplier"] ?? "",
      expenseType: json["expenseType"] ?? "",
      name: json["name"] ?? "",
      activityType: json["activityType"] ?? "",
      term: json["term"] ?? "",
      schoolId: json["schoolId"] ?? "",
      dateCreated: (json["dateCreated"] as Timestamp).toDate(),
      ledgerid: json["ledgerid"] ?? "",
      paymentmethod: json["paymentmethod"] ?? "",
      receivedaccount: json["receivedaccount"] ?? "",
      note: json["note"] ?? "",
      staff: json["staff"] ?? "",
      amount: json["amount"] ?? "",
    );
  }
}
