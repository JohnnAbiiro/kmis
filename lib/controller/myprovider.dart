import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ksoftsms/controller/dbmodels/expenseModel.dart';
import 'package:ksoftsms/controller/dbmodels/termmodel.dart';
import 'package:ksoftsms/controller/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/academicyrmodel.dart';
import 'dbmodels/classmodel.dart';
import 'dbmodels/componentmodel.dart';
import 'dbmodels/contestantsmodel.dart';
import 'dbmodels/departmodel.dart';

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

  Future<void> fetchterms() async {
    try {
      loadterms = true;
      notifyListeners();

      final snapshot = await db.collection("terms").get();

      terms = snapshot.docs.map((doc) {
        return TermModel.fromMap(doc.data(), doc.id);
      }).toList();

      loadterms = false;
      print(terms);
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
      final snapshot = await db.collection("department").get();
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
      final snapshot = await db.collection("classes").get();
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
      final snapshot = await db.collection("subjects").get();
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

      final snapshot = await db.collection("students").get();

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
      //final snap = await db.collection('staff').where('schoolId', isEqualTo: schoolid).get();
      final snap = await db.collection('staff').get();
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
      final snap = await db.collection('scoringconfi').get();
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

      //fetch all regions (no restriction)
      QuerySnapshot querySnapshot = await db.collection("regions").get();

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
          .collection("assesscomponent")
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
          .collection("teacherSetup")
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
      final docRef = FirebaseFirestore.instance
          .collection('assesscomponent')
          .doc(id);

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

      // Map teachers to info for easy reporting
      final teacherInfo = {
        for (final t in teacherIds)
          t.id ?? t.email: {
            "tcherid": t.id ?? "",
            "tchername": t.name,
            "tcheremail": t.email,
            "schoolId": t.schoolId,
            "school": t.schoolname,
          }
      };
      // Fetch all students in selected classes
      final studentSnap = await db
          .collection("students")
          .where("schoolId", isEqualTo: schoolId)
          .where("level", whereIn: classNames)
          .get();

      for (final studentDoc in studentSnap.docs) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        final studentId = studentDoc.id;
        final studentClass = studentData['level'] ?? '';

        if (!classNames.contains(studentClass)) continue;
        // subject scaffolding
        final Map<String, dynamic> subjectMap = {};
        final Map<String, String> scoredFlags = {};
        final Map<String, String> totalScores = {};

        for (final subject in subjects) {
          final scoring = SubjectScoring.create(
            studentId: studentId,
            studentName: studentData['name'] ?? '',
            academicYear: academicYear,
            term: term,
            staff: name,
            classes: studentClass,
            teacher: '',
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
          );
          subjectMap[subject.id] = {
            ...scoring.subjectData[subject.id],
            "teachers": teacherInfo,
          };
        }

        final scoringId = "${studentId}_${academicYear}_$term";
        final scoringRef = db.collection("subjectScoring").doc(scoringId);
        final scoringData = {
          "studentId": studentId,
          "studentName": studentData['name'] ?? '',
          "academicYear": academicYear,
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
        final classesMap = classes.map((s) => ClassModel(id: s.id,name: s.name, department: s.department,staff: s.staff)).toList();
        final componentsMap = components.map((s) => ComponentModel(id: s.id,name: s.name, staff: s.staff, schoolId: s.schoolId, totalMark: s.totalMark, type: '',)).toList();
        final subjectsList = subjects.map((s) => SubjectModel(id: s.id,name: s.name,)).toList();

        final teacherSetup = TeacherSetup(
          staffid: teacher.id ?? teacher.email,
          staffname: teacher.name,
          classname: classesMap,
          schoolId: schoolId,
          academicyear: academicYear,
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
  Future<void> deleteteacher(String staffId) async { const teachersetupColl = 'teachersetup';    const subjectScoringColl = 'subjectScoring';
    final teachersetupDocId = '${staffId}_${academicyrid}_$term';
    final setupRef = db.collection(teachersetupColl).doc(teachersetupDocId);
   print(teachersetupDocId);
    try {
      // 1) Read teacher setup
      final setupSnap = await setupRef.get();
      if (!setupSnap.exists) {
        debugPrint('No teachersetup found: $teachersetupDocId');
        return;
      }
      final Map<String, dynamic> setupData =
      setupSnap.data()! as Map<String, dynamic>;

      // 2) Extract subjects and classes from setup
      final List<String> subjectIds = (setupData['subjects'] as List<dynamic>?)
          ?.map((s) {
        final m = s as Map<String, dynamic>;
        return (m['id'] ?? m['subjectId'] ?? m['name'] ?? '').toString();
      })
          .where((id) => id.isNotEmpty)
          .toList() ??
          [];

      final List<String> classes = (setupData['classname'] as List<dynamic>?)
          ?.map((c) {
        if (c is String) return c;
        if (c is Map && c['name'] != null) return c['name'].toString();
        return c.toString();
      })
          .toList() ??
          [];

      if (subjectIds.isEmpty) {
        debugPrint('No subjects found in teachersetup $teachersetupDocId — nothing to clean.');
      }
      final int chunkSize = 10;
      final List<List<String>> classChunks = [];
      for (var i = 0; i < classes.length; i += chunkSize) {
        classChunks.add(classes.sublist(
          i,
          i + chunkSize > classes.length ? classes.length : i + chunkSize,
        ));
      }


      final List<QueryDocumentSnapshot<Map<String, dynamic>>> scoringDocs = [];

      for (final chunk in classChunks.isNotEmpty ? classChunks : [<String>[]]) {
        Query<Map<String, dynamic>> q = db
            .collection(subjectScoringColl)
            .withConverter<Map<String, dynamic>>(
            fromFirestore: (s, _) => s.data() ?? <String, dynamic>{},
            toFirestore: (m, _) => m);

        q = q.where('schoolId', isEqualTo: schoolid)
            .where('academicYear', isEqualTo: academicyrid)
            .where('term', isEqualTo: term);

        if (chunk.isNotEmpty) {
          q = q.where('class', whereIn: chunk);
        }

        final snap = await q.get();
        scoringDocs.addAll(snap.docs);
      }

      final List<Map<String, String>> conflicts = [];
      bool _hasMarksInSubjectMap(Map<String, dynamic> subj) {
        bool notZero(dynamic v) {
          if (v == null) return false;
          final s = v.toString().trim();
          if (s.isEmpty) return false;
          if (s == '0' || s == '0.0' || s == '0.00') return false;
          return true;
        }

        if (notZero(subj['CA']) ||
            notZero(subj['Exams']) ||
            notZero(subj['CAtotal']) ||
            notZero(subj['examstotal']) ||
            notZero(subj['totalScore']) ||
            notZero(subj['rawCA']) ||
            notZero(subj['rawExams'])) {
          return true;
        }

        if (subj['scores'] is Map) {
          final scoresMap = subj['scores'] as Map;
          for (final v in scoresMap.values) {
            if (notZero(v)) return true;
          }
        }
        final status = subj['status']?.toString().toLowerCase();
        if (status != null && status.isNotEmpty && status != 'pending' && status != 'no') {
          return true;
        }
        return false;
      }

      for (final doc in scoringDocs) {
        final data = doc.data();
        final subjectsMap = (data['subjects'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        for (final subId in subjectIds) {
          if (!subjectsMap.containsKey(subId)) continue;
          final subjRaw = subjectsMap[subId];
          if (subjRaw == null) continue;
          if (subjRaw is! Map) continue;
          final Map<String, dynamic> subj = Map<String, dynamic>.from(subjRaw);
          if (_hasMarksInSubjectMap(subj)) {
            conflicts.add({
              'docId': doc.id,
              'studentId': data['studentId']?.toString() ?? '',
              'studentName': data['studentName']?.toString() ?? '',
              'subjectId': subId,
              'subjectName': subj['subjectName']?.toString() ?? '',
            });

          }
        }
      }
      if (conflicts.isNotEmpty) {
        // Abort: found scores — do not delete anything
        final example = conflicts.take(5).map((c) => '${c['studentName']}:${c['subjectId']}').join(', ');
        throw StateError(
            'Cannot delete teacher/setup — found existing scores for subjects. Example: $example. '
                'Found ${conflicts.length} scoring entries.');
      }
      WriteBatch batch = db.batch();
      int pendingWrites = 0;
      Future<void> _commitBatchIfNeeded() async {
        if (pendingWrites > 0) {
          await batch.commit();
          pendingWrites = 0;
          batch = db.batch();
        }
      }
      for (final doc in scoringDocs) {
        final data = doc.data();
        final subjectsMap = (data['subjects'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final Map<String, dynamic> updates = <String, dynamic>{};
        for (final subId in subjectIds) {
          if (subjectsMap.containsKey(subId)) {
            updates['subjects.$subId'] = FieldValue.delete();
          }
        }
        if (data['teachers'] is List) {
          final List<dynamic> teachersList = List<dynamic>.from(data['teachers'] as List<dynamic>);
          final newTeachers = teachersList.where((t) {
            if (t is Map) {
              final id = t['id']?.toString();
              final tTerm = t['term']?.toString();
              return !(id == staffId && (tTerm == null || tTerm == term || tTerm == term));
            }
            return true;
          }).toList();

          if (newTeachers.length != teachersList.length) {
            updates['teachers'] = newTeachers;
          }
        }
        if (updates.isNotEmpty) {
          batch.update(doc.reference, updates);
          pendingWrites++;
          if (pendingWrites >= 450) {
            await _commitBatchIfNeeded();
          }
        }
      }
      // commit any remaining student updates
      await _commitBatchIfNeeded();
      await setupRef.delete();
      debugPrint('deleteTeacherAndCleanup: completed for $teachersetupDocId (teacher $staffId)');
    } catch (e, st) {
      debugPrint('deleteTeacherAndCleanup error: $e\n$st');
      rethrow;
    }
  }

  bool isloadac =false;
  List<Map<String, dynamic>> marksList = [];
  bool isloadscore=false;
  Future<void> fetchStaffScoringMarks({required String className,required String subjectKey,required String teacherId,}) async {
    await getdata();
    isloadscore = true;
    notifyListeners();

    try {
      final snap = await db
          .collection('subjectScoring')
          .where('academicYear', isEqualTo: "20242025")
          .where('term', isEqualTo: "First")
          .where('class', isEqualTo: className)
          .where('schoolId', isEqualTo: schoolid)
          .get();

      marksList = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final id = doc.id;


        final subjects = Map<String, dynamic>.from(data['subjects'] ?? {});


        Map<String, dynamic> subjectData = {};
        if (subjects.containsKey(subjectKey)) {
          subjectData = Map<String, dynamic>.from(subjects[subjectKey] ?? {});
        } else {
          for (final v in subjects.values) {
            if (v is Map) {
              final name = (v['subjectName'] ?? v['name'] ?? '').toString();
              if (name.toLowerCase() == subjectKey.toLowerCase()) {
                subjectData = Map<String, dynamic>.from(v);
                break;
              }
            }
          }
        }
        if (subjectData.isEmpty) {
          print("$id skipped: subject '$subjectKey' not found");
          return null;
        }
        final subjTeachers = Map<String, dynamic>.from(subjectData['teachers'] ?? {});
        Map<String, dynamic> teacherData = {};
        if (subjTeachers.containsKey(teacherId)) {
          teacherData = Map<String, dynamic>.from(subjTeachers[teacherId] ?? {});
        } else {
          for (final v in subjTeachers.values) {
            if (v is Map && v['tcherid'] == teacherId) {
              teacherData = Map<String, dynamic>.from(v);
              break;
            }
          }
        }


        if (teacherData.isEmpty) {
          final topTeachers = Map<String, dynamic>.from(data['teachers'] ?? {});
          if (topTeachers.containsKey(teacherId)) {
            teacherData = Map<String, dynamic>.from(topTeachers[teacherId] ?? {});
          } else {
            for (final v in topTeachers.values) {
              if (v is Map && v['tcherid'] == teacherId) {
                teacherData = Map<String, dynamic>.from(v);
                break;
              }
            }
          }
        }

        if (teacherData.isEmpty) {
          return null;
        }
        // scores ---
        final scores = Map<String, dynamic>.from(subjectData['scores'] ?? {});
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
          'teacherId': teacherData['tcherid'] ?? '',
          'teacherName': teacherData['tchername'] ?? '',
          'teacherEmail': teacherData['tcheremail'] ?? '',
          'subject': subjectData['subjectName'] ?? subjectData['name'] ?? '',
          'subjectId': subjectData['subjectId'] ?? subjectData['id'] ?? subjectKey,
          'term': data['term'] ?? '',
          'academicyrid': data['academicYear'] ?? academicyrid,
          'department': data['department'] ?? '',
          'level': data['level'] ?? '',
        };
      }).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      print("fetchStaffScoringMarks error: $e");
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
 /* Future<void> saveStudentMarks({
    required String studentId,
    required String subject,
    required String ca,
    required String exams,
    required String total,
    required String caConverted,
    required String examConverted,
    required String subjectkey,
    required String studentid,

    required String grade,
    required String remark,
    String? caw,
    String? examsw,
    String? maxca,
    String? maxexams,
    String? department,
  }) async { try {
      //student subject record

    final studentDocRef = db
        .collection("subjectScoring")
        .doc(academicYearId)
        .collection(term)
        .doc(studentId);

// 👇 Correct structure for nested subject update
    final studentData = {
      "subjects.$subjectId": {
        "CA": ca.toString(),
        "CAtotal": continuousWeight.toString(),
        "Exams": exams.toString(),
        "examstotal": examWeight.toString(),
        "rawCA": caConverted.toStringAsFixed(2),
        "rawExams": examConverted.toStringAsFixed(2),
        "grade": grade ?? "",
        "remark": remark ?? "",
        "maxca": maxContinuous.toString(),
        "maxexams": maxExam.toString(),
        "caw": continuousWeight.toString(),
        "examsw": examWeight.toString(),
        "scored": "yes",
      },
      "scores": {
        "CA": ca.toString(),
        "Exams": exams.toString(),
        "totalScore": total.toStringAsFixed(2),
        "status": "completed",
        "subjectId": subjectId,
        "subjectName": subject,
        "timestamp": FieldValue.serverTimestamp(),
      }
    };

// ✅ Use update() so it only modifies existing keys (will fail if doc/field doesn’t exist)
    await studentDocRef.update(studentData);

    //Update teacher totals
     /* final id ="${schoolid}_${academicyrid}_$term";
      final teacherDocRef = db.collection("teacherSetup").doc(id);
      await teacherDocRef.set({
        schoolid: {
          "id": schoolid,
          "name": name,
          "term": term,
          "yeargroup": academicYearId,
          "total$subjectId": total,
          "timestamp": FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
      */
    }
    catch (e) {
      throw Exception("Error saving marks: $e");
    }
  }*/
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
      savemarks =true;
      notifyListeners();
      final studentid = "${studentId}_${academicyrid}_$term";
      final studentDocRef = db
          .collection("subjectScoring")
          .doc(studentid);

      //update this student's subject record
      final studentData = {
        "subjects.$subjectId": {
          "CA": ca,
          "CAtotal": caw ?? "0",
          "Exams": exams,
          "examstotal": examsw ?? "0",
          "rawCA": caConverted,
          "rawExams": examConverted,
          "grade": grade,
          "remark": remark,
          "maxca": maxca ?? "0",
          "maxexams": maxexams ?? "0",
          "caw": caw ?? "0",
          "examsw": examsw ?? "0",
          "scored": "yes",
        },
        "scores": {
          "CA": ca,
          "Exams": exams,
          "totalScore": total,
          "status": "completed",
          "subjectId": subjectId,
          "subjectName": subjectName,
          "timestamp": FieldValue.serverTimestamp(),
        }
      };

     // await studentDocRef.set(studentData, SetOptions(merge: true));
      await studentDocRef.update(studentData);

      //all students are scored for this subject
      final subjectQuery = await db
          .collection("subjectScoring")
          .where("subjects.$subjectId.scored", isEqualTo: "no")
          .get();

      final allScored = subjectQuery.docs.isEmpty;

      if (allScored) {
        //Mark teacherSetup subject complete
        final teacherSetupId = "${teacherId}_${academicyrid}_$term";
        final teacherDocRef = db.collection("teacherSetup").doc(teacherSetupId);
        await teacherDocRef.update({
          "subjects.$subjectId.isComplete": "yes",
          "subjects.$subjectId.timestamp": FieldValue.serverTimestamp(),
        });
      }
      savemarks =false;
      notifyListeners();
    } catch (e) {
      throw Exception("Error saving marks: $e");
    }
  }


}
