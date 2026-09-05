


import 'package:ksoftsms/controller/dbmodels/subjectmodel.dart';
import 'classmodel.dart';
import 'componentmodel.dart';

class TeacherSetup {
  final String staffid;
  final String staffname;
  final String createby;
  final String schoolId;
  final String academicyear;
  final String term;
  final List<ClassModel> classname;
  final String status;
  final String complete;
  final String? email;
  final String? phone;
  final List<SubjectModel> subjects;
  final List<ComponentModel>? component;
  final DateTime timestamp;

  TeacherSetup({
    required this.staffid,
    required this.staffname,
    required this.createby,
    required this.schoolId,
    required this.academicyear,
    required this.term,
    required this.classname,
    this.status = "active",
    this.complete = "no",
    this.email,
    this.phone,
    required this.subjects,
    this.component,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      "staffid": staffid,
      "staffname": staffname,
      "createby": createby,
      "schoolId": schoolId,
      "academicyear": academicyear,
      "term": term,
      "status": status,
      "complete": complete,
      "email": email,
      "phone": phone,
      "timestamp": timestamp.toIso8601String(),


      "classname": {
        for (var c in classname)
          c.name: {
            "id": c.id,
            "name": c.name,
            "department": c.department,
            "staff": c.staff,
            "status":"no",
          }
      },


      "component": component != null
          ? {
        for (var comp in component!)
          comp.name: {
            "id": comp.id,
            "name": comp.name,
            "staff": comp.staff,
            "schoolId": comp.schoolId,
            "totalMark": comp.totalMark,
            "type": comp.type,
          }
      }
          : {},


      "subjects": {
        for (var lvl in subjects)
          lvl.name: {
            "id": lvl.id,
            "name": lvl.name,
            "isComplete": "no",
          }
      },
    };
  }
}


