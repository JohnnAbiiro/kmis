import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolModel {
  final String id;
  final String schoolname;
  final String prefix;
  final String address;
  final String email;
  final String phone;
  final String? academicyr;
  final String? term;
  final String logoUrl;
  final DateTime createdAt;

  // 🔹 New fields
  final bool agreedToTerms;
  final String countryCode;
  final String countryName;
  final String schoolId;
  final String type;

  // 🔹 Notification fields
  final String? smsSenderId;
  final String? smtpHost;
  final int? smtpPort;
  final String? smtpEmail;
  final String? smtpPassword;

  SchoolModel({
    required this.id,
    required this.schoolname,
    required this.prefix,
    required this.address,
    required this.email,
    required this.phone,
     this.academicyr,
     this.term,
    required this.logoUrl,
    required this.createdAt,
    this.agreedToTerms = true,
    this.countryCode = "+233",
    this.countryName = "Ghana",
    this.schoolId = "",
    this.type = "Pre-tertiary",
    this.smsSenderId,
    this.smtpHost = "smtp.gmail.com",
    this.smtpPort = 465,
    this.smtpEmail,
    this.smtpPassword,
  });

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": schoolname,
    "prefix": prefix,
    "address": address,
    "email": email,
    "phone": phone,
    "academicyr": academicyr,
    "term": term,
    "logoUrl": logoUrl,
    "createdAt": createdAt,

    // new
    "agreedtoterms": agreedToTerms,
    "countrycode": countryCode,
    "countryname": countryName,
    "schoolid": schoolId,
    "type": type,

    // notifications
    "smsSenderId": smsSenderId,
    "smtpHost": smtpHost,
    "smtpPort": smtpPort,
    "smtpEmail": smtpEmail,
    "smtpPassword": smtpPassword,
  };

  factory SchoolModel.fromMap(Map<String, dynamic> map, String id) {
    return SchoolModel(
      id: id,
      schoolname: map["name"] ?? "",
      prefix: map["prefix"] ?? "",
      address: map["address"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? "",
      logoUrl: map["logoUrl"] ?? "",
      createdAt:
      (map["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),

      // new
      agreedToTerms: map["agreedtoterms"] ?? true,
      countryCode: map["countrycode"] ?? "+233",
      countryName: map["countryname"] ?? "Ghana",
      schoolId: map["schoolid"] ?? "",
      type: map["type"] ?? "Pre-tertiary",

      smsSenderId: map["smsSenderId"],
      smtpHost: map["smtpHost"] ?? "smtp.gmail.com",
      smtpPort: map["smtpPort"] ?? 465,
      smtpEmail: map["smtpEmail"],
      smtpPassword: map["smtpPassword"],
    );
  }
}
