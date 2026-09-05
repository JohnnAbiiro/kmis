

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ksoftsms/controller/dbmodels/SupplierModel.dart';
import 'package:ksoftsms/controller/dbmodels/accountsModel.dart';
import 'package:ksoftsms/controller/dbmodels/activityModel.dart';
import 'package:ksoftsms/controller/dbmodels/billedModel.dart';
import 'package:ksoftsms/controller/dbmodels/contestantsmodel.dart';
import 'package:ksoftsms/controller/dbmodels/feeSetUpModel.dart';
import 'package:ksoftsms/controller/dbmodels/iteRegModel.dart';
import 'package:ksoftsms/controller/dbmodels/paymentMethodsModel.dart';
import 'package:ksoftsms/controller/dbmodels/singleBilledModel.dart';
import 'package:ksoftsms/controller/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dbmodels/expenseModel.dart';
import 'dbmodels/feePaymentModel.dart';
import 'dbmodels/schoolmodel.dart';
import 'dbmodels/staffmodel.dart';

class LoginProvider extends ChangeNotifier {
  String today = DateFormat("MMMM d, y").format(DateTime.now());
  List<String> staffSchoolIds = [];
  List<String> schoolnames = [];
  List<SchoolModel> schoolList = [];
  List<Staff> staffschools = [];

  List<Staff> stafflist = [];
  List<SupplierModel> supplierlist = [];
  List<ExpenseModel> expenselists = [];
  List<FeePaymentModel> feepaymentlist = [];
  List<SingleBilledModel> singlebilledlist = [];
  List<BilledModel> billedlist = [];
  List<ActivityModel> activitylist = [];
  List<CoaModel> accountlist = [];
  List<ItemRegModel> itemreglist = [];
  List<Map<String, dynamic>> accountantSummaryList = [];

  List<String> staffaccesslevel = [
    "admin",
    "super admin",
    "academic",
    "hod",
    "tutor",
    "student",
    "teacher",
    "head teacher",
    "accountant",
    "admissions officer",
    "store officer",
  ];
  List<StudentModel> selectedStudents = [];
  List<ExpenseModel> expenselist = [];
  List<SupplierModel> supplierList = [];
  List<StudentModel> searchResults = [];
  List<Map<String, String>> linkedAccounts = [];
  Map<String, dynamic> receiptrecords = {};
  final numberFormat = NumberFormat("#,##0.00", "en_US");
  String currentschool = "";
  Staff? usermodel;
  String schoolid = "";
  String staffid = "";
  String region = "";
  String createddate = "";
  String accesslevel = "";
  //String schoolType = "Pre-tertiary";
  String schoolType = "tertiary";
  String departmentId = "";

  bool get isSuperAdmin => accesslevel.trim().toLowerCase() == 'super admin';
  bool get isAdmin => accesslevel.trim().toLowerCase() == 'admin';
  bool get isAcademic => accesslevel.trim().toLowerCase() == 'academic';
  bool get isHod => accesslevel.trim().toLowerCase() == 'hod';
  bool get isTutor => accesslevel.trim().toLowerCase() == 'tutor';
  bool get isStudent => accesslevel.trim().toLowerCase() == 'student';
  String phone = "";
  String name = "";
  String year = "";
  String academicyrid = "";
  String term = "";
  String email = "";
  String errorMessage = "";
  int staffcount_in_school = 0;
  String schooldomain = "kologsoftsmiscom.com";
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  List<String> accounts = [];
  List<String> currentaccounts = [];
  List<String> accountclass = [];
  List<FeeSetUpModel> fees = [];
  List<PaymentMethodModel> paymethodlist = [];
  String receiptno = "";
  String status = "";
  List<String> accountsubclass = [];
  String receiptName = "";
  String receiptpaymentmethod = "";
  String receiptdate = "";

  String receiptnote = "";
  String receipt = "";
  double receiptTotal = 0;
  double outstandingBalance = 0;
  double totalBilled = 0;
  double totalPaid = 0;

  String normalizeAndSanitize(dynamic value) {
    if (value == null) return "n_a";

    String result = value.toString().trim();

    if (result.isEmpty) return "n_a";

    result = result
        .replaceAll('/', '_')
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

    result = result.toLowerCase();

    return result.isNotEmpty ? result : "n_a";
  }

  List<Map<String, dynamic>> assignedList = [];

  //  login(String email, String password, BuildContext context) async {
  //   try {
  //     final loginhere = await auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //
  //     if (loginhere.user != null) {
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('useremail', email);
  //       final detail = await db.collection("staff").where('email', isEqualTo: email).get();
  //       int numberofdocs = detail.docs.length;
  //       final userData = detail.docs.first.data();
  //       usermodel = Staff.fromMap(userData, detail.docs.first.id);
  //       String emailTxt = usermodel?.email ?? '';
  //       String nameTxt = usermodel?.name ?? '';
  //       String roleTxt = usermodel?.accessLevel ?? '';
  //       String phoneTxt = usermodel?.phone ?? '';
  //       String schoolTxt = usermodel?.schoolname ?? '';
  //       String scchoolIdTxt = usermodel?.schoolId ?? '';
  //
  //       prefs.setString("school", schoolTxt);
  //       prefs.setString("email", emailTxt);
  //       prefs.setString("name", nameTxt);
  //       prefs.setString("role", roleTxt);
  //       prefs.setString("phone", phoneTxt);
  //       prefs.setString("schoolid", scchoolIdTxt);
  //       await fetchtermyear(scchoolIdTxt, prefs);
  //       if (numberofdocs > 1) {
  //         staffschools = detail.docs.map((doc) {
  //           return Staff.fromMap(doc.data(), doc.id);
  //         }).toList();
  //         prefs.setStringList("staffschools", staffschools.map((e) => e.schoolId).toList());
  //         prefs.setStringList("schoolnames", staffschools.map((e) => e.schoolname).toList());
  //         await getdata();
  //         Navigator.pushNamed(context, Routes.nextpage);
  //         notifyListeners();
  //       }
  //
  //       else {
  //         await getdata();
  //         auth.currentUser!.updateDisplayName(nameTxt);
  //         Navigator.pushNamed(context, Routes.dashboard);
  //         notifyListeners();
  //       }
  //
  //       //useremail=email;
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     errorMessage=e.toString();
  //
  //     print(e);
  //   }
  // }
  login(String email, String password, BuildContext context) async {
    try {
      final loginhere = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (loginhere.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('useremail', email);

        final detail = await db
            .collection("staff")
            .where('email', isEqualTo: email)
            .get();
        int numberofdocs = detail.docs.length;

        if (numberofdocs == 0) {
          throw ("No staff data found for this email.");
        }

        final userData = detail.docs.first.data();
        usermodel = Staff.fromMap(userData, detail.docs.first.id);

        String emailTxt = usermodel?.email ?? '';
        String nameTxt = usermodel?.name ?? '';
        String roleTxt = usermodel?.accessLevel ?? '';
        String phoneTxt = usermodel?.phone ?? '';
        String schoolTxt = usermodel?.schoolname ?? '';
        String schoolIdTxt = usermodel?.schoolId ?? '';
        String IdTxt = usermodel?.id ?? '';
        createddate = usermodel?.createdAt != null
            ? usermodel!.createdAt.toIso8601String()
            : '';
        region = usermodel?.region ?? '';
        departmentId =
            userData["departmentId"]?.toString() ??
                userData["departmentid"]?.toString() ??
                "";

        await Future.wait([
          prefs.setString("school", schoolTxt),
          prefs.setString("email", emailTxt),
          prefs.setString("name", nameTxt),
          prefs.setString("role", roleTxt),
          prefs.setString("accessLevel", roleTxt),
          prefs.setString("phone", phoneTxt),
          prefs.setString("schoolid", schoolIdTxt),
          prefs.setString("staffid", IdTxt),
          prefs.setString("createddate", createddate),
          prefs.setString("region", region),
          prefs.setString("departmentId", departmentId),
        ]);

        try {
          var schoolSnapshot = await db
              .collection("schools")
              .doc(schoolIdTxt)
              .get();
          if (!schoolSnapshot.exists && schoolIdTxt.isNotEmpty) {
            final schoolQuery = await db
                .collection("schools")
                .where("schoolid", isEqualTo: schoolIdTxt)
                .limit(1)
                .get();
            if (schoolQuery.docs.isNotEmpty) {
              schoolSnapshot = schoolQuery.docs.first;
            }
          }
          if (schoolSnapshot.exists) {
            final data = schoolSnapshot.data() as Map<String, dynamic>;
            final String termTxt = data["term"]?.toString() ?? "";
            final String yearTxt = data["academicyr"]?.toString() ?? "";
            final String academicyridTxt =
                data["academicyrid"]?.toString() ?? "";
            final String schoolTypeTxt =
                data["type"]?.toString() ?? "Pre-tertiary";
            final String schoolNameTxt =
                data["schoolname"]?.toString() ?? schoolTxt;

            await Future.wait([
              prefs.setString("school", schoolNameTxt),
              prefs.setString("term", termTxt),
              prefs.setString("year", yearTxt),
              prefs.setString("academicyrid", academicyridTxt),
              prefs.setString("staffkey", academicyridTxt),
              prefs.setString("schoolType", schoolTypeTxt),
            ]);
            schoolTxt = schoolNameTxt;
            currentschool = schoolNameTxt;
            schoolType = schoolTypeTxt;
            term = termTxt;
            year = yearTxt;
            academicyrid = academicyridTxt;
            notifyListeners();
          } else {
            debugPrint(
              "Firestore returned NO DOCUMENT for schoolId: $schoolIdTxt",
            );
          }
        } catch (e) {
          debugPrint("ERROR fetching academic term/year: $e");
        }

        if (numberofdocs > 1) {
          // Staff belongs to multiple schools
          staffschools = detail.docs.map((doc) {
            return Staff.fromMap(doc.data(), doc.id);
          }).toList();
          await prefs.setStringList(
            "staffschools",
            staffschools.map((e) => e.schoolId).toList(),
          );
          await prefs.setStringList(
            "schoolnames",
            staffschools.map((e) => e.schoolname).toList(),
          );

          await getdata();
          context.go(Routes.nextpage);
        } else {
          // Single school
          await prefs.remove("staffschools");
          await prefs.remove("schoolnames");
          await getdata();
          await auth.currentUser!.updateDisplayName(nameTxt);
          final normalizedRole = roleTxt.trim().toLowerCase();
          if (normalizedRole == 'teacher' ||
              normalizedRole == 'tutor' ||
              normalizedRole == 'staff-tutor') {
            context.go(Routes.staffhome);
          } else {
            context.go(Routes.dashboard);
          }
        }

        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      print(e);
    }
  }

  getdata() async {
    final prefs = await SharedPreferences.getInstance();
    schoolid = prefs.getString('schoolid') ?? '';
    staffid = prefs.getString('staffid') ?? '';
    region = prefs.getString('region') ?? '';
    createddate = prefs.getString('createddate') ?? '';
    currentschool = prefs.getString('school') ?? '';
    phone = prefs.getString('phone') ?? '';
    email = prefs.getString('email') ?? '';
    accesslevel = prefs.getString('role') ?? '';
    if (accesslevel.isEmpty) {
      accesslevel = prefs.getString('accessLevel') ?? '';
    }
    schoolType = prefs.getString('schoolType') ?? 'Pre-tertiary';
    departmentId = prefs.getString('departmentId') ?? '';
    name = prefs.getString('name') ?? '';
    year = prefs.getString('year') ?? '';
    academicyrid = prefs.getString('academicyrid') ?? '';
    term = prefs.getString('term') ?? '';
    staffSchoolIds = prefs.getStringList("staffschools") ?? [];
    schoolnames = prefs.getStringList("schoolnames") ?? [];
    receiptno = prefs.getString("receiptno") ?? "";
    notifyListeners();
  }

  Future<void> fetchAssignedCourses() async {
    await getdata();
    if (schoolid.isEmpty || staffid.isEmpty) {
      assignedList = [];
      notifyListeners();
      return;
    }
    try {
      final snapshot = await db
          .collection('teacherSetup')
          .where('schoolId', isEqualTo: schoolid)
          .where('staffid', isEqualTo: staffid)
          .get();
      final assignments = <Map<String, dynamic>>[];
      for (final document in snapshot.docs) {
        final data = document.data();
        final subjects = data['subjects'];
        final classes = data['classname'];
        final subjectEntries = subjects is Map ? subjects.values : const [];
        final classEntries = classes is Map ? classes.values : const [];
        for (final subject in subjectEntries) {
          if (subject is! Map) continue;
          for (final schoolClass in classEntries) {
            if (schoolClass is! Map) continue;
            assignments.add({
              'subject': subject['name'] ?? subject['id'] ?? '',
              'subjectId': subject['id'] ?? '',
              'class': schoolClass['name'] ?? '',
              'department': schoolClass['department'] ?? '',
              'academicYear': data['academicyear'] ?? year,
              'term': data['term'] ?? term,
              'setupId': document.id,
            });
          }
        }
      }
      assignedList = assignments;
    } catch (error) {
      debugPrint('Unable to load assigned courses: $error');
      assignedList = [];
    }
    notifyListeners();
  }

  setSchool(String school, String schoolid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("school", school);
      await prefs.setString("schoolid", schoolid);
    } catch (e) {
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  staffcount() async {
    await getdata();
    try {
      print(schoolid);
      final detail = await db
          .collection("staff")
          .where('schoolId', isEqualTo: schoolid)
          .get();
      int numberofdocs = detail.docs.length;
      staffcount_in_school = numberofdocs;
      print(numberofdocs);
    } catch (e) {
      print(e);
      return 0;
    }
  }

  fetchStaff() async {
    try {
      final snapshot = await db
          .collection('staff')
          .where('schoolId', isEqualTo: schoolid)
          .get();
      stafflist = snapshot.docs.map((doc) {
        return Staff.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  fetchSupplier() async {
    try {
      final snapshot = await db.collection('supplier').get();
      supplierlist = snapshot.docs.map((doc) {
        return SupplierModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      //print(e);
    }
    notifyListeners();
  }

  fetchExpense() async {
    try {
      final snapshot = await db.collection('expense').get();
      expenselists = snapshot.docs.map((doc) {
        return ExpenseModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {}
    notifyListeners();
  }

  fetchFeePayment({DateTime? startDate, DateTime? endDate}) async {
    try {
      if (schoolid.isEmpty) await getdata();
      debugPrint("Fetching payments for school ID: '$schoolid'");
      
      Query query = db.collection('feepayment').where('schoolId', isEqualTo: schoolid);
      
      if (startDate != null) {
        query = query.where('dateCreated', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query.where('dateCreated', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
      }

      final snapshot = await query.orderBy('dateCreated', descending: true).get();
      
      feepaymentlist = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FeePaymentModel.fromJson(data);
      }).toList();
      
      debugPrint("SUCCESS: Fetched ${feepaymentlist.length} payment records.");
      
      // If we got nothing, try checking if they were saved with 'schoolid' (lowercase i)
      if (feepaymentlist.isEmpty) {
        debugPrint("Trying alternative field name 'schoolid'...");
        final altSnap = await db.collection('feepayment').where('schoolid', isEqualTo: schoolid).limit(10).get();
        if (altSnap.docs.isNotEmpty) {
          feepaymentlist = altSnap.docs.map((doc) => FeePaymentModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
          debugPrint("Found ${feepaymentlist.length} records with lowercase 'schoolid'");
        }
      }
    } catch (e) {
      debugPrint("CRITICAL ERROR in fetchFeePayment: $e");
    }
    notifyListeners();
  }

  fetchSingleBilled() async {
    try {
      final snapshot = await db.collection('singlebilled').get();
      singlebilledlist = snapshot.docs.map((doc) {
        return SingleBilledModel.fromMap(doc.data());
      }).toList();
    } catch (e) {}
    notifyListeners();
  }

  fetchBilled() async {
    try {
      final snapshot = await db.collection('billed').get();
      billedlist = snapshot.docs.map((doc) {
        return BilledModel.fromMap(doc.data());
      }).toList();
    } catch (e) {}
    notifyListeners();
  }

  fetchActivityList() async {
    try {
      final snapshot = await db.collection('systemActivity').get();
      activitylist = snapshot.docs.map((doc) {
        return ActivityModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {}
    notifyListeners();
  }

  fetchAccountList() async {
    try {
      final snapshot = await db.collection('mainaccounts').get();
      accountlist = snapshot.docs.map((doc) {
        return CoaModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {}
    notifyListeners();
  }

  fetchItemRegList() async {
    try {
      final snapshot = await db.collection('itemReg').get();
      itemreglist = snapshot.docs.map((doc) {
        return ItemRegModel.fromMap(doc.data());
      }).toList();
    } catch (e) {}
    notifyListeners();
  }

  Future<void> fetchAccountantSummary({DateTime? startDate, DateTime? endDate}) async {
    try {
      if (schoolid.isEmpty) await getdata();
      Query query = db.collection('accountantDailySummary').where('schoolId', isEqualTo: schoolid);

      if (startDate != null) {
        String startStr = DateFormat('yyyy-MM-dd').format(startDate);
        query = query.where('date', isGreaterThanOrEqualTo: startStr);
      }
      if (endDate != null) {
        String endStr = DateFormat('yyyy-MM-dd').format(endDate);
        query = query.where('date', isLessThanOrEqualTo: endStr);
      }

      final snapshot = await query.orderBy('date', descending: true).get();
      accountantSummaryList = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint("Error fetching accountant summary: $e");
    }
    notifyListeners();
  }

  Future<void> deleteStaff(String id, int index, BuildContext context) async {
    try {
      await db.collection('staff').doc(id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("deleted successfully")));
      stafflist.removeAt(index);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting: $e")));
    }
    fetchStaff();
    notifyListeners();
  }

  Future<bool> staffexistbyphone(String phone) async {
    try {
      final detail = await db
          .collection("staff")
          .where('phone', isEqualTo: phone)
          .where('schoolId', isEqualTo: schoolid)
          .get();
      int numberofdocs = detail.docs.length;
      if (numberofdocs > 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> staffexistbyemail(String email) async {
    try {
      final detail = await db
          .collection("staff")
          .where('email', isEqualTo: email)
          .where('schoolId', isEqualTo: schoolid)
          .get();
      int numberofdocs = detail.docs.length;
      if (numberofdocs > 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  //  Future<void> fetchtermyear(String schoolId, SharedPreferences prefs) async {
  //   try {
  //     final snapshot = await db.collection("schools").doc(schoolId).get();
  //
  //     if (snapshot.exists) {
  //       final data = snapshot.data() as Map<String, dynamic>;
  //       //debugPrint("RAW SCHOOL DATA: $data");
  //       final String termTxt = data['term']?.toString() ?? "";
  //       final String yearTxt = data['academicyr']?.toString() ?? "";
  //       final String academicyridTxt = data['academicyrid']?.toString() ?? "";
  //       await prefs.setString("term", termTxt);
  //       await prefs.setString("year", yearTxt);
  //       await prefs.setString("academicyrid", academicyridTxt);
  //
  //     }
  //   } catch (e) {
  //     debugPrint("Error fetching term/year: $e");
  //   }
  // }
  void setAccounts(List<String> accounts) {
    accounts = accounts;
    notifyListeners();
  }

  Future<void> fetchAccounts() async {
    try {
      final snapshot = await db.collection("mainaccounts").get();
      accounts = snapshot.docs
          .map((doc) => (doc.data()["name"] ?? "") as String)
          .where((name) => name.isNotEmpty)
          .toList();
      accountclass = snapshot.docs
          .map((doc) => (doc.data()["accountType"] ?? "") as String)
          .where((name) => name.isNotEmpty)
          .toList();
      accountsubclass = snapshot.docs
          .map((doc) => (doc.data()["subType"] ?? "") as String)
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (e) {
      print("Error fetching accounts: $e");
    }
    notifyListeners();
  }

  Future<void> fetchCurrentAccounts() async {
    try {
      final snapshot = await db
          .collection("mainaccounts")
          .where('subType', isEqualTo: 'Current Assets')
          .get();
      currentaccounts = snapshot.docs
          .map((doc) => (doc.data()["name"] ?? "") as String)
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (e) {
      print("Error fetching accounts: $e");
    }
    notifyListeners();
  }

  Future<void> fetchFess() async {
    try {
      //loadclassdata = true;
      notifyListeners();
      final snapshot = await db.collection("feeSetup").get();
      fees = snapshot.docs.map((doc) {
        return FeeSetUpModel.fromMap(doc.data());
      }).toList();

      //  loadclassdata = false;
      notifyListeners();
    } catch (e) {
      // loadclassdata = false;
      notifyListeners();
      print("Failed to fetch class: $e");
    }
  }

  Future<void> paymentmethodslist() async {
    try {
      //loadclassdata = true;
      final snapshot = await db.collection("paymentmethod").get();

      paymethodlist = snapshot.docs.map((doc) {
        return PaymentMethodModel.fromMap(doc.data());
      }).toList();

      //  loadclassdata = false;
      notifyListeners();
    } catch (e) {
      // loadclassdata = false;
      notifyListeners();
      print("Failed to fetch class: $e");
    }
    notifyListeners();
  }

  emptysearchResults() {
    searchResults = [];
    notifyListeners();
  }

  searchStudents(String query) async {
    try {
      if (query.isEmpty) {
        searchResults = [];
        return;
      }
      searchResults.clear();

      final snap = await FirebaseFirestore.instance
          .collection("students")
          .where("name", isGreaterThanOrEqualTo: query)
          .where("name", isLessThanOrEqualTo: "$query\uf8ff")
          .limit(10)
          .get();
      //searchResults = snap.docs.map((d) => {"id": d.id, ...d.data() as Map<String, dynamic>}).toList();
      searchResults = snap.docs.map((doc) {
        return StudentModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print("Error searching students: $e");
    }
    notifyListeners();
  }

  void addStudent(StudentModel student) {
    if (!selectedStudents.any((s) => s.studentid == student.studentid)) {
      selectedStudents.add(student);
      notifyListeners();
    }
  }

  void removeStudent(String studentId) {
    selectedStudents.removeWhere((s) => s.studentid == studentId);
    notifyListeners();
  }

  Future<void> fetchLinkedAccounts(String paymentMethodName) async {
    linkedAccounts.clear();
    final snapshot = await FirebaseFirestore.instance
        .collection("paymentmethod")
        .where("name", isEqualTo: paymentMethodName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      print(snapshot.docs.length);

      final data = snapshot.docs.first.data();
      if (data.containsKey("linkedAccounts")) {
        final ids = List<String>.from(data["linkedAccounts"]);

        // fetch account names from mainaccounts
        if (ids.isNotEmpty) {
          linkedAccounts = ids.map((id) {
            return {"name": id};
          }).toList();
        }
      }
    }
    notifyListeners();
  }

  void clearSelectedStudents() {
    selectedStudents.clear();
    notifyListeners();
  }

  generatereceiptnumber() async {
    SharedPreferences spref = await SharedPreferences.getInstance();
    try {
      final now = DateTime.now();
      final dateKey =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final lastreceiptnumber = await db
          .collection("feepayment")
          .where('schoolId', isEqualTo: schoolid)
          .get();
      String numberPart = schoolid.replaceAll(RegExp(r'[^0-9]'), '');
      receiptno = "$numberPart$dateKey${(lastreceiptnumber.docs.length + 1)}";
      await spref.setString("receiptno", receiptno);
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  myreceipt() async {
    try {
      await getdata();
      final docId = "${schoolid}_$receiptno";
      final data = await db.collection("feepayment").doc(docId).get();
      if (!data.exists) {
        // Fallback for old records if any
        final oldData = await db.collection("feepayment").doc(receiptno).get();
        if (oldData.exists) {
           await _processReceiptData(oldData.data()!);
        }
        return;
      }

      await _processReceiptData(data.data()!);
    } catch (e) {
      print("Error in myreceipt: $e");
    }
    notifyListeners();
  }

  Future<void> _processReceiptData(Map<String, dynamic> paymentData) async {
    receiptName = paymentData['studentName'] ?? "";
    receiptrecords = paymentData['fees'] ?? {};
    receiptpaymentmethod = paymentData['paymentmethod'] ?? "";
    receiptnote = receiptrecords.keys.join(", ");
    final ts = paymentData['dateCreated'];
    if (ts is Timestamp) {
      DateTime date = ts.toDate();
      receiptdate = DateFormat("MMMM d, y").format(date);
    }
    
    double receiptval = 0;
    for (var values in receiptrecords.values) {
      receiptval += double.tryParse(values.toString()) ?? 0;
    }
    receiptTotal = receiptval;

    // Robustly fetch student financial info
    final studentIdField = paymentData['studentId'];
    if (studentIdField != null && studentIdField.toString().isNotEmpty && studentIdField.toString().toLowerCase() != "null") {
      final String sid = studentIdField.toString().trim();
      
      // 1. Try querying by the field 'studentid'
      final studentQuery = await db.collection("students")
          .where("studentid", isEqualTo: sid)
          .where("schoolId", isEqualTo: schoolid)
          .limit(1)
          .get();
      
      DocumentSnapshot? studentDoc;
      if (studentQuery.docs.isNotEmpty) {
        studentDoc = studentQuery.docs.first;
      } else {
        // 2. Fallback to direct document ID lookup (try a few common variations)
        final List<String> possibleIds = [
          "${schoolid}_$sid".toUpperCase(),
          "${schoolid}_$sid",
          sid.toUpperCase(),
          sid,
        ];
        
        for (String id in possibleIds) {
          final doc = await db.collection("students").doc(id).get();
          if (doc.exists) {
            studentDoc = doc;
            break;
          }
        }
      }

      if (studentDoc != null && studentDoc.exists) {
        final sData = studentDoc.data() as Map<String, dynamic>;
        final sAccounts = Map<String, dynamic>.from(sData['accounts'] ?? {});
        
        // Ensure we handle numeric types correctly from Firestore
        totalBilled = (sAccounts['billed'] ?? 0.0).toDouble();
        totalPaid = (sAccounts['paid'] ?? 0.0).toDouble();
        
        // Calculate balance if missing, or use existing
        if (sAccounts.containsKey('balance')) {
          outstandingBalance = (sAccounts['balance'] ?? 0.0).toDouble();
        } else {
          outstandingBalance = totalBilled - totalPaid;
        }
        
        // Fix for negative zero or tiny floating point issues
        if (outstandingBalance.abs() < 0.01) outstandingBalance = 0.0;
        
        debugPrint("SUCCESS: Student found. Balance: $outstandingBalance");
      } else {
        debugPrint("ERROR: Student profile NOT found for receipt. ID: $sid");
        outstandingBalance = -1; // Marker for not found
      }
    } else {
      outstandingBalance = -1;
    }
    notifyListeners();
  }

  Future<void> fetchexpense() async {
    try {
      //loadterms = true;
      final snapshot = await db
          .collection("mainaccounts")
          .where('accountType', isEqualTo: "Expense")
          .get();

      expenselist = snapshot.docs.map((doc) {
        return ExpenseModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // loadterms = false;
      notifyListeners();
    } catch (e) {
      //loadterms = false;
      notifyListeners();
      print("Failed to fetch terms: $e");
    }
  }

  Future<void> fetchsuppliers() async {
    try {
      //loadterms = true;
      final snapshot = await db
          .collection("supplier")
          .where('schoolId', isEqualTo: schoolid)
          .get();
      supplierList = snapshot.docs.map((doc) {
        return SupplierModel.fromMap(doc.data());
      }).toList();
      notifyListeners();
    } catch (e) {
      //loadterms = false;
      notifyListeners();
      print("Failed to fetch terms: $e");
    }
  }

  logout(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final auth = FirebaseAuth.instance;
    await auth.signOut();

    await Future.wait([
      pref.remove('useremail'),
      pref.remove('year'),
      pref.remove('school'),
      pref.remove('academicyrid'),
      pref.remove('staffkey'),
      pref.remove('term'),
      pref.remove('schoolnames'),
      pref.remove('staffschools'),
      pref.remove('schoolid'),
      pref.remove('staffid'),
      pref.remove('name'),
      pref.remove('email'),
      pref.remove('role'),
      pref.remove('accessLevel'),
      pref.remove('phone'),
      pref.remove('createddate'),
      pref.remove('region'),
      pref.remove('departmentId'),
      pref.remove('schoolType'),
    ]);
    assignedList = [];
    //await getdata();
    // Navigate to login
 context.go(Routes.login);
    notifyListeners();
  }

  set termset(String value) {
    term = value;
    notifyListeners();
  }

  set academicYearset(String value) {
    year = value;
    notifyListeners();
  }

  set academicYearIdset(String value) {
    academicyrid = value;
    notifyListeners();
  }

  Future<void> changePassword(
      String currentPassword,
      String newPassword,
      ) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Current password is incorrect');
      } else if (e.code == 'weak-password') {
        throw Exception('New password is too weak');
      } else {
        throw Exception(e.message ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
