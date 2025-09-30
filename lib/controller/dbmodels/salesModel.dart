import 'package:cloud_firestore/cloud_firestore.dart';

class SalesModel {
  final String item;
  final String quantity;
  final String? unitcost;
  final String? unitprice;
  final String? totalcost;
  final String? totalprice;
  final String? studentId;
  final String? studentName;
  final String? saletype;
  final String staff;
  final String? schoolId;
  final DateTime timestamp;

  SalesModel(
      {
        required this.item,
        required this.quantity,
        required this.unitcost,
        required  this.unitprice,
        required  this.totalcost,
        required this.totalprice,
        required this.staff,
        required this.schoolId,
        required this.studentName,
        required this.studentId,
        required this.saletype,
        DateTime? timestamp,
      }) : timestamp = timestamp ?? DateTime.now();


  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'studentId': studentId,
      'purchasetype': saletype,
      'item': item,
      'quantity': quantity,
      'unitcost': unitcost,
      'unitprice': unitprice,
      'totalcost': totalcost,
      'totalprice': totalprice,
      'staff': staff,
      'schoolId': schoolId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create from Map (when reading data)
  factory SalesModel.fromMap(Map<String, dynamic> map) {
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

    return SalesModel(
      saletype: map['saletype'] ?? '',
      studentName: map['studentName'] ?? '',
      studentId: map['studentId'] ?? '',
      item: map['item'] ?? '',
      quantity: map['quantity'] ?? '',
      unitcost: map['unitcost'],
      unitprice: map['unitprice'],
      totalcost: map['totalcost'],
      totalprice: map['totalprice'],
      staff: map['staff'] ?? '',
      schoolId: map['schoolId'],
      timestamp: parsedTime,
    );
  }
}
