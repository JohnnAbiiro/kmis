import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  final String? id;
  final String name;
  final String accessLevel;
  final String teaching;
  final String phone;
  final String email;
  final String sex;
  final String region;
  final String status;
  final String schoolname;
  final String schoolId;
  final String facultyId;
  final String facultyName;
  final String departmentId;
  final String departmentName;
  final String classOrLevel;
  final DateTime createdAt;

  Staff({
    this.id,
    required this.name,
    required this.accessLevel,
    required this.teaching,
    required this.phone,
    required this.email,
    required this.sex,
    required this.region,
    required this.schoolId,
    this.facultyId = "",
    this.facultyName = "",
    this.departmentId = "",
    this.departmentName = "",
    this.classOrLevel = "",
    required this.schoolname,
    required this.createdAt,
    this.status = "0",
  });

  Map<String, dynamic> toMapForRegister() {
    return {
      "id": id ?? "",
      "name": name,
      "accessLevel": accessLevel,
      "teaching": teaching,
      "phone": phone,
      "email": email,
      "sex": sex,
      "region": region,
      "status": status,
      "school": schoolname,
      "schoolId": schoolId,
      "facultyId": facultyId,
      "facultyName": facultyName,
      "departmentId": departmentId,
      "departmentName": departmentName,
      "classOrLevel": classOrLevel,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    final Map<String, dynamic> data = {};
    void addIfNotEmpty(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        data[key] = value;
      }
    }

    addIfNotEmpty("id", id);
    addIfNotEmpty("name", name);
    addIfNotEmpty("accessLevel", accessLevel);
    addIfNotEmpty("teaching", teaching);
    addIfNotEmpty("phone", phone);
    addIfNotEmpty("email", email);
    addIfNotEmpty("sex", sex);
    addIfNotEmpty("region", region);
    addIfNotEmpty("schoolId", schoolId);
    addIfNotEmpty("schoolname", schoolname);
    addIfNotEmpty("facultyId", facultyId);
    addIfNotEmpty("facultyName", facultyName);
    addIfNotEmpty("departmentId", departmentId);
    addIfNotEmpty("departmentName", departmentName);
    addIfNotEmpty("classOrLevel", classOrLevel);

    return data;
  }

  factory Staff.fromMap(Map<String, dynamic> map, String id) {
    return Staff(
      id: id,
      name: map["name"] ?? "",
      accessLevel: map["accessLevel"] ?? map["accesslevel"] ?? "",
      teaching: map["teaching"] ?? "",
      phone: map["phone"] ?? "",
      email: map["email"] ?? "",
      sex: map["sex"] ?? "",
      region: map["region"] ?? "",
      status: map["status"] ?? "0",
      schoolId: map["schoolId"] ?? map["schoolid"] ?? "",
      schoolname: map["schoolname"] ?? map["school"] ?? "",
      facultyId: map["facultyId"] ?? map["facultyid"] ?? "",
      facultyName: map["facultyName"] ?? map["facultyname"] ?? "",
      departmentId: map["departmentId"] ?? map["departmentid"] ?? "",
      departmentName: map["departmentName"] ?? map["departmentname"] ?? "",
      classOrLevel: map["classOrLevel"] ?? map["classorlevel"] ?? "",
      createdAt: (map["createdAt"] is Timestamp)
          ? (map["createdAt"] as Timestamp).toDate()
          : (map["createdAt"] ?? DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'accessLevel': accessLevel,
      'teaching': teaching,
      'phone': phone,
      'email': email,
      'sex': sex,
      'region': region,
      'status': status,
      'schoolId': schoolId,
      'schoolname': schoolname,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'classOrLevel': classOrLevel,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}