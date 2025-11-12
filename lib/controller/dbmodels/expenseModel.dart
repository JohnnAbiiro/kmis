import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String supplier;
  final String expenseName;
  final String name;
  final String activityType;
  final String term;
  final String schoolId;
  final DateTime dateCreated;
  final String ledgerid;
  final String paymentmethod;
  final String paidAccount;
  final String note;
  final String staff;
  final String fees;
  final String expenseType;


  ExpenseModel({
    required this.expenseName,
    required this.supplier,
    required this.expenseType,
    required this.name,
    required this.activityType,
    required this.term,
    required this.schoolId,
    required this.dateCreated,
    required this.ledgerid,
    required this.paymentmethod,
    required this.paidAccount,
    required this.note,
    required this.staff,
    required this.fees,
  });

  Map<String, dynamic> toJson() {
    return {
      "expenseName": expenseName,
      "supplier": supplier,
      "expenseType": expenseType,
      "name": name,
      "activityType": activityType,
      "term": term,
      "schoolId": schoolId,
      "dateCreated": dateCreated,
      "ledgerid": ledgerid,
      "paymentmethod": paymentmethod,
      "paidAccount": paidAccount,
      "note": note,
      "staff": staff,
      "fees": fees,
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
      paidAccount: json["paidAccount"] ?? "",
      note: json["note"] ?? "",
      staff: json["staff"] ?? "",
      expenseName: json["expenseName"] ?? "",
      fees: json["fees"] ?? "00",
    );
  }
}
