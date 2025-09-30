import 'package:cloud_firestore/cloud_firestore.dart';

class ItemRegModel {
  final String name;
  final String barcode;
  final String costPrice;
  final String sellingPrice;
  final String openningStock;
  final String category;
  final String staff;
  final String schioolid;
  final DateTime? dateCreated;

  ItemRegModel({
    required this.barcode,
    required this.name,
    required this.costPrice,
    required this.sellingPrice,
    required this.openningStock,
    required this.category,
    required this.staff,
    required this.schioolid,
    this.dateCreated,
  });

  factory ItemRegModel.fromMap(Map<String, dynamic> map) {
    return ItemRegModel(
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      costPrice: map['costPrice'] ?? '',
      sellingPrice: map['sellingPrice'] ?? '',
      openningStock: map['openningStock'] ?? '',
      category: map['category'] ?? '',
      staff: map['staff'] ?? '',
      schioolid: map['schioolid'] ?? '',
      dateCreated: map['dateCreated'] != null
          ? (map['dateCreated'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "barcode": barcode,
      "name": name,
      "costPrice": costPrice,
      "sellingPrice": sellingPrice,
      "openningStock": openningStock,
      "category": category,
      "staff": staff,
      "schioolid": schioolid,
      "dateCreated": dateCreated != null
          ? Timestamp.fromDate(dateCreated!)
          : FieldValue.serverTimestamp(),
    };
  }
}
