import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ksoftsms/controller/loginprovider.dart';
import 'package:ksoftsms/controller/myprovider.dart';

class AppProvider  extends Myprovider{
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // List<Map<String, dynamic>> assignedList = [];
  //
  // Future<void> fetchTeacherSetup(String staffKey) async {
  //   try {
  //     final snapshot = await db.collection("teacherSetup").doc(staffKey).get();
  //
  //     if (!snapshot.exists || snapshot.data() == null) {
  //       assignedList = [];
  //       notifyListeners();
  //       return;
  //     }
  //
  //     final data = snapshot.data() as Map<String, dynamic>;
  //     final classesMap = Map<String, dynamic>.from(data['classname'] ?? {});
  //     final subjectsMap = Map<String, dynamic>.from(data['subjects'] ?? {});
  //
  //     if (classesMap.isEmpty || subjectsMap.isEmpty) {
  //       assignedList = [];
  //       notifyListeners();
  //       return;
  //     }
  //
  //     assignedList = [
  //       for (final classEntry in classesMap.values)
  //         for (final subjectEntry in subjectsMap.values)
  //           if (subjectEntry is Map<String, dynamic> &&
  //               subjectEntry.containsKey('name') &&
  //               subjectEntry.containsKey('id'))
  //             {
  //               "class": classEntry['name'],
  //               "subject": subjectEntry['name'],
  //               "subjectkey": subjectEntry['id'],
  //               "department": classEntry['department'],
  //             }
  //     ];
  //
  //     notifyListeners();
  //   } catch (e) {
  //     debugPrint("Error fetching teacher setup: $e");
  //     assignedList = [];
  //     notifyListeners();
  //   }
  // }
}