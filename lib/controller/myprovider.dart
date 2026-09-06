import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ksoftsms/controller/dbmodels/expenseModel.dart';
import 'package:ksoftsms/controller/dbmodels/facultymodel.dart';
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
  List<FacultyModel> faculties = [];
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
  bool hassubjectkey = false;
  bool loadacademicyear =false;
  XFile? imagefile;
  String imageUrl = "";
  String department = "";
  List<TeacherSetup> teacherSetupList = [];
  bool isLoadingTeacherList = false;
  DocumentSnapshot? firstTeacherDocument;
  DocumentSnapshot? lastTeacherDocument;
  List<ScoremodelConfig> scoreConfigList = [];
  StudentModel? searchedStudentModel;
  Map<String, dynamic>? selectedGradingSystem={};
  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('themeMode') ?? ThemeMode.light.index;
    _themeMode = ThemeMode.values[index];
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  loadSelectedGradingSystem({required String level}) async {
    try {
      final snapshot = await db
          .collection('assessmentSystems')
          .doc(level)
          .get();

      if (snapshot.exists) {
        selectedGradingSystem =
        snapshot.data() as Map<String, dynamic>;
      } else {
        selectedGradingSystem = null;
        debugPrint("No grading system found for level: $level");
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading grading system: $e");
    }
  }



  // Get existing marks
  Future<Map<String, dynamic>?> getExistingMarks({
    required String studentId,
    required String assessmentType,
  }) async {
    final snapshot = await db.collection('studentMarks')
        .where('studentId', isEqualTo: studentId)
        .where('assessmentType', isEqualTo: assessmentType)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  // Save assessment marks
  Future<void> saveAssessmentMarks(Map<String, dynamic> marksData) async {
    await db.collection('studentMarks').add(marksData);
  }

  // Update student marks
  Future<void> updateStudentMarks({
    required String assessmentType,
    required double marks,
  }) async {
    // Update the main marks record
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
  bool loadfaculty =false;
  Future<void> fetchFaculty() async {
    try {
      loadfaculty = true;
      notifyListeners();
      final snapshot = await db.collection("faculties").where("schoolId", isEqualTo: schoolid).get();
      faculties = snapshot.docs.map((doc) {
        return FacultyModel.fromMap(doc.data(), doc.id);
      }).toList();

      loadfaculty = false;
      notifyListeners();
    } catch (e) {
      loadfaculty = false;
      notifyListeners();
      print("Failed to fetch faculties: $e");
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
    Future<void> deleteFaculties(String id) async {
    await db.collection('faculties').doc(id).delete();
    faculties.removeWhere((c) => c.id == id);
    notifyListeners();
  }
  Future<void> deleteDepartment(String id) async {
    await db.collection('department').doc(id).delete();
    departments.removeWhere((c) => c.id == id);
    notifyListeners();
  }
  Future<void> deleteClass(String id) async {
    await db.collection('classes').doc(id).delete();
    classdata.removeWhere((c) => c.id == id);
    notifyListeners();
  }
  Future<void> deleteSubject(String id) async {
    await db.collection('subjects').doc(id).delete();
    subjectList.removeWhere((c) => c.id == id);
    notifyListeners();
  }
  Future<void> deleteStudents(String id) async {
    await db.collection('students').doc(id).delete();
    studentlist.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> deleteAcademicyr(String id) async {
    await db.collection('academicyears').doc(id).delete();
    academicyears.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> deleteTerms(String id) async {
    await db.collection('terms').doc(id).delete();
    terms.removeWhere((c) => c.id == id);
    notifyListeners();
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




  Future<Map<String, dynamic>?> fetchGradingSystem(String schoolId, {String? department}) async {
    try {
      final deptId = department != null
          ? "${schoolId}_${department.toLowerCase()}"
          : "${schoolId}_default";


      final deptDoc = await db.collection("gradingsystems").doc(deptId).get();
      if (deptDoc.exists) {
        return deptDoc.data();
      }


      final defaultDoc = await db.collection("gradingsystems").doc("${schoolId}_default").get();
      if (defaultDoc.exists) {
        return defaultDoc.data();
      }

      throw Exception("No grading system found for $schoolId");
    } catch (e) {
      throw Exception("Error fetching grading system: $e");
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
  void upsertIdFormat(IdformatModel model) {
    final index = idFormats.indexWhere((f) => f.id == model.id);
    if (index != -1) {
      idFormats[index] = model;
    } else {
      idFormats.add(model);
    }
    notifyListeners();
  }
  void upsertAcademicYear(AcademicModel model) {
    final index = academicyears.indexWhere((y) => y.id == model.id);
    if (index != -1) {
      academicyears[index] = model;
    } else {
      academicyears.add(model);
    }
    notifyListeners();
  }
  Map<String, dynamic>? selectedEntry ={};
  void upsertClass(ClassModel model) {
    final index = classdata.indexWhere((c) => c.id == model.id);
    if (index != -1) {
      classdata[index] = model;
    } else {
      classdata.add(model);
    }
    notifyListeners();
  }
  void upsertDepartment(DepartmentModel model) {
    final index = departments.indexWhere((c) => c.id == model.id);
    if (index != -1) {
      departments[index] = model;
    } else {
      departments.add(model);
    }
    notifyListeners();
  }

  void upsertFaculty(FacultyModel model) {
    final index = faculties.indexWhere((c) => c.id == model.id);
    if (index != -1) {
      faculties[index] = model;
    } else {
      faculties.add(model);
    }
    notifyListeners();
  }
  void upsertStudent(StudentModel model) {
    final index = studentlist.indexWhere((s) => s.id == model.id);
    if (index != -1) {
      studentlist[index] = model;
    } else {
      studentlist.add(model);
    }
    notifyListeners();
  }
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
  String assessmentType = '';
  //String imageUrl = '';


   saveAssessmentData(Map<String, dynamic> assessmentData) async {
    try {
      final String student = "$schoolid ${assessmentData['studentId']} $year $term";
      final String studentId = normalizeAndSanitize(student);
      final DocumentReference docRef =
      db.collection('assessments').doc(studentId);
      await docRef.set(assessmentData, SetOptions(merge: true));

      print("Assessment saved successfully for student $studentId!");
    } catch (e) {
      print("Error saving assessment: $e");
    }
  }


  updateStudentAssessmentData(String studentId, String subjectKey) async {
    try {
      final DocumentReference docRef = db.collection('students').doc(studentId);
      await docRef.set({
        'assessmentData': FieldValue.arrayUnion([subjectKey])
      }, SetOptions(merge: true));

      print("Assessment updated successfully for student $studentId! and key $subjectKey");
    } catch (e) {
      print("Error saving assessment: $e");
    }
  }


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
      assessmentType = prefs.getString('assessmentType') ?? '';
      notifyListeners();
      print("Student details loaded successfully.$assessmentType");
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
    await prefs.remove('scores');
    await prefs.remove('assessmentType');
    await prefs.remove('department');
    await prefs.remove('hassubjectkey');

    studentId='';
    studentName = '';
    className = '';
    subject = '';
    ca = '';
    exam = '';
    total = '';
    subjectkey = '';
    assessmentType = '';

    imageUrl = '';
    notifyListeners();
  }
  studentsdetails(
      String studentId,
      String studentName,
      String className,
      String department,
      bool   hassubjectkey,
      String subject,
      String photoUrl,
      String total,
      String subjectkey,
      String assessmentType,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('studentId', studentId);
      await prefs.setString('studentName', studentName);
      await prefs.setString('class', className);
      await prefs.setString('department', department);
      await prefs.setBool('hassubjectkey', hassubjectkey);
      await prefs.setString('subject', subject);
      await prefs.setString('studentphoto', photoUrl);
      await prefs.setString('total', total);
      await prefs.setString('subjectkey', subjectkey);
      await prefs.setString('assessmentType', assessmentType);
      imageUrl = photoUrl;
      notifyListeners();
    } catch (e) {
      print("Error saving student details: $e");
    }
  }


  void upsertSubjectLocal(SubjectModel subject) {
    final index = subjectList.indexWhere((s) => s.id == subject.id);
    if (index >= 0) {
      subjectList[index] = subject;
    } else {
      subjectList.add(subject);
    }
    notifyListeners();
  }

  void removeSubjectLocal(String id) {
    subjectList.removeWhere((s) => s.id == id);
    notifyListeners();
  }
  void removeAcademicYear(String id) {
    academicyears.removeWhere((y) => y.id == id);
    notifyListeners();
  }

  void upsertTerm(TermModel term) {
    final index = terms.indexWhere((t) => t.id == term.id);
    if (index == -1) {
      terms.add(term);
    } else {
      terms[index] = term;
    }
    notifyListeners();
  }
  void removeTerm(String id) {
    terms.removeWhere((t) => t.id == id);
    notifyListeners();
  }
  void removeDepartment(String id) {
    departments.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void removeClass(String id) {
    classdata.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  bool get canManageSetupLock {
    final r = staffaccesslevel;

    return r == 'superadmin' ||
        r == 'super admin' ||
        r == 'admin' ||
        r == 'academic';
  }


  Future<bool> getSetupLockStatus() async {
    if (schoolid.trim().isEmpty) return false;

    final doc = await db
        .collection('schools')
        .doc(schoolid.trim())
        .get();

    if (!doc.exists) return false;

    final data = doc.data();

    return data?['setupCompleted'] == true;
  }


  Future<bool> setSetupLock(bool locked) async {
    if (!canManageSetupLock) {
      throw Exception(
        'You do not have permission to lock or unlock the school setup.',
      );
    }

    final id = schoolid.trim();

    if (id.isEmpty) {
      throw Exception('School ID is empty.');
    }

    await db.collection('schools').doc(id).set({
      'setupCompleted': locked,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return locked;
  }
}
