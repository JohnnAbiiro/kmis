
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ksoftsms/controller/dbmodels/SupplierModel.dart';
import 'package:ksoftsms/controller/dbmodels/contestantsmodel.dart';
import 'package:ksoftsms/controller/dbmodels/feeSetUpModel.dart';
import 'package:ksoftsms/controller/dbmodels/paymentMethodsModel.dart';
import 'package:ksoftsms/controller/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dbmodels/expenseModel.dart';
import 'dbmodels/feePaymentModel.dart';
import 'dbmodels/schoolmodel.dart';
import 'dbmodels/staffmodel.dart';

class LoginProvider extends ChangeNotifier {
  String today = DateFormat("MMMM d, y").format(DateTime.now());
  List<String> staffSchoolIds=[];
  List<String> schoolnames=[];
  List<SchoolModel> schoolList = [];
  List<Staff> staffschools = [];
  List<String> staffaccesslevel = ["admin", "teacher", "super admin"];
  List<StudentModel> selectedStudents = [];
  List<ExpenseModel> expenselist = [];

  List<SupplierModel> supplierList = [];
  List<StudentModel> searchResults = [];
  List<Map<String, String>> linkedAccounts = []; // holds account id + name
  Map<String,dynamic> receiptrecords = {};
  final numberFormat = NumberFormat("#,##0.00", "en_US");
  String currentschool = "";
  Staff? usermodel;
  String schoolid = "";
  String accesslevel = "";
  String phone = "";
  String name = "";
  String year = "";
  String academicyrid = "";
  String term = "";
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
   String receiptno="";
  List<String> accountsubclass = [];
  String receiptName="";
  String receiptpaymentmethod="";
  String receiptdate="";

  String receiptnote="";
  String receipt="";
  double receiptTotal=0;

   login(String email, String password, BuildContext context) async {
    try {
      final loginhere = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (loginhere.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('useremail', email);
        final detail = await db.collection("staff").where('email', isEqualTo: email).get();
        int numberofdocs = detail.docs.length;
        final userData = detail.docs.first.data();
        usermodel = Staff.fromMap(userData, detail.docs.first.id);
        String emailTxt = usermodel?.email ?? '';
        String nameTxt = usermodel?.name ?? '';
        String roleTxt = usermodel?.accessLevel ?? '';
        String phoneTxt = usermodel?.phone ?? '';
        String schoolTxt = usermodel?.schoolname ?? '';
        String scchoolIdTxt = usermodel?.schoolId ?? '';

        prefs.setString("school", schoolTxt);
        prefs.setString("email", emailTxt);
        prefs.setString("name", nameTxt);
        prefs.setString("role", roleTxt);
        prefs.setString("phone", phoneTxt);
        prefs.setString("schoolid", scchoolIdTxt);
        await fetchtermyear(scchoolIdTxt, prefs);
        if (numberofdocs > 1) {
          staffschools = detail.docs.map((doc) {
            return Staff.fromMap(doc.data(), doc.id);
          }).toList();
          prefs.setStringList("staffschools", staffschools.map((e) => e.schoolId).toList());
          prefs.setStringList("schoolnames", staffschools.map((e) => e.schoolname).toList());
          await getdata();
          context.go(Routes.nextpage);
          notifyListeners();
        }

        else {
          await getdata();
          auth.currentUser!.updateDisplayName(nameTxt);
          context.go(Routes.dashboard);
          notifyListeners();
        }

        //useremail=email;
        notifyListeners();
      }
    } catch (e) {
      errorMessage=e.toString();

      print(e);
    }
  }
   getdata() async {
    final prefs = await SharedPreferences.getInstance();
    schoolid = prefs.getString('schoolid') ?? '';
    currentschool = prefs.getString('school') ?? '';
    phone = prefs.getString('phone') ?? '';
    accesslevel = prefs.getString('role') ?? '';
    name = prefs.getString('name') ?? '';
    year = prefs.getString('year') ?? '';
    academicyrid = prefs.getString('academicyrid') ?? '';
    term = prefs.getString('term') ?? '';
    staffSchoolIds = prefs.getStringList("staffschools") ?? [];
    schoolnames = prefs.getStringList("schoolnames") ?? [];
    receiptno=prefs.getString("receiptno")??"";
   print(schoolid);
    notifyListeners();
  }
   setSchool(String school, String schoolid) async {
    try{
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("school", school);
      await prefs.setString("schoolid", schoolid);
    }catch(e){
      errorMessage = e.toString();
    }
    notifyListeners();
  }
   staffcount() async {
    await getdata();
    try {
      print(schoolid);
      final detail = await db.collection("staff").where('schoolId', isEqualTo: schoolid).get();
      int numberofdocs = detail.docs.length;
      staffcount_in_school = numberofdocs;
      print(numberofdocs);
    } catch (e) {
      print(e);
      return 0;
    }
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
   Future<void> fetchtermyear(String schoolId, SharedPreferences prefs) async {
    try {
      final snapshot = await db.collection("schools").doc(schoolId).get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final String termTxt = data['term']?.toString() ?? "";
        final String yearTxt = data['academicyr']?.toString() ?? "";
        final String academicyridTxt = data['academicyrid']?.toString() ?? "";
        await prefs.setString("term", termTxt);
        await prefs.setString("year", yearTxt);
        await prefs.setString("academicyrid", academicyridTxt);
      }
    } catch (e) {
      debugPrint("Error fetching term/year: $e");
    }
  }
   void setAccounts(List<String> accounts) {
    accounts = accounts;
    notifyListeners();
  }
   Future<void> fetchAccounts() async {
    try {
      final snapshot = await db.collection("mainaccounts").get();
      accounts = snapshot.docs.map((doc) => (doc.data()["name"] ?? "") as String).where((name) => name.isNotEmpty).toList();
      accountclass = snapshot.docs.map((doc) => (doc.data()["accountType"] ?? "") as String).where((name) => name.isNotEmpty).toList();
      accountsubclass = snapshot.docs.map((doc) => (doc.data()["subType"] ?? "") as String).where((name) => name.isNotEmpty).toList();
    } catch (e) {
      print("Error fetching accounts: $e");
    }
    notifyListeners();
  }
   Future<void> fetchCurrentAccounts() async {
    try {
      final snapshot = await db.collection("mainaccounts").where('subType',isEqualTo: 'Current Assets').get();
      currentaccounts = snapshot.docs.map((doc) => (doc.data()["name"] ?? "") as String).where((name) => name.isNotEmpty).toList();
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
   emptysearchResults(){
    searchResults=[];
    notifyListeners();
  }
   Future<void> searchStudents(String query) async {
    try {
      if (query.isEmpty) {
        searchResults = [];
        return;
      }
      searchResults.clear();

      final snap = await FirebaseFirestore.instance.collection("students").where("name", isGreaterThanOrEqualTo: query).where("name", isLessThanOrEqualTo: "$query\uf8ff").limit(10).get();
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
   generatereceiptnumber()async{
    SharedPreferences spref=await SharedPreferences.getInstance();
    try{
      final now = DateTime.now();
      final dateKey = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final lastreceiptnumber= await db.collection("feepayment").where('schoolId',isEqualTo: schoolid).get();
      String numberPart = schoolid.replaceAll(RegExp(r'[^0-9]'), '');
      receiptno="$numberPart$dateKey${(lastreceiptnumber.docs.length + 1)}";
      await spref.setString("receiptno", receiptno);
    }catch(e){
      print(e);
    }
     notifyListeners();
   }
   myreceipt()async{
    try{
        await getdata();
        final data=await db.collection("feepayment").doc(receiptno).get();
        receiptName=data.data()!['studentName'];
        receiptrecords=data.data()!['fees'];
        receiptpaymentmethod=data.data()!['paymentmethod'];
         receiptnote=receiptrecords.keys.toString().toString();
        final ts = data['dateCreated'];
        DateTime date = ts.toDate();
         receiptdate = DateFormat("MMMM d, y").format(date);
         double receiptval=0;
        receiptTotal=receiptval;

        for(var values in receiptrecords.values){
           receiptval+=double.parse(values.toString());
         }
        receiptTotal=receiptval;
        print(receiptTotal.toStringAsFixed(2));
         print(receiptTotal);
    }catch(e){
      print(e);
    }
    notifyListeners();


   }
  Future<void> fetchexpense() async {
    try {
      //loadterms = true;
      final snapshot = await db.collection("mainaccounts").where('accountType',isEqualTo:"Expense" ).get();

      expenselist = snapshot.docs.map((doc) {
        return ExpenseModel.fromJson(doc.data());
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
      final snapshot = await db.collection("supplier").where('schoolId',isEqualTo:schoolid ).get();
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





}