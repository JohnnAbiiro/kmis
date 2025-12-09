import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ksoftsms/controller/dbmodels/expenseModel.dart';
import 'package:ksoftsms/controller/dbmodels/itemCategoryModel.dart';
import 'package:ksoftsms/controller/dbmodels/termmodel.dart';
import 'package:ksoftsms/controller/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../components/academicyrmodel.dart';
import '../components/terminalreportsheetprinter.dart';
import '../reportpdf/subjectprinter.dart';
import '../reportpdf/totalprinter.dart';
import '../reportpdf/transcript_printer.dart';
import 'dbmodels/classmodel.dart';
import 'dbmodels/componentmodel.dart';
import 'dbmodels/contestantsmodel.dart';
import 'dbmodels/departmodel.dart';

import 'dbmodels/idformatmodel.dart';
import 'dbmodels/regionmodel.dart';
import 'dbmodels/schoolmodel.dart';
import 'dbmodels/scoremodel.dart';
import 'dbmodels/scoring_mark_model.dart';
import 'dbmodels/staffmodel.dart';
import 'dbmodels/subjectmodel.dart';
import 'dbmodels/teachermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginprovider.dart';
class Myprovider extends LoginProvider {
  List<TermModel> terms = [];
  List<itemCategoryModel> itemCategorList = [];
  List<AcademicModel> academicyears = [];
  List<DepartmentModel> departments = [];
  List<ClassModel> classdata = [];
  List<SubjectModel> subjectList = [];
  List<StudentModel> studentlist = [];
  List<Staff> stafflist = [];
  List<RegionModel> regionList = [];
  List<ScoremodelConfig> scoreconfig = [];
  List<ComponentModel> accessComponents = [];
  bool loadterms = false;
  bool loaddepart = false;
  bool loadclassdata = false;
  bool loadsubject = false;
  bool isLoadingRegions = false;
  bool loadStudent = false;
  bool loadschool = false;
  bool loadstaff = false;
  bool loadingsconfig = true;
  bool isloadcomponents=true;
  bool savingSetup = false;
  bool savemarks = false;
  bool loginform = true;
  bool regform = false;
  bool loadacademicyear =false;
  XFile? imagefile;
  String imageUrl = "";
  List<TeacherSetup> teacherSetupList = [];
  bool isLoadingTeacherList = false;
  DocumentSnapshot? firstTeacherDocument;
  DocumentSnapshot? lastTeacherDocument;
  List<ScoremodelConfig> scoreConfigList = [];
  StudentModel? searchedStudentModel;

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  Future<void> fetchtemCategory() async {
    try {
      notifyListeners();

      final snapshot = await db.collection("itemcategory").where("schoolId", isEqualTo: schoolid).get();

      itemCategorList = snapshot.docs.map((doc) {
        return itemCategoryModel.fromMap(doc.data());
      }).toList();

      loadterms = false;

      notifyListeners();
    } catch (e) {
      loadterms = false;
      notifyListeners();
      print("Failed to fetch terms: $e");
    }
  }
  Future<void> fetchterms() async {
    try {
      loadterms = true;
      notifyListeners();

      final snapshot = await db.collection("terms").where("schoolId", isEqualTo: schoolid).get();

      terms = snapshot.docs.map((doc) {
        return TermModel.fromMap(doc.data(), doc.id);
      }).toList();

      loadterms = false;

      notifyListeners();
    } catch (e) {
      loadterms = false;
      notifyListeners();
      print("Failed to fetch terms: $e");
    }
  }
  Future<void> fetchdepart() async {
    try {
      loaddepart = true;
      notifyListeners();
      final snapshot = await db.collection("department").where("schoolId", isEqualTo: schoolid).get();
      departments = snapshot.docs.map((doc) {
        return DepartmentModel.fromMap(doc.data(), doc.id);
      }).toList();

      loaddepart = false;
      notifyListeners();
    } catch (e) {
      loaddepart = false;
      notifyListeners();
      print("Failed to fetch departments: $e");
    }
  }
  Future<void> fetchclass() async {
    try {
      loadclassdata = true;
      notifyListeners();
      final snapshot = await db.collection("classes").where("schoolId", isEqualTo: schoolid).get();
      classdata = snapshot.docs.map((doc) {
        return ClassModel.fromMap(doc.data(), doc.id);
      }).toList();

      loadclassdata = false;
      notifyListeners();
    } catch (e) {
      loadclassdata = false;
      notifyListeners();
      print("Failed to fetch class: $e");
    }
  }
  Future<void> fetchsubjects() async {
    try {
      loadsubject = true;
      notifyListeners();
      final snapshot = await db.collection("subjects").where("schoolId", isEqualTo: schoolid).get();
      subjectList = snapshot.docs.map((doc) {
        return SubjectModel.fromMap(doc.data(), doc.id);
      }).toList();

      loadsubject = false;
      notifyListeners();
    } catch (e) {
      loadsubject = false;
      notifyListeners();
      print("Failed to fetch class: $e");
    }
  }
  Future<void> fetchstudents() async {
    try {
      loadStudent = true;
      notifyListeners();

      final snapshot = await db.collection("students").where("schoolId", isEqualTo: schoolid).get();

      studentlist = snapshot.docs.map((doc) {
        final data = doc.data();
        // inject Firestore docId into the map (in case it's missing)
        data['id'] = doc.id;
        return StudentModel.fromMap(data);
      }).toList();

      loadStudent = false;
      notifyListeners();
    } catch (e) {
      loadStudent = false;
      notifyListeners();
      print("Failed to fetch students: $e");
    }
  }
  Future<void> fetchstaff() async {
    try {
      loadstaff = true;
      notifyListeners();
      final snap = await db.collection('staff').where('schoolId', isEqualTo: schoolid).get();

      stafflist = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Staff.fromMap(data, doc.id);
      }).toList();
      loadstaff = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching staff: $e");
    }
  }
  Future<void> fetchacademicyear() async {
    try {
      loadacademicyear = true;
      notifyListeners();

      final snapshot = await db
          .collection("academicyears")
          .where("schoolid", isEqualTo: schoolid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        academicyears = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return AcademicModel.fromMap(data, doc.id);
        }).toList();
      } else {
        academicyears = []; // explicitly set empty
      }

      loadacademicyear = false;
      notifyListeners();
    } catch (e) {
      loadacademicyear = false;
      academicyears = [];
      notifyListeners();
      print("Failed to fetch academic years: $e");
    }
  }
  Future<void> fetchScoreConfig() async {
    try {
      loadingsconfig = true;
      notifyListeners();
      final snap = await db.collection('scoringconfi').where("schoolId", isEqualTo: schoolid).get();
      scoreconfig = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ScoremodelConfig.fromFirestore(data, doc.id);
      }).toList();
      loadingsconfig = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching score config: $e");
    }
  }
  Future<void> scoringconfig(String schoolId) async {
    try {
      final snapshot = await db
          .collection("scoreconfig")
          .where("schoolId", isEqualTo: schoolId)
          .get();
      scoreConfigList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ScoremodelConfig.fromFirestore(data, doc.id);
      }).toList();
      notifyListeners();
      if (scoreConfigList.isEmpty) {
        throw Exception("No score configuration found for school $schoolId");
      }
    } catch (e) {
      throw Exception("Failed to fetch score config: $e");
    }
  }
  Future<void> getfetchRegions() async {
    try {
      isLoadingRegions = true;
      notifyListeners();
      QuerySnapshot querySnapshot = await db.collection("regions").where("schoolId", isEqualTo: schoolid).get();

      regionList = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        DateTime? parsedTime;
        if (data['timestamp'] != null) {
          if (data['timestamp'] is Timestamp) {
            parsedTime = (data['timestamp'] as Timestamp).toDate();
          } else {
            parsedTime = DateTime.tryParse(data['timestamp'].toString());
          }
        }

        return RegionModel(
          id: doc.id,
          regionname: data['name'] ?? '',
          schoolId: data['schoolId'] ?? '',
          time: parsedTime ?? DateTime.now(),
          staff: data['staff'] ?? '',
        );
      }).toList();


      isLoadingRegions = false;
      notifyListeners();
    } catch (e) {
      isLoadingRegions = false;
      print("Failed to fetch regions: $e");
      notifyListeners();
    }
  }
  Future<void> deleteData(String collection, String documentId) async {
    try {
    //  fetchstaff();
      fetchomponents();
      fetchterms();
      fetchdepart();
      fetchclass();
      fetchsubjects();
      notifyListeners();
      await db.collection(collection).doc(documentId).delete();
      debugPrint('Document $documentId deleted from $collection.');
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }
  showform(bool show, String type) {
    if (type == 'login') {
      loginform = true;
      regform = false;
    }
    if (type == 'signup') {
      regform = true;
      loginform = false;
    }
    notifyListeners();
  }
  Future<void> fetchomponents() async {
    isloadcomponents = true;
    notifyListeners();
    try {
      final snapshot = await db
          .collection("assesscomponent").where("schoolId", isEqualTo: schoolid)
          .orderBy("dateCreated", descending: true)
          .get();

      accessComponents = snapshot.docs.map((doc) {
        final data = doc.data();
        return ComponentModel.fromMap({
          ...data,
          "id": doc.id, // include id
        });
      }).toList();
    } catch (e) {
      print("Error fetching access components: $e");
    }

    isloadcomponents = false;
    notifyListeners();
  }
  Future<Map<String, dynamic>> getIdFormat(String schoolId) async {
    final query = await db.collection('idformats').where('schoolId', isEqualTo: schoolId).limit(1).get();
    if (query.docs.isEmpty) {
      throw Exception("No ID format found for school $schoolId");
    }
    final data = query.docs.first.data() as Map<String, dynamic>;
    String name = data['name'] as String;
    int lastNumber = (data['lastnumber'] ?? 0) as int;
    return {
      "name": name,
      "lastnumber": lastNumber,
    };
  }
  Future<void> fetchTeacherSetupList({int limit = 10,bool reset = false, bool nextPage = true,  }) async {    try {
      isLoadingTeacherList = true;
      notifyListeners();

      Query query = db
          .collection("teacherSetup").where("schoolId", isEqualTo: schoolid)
          .orderBy("timestamp", descending: false)
          .limit(limit);

      if (!reset && lastTeacherDocument != null && nextPage) {
        query = query.startAfterDocument(lastTeacherDocument!);
      } else if (!reset && firstTeacherDocument != null && !nextPage) {
        query = query.endBeforeDocument(firstTeacherDocument!).limitToLast(limit);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        // Save pagination cursors
        firstTeacherDocument = snapshot.docs.first;
        lastTeacherDocument = snapshot.docs.last;

        teacherSetupList = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Helper: parse timestamp field safely
          DateTime parseTimestamp(dynamic t) {
            if (t == null) return DateTime.now();
            if (t is Timestamp) return t.toDate();
            if (t is DateTime) return t;
            if (t is String) return DateTime.tryParse(t) ?? DateTime.now();
            return DateTime.now();
          }

          // --- classname: can be Map<String, dynamic> or List<dynamic>
          List<ClassModel> classnameList = [];
          final classnameField = data['classname'];
          if (classnameField != null) {
            if (classnameField is Map) {
              classnameList = (Map<String, dynamic>.from(classnameField))
                  .values
                  .map((c) {
                final m = Map<String, dynamic>.from(c as Map);
                return ClassModel(
                  id: m['id'] ?? '',
                  name: m['name'] ?? '',
                  staff: m['staff'] ?? '',
                  schoolId: m['schoolId'] ?? null,
                  // if your ClassModel expects timestamp, you can parse m['timestamp'] similarly
                );
              }).toList();
            } else if (classnameField is List) {
              classnameList = (classnameField as List<dynamic>)
                  .map((c) => ClassModel(
                id: (c as Map)['id'] ?? '',
                name: c['name'] ?? '',
                staff: c['staff'] ?? '',
                schoolId: c['schoolId'],
              ))
                  .toList();
            }
          }

          // --- component: can be Map<String, dynamic> or List<dynamic>
          List<ComponentModel> componentList = [];
          final componentField = data['component'];
          if (componentField != null) {
            if (componentField is Map) {
              componentList = (Map<String, dynamic>.from(componentField))
                  .values
                  .map((c) {
                final m = Map<String, dynamic>.from(c as Map);
                return ComponentModel.fromMap(m);
              }).toList();
            } else if (componentField is List) {
              componentList = (componentField as List<dynamic>)
                  .map((c) => ComponentModel.fromMap(Map<String, dynamic>.from(c as Map)))
                  .toList();
            }
          }

          // --- subjects: can be Map<String, dynamic> or List<dynamic>
          List<SubjectModel> subjectsList = [];
          final subjectsField = data['subjects'];
          if (subjectsField != null) {
            if (subjectsField is Map) {
              subjectsList = (Map<String, dynamic>.from(subjectsField))
                  .values
                  .map((s) {
                final m = Map<String, dynamic>.from(s as Map);
                return SubjectModel(
                  id: m['id'] ?? '',
                  name: m['name'] ?? '',
                  // if your SubjectModel has isComplete, include it:
                  // isComplete: m['isComplete'] ?? 'no',
                );
              }).toList();
            } else if (subjectsField is List) {
              subjectsList = (subjectsField as List<dynamic>)
                  .map((s) => SubjectModel(
                id: (s as Map)['id'] ?? '',
                name: s['name'] ?? '',
              ))
                  .toList();
            }
          }

          final timestamp = parseTimestamp(data['timestamp']);

          return TeacherSetup(
            staffid: data['staffid'] ?? '',
            staffname: data['staffname'] ?? '',
            schoolId: data['schoolId'] ?? '',
            academicyear: data['academicyear'] ?? '',
            term: data['term'] ?? '',
            component: componentList,
            classname: classnameList,
            status: data['status'] ?? 'active',
            complete: data['complete'] ?? 'no',
            email: data['email'] ?? '',
            phone: data['phone'] ?? '',
            createby: data['createby'] ?? '',
            subjects: subjectsList,
            timestamp: timestamp,
          );
        }).toList();
      } else {
        teacherSetupList = [];
      }
    } catch (e, st) {
      debugPrint("Error fetching teacherSetup: $e");
      debugPrintStack(stackTrace: st);
    } finally {
      isLoadingTeacherList = false;
      notifyListeners();
    }
  }
  updateAccessComponent(String id, Map<String, dynamic> newData) async {
    try {
      final docRef = db.collection('assesscomponent').doc(id);
      await docRef.update(newData);
      // Refresh the list after update
      await fetchomponents();

      notifyListeners();
    } catch (e) {
      debugPrint("Error updating component: $e");
      rethrow;
    }
  }
  Future<void> saveTeacherSetupMulti({required List<Staff> teacherIds,required String schoolId,required String academicYear, required String term,    required List<ClassModel> classes, required List<SubjectModel> subjects,  required List<ComponentModel> components,  }) async {
    if (teacherIds.isEmpty) throw Exception("No teachers selected.");
    if (subjects.isEmpty) throw Exception("No subjects selected.");
    if (classes.isEmpty) throw Exception("No class selected.");
    if (academicYear.trim().isEmpty || term.trim().isEmpty) {
      throw Exception("Academic year and term are required.");
    }

    savingSetup = true;
    notifyListeners();
    const int _batchLimit = 450;

    try {
      WriteBatch batch = db.batch();
      int writes = 0;

      final classNames = classes.map((c) => c.name).toList();
      final departlevel = classes.map((c) => c.department).toList();
      final Map<String, dynamic> teacherInfo = {};

      for (final t in teacherIds) {
        for (final sub in subjects) {
          final subjectKey = sub.id; // or sub.name

          //  Do NOT assign two teachers to the same subject
          if (teacherInfo.containsKey(subjectKey)) {
            print(
                " Subject ${sub.name} already has a teacher assigned.");
            continue; // move to next teacher
          }

          // ✅ Assign teacher to this subject
          teacherInfo[subjectKey] = {
            "tcherid": t.id,
            "tchername": t.name,
            "tcheremail": t.email,
            "schoolId": t.schoolId,
            "school": t.schoolname,
          };
          print("assign: ${t.name} → Subject ${sub.name}");
        }
      }
       // final teacherInfo = {
      //   for (final t in teacherIds)
      //     t.id ?? t.email: {
      //       "tcherid": t.id ?? "",
      //       "tchername": t.name,
      //       "tcheremail": t.email,
      //       "schoolId": t.schoolId,
      //       "school": t.schoolname,
      //     }
      // };
      final studentSnap = await db.collection("students")
          .where("schoolId", isEqualTo: schoolId)
          .where("level", whereIn: classNames).get();

      for (final studentDoc in studentSnap.docs) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        if (studentData.isEmpty) {
          debugPrint("student not found");
          throw Exception("student not found");
        }

        if (!studentData.containsKey('name') || !studentData.containsKey('level') ||
            studentData['level'] == null || (studentData['level'] as String).trim().isEmpty
        ) {
          debugPrint("document missing required fields");
          throw Exception("document missing required fields");
        }
        final studentId = studentDoc.id;
        final studentClass = studentData['level'] ?? '';

        if (!classNames.contains(studentClass)) continue;
        // subject scaffolding
        final Map<String, dynamic> subjectMap = {};
        final Map<String, String> scoredFlags = {};
        final Map<String, dynamic> scores = {};
        final Map<String, String> totalScores = {};

        for (final subject in subjects) {
          final scoring = SubjectScoring.create(
            studentId: studentId,
            studentName: studentData['name'] ?? '',
            academicYear: year,
            term: term,
            staff: name,
            classes: studentClass,
            level: studentData['level'] ?? '',
            department: studentData['department'] ?? '',
            region: studentData['region'] ?? '',
            schoolId: schoolId,
            school: studentData['school'] ?? '',
            photoUrl: studentData['photourl'] ?? '',
            dob: studentData['dob'] ?? '',
            email: studentData['email'] ?? '',
            phone: studentData['phone'] ?? '',
            sex: studentData['sex'] ?? '',
            status: studentData['status'] ?? 'active',
            yeargroup: studentData['yeargroup'] ?? '',
            subjectId: subject.id,
            subjectName: subject.name,
            components: components,
            teacher: teacherInfo,
            scores: {},
            attendance: '',
            remarks: '',
            reopening: '',
            nextclass: '',
            nextfees: '',
            totalattend: '',
            yearlytotal: '',
            average: '',
            position: ''
          );
          scores[subject.id] = {
            "subjectId": subject.id,
            "subjectName": subject.name,
            "code": subject.code,
            "CA": '0',
            "convertedca": '0',
            "convertedexams": '0',
            "Exams": '0',
            "totalScore": '0',
            "scored": 'no',
          };
          subjectMap[subject.id] = {
            "subjectId": subject.id,
            "subjectName": subject.name,
            "code": subject.code,
            ...scoring.subjectData[subject.id],

          };

        }

        final scoringId = "${studentId}_${academicyrid}_$term";
        final scoringRef = db.collection("subjectScoring").doc(scoringId);
        final scoringData = {
          "studentId": studentId,
          "studentName": studentData['name'] ?? '',
          "academicYear": year,
          "term": term,
          "level": studentData['level'] ?? '',
          "class": studentClass,
          "department": studentData['department'] ?? '',
          "region": studentData['region'] ?? '',
          "schoolId": schoolId,
          "school": studentData['school'] ?? '',
          "photourl": studentData['photourl'] ?? '',
          "dob": studentData['dob'] ?? '',
          "email": studentData['email'] ?? '',
          "phone": studentData['phone'] ?? '',
          "sex": studentData['sex'] ?? '',
          "status": studentData['status'] ?? 'active',
          "yeargroup": studentData['yeargroup'] ?? '',
          "subjects": subjectMap,
          "teacher": teacherInfo,
          "scores": scores,
          ...scoredFlags,
          ...totalScores,
          "timestamp": DateTime.now(),
        };

        batch.set(scoringRef, scoringData, SetOptions(merge: true));
        writes++;

        if (writes >= _batchLimit) {
          await batch.commit();
          batch = db.batch();
          writes = 0;
        }
      }

      if (writes > 0) await batch.commit();

      // ----------------------------
      // Save TeacherSetup
      // ----------------------------
      batch = db.batch();
      writes = 0;
      for (final teacher in teacherIds) {
        final teacherSetupId = "${teacher.id}_${academicYear}_$term";
        final classesMap = classes.map((s) => ClassModel(id: s.id,name: s.name, department: s.department,staff: s.staff,status: 'no')).toList();
        final componentsMap = components.map((s) => ComponentModel(id: s.id,name: s.name, staff: s.staff, schoolId: s.schoolId, totalMark: s.totalMark, type: '',)).toList();
        final subjectsList = subjects.map((s) => SubjectModel(id: s.id,name: s.name,)).toList();

        final teacherSetup = TeacherSetup(
          staffid: teacher.id ?? teacher.email,
          staffname: teacher.name,
          classname: classesMap,
          schoolId: schoolId,
          academicyear:year,
          term: term,
          component: componentsMap,
          subjects: subjectsList,
          createby: name,
          email: teacher.email,
          phone: teacher.phone,
        );

        final teacherSetupRef = db.collection("teacherSetup").doc(teacherSetupId);
        batch.set(teacherSetupRef, teacherSetup.toJson(), SetOptions(merge: true));
        writes++;

        if (writes >= _batchLimit) {
          await batch.commit();
          batch = db.batch();
          writes = 0;
        }
      }

      if (writes > 0) await batch.commit();
    } catch (e, stack) {
      debugPrint("Error in saveTeacherSetupMulti: $e");
      debugPrintStack(stackTrace: stack);
      rethrow;
    } finally {
      savingSetup = false;
      notifyListeners();
    }
  }
  Future<void> saveStudentSetupMulti({required List<StudentModel> students,required List<Staff> selectedTeachers, required List<SubjectModel> selectedSubjects, required List<ClassModel> selectedClasses,required List<ComponentModel> selectedComponents,required String academicYear, required String term, required String schoolId,}) async {
    if (students.isEmpty) throw Exception("No students selected.");
    if (selectedTeachers.isEmpty) throw Exception("No teachers selected.");
    if (selectedSubjects.isEmpty) throw Exception("No subjects selected.");
    if (academicYear.isEmpty || term.isEmpty) throw Exception("Academic year & term required.");

    savingSetup = true;
    notifyListeners();
    const int _batchLimit = 450;
    try {
      WriteBatch batch = db.batch();
      int writes = 0;
      final Map<String, dynamic> teacherInfo = {};
      for (final t in selectedTeachers) {
        for (final sub in selectedSubjects) {
          final subjectKey = sub.id;
          final subjectname = sub.name;
          final subjectdepartment = sub.level;
          final subjectcode = sub.code;

          if (teacherInfo.containsKey(subjectKey)) {
            print("Subject ${sub.name} already has a teacher assigned.");
            continue;
          }

          teacherInfo[subjectKey] = {
            "tcherid": t.id,
            "tchername": t.name,
            "subjectcode":subjectcode,
            "subjectdepartment":subjectdepartment,
            "subjectname":subjectname,
            "tcheremail": t.email,
            "schoolId": t.schoolId,
            "school": t.schoolname,
          };
          //print("assign: ${t.name}  Subject ${sub.name}");
        }
      }
      final filteredStudents = students;
      if (filteredStudents.isEmpty) {
        print("No students found.");
      }
      for (final s in filteredStudents) {

        final studentId = s.id;
        final scoringId = "${studentId}_${academicyrid}_${term}";

        final Map<String, dynamic> subjectMap = {};
        final Map<String, dynamic> scoresMap = {};


        for (final subject in selectedSubjects) {
          final subjectKey = subject.id;
          final subjectName = subject.name;
          scoresMap[subject.id] = {
            "subjectId": subject.id,
            "subjectName": subject.name,
            "code": subject.code,
            "CA": "0",
            "convertedca": "0",
            "Exams": "0",
            "convertedexams": "0",
            "totalScore": "0",
            "scored": "no",
          };

          subjectMap[subject.id] = {
            "subjectId": subject.id,
            "subjectName": subject.name,
            "code": subject.code,
            "isComplete": "no",
            ...scoresMap[subject.id],
          };
        }

        final scoringRef = db.collection("subjectScoring").doc(scoringId);

        final scoringData = SubjectScoring.create(
            studentId: studentId,
            studentName: s.name ?? '',
            attendance: '',
            remarks: '',
            reopening: '',
            nextclass: '',
            nextfees: '',
            totalattend: '',
            academicYear: year,
            term: term,
            staff: '',
            classes: '',
            teacher: teacherInfo,
            scores: scoresMap,
            level: s.level,
            department: s.department,
            region: s.region,
            schoolId: s.schoolId,
            school: s.school,
            photoUrl: s.photourl,
            dob: s.dob,
            email: s.email!,
            phone: s.phone,
            sex: s.sex,
            status: s.status,
            yeargroup: s.yeargroup,
            subjectId: '',
            subjectName: '',
            components: [],
            yearlytotal: '',
            average: '',
            position: ''

        );

        batch.set(scoringRef, scoringData, SetOptions(merge: true));
        writes++;

        if (writes >= _batchLimit) {
          await batch.commit();
          batch = db.batch();
          writes = 0;
        }
      }

      if (writes > 0) await batch.commit();
       // ___________________________
      // setup for teachers
      // ----------------------------

      WriteBatch teacherBatch = db.batch();
      int teacherWrites = 0;


      final Map<String, dynamic> classMap = {
        for (final s in filteredStudents)
          s.level: {
            "id": s.level,
            "name": s.level,
            "department": s.department,
            "status": "no",
            "complete": "no",
          }
      };

      for (final t in selectedTeachers) {
        final teacherDoc = db.collection("teacherSetup").doc("${t.id}_${academicyrid}_$term");
        final teacherSnap = await teacherDoc.get();

        final Map<String, dynamic> subjectMap = {
          for (final s in selectedSubjects)
            s.id: {
              "id": s.id,
              "name": s.name,
              "code": s.code,
              "isComplete": "no",
              "status": "no",
            }
        };

        if (!teacherSnap.exists) {
          teacherBatch.set(teacherDoc, {
            "staffid": t.id,
            "staffname": t.name,
            "tcheremail": t.email,
            "schoolId": t.schoolId,
            "school": t.schoolname,
            "subjects": subjectMap,
            "classname": classMap,
            "timestamp": DateTime.now(),
            "academicyear": year,
            "term": term,
            "component": selectedComponents.map((c) => c.toJson()).toList(),
            "createby": name,
            "email": t.email,
            "phone": t.phone,
          });

          teacherWrites++;
        }

        else {
          final data = teacherSnap.data()!;
          Map<String, dynamic> existingSubjects =
          Map<String, dynamic>.from(data["subjects"] ?? {});

          Map<String, dynamic> existingClasses =
          Map<String, dynamic>.from(data["classname"] ?? {});


          subjectMap.forEach((key, value) {
            if (!existingSubjects.containsKey(key)) {
              existingSubjects[key] = value;
            }
          });


          classMap.forEach((key, value) {
            if (!existingClasses.containsKey(key)) {
              existingClasses[key] = value;
            }
          });

          teacherBatch.update(teacherDoc, {
            "subjects": existingSubjects,
            "classname": existingClasses,
            "timestamp": DateTime.now(),
            "component": selectedComponents.map((c) => c.toJson()).toList(),
          });

          teacherWrites++;
        }

        if (teacherWrites >= 400) {
          await teacherBatch.commit();
          teacherBatch = db.batch();
          teacherWrites = 0;
        }
      }

      if (teacherWrites > 0) await teacherBatch.commit();

    } catch (e) {
      print("Error saving student(s): $e");
      rethrow;
    } finally {
      savingSetup = false;
      notifyListeners();
    }
  }


  pickImageFromGallery(BuildContext context) async {
    try {
      final XFile? selectedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (selectedImage == null) {
        print("No image selected");
        return;
      }

      final int fileSizeInBytes = await selectedImage.length();

      if (fileSizeInBytes > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Image size exceeds 5MB. Please choose a smaller file.',
            ),
          ),
        );
        return;
      }
      imagefile = selectedImage;
      notifyListeners();
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick image.')));
    }
  }
  uploadImage(String studentcode) async {
    if (imagefile == null) return;

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child(
        'uploads/$fileName$studentcode.jpg',
      );
      UploadTask uploadTask;

      if (kIsWeb) {
        print("Uploading for Web");
        final Uint8List data = await imagefile!.readAsBytes();
        uploadTask = ref.putData(
          data,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        print("Uploading for iOS/Android/Mac");

        final file = File(imagefile!.path);
        uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrl = downloadUrl;
      // print("Image URL: $imageUrl");
      notifyListeners();
    } catch (e) {
      print('Upload failed: $e');
    }
  }
  Future<void> deleteteacher(String staffId) async {
    const teachersetupColl = "teacherSetup";
    const subjectScoringColl = "subjectScoring";

    try {
     print("$year the term $term");
      final teacherSetupQuery = await db .collection(teachersetupColl)
          .where("staffid", isEqualTo: staffId).where("academicyear", isEqualTo: year)
          .where("term", isEqualTo: term).limit(1).get();

      if (teacherSetupQuery.docs.isEmpty) {
        throw("Teacher setup NOT FOUND for: $staffId");
        return;
      }

      final setupDoc = teacherSetupQuery.docs.first;
      final setupData = setupDoc.data();

      // Extract subject IDs
      final subjectsMap = setupData["subjects"] as Map<String, dynamic>? ?? {};
      final List<String> subjectIds = subjectsMap.values
          .map((s) => s["id"].toString())
          .where((id) => id.isNotEmpty)
          .toList();

      // Extract classes
      final classMap = setupData["classname"] as Map<String, dynamic>? ?? {};
      final List<String> classNames = classMap.keys.toList();

      // -------------------------------
      // 2) Query subjectScoring
      // -------------------------------
      final scoringQuery = await db
          .collection(subjectScoringColl)
          .where("schoolId", isEqualTo: schoolid)
          .where("academicYear", isEqualTo: year)
          .where("term", isEqualTo: term)
          .where("class", whereIn: classNames.isEmpty ? ["NONE"] : classNames)
          .get();

      final scoringDocs = scoringQuery.docs;
      bool hasScore(Map<String, dynamic> sub) {
        bool nz(dynamic v) =>
            v != null &&
                v.toString() != "0" &&
                v.toString().trim().isNotEmpty;

        if (nz(sub["CA"]) ||
            nz(sub["Exams"]) ||
            nz(sub["totalScore"])) return true;

        return false;
      }
      for (final doc in scoringDocs) {
        final data = doc.data();
        final subs = data["subjects"] as Map<String, dynamic>? ?? {};

        for (final sid in subjectIds) {
          if (!subs.containsKey(sid)) continue;
          if (hasScore(subs[sid])) {
            throw StateError(
                "Teacher CANNOT be deleted. Scores exist in subject: $sid");
          }
        }
      }
      WriteBatch batch = db.batch();
      int pending = 0;
      Future<void> flush() async {
        if (pending > 0) {
          await batch.commit();
          pending = 0;
          batch = db.batch();
        }
      }
      for (final doc in scoringDocs) {
        final updates = <String, dynamic>{};
        final data = doc.data();
        if (data["teacher"] is Map) {
          if (data["teacher"].containsKey(staffId)) {
            updates["teacher.$staffId"] = FieldValue.delete();
          }
        }
        for (final sid in subjectIds) {
          updates["subjects.$sid"] = FieldValue.delete();
          updates["scores.$sid"] = FieldValue.delete();
        }
        batch.update(doc.reference, updates);
        pending++;

        if (pending >= 400) await flush();
      }
      await flush();
      await setupDoc.reference.delete();
      debugPrint("Teacher deleted successfully: $staffId");
     fetchTeacherSetupList(reset: true);
     notifyListeners();
    } catch (e) {
      print("deleteTeacher ERROR: $e");
      rethrow;
    }
  }
  bool isloadac =false;
  List<Map<String, dynamic>> marksList = [];
  bool isloadscore=false;
  Future<void> fetchStaffScoringMarks({required String className, required String subjectKey,}) async {
    await getdata();
    isloadscore = true;
    notifyListeners();
    try {
      final snap = await db
     .collection('subjectScoring')
     .where('academicYear', isEqualTo: year)
     .where('term', isEqualTo: term)
     .where('class', isEqualTo: className)
     .where('schoolId', isEqualTo: schoolid).get();
     //  marksList = snap.docs.map((doc) {
     // final data = doc.data() as Map<String, dynamic>;
     // final id = doc.id;
     // final subjects = Map<String, dynamic>.from(data['subjects'] ?? {});
     // if (!subjects.containsKey(subjectKey)) {
     //      return null;
     //    }
     // final subjectData = Map<String, dynamic>.from(subjects[subjectKey]);
     //
     // subjectData.forEach((k, v) => print("  $k : $v"));
     // final rootTeachers = Map<String, dynamic>.from(data['teacher'] ?? {});
     // Map<String, dynamic>? teacherData;
     // if (rootTeachers.containsKey(staffid)) {
     // teacherData = Map<String, dynamic>.from(rootTeachers[staffid]);
     //
     //    } else {
     //      for (final t in rootTeachers.values) {
     //        if (t is Map && t['tcherid'] == staffid) {
     //          teacherData = Map<String, dynamic>.from(t);
     //
     //          break;
     //        }
     //      }
     //    }
     //
     //    if (teacherData == null) {
     //
     //      return null;
     //    }
     //
     //
     //    teacherData.forEach((k, v) => print("  $k : $v"));
     //    final scores = Map<String, dynamic>.from(data['scores'] ?? {});
     //    final sortedScores = Map.fromEntries(
     //      scores.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
     //    );
     //    return {
     //      'id': id,
     //      'studentName': data['studentName'] ?? '',
     //      'studentId': data['studentId'] ?? '',
     //      'class': data['class'] ?? '',
     //      'photoUrl': data['photourl'] ?? '',
     //
     //      // scoring
     //      'scores': sortedScores,
     //
     //      // pulled from subject map
     //      'subject': subjectData['subjectName'] ?? '',
     //      'subjectId': subjectData['subjectId'] ?? subjectKey,
     //
     //      // teacher info
     //      'teacherId': teacherData['tcherid'] ?? '',
     //      'teacherName': teacherData['tchername'] ?? '',
     //      'teacherEmail': teacherData['tcheremail'] ?? '',
     //
     //      'term': data['term'] ?? '',
     //      'academicYear': data['academicYear'] ?? '',
     //      'department': data['department'] ?? '',
     //      'level': data['level'] ?? '',
     //    };
     //  }).whereType<Map<String, dynamic>>().toList();
      marksList = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final id = doc.id;

        final subjects = Map<String, dynamic>.from(data['subjects'] ?? {});

        // If subject is missing, skip
        if (!subjects.containsKey(subjectKey)) return null;

        final subjectData = Map<String, dynamic>.from(subjects[subjectKey]);

        // 🔥 ADD THIS FILTER HERE
        final scored = subjectData['scored']?.toString().toLowerCase() ?? 'no';
        if (scored != "no") {
          // skip students already scored
          return null;
        }

        // Teacher section
        final rootTeachers = Map<String, dynamic>.from(data['teacher'] ?? {});
        Map<String, dynamic>? teacherData;

        if (rootTeachers.containsKey(staffid)) {
          teacherData = Map<String, dynamic>.from(rootTeachers[staffid]);
        } else {
          for (final t in rootTeachers.values) {
            if (t is Map && t['tcherid'] == staffid) {
              teacherData = Map<String, dynamic>.from(t);
              break;
            }
          }
        }

        // If teacher not found, skip
        if (teacherData == null) return null;

        final scores = Map<String, dynamic>.from(data['scores'] ?? {});
        final sortedScores = Map.fromEntries(
          scores.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
        );

        return {
          'id': id,
          'studentName': data['studentName'] ?? '',
          'studentId': data['studentId'] ?? '',
          'class': data['class'] ?? '',
          'photoUrl': data['photourl'] ?? '',

          'scores': sortedScores,

          'subject': subjectData['subjectName'] ?? '',
          'subjectId': subjectData['subjectId'] ?? subjectKey,

          'teacherId': teacherData['tcherid'] ?? '',
          'teacherName': teacherData['tchername'] ?? '',
          'teacherEmail': teacherData['tcheremail'] ?? '',

          'term': data['term'] ?? '',
          'academicYear': data['academicYear'] ?? '',
          'department': data['department'] ?? '',
          'level': data['level'] ?? '',
        };
      }).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      print("$e");

    } finally {
      isloadscore = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> fetchGradingSystem(String schoolId, {String? department}) async {
    try {
      final deptId = department != null
          ? "${schoolId}_${department.toLowerCase()}"
          : "${schoolId}_default";

      // 👉 First try department grading system
      final deptDoc = await db.collection("gradingsystems").doc(deptId).get();
      if (deptDoc.exists) {
        return deptDoc.data();
      }

      // 👉 Fallback: default grading system
      final defaultDoc = await db.collection("gradingsystems").doc("${schoolId}_default").get();
      if (defaultDoc.exists) {
        return defaultDoc.data();
      }

      throw Exception("No grading system found for $schoolId");
    } catch (e) {
      throw Exception("Error fetching grading system: $e");
    }
  }


  Future<void> saveStudentMarks({
    required String studentId,
    required String subjectId,
    required String subjectName,
    required String ca,
    required String exams,
    required String total,
    required String caConverted,
    required String examConverted,
    required String grade,
    required String remark,
    required String schoolId,
    required String teacherId,
    String? caw,
    String? examsw,
    String? maxca,
    String? maxexams,
  }) async {
    try {
      savemarks = true;
      notifyListeners();

      final studentid = "${studentId}_${academicyrid}_$term";
      final studentDocRef = db.collection("subjectScoring").doc(studentid);
      studentDocRef.update(
      {
        "subjects.$subjectId.CA": ca,
        "subjects.$subjectId.CAtotal": caw ?? "0",
        "subjects.$subjectId.Exams": exams,
        "subjects.$subjectId.examstotal": examsw ?? "0",
        "subjects.$subjectId.rawCA": caConverted,
        "subjects.$subjectId.rawExams": examConverted,
        "subjects.$subjectId.grade": grade,
        "subjects.$subjectId.remark": remark,
        "subjects.$subjectId.maxca": maxca ?? "0",
        "subjects.$subjectId.maxexams": maxexams ?? "0",
        "subjects.$subjectId.caw": caw ?? "0",
        "subjects.$subjectId.examsw": examsw ?? "0",
        "subjects.$subjectId.scored": "yes",
        "subjects.$subjectId.subjectName": subjectName,
        "subjects.$subjectId.totalScore": total,
        "subjects.$subjectId.total": total,
        "subjects.$subjectId.status": "completed",
      }
      );
      studentDocRef.update(
          {

            "scores.$subjectId.CA": ca,
            "scores.$subjectId.Exams": exams,
            "scores.$subjectId.convertedca": caConverted,
            "scores.$subjectId.convertedexams": examConverted,
            "scores.$subjectId.totalScore": total,
            "scores.$subjectId.status": "completed",
            "scores.$subjectId.subjectName": subjectName,
            "scores.$subjectId.subjectId": subjectId,
            "scores.$subjectId.timestamp": FieldValue.serverTimestamp(),
          }
      );
     studentDocRef.set({
      "headremarks" :"",
       "reopening" :"",
       "nextfees" :"",
       "nextclass" :"",
       "attendance" :"",
       "remark":"",
     },SetOptions(merge: true));
      final allStudentsSnapshot = await db.collection("subjectScoring")
          .where("subjects.$subjectId.scored", isEqualTo: "yes").get();

      // Create list of: studentDocId + score
      List<Map<String, dynamic>> scoreList = [];

      for (var doc in allStudentsSnapshot.docs) {
        final data = doc.data();
        final subj = data["subjects"][subjectId];

        if (subj != null && subj["totalScore"] != null) {
          scoreList.add({
            "docId": doc.id,
            "score": double.tryParse(subj["totalScore"].toString()) ?? 0,
          });
        }
      }

      scoreList.sort((a, b) => b["score"].compareTo(a["score"]));

      int rank = 1;
      int itemsProcessed = 0;
      double? previousScore;

      for (var item in scoreList) {
        itemsProcessed++;

        // same score gets same rank
        if (previousScore != null && previousScore != item["score"]) {
          rank = itemsProcessed; // next rank after group
        }

        previousScore = item["score"];
        item["rank"] = rank;
      }

      WriteBatch batch = db.batch();

      for (var item in scoreList) {
        final ref = db.collection("subjectScoring").doc(item["docId"]);
        batch.update(ref, {
          "subjects.$subjectId.pos": item["rank"].toString(),
        });
      }

      await batch.commit();
      final subjectQuery = await db.collection("subjectScoring").where("subjects.$subjectId.scored", isEqualTo: "no").get();
      final allScored = subjectQuery.docs.isEmpty;

      if (allScored) {
        final teacherSetupId = "${teacherId}_${academicyrid}_$term";
        final teacherDocRef = db.collection("teacherSetup").doc(teacherSetupId);
        await teacherDocRef.update({
          "subjects.$subjectId.isComplete": "yes",
          "subjects.$subjectId.timestamp": FieldValue.serverTimestamp(),
        });
      }

      savemarks = false;
      notifyListeners();

    } catch (e) {
      throw Exception("Error saving marks: $e");
    }
  }
  Future<void> generateReports({required String level, required String term,required String academyear,}) async {
    try {
      String? caw;
      String? examw;
      final query = await db.collection('subjectScoring')
          .where('schoolId', isEqualTo: schoolid)
          .where('level', isEqualTo: level)
          .where('term', isEqualTo: term)
          .where('academicYear', isEqualTo: academyear)
          .get();
     if (query.docs.isEmpty) {
        throw ("No report data found for this selection.");
      }

      // Convert docs to a list of maps with totalScore computed
      final students = query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final subjectsMap = data['subjects'] != null
            ? Map<String, dynamic>.from(data['subjects'])
            : {};

        // Sum all subject totals for this student
        num totalScore = 0;
        subjectsMap.forEach((key, s) {
          if (s is Map && s.containsKey('total')) {
            totalScore += num.tryParse(s['total']?.toString() ?? "0") ?? 0;
          }
        });

        data['totalScore'] = totalScore;
        data['subjectsMap'] = subjectsMap;
        return data;
      }).toList();

      // Sort students by totalScore descending
      students.sort((a, b) => (b['totalScore'] as num).compareTo(a['totalScore'] as num));


      int rank = 1;
      for (int i = 0; i < students.length; i++) {
        if (i > 0 && students[i]['totalScore'] != students[i - 1]['totalScore']) {
          rank = i + 1;
        }
        students[i]['position'] = rank.toString();
      }
      final pdf = pw.Document();

      for (var data in students) {

        final studentName = data['studentName'] ?? "";
        final studentID = data['studentId'] ?? "";
        final studentClass = data['classes'] ?? level;

        final schoolName = data['school'] ?? "School";
        final openingDate = data['reopening'] ?? "";
        final promotedTo = data['nextclass'] ?? "";
        final nextTermFees = data['nextfees'] ?? "";
        final teacherRemarks = data['remark'] ?? "";
        final headTeacherRemarks = data['headremarks'] ?? "";
        final attendance ="${data['attendance']?.toString() ?? ''} out of ${data['totalattend']?.toString() ?? ''}";
        final academicYearAverage = (data['totalScore'] as num).toStringAsFixed(2);

        final areaOfInterest = data['interest'] ?? "";
        final areaOfStrength = data['strength'] ?? "";
        final weakness = data['weakness'] ?? "";
        final numinclass = students.length;
        final subjectsMap = data['subjectsMap'] as Map<String, dynamic>;
        List<Map<String, dynamic>> subjects = [];


        subjectsMap.forEach((key, s) {
          if (s is Map && s.containsKey('subjectName')) {
            caw= s['caw']?.toString() ?? "";
            examw= s['examsw']?.toString() ?? "";
            subjects.add({
              "code": capitalize(s['code']?.toString() ?? ""),
              "subject": s['subjectName']?.toString() ?? "",
              "classScore": (s['rawCA'] != null ? double.tryParse(s['rawCA'].toString()) ?? 0 : 0).toStringAsFixed(2),
              "examScore": (s['rawExams'] != null ? double.tryParse(s['rawExams'].toString()) ?? 0 : 0).toStringAsFixed(2),
              "totalScore": (s['total'] != null ? double.tryParse(s['total'].toString()) ?? 0 : 0).toStringAsFixed(2),
              "position": s['pos']?.toString() ?? "",
              "remarks": s['remark']?.toString() ?? "",
            });
          }
        });

        final report = ReportCardPrinter(
          schoolName: schoolName,
          reportTitle: "$term Term Report",
          examSession: academyear,
          logoAssetPathl: "assets/images/logo.png",
          logoAssetPathr: "assets/images/logo.png",
          studentName: studentName,
          studentId: studentID,
          studentClass: studentClass,
          noInClass: numinclass.toString(),
          reOpeningDate: openingDate,
          promotedTo: promotedTo,
          nextTermFees: nextTermFees,
          position: data['position'] ?? "",
          subjects: subjects,
          attendance: attendance,
          teacherRemarks: teacherRemarks,
          headTeacherRemarks: headTeacherRemarks,
          academicYearAverage: academicYearAverage,
          areaOfInterest: areaOfInterest,
          areaOfStrength: areaOfStrength,
          weakness: weakness,
          caweight:caw ?? "",
          examweight:examw ?? "" ,
        );

        pdf.addPage(
          await report.generatePage(PdfPageFormat.a4, report.reportTitle),
        );
      }

      // Preview PDF immediately
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

    } catch (e) {
      // Re-throw so UI can catch it
      throw ("Report generation failed: $e");
    }
  }

  List<IdformatModel> idFormats = [];
  bool loadIdFormats = false;

  Future<void> fetchIdFormats() async {
    loadIdFormats = true;
    notifyListeners();

    try {
      final querySnapshot = await db
          .collection("idformats")
          .where("schoolId", isEqualTo: schoolid)
          .get();

      // Map Firestore docs to IdformatModel with doc.id
      idFormats = querySnapshot.docs.map<IdformatModel>((doc) {
        final data = doc.data();
        return IdformatModel.fromMap(data, doc.id); // pass doc.id as second argument
      }).toList();

    } catch (e) {
      print("Error fetching ID formats: $e");
      idFormats = [];
    }

    loadIdFormats = false;
    notifyListeners();
  }
  Map<String, dynamic>? selectedEntry ={};

  Future<void> setSelectedEntry(Map<String, dynamic> entry) async {
    selectedEntry = entry;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedEntry", jsonEncode(entry));
  }

  Future<void> loadSelectedEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString("selectedEntry");

    if (stored != null && stored.isNotEmpty) {
      try {
        selectedEntry = jsonDecode(stored) as Map<String, dynamic>;
      } catch (e) {
        selectedEntry = null;
      }
    }

    notifyListeners();
  }
  Future<void> clearSelectedEntry() async {
    selectedEntry = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("selectedEntry");
  }

  List<Map<String, dynamic>> promotionList = [];
  bool loadingPromotion = false;

  Future<void> fetchPromotionSettings() async {
    loadingPromotion = true;
    notifyListeners();
    String id ="promotionsettig";
    final docId = "$schoolid-$id".toLowerCase();

    final doc = await db.collection("promotion_settings").doc(docId).get();

    if (!doc.exists) {
      promotionList = [];
    } else {
      final data = doc.data() as Map<String, dynamic>;
      promotionList = (data["rules"] as List?)?.cast<Map<String, dynamic>>() ?? [];
    }

    loadingPromotion = false;
    notifyListeners();
  }
  Map<String, dynamic>? editPromotionData;
  void setEditPromotionData(Map<String, dynamic>? data) {
    editPromotionData = data;
    notifyListeners();
  }
  Map<String, String?> selectedTarget = {};
  Set<String> promoted = {};

  void updateClassTarget(String classId, String? newValue) {
    selectedTarget[classId] = newValue;
    notifyListeners();
  }

  Future<void> promoteOneClass(String id, String name) async {
    final next = selectedTarget[id];

    if (next == null) return; // protect

    // TODO: perform Firestore update here

    promoted.add(id);
    notifyListeners();
  }
  String? selectedRemarksClass;
  List<dynamic> remarksStudents = [];
  Map<String, String> remarksData = {};
  bool loadRemarks = false;
  void setRemarksClass(String? value) {
    selectedRemarksClass = value;


    remarksStudents.clear();
    remarksData.clear();

    notifyListeners();
  }
  Future<void> fetchRemarksStudents() async {
    if (selectedRemarksClass == null) return;

    loadRemarks = true;
    notifyListeners();

    remarksData = {
      for (var s in remarksStudents) s['id'].toString(): "",
    };

    loadRemarks = false;
    notifyListeners();
  }
  void setRemark(String studentId, String remark) {
    remarksData[studentId] = remark;
    notifyListeners();
  }

  Future<void> saveSingleRemark(String studentId) async {
    final remark = remarksData[studentId] ?? "";

    if (remark.trim().isEmpty) return;


    notifyListeners();
  }

  Future<void> saveAllRemarks() async {
    List<Map<String, dynamic>> data = remarksData.entries.map((e) {
      return {
        "student_id": e.key,
        "class": selectedRemarksClass,
        "remark": e.value,
        "date": DateTime.now().toIso8601String(),
      };
    }).toList();
    notifyListeners();
  }
  Future<List<Map<String, dynamic>>> getClassStudents(String className) async {
    try {
      final q = await db
          .collection('students')
          .where('schoolId', isEqualTo: schoolid)
          .where('class', isEqualTo: className)
          .get();

      return q.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data() as Map);
        m['id'] = d.id;
        return m;
      }).toList();
    } catch (e) {
      // log or handle error
      print('getClassStudents error: $e');
      return [];
    }
  }

  Future<DocumentReference> insert(String collection, Map<String, dynamic> data) async {
    try {
      return await db.collection(collection).add(data);
    } catch (e) {
      print('insert error: $e');
      rethrow;
    }
  }

  Future<void> insertBulk(String collection, List<Map<String, dynamic>> docs) async {
    if (docs.isEmpty) return;
    final batch = db.batch();
    try {
      for (final doc in docs) {
        final ref = db.collection(collection).doc();
        batch.set(ref, doc);
      }
      await batch.commit();
    } catch (e) {
      print('insertBulk error: $e');
      rethrow;
    }
  }

  Future<void> saveAttendanceBulk(List<Map<String, dynamic>> docs) async {
    await insertBulk('attendance', docs);
  }
  bool loadStudentone=false;
  List<Map<String, dynamic>> studentlistattend = [];
   fetchstudent(String level) async {
    try {
      loadStudentone = true;
      notifyListeners();

      final snapshot = await db.collection("subjectScoring").where("level", isEqualTo: level)
          .where("academicYear", isEqualTo: year)
          .where("schoolId", isEqualTo: schoolid)
          .get();

      studentlistattend = snapshot.docs.map((doc) {
        final data = doc.data();

        // add document ID
        data['id'] = doc.id;

        // convert Firestore Timestamp fields to String
        if (data['timestamp'] is Timestamp) {
          data['timestamp'] =
              (data['timestamp'] as Timestamp).toDate().toIso8601String();
        }

        if (data['dob'] is Timestamp) {
          data['dob'] =
              (data['dob'] as Timestamp).toDate().toIso8601String();
        }

        // return the map directly
        return data;
      }).toList();

      loadStudentone = false;
      notifyListeners();
    } catch (e) {
      loadStudentone = false;
      notifyListeners();
      print("Failed to fetch students: $e");
    }
  }
  Future<void> updateattendance(String attend, String id) async {
    try {
      final docRef = db.collection('subjectScoring').doc(id);

      // await docRef.update({
      //   'attendance': attend,
      //   'updatedAt': Timestamp.now(),
      // });
    await docRef.set({
    'attendance': attend,
    'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
      print("Attendance updated for $id");
    } catch (e) {
      print("Error updating attendance: $e");
    }
  }
  Future<void> bulkupdateattendance(String attend, String selectedclass) async {
    try {
      final snapshot = await db.collection('subjectScoring')
          .where("academicYear", isEqualTo: year)
          .where("term", isEqualTo: term)
          .where("schoolId", isEqualTo: schoolid)
          .where("level",isEqualTo: selectedclass).get();

      if (snapshot.docs.isEmpty) {
        throw("No records found to update.");

      }

      for (var doc in snapshot.docs) {
        await doc.reference.set({
          'totalattend': attend,
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));
      }
      print("Attendance updated for ${snapshot.docs.length} records");
    } catch (e) {
      print("Error updating attendance: $e");
    }
  }

  Future<void> updateremarks(String attend, String id) async {
    try {
      final docRef = db.collection('subjectScoring').doc(id);

      // await docRef.update({
      //   'remarks': attend,
      //   'updatedAt': Timestamp.now(),
      // });
      await docRef.set({
        'remark': attend,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
      print("Remarks updated for $id");
    } catch (e) {
      print("Error updating Remarks: $e");
    }
  }
  Future<void> headremarks(String attend, String id) async {
    try {
      final docRef = db.collection('subjectScoring').doc(id);

      // await docRef.update({
      //   'remarks': attend,
      //   'updatedAt': Timestamp.now(),
      // });
      await docRef.set({
        'headremarks': attend,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
      print("Remarks updated for $id");
    } catch (e) {
      print("Error updating Remarks: $e");
    }
  }
  Future<void> reopening(String reopen, String level) async {
    try {
      final querySnapshot = await db
      .collection('subjectScoring')
      .where('class', isEqualTo: level)
      .where('academicYear', isEqualTo: year)
      .where('term', isEqualTo: term).get();
      if (querySnapshot.docs.isEmpty) {
        print("No documents found for classs = $level");
        return;
      }
      for (var doc in querySnapshot.docs) {
        await doc.reference.set({
          'reopening': reopen.toString(),
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));

        print("Remarks updated for doc: ${doc.id}");
      }

    } catch (e) {
      print("Error updating Remarks: $e");
    }
  }
  Future<void> nextfees(String nextfees, String level) async {
    try {
      final querySnapshot = await db
          .collection('subjectScoring')
          .where('class', isEqualTo: level)
          .where('academicYear', isEqualTo: year)
          .where('term', isEqualTo: term).get();
      if (querySnapshot.docs.isEmpty) {
        print("No documents found for classs = $level");
        return;
      }
      for (var doc in querySnapshot.docs) {
        await doc.reference.set({
          'nextfees': nextfees,
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));

        print("Remarks updated for doc: ${doc.id}");
      }

    } catch (e) {
      print("Error updating Remarks: $e");
    }
  }
  Future<void> generatetotal(Map<String, dynamic> info, BuildContext context) async {
    try {
      final String academicYear = info['academicYear'];
      final String term = info['term'];
      final String className = info['className'];
      final snapshot = await db
          .collection('subjectScoring')
          .where('schoolId', isEqualTo: schoolid)
          .where('academicYear', isEqualTo: academicYear)
          .where('term', isEqualTo: term)
          .where('class', isEqualTo: className)
          .get();

      if (snapshot.docs.isEmpty) {
        throw ("No subject records found.");
      }
      final List<Map<String, String>> rows = [];
      final Set<String> subjectSet = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('subjects')) {
          final subjects = Map<String, dynamic>.from(data['subjects']);
          for (final s in subjects.values) {
            final subjectName = s['subjectName']?.toString() ?? "";
            if (subjectName.isNotEmpty) subjectSet.add(subjectName);
          }
        }
      }

      final List<String> subjectOrder = subjectSet.toList()..sort();
      final Map<String, double> subjectMaxMap = {};

      // Build rows
      for (final doc in snapshot.docs) {
        final data = doc.data();

        final studentName = data['studentName'] ?? "";
        final studentId = data['studentId'] ?? "";

        if (!data.containsKey('subjects')) continue;

        final subjects = Map<String, dynamic>.from(data['subjects']);

        double studentTotal = 0;

        final row = <String, String>{
          "name": studentName,
          "code": studentId,
        };

        for (final key in subjectOrder) {
          final match = subjects.values.firstWhere(
                (s) => s['subjectName'] == key,
            orElse: () => null,
          );

          double total = 0;

          if (match != null) {
            total = double.tryParse(match['totalScore']?.toString() ?? "0") ?? 0;
            row[key] = total.toString();
          } else {
            row[key] = "0";
          }

          studentTotal += total;

          if ((subjectMaxMap[key] ?? 0) < total) {
            subjectMaxMap[key] = total;
          }
        }

        row["total"] = studentTotal.toString();
        rows.add(row);
      }

      // Compute overall maximum total
      final double totalMarks =
      subjectMaxMap.values.fold(0, (a, b) => a + b);

      // -------------------------------------------------------------------
      // SORT STUDENTS — Highest total first
      // -------------------------------------------------------------------
      rows.sort((a, b) {
        double ta = double.tryParse(a["total"] ?? "0") ?? 0;
        double tb = double.tryParse(b["total"] ?? "0") ?? 0;
        return tb.compareTo(ta);
      });

      int rank = 1;
      double? lastScore;
      int count = 0;

      for (final r in rows) {
        count++;
        double score = double.tryParse(r["total"] ?? "0") ?? 0;

        if (lastScore != null && score < lastScore!) {
          rank = count;   // next rank starts at current position
        }

        r["rank"] = rank.toString();
        lastScore = score;
      }

      // HEADERS
      final criteriaHeaders = {
        for (final s in subjectOrder) s: s.toUpperCase(),
        "rank": "RANK",
        "total": "TOTAL",

      };

      final doctitle =
      "${info['academicYear']}_${info['term']}_${info['className']}"
          .toUpperCase();

      // PRINT
      final printer = SubjectscorePrinter(
        schoolName: currentschool,
        reportTitle1: doctitle,
        reportTitle: "TERM SCORE SHEET ($term - $academicYear)",
        className: className,
        rows: rows, // now sorted + ranked
        totalMarks: totalMarks.toString(),
        logoAssetPathLeft: "assets/logo.png",
        logoAssetPathRight: "assets/logo.png",
        criteriaHeaders: criteriaHeaders,
      );

      printer.printOrPreview(context);

    } catch (e) {
      throw ("Error generating total scoresheet or no record found");
    }
  }
  Future<void> generatebestsubject({required String subject, required String? subjectcode,required List<String> years, required List<String> terms,required BuildContext context,}) async {
    try {
      final snap = await db.collection("subjectScoring").get();
      if (snap.docs.isEmpty) {
        throw("NO STUDENTS FOUND!");

      }
      final filtered = snap.docs.where((doc) {
        final data = doc.data();

        final dbYear = data["academicYear"]?.toString() ?? "";
        final dbTerm = data["term"]?.toString() ?? "";
        final scoresMap = data["scores"] ?? {};

        Map<String, dynamic>? subjectEntry;

        scoresMap.forEach((key, value) {
          if (value is Map) {
            final m = Map<String, dynamic>.from(value);

            if (m["subjectName"] == subject || m["code"] == subjectcode) {
              subjectEntry = m;
            }
          }
        });

        if (subjectEntry == null) return false;

        return years.contains(dbYear) && terms.contains(dbTerm);
      }).toList();

      if (filtered.isEmpty) {
        throw("NO MATCHING SUBJECT RECORDS FOUND!");

      }

      List<Map<String, dynamic>> rows = [];

      for (final doc in filtered) {
        final data = doc.data() as Map<String, dynamic>;

        final studentName = data["studentName"];
        final studentId = data["studentId"];
        final academicYear = data["academicYear"];
        final term = data["term"];
        final scoresMap = data["scores"] ?? {};

        Map<String, dynamic>? entry;

        scoresMap.forEach((key, value) {
          if (value is Map) {
            final m = Map<String, dynamic>.from(value);

            if (m["subjectName"] == subject || m["code"] == subjectcode) {
              entry = m;
            }
          }
        });

        if (entry == null) continue;

        double total = double.tryParse(entry!["totalScore"] ?? "0") ?? 0;

        rows.add({
          "studentName": studentName,
          "studentId": studentId,
          "academicYear": academicYear,
          "term": term,
          "total": total.toString(),
        });
      }


      rows.sort((a, b) =>
          double.parse(b["total"]).compareTo(double.parse(a["total"])));


      int rank = 1;
      double? lastScore;
      int count = 0;

      for (final r in rows) {
        count++;
        double score = double.tryParse(r["total"] ?? "0") ?? 0;

        if (lastScore != null && score < lastScore!) {
          rank = count;
        }

        r["rank"] = rank.toString();
        lastScore = score;
      }


      final rowsStringMap = rows.map((r) =>
          r.map((key, value) => MapEntry(key, value.toString()))
      ).toList();

      final doctitle = "${subject.toUpperCase()} (${years.join(", ")})";

      final criteriaHeaders = {
        "studentId": "ID",
        "studentName": "STUDENT NAME",
        "total": "TOTAL",
        "rank": "RANK",
      };

      final printer = SubjectscorebestPrinter(
        schoolName: currentschool,
        reportTitle: "BEST SUBJECT REPORT",
        reportTitle1: "SUBJECT: $subject   CODE: $subjectcode",
        className: "YEARS: ${years.join(", ")} | TERMS: ${terms.join(", ")}",
        rows: rowsStringMap,

        logoAssetPathLeft: "assets/logo.png",
        logoAssetPathRight: "assets/logo.png",
      );
      printer.printOrPreview(context);

      print("✓ Report Generated Successfully");

    } catch (e) {
      throw ("$e");
    }
  }

  Future<void> generateStudentDetailReport({required String student,required String studentid, required List<String> termIds,required List<String> academicYears, }) async {
    try {

      final pdf = pw.Document();
      Query baseQuery = db.collection("subjectScoring")
          .where("schoolId", isEqualTo: schoolid)
          .where("studentId", isEqualTo: studentid);
      if (academicYears.isNotEmpty) {
        baseQuery = baseQuery.where("academicYear", whereIn: academicYears);
      }
      if (termIds.isNotEmpty) {
        baseQuery = baseQuery.where("term", whereIn: termIds);
      }
      final snap = await baseQuery.get();
      if (snap.docs.isEmpty) {
        throw ("No records found for student.");
      }


      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final year = data["academicYear"]?.toString() ?? "";
        final term = data["term"]?.toString() ?? "";
        final noinclass =data.length;
        final subjectsMap = Map<String, dynamic>.from(data["subjects"] ?? {});
        List<Map<String, dynamic>> subjects = [];
        subjectsMap.forEach((key, raw) {
          if (raw is Map) {
            final s = Map<String, dynamic>.from(raw);
            subjects.add({
              "code": s["code"]?.toString() ?? "",
              "subject": s["subjectName"]?.toString() ?? "",
              "classScore":
              (double.tryParse("${s['rawCA']}") ?? 0).toStringAsFixed(2),
              "examScore":
              (double.tryParse("${s['rawExams']}") ?? 0).toStringAsFixed(2),
              "totalScore":
              (double.tryParse("${s['total']}") ?? 0).toStringAsFixed(2),
              "position": s["pos"]?.toString() ?? "",
              "remarks": s["remark"]?.toString() ?? "",
            });
          }
        });

        // ---- COMPUTE OVERALL SCORE ----
        final totalScore = subjects.fold<double>(
          0,
              (p, s) => p + double.tryParse(s["totalScore"] ?? "0")!,
        );

        // ---- PRINT PAGE ----
        final report = ReportCardPrinter(
          schoolName: data["school"] ?? "School",
          reportTitle: "$term Report",
          examSession: year,
          logoAssetPathl: "assets/images/logo.png",
          logoAssetPathr: "assets/images/logo.png",
          studentName: student,
          studentId: studentid,
          studentClass: '',
          noInClass: noinclass.toString(),
         // noInClass: data["noInClass"]?.toString() ?? "",
          reOpeningDate: data["reopening"] ?? "",
          promotedTo: data["nextclass"] ?? "",
          nextTermFees: data["nextfees"] ?? "",
          position: data["position"] ?? "",
          subjects: subjects,
          attendance: data["attendance"]?.toString() ?? "",
          teacherRemarks: data["remark"] ?? "",
          headTeacherRemarks: data["headremarks"] ?? "",
          academicYearAverage: totalScore.toStringAsFixed(2),
          areaOfInterest: data["interest"] ?? "",
          areaOfStrength: data["strength"] ?? "",
          weakness: data["weakness"] ?? "",
          caweight: data["caw"]?.toString() ?? "",
          examweight: data["examsw"]?.toString() ?? "",
        );

        pdf.addPage(await report.generatePage(
          PdfPageFormat.a4,
          "$term Report • $year",
        ));
      }


      // -------------------------
      // 5. OUTPUT PDF
      // -------------------------
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      throw ("Student detail report generation failed: $e");
    }
  }
  Future<void> generatetranscriptReport({required String student,required String studentid, required List<String> termIds,required List<String> academicYears,}) async {
    try {
      final pdf = pw.Document();
       Query baseQuery = db
          .collection("subjectScoring")
          .where("schoolId", isEqualTo: schoolid)
          .where("studentId", isEqualTo: studentid);

      if (academicYears.isNotEmpty) {
        baseQuery = baseQuery.where("academicYear", whereIn: academicYears);
      }
      if (termIds.isNotEmpty) {
        baseQuery = baseQuery.where("term", whereIn: termIds);
      }

      final snap = await baseQuery.get();
      if (snap.docs.isEmpty) {
        throw ("No academic records found for this student.");
      }

      // -----------------------------------------------------------
      // 2. FETCH GRADING SYSTEM (Interpretation of grades)
      // -----------------------------------------------------------
      final gradeSnap = await db
          .collection("gradingsystems")
          .where("schoolid", isEqualTo: schoolid)
          .get();

      if (gradeSnap.docs.isEmpty) {
        throw ("Grading System not found for this school.");
      }

      final gradeDoc = gradeSnap.docs.first.data();
      final gradeMap = Map<String, dynamic>.from(gradeDoc["gradingsystem"] ?? {});

      // Sort grade rows (1,2,3,4,5...)
      final sortedGradeKeys = gradeMap.keys.toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

      /// FINAL INTERPRETATION TABLE
      /// columns: Grade Name | Weight | Min | Max | Remark
      final List<List<String>> gradeInterpretation = sortedGradeKeys.map((key) {
        final g = Map<String, dynamic>.from(gradeMap[key]);
        return [
          key, // grade name
          key, // weight (matches your PDF)
          g["min"]?.toString() ?? "",
          g["max"]?.toString() ?? "",
          g["remark"]?.toString() ?? "",
        ];
      }).toList();

      // -----------------------------------------------------------
      // 3. LOOP THROUGH EACH ACADEMIC RECORD AND PREPARE TRANSCRIPT
      // -----------------------------------------------------------
      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final year = data["academicYear"]?.toString() ?? "";
        final term = data["term"]?.toString() ?? "";

        // SUBJECTS LIST
        final subjectsMap = Map<String, dynamic>.from(data["subjects"] ?? {});
        List<Map<String, dynamic>> subjects = [];

        subjectsMap.forEach((key, raw) {
          if (raw is Map) {
            final s = Map<String, dynamic>.from(raw);

            subjects.add({
              "code": s["code"]?.toString() ?? "",
              "title": s["subjectName"]?.toString() ?? "",
              "mark": (double.tryParse("${s['total']}") ?? 0).toStringAsFixed(2),
            });
          }
        });

        // Sort subjects alphabetically
        subjects.sort((a, b) => a["code"].compareTo(b["code"]));

        // Compute totals
        final totalScore = subjects.fold<double>(
          0,
              (sum, s) => sum + double.parse(s["mark"]),
        );
        final averageScore = subjects.isNotEmpty
            ? totalScore / subjects.length
            : 0;

        final printer = TranscriptPrinter(
          schoolName: data["school"] ?? "",
          address: data["address"] ?? "Box 5",
          logoAssetLeft: "assets/logo.png",
          logoAssetRight: "assets/logo.png",
          studentName: student,
          programme: data["programme"] ?? "",
          startDate: data["startDate"] ?? "",
          level: data["level"] ?? "",
          term: term,
          gradeInterpretation: gradeInterpretation,
          courses: subjects.map((s) {
            return {
              "code": s["code"],
              "title": s["title"],
              "mark": s["mark"],
            };
          }).toList(),
          totalScore: totalScore.toStringAsFixed(2),
          averageScore: averageScore.toStringAsFixed(2),
        );

        pdf.addPage(await printer.generatePage(PdfPageFormat.a4));
      }

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      throw ("Transcript generation failed: $e");
    }
  }
  Map<String, bool> hasDataCache = {};
  Future<bool> checkHasData(String className, String year, String term) async {
    final key = "${className}_${year}_$term";
    if (hasDataCache.containsKey(key)) return hasDataCache[key]!;
    final snapshot = await db.collection('subjectScoring')
        .where('schoolId', isEqualTo: schoolid)
        .where('academicYear', isEqualTo: year)
        .where('term', isEqualTo: term)
        .where('class', isEqualTo: className)
        .limit(1)
        .get();
    final hasData = snapshot.docs.isNotEmpty;
    hasDataCache[key] = hasData;
    return hasData;
  }
  Future<void> updateSchoolsetting(String year, String term) async {
    try {
      final cleanYear = year.replaceAll('/', '');
      await db.collection('schools').doc(schoolid).update({
        'academicyr': year,
        'academicyrid': cleanYear,
        'term': term,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error updating academic settings: $e");
    }
  }
  bool contestantLoading = false;
  Future<StudentModel?> searchStudent(String studentId) async {
    try {
      searchedStudentModel = null;
      notifyListeners();

      final snap = await db.collection('students').doc(studentId).get();

      if (!snap.exists) {
        searchedStudentModel = null;
        notifyListeners();
        return null;
      }

      // Convert Firestore data to Map
      final data = Map<String, dynamic>.from(snap.data() ?? {});
      data['id'] = data['id'] ?? snap.id;

      // Convert map → StudentModel
      final student = StudentModel.fromMap(data);

      searchedStudentModel = student;

      notifyListeners();
      return student;
    } catch (e) {
      print("Error searching student: $e");
      searchedStudentModel = null;
      notifyListeners();
      return null;
    }
  }
  void clearSearchedStudent() {
    searchedStudentModel = null;
    notifyListeners();
  }
  Future<Map<String, dynamic>> getnextclass({required String currentLevel}) async {
    final settingsSnap = await db.collection("promotion_settings")
        .where("schoolId", isEqualTo: schoolid).limit(1).get();

    if (settingsSnap.docs.isEmpty) {
      return {
        "previous": "",
        "next": "",
      };
    }
    final settings = settingsSnap.docs.first.data();
    final rules = settings["rules"] as List<dynamic>;
    for (var rule in rules) {
      final current = rule["current"]?.toString().trim().toLowerCase() ?? "";
      if (current == currentLevel.trim().toLowerCase()) {
        return {
          "previous": rule["previous"]?.toString() ?? "",
          "next": rule["next"]?.toString() ?? "",
        };
      }
    }
    return {
      "previous": "",
      "next": "",
    };
  }
  Future<void> singlepromotion({ required List<StudentModel> students, required String selectedClass, required String previousClass, required String currentClass, required String nextClass,}) async {
    final batch = db.batch();
    try {
      for (final student in students) {
        final ref = db.collection("students").doc(student.id);

        batch.update(ref, {
          "class": nextClass,
          "previousclass": previousClass,
          "currentclass": currentClass,
          "nextclass": nextClass,
          "level":currentClass,
          "promotiondate": DateTime.now().toString(),
        });
      }

      await batch.commit();

    } catch (e) {
      rethrow;
    }
  }

  List<Map<String, dynamic>> scoredList = [];
  bool isLoadfetchingmark = false;
  fetchScoredMarks() async {
    try {
      isLoadfetchingmark = true;
      notifyListeners();
      await getdata();
      final query = db.collection('subjectScoring')
          .where('term', isEqualTo: term)
          .where('academicYear', isEqualTo: year)
          .where('level', isEqualTo: selectedEntry?['class'])
          .where('teacher.${selectedEntry?['subjectkey']}.tcherid', isEqualTo: staffid);

      final snapshot = await query.get();

      scoredList = snapshot.docs.map((doc) {
        final data = doc.data();

        // Extract subject-specific score section safely
        final subjectKey = selectedEntry?['subjectkey'];
        final subjectScores = (data['scores']?[subjectKey] as Map<String, dynamic>?) ?? {};

        // Sort score fields alphabetically
        final sortedScoresList = subjectScores.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        final sortedScoresMap = Map.fromEntries(sortedScoresList);

        return {
          'id': doc.id,
          'studentName': data['studentName'] ?? '',
          'studentId': data['studentId'] ?? '',
          'level': data['level'] ?? '',
          'photoUrl': data['photourl'] ?? '',
          'scores': sortedScoresMap,
          'totalscore': subjectScores['totalScore']?.toString() ?? '0',
        };
      }).toList();

    } catch (e) {
      print("Error fetching scored marks: $e");
    } finally {
      isLoadfetchingmark = false;
      notifyListeners();
    }
  }
  String studentId = '';
  String studentName = '';
  String className = '';
  String subject = '';
  String photoUrl = '';
  String ca = '';
  String exam = '';
  String total = '';
  String subjectkey = '';
  //String imageUrl = '';
  loadStudentDetails() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      studentId = prefs.getString('studentId') ?? '';
      studentName = prefs.getString('studentName') ?? '';
      className = prefs.getString('class') ?? '';
      subject = prefs.getString('subject') ?? '';
      imageUrl = prefs.getString('studentphoto') ?? '';
      ca = prefs.getString('ca') ?? '';
      exam = prefs.getString('exam') ?? '';
      total = prefs.getString('total') ?? '';
      subjectkey = prefs.getString('subjectkey') ?? '';
      notifyListeners();
    } catch (e) {
      print("Error loading student details: $e");
    }
  }
  clearstudentsdetail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scoringid');
    await prefs.remove('studentId');
    await prefs.remove('studentName');
    await prefs.remove('studentphoto');
    await prefs.remove('pagekey');
    await prefs.remove('scores');

    imageUrl = '';
    notifyListeners();
  }
  studentsdetails(
      String studentId,
      String studentName,
      String className,
      String subject,
      String photoUrl,
      String ca,
      String exam,
      String total,
      String subjectkey,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('studentId', studentId);
      await prefs.setString('studentName', studentName);
      await prefs.setString('class', className);
      await prefs.setString('subject', subject);
      await prefs.setString('studentphoto', photoUrl);
      await prefs.setString('ca', ca);
      await prefs.setString('exam', exam);
      await prefs.setString('total', total);
      await prefs.setString('subjectkey', subjectkey);

      imageUrl = photoUrl;
      notifyListeners();
    } catch (e) {
      print("Error saving student details: $e");
    }
  }
}
