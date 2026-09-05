// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_progress_hud/flutter_progress_hud.dart';
// import 'package:ksoftsms/controller/loginprovider.dart';
// import 'package:ksoftsms/controller/myprovider.dart';
// import 'package:provider/provider.dart';
// import '../controller/dbmodels/staffmodel.dart';
// import '../controller/routes.dart';
//
// class Regstaff extends StatefulWidget {
//   final Staff? staffData;
//   const Regstaff({Key? key, this.staffData}) : super(key: key);
//
//   @override
//   State<Regstaff> createState() => _RegstaffState();
// }
//
// class _RegstaffState extends State<Regstaff> {
//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final emailController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//
//   final List<String> _sex = ['Male', "Female"];
//   String? myRegion;
//   String? _selectedSex;
//   String? _selectedAccessLevel;
//   final departmentIdController = TextEditingController();
//   final List<String> schoolStaffRoles = const [
//     'admin',
//     'academic',
//     'hod',
//     'tutor',
//   ];
//
//   bool _showStaffContainer = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<Myprovider>().getdata();
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<Myprovider>().getdata();
//       context.read<Myprovider>().getfetchRegions();
//       context.read<Myprovider>().staffcount();
//     });
//
//   }
//
//   @override
//   void dispose() {
//     departmentIdController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final inputFill = const Color(0xFFffffff);
//     final isEdit = widget.staffData != null;
//
//     return ProgressHUD(
//       child: Builder(
//         builder: (context) {
//           return Consumer<Myprovider>(
//             builder: (context, value, child) {
//               return Scaffold(
//                 appBar: AppBar(
//                   backgroundColor: const Color(0xFF00273a),
//                   leading: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                   title: Text(value.currentschool,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 body: SingleChildScrollView(
//                   padding: const EdgeInsets.all(20),
//                   child: LayoutBuilder(
//                       builder: (context, constraints){
//                         bool isWideScreen = constraints.maxWidth > 500;
//
//                         return Center(
//                           child: Wrap(
//                             spacing: 12,
//                             runSpacing: 12,
//                             children: [
//                               Container(
//                                 color: const Color(0xFFffffff),
//                                 margin: const EdgeInsets.all(20),
//                                 child: ConstrainedBox(
//                                   constraints: const BoxConstraints(maxWidth: 500),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(40.0),
//                                     child: Form(
//                                       key: _formKey,
//                                       child: Column(
//                                         children: [
//                                           // Name
//                                           TextFormField(
//                                             controller: nameController,
//                                             decoration: _inputDecoration("Staff Name", "Enter Staff Name", inputFill),
//                                             style: const TextStyle(fontSize: 16),
//                                             validator: (value) =>
//                                             value == null || value.trim().isEmpty ? 'Staff name cannot be empty' : null,
//                                           ),
//                                           const SizedBox(height: 20),
//                                           // Phone
//                                           TextFormField(
//                                             keyboardType: TextInputType.phone,
//                                             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                                             controller: phoneController,
//                                             decoration: _inputDecoration("Phone", "Enter Phone Number", inputFill),
//                                             style: const TextStyle(fontSize: 16),
//                                             validator: (value) =>
//                                             value == null || value.trim().isEmpty ? 'Phone number cannot be empty' : null,
//                                           ),
//                                           const SizedBox(height: 20),
//
//                                           TextFormField(
//                                             keyboardType: TextInputType.emailAddress,
//                                             controller: emailController,
//                                             decoration: _inputDecoration("Email", "Enter Email Address", inputFill),
//                                             inputFormatters: [
//                                               // deny spaces
//                                               FilteringTextInputFormatter.deny(RegExp(r'\s')),
//                                             ],
//                                             validator: (value) {
//                                               if (value == null || value.isEmpty) {
//                                                 return "Please enter your email";
//                                               }
//                                               // simple email check
//                                               if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
//                                                 return "Enter a valid email";
//                                               }
//                                               return null;
//                                             },
//                                             style: const TextStyle(fontSize: 16),
//
//                                           ),
//                                           const SizedBox(height: 20),
//                                           // Sex
//                                           DropdownButtonFormField<String>(
//                                             value: _selectedSex,
//                                             items: _sex.map((cat) {
//                                               return DropdownMenuItem(
//                                                 value: cat,
//                                                 child: Text(cat, style: const TextStyle(color: Colors.black54)),
//                                               );
//                                             }).toList(),
//                                             dropdownColor: inputFill,
//                                             onChanged: (value) => setState(() => _selectedSex = value),
//                                             decoration: _inputDecoration("Sex", null, inputFill),
//                                             validator: (value) => value == null ? 'Please select sex' : null,
//                                           ),
//                                           const SizedBox(height: 20),
//
//                                           // Region
//                                           DropdownButtonFormField<String>(
//                                             value: myRegion,
//                                             items: value.regionList.map((cat) {
//                                               return DropdownMenuItem(
//                                                 value: cat.regionname,
//                                                 child: Text(cat.regionname, style: const TextStyle(color: Colors.black54)),
//                                               );
//                                             }).toList(),
//                                             dropdownColor: inputFill,
//                                             onChanged: (val) => setState(() => myRegion = val),
//                                             decoration: _inputDecoration("Region", null, inputFill),
//                                             validator: (value) => value == null ? 'Please select region' : null,
//                                           ),
//                                           const SizedBox(height: 20),
//
//                                           TextFormField(
//                                             controller: departmentIdController,
//                                             decoration: _inputDecoration(
//                                               "Department ID",
//                                               "Required for HOD staff",
//                                               inputFill,
//                                             ),
//                                             style: const TextStyle(fontSize: 16),
//                                             validator: (value) {
//                                               if ((_selectedAccessLevel ?? '').toLowerCase() == 'hod' &&
//                                                   (value == null || value.trim().isEmpty)) {
//                                                 return 'Department ID is required for HOD';
//                                               }
//                                               return null;
//                                             },
//                                           ),
//                                           const SizedBox(height: 20),
//
//                                           // Access Level
//                                           DropdownButtonFormField<String>(
//                                             value: _selectedAccessLevel,
//                                             items: schoolStaffRoles.map((accesslevel) {
//                                               return DropdownMenuItem(
//                                                 value: accesslevel,
//                                                 child: Text(accesslevel, style: const TextStyle(color: Colors.black54)),
//                                               );
//                                             }).toList(),
//                                             onChanged: (val) => setState(() => _selectedAccessLevel = val),
//                                             decoration: _inputDecoration("Access Level", null, inputFill),
//                                             validator: (value) => value == null ? 'Please select access level' : null,
//                                           ),
//                                           const SizedBox(height: 30),
//                                           // Buttons
//                                           Column(
//                                             children: [
//                                               Wrap(
//                                                 spacing: 10,
//                                                 runSpacing: 10,
//                                                 children: [
//                                                   ElevatedButton.icon(
//                                                     onPressed: () async {
//                                                       if (_formKey.currentState!.validate()) {
//                                                         final progress = ProgressHUD.of(context);
//                                                         progress!.show();
//                                                         String nameTxt= nameController.text.trim();
//                                                         String phoneTxt= phoneController.text.trim();
//                                                         String sexTxt= _selectedSex ?? "";
//                                                         String regionTxt= myRegion ?? "";
//                                                         String emailTxt= emailController.text.trim().toString().toLowerCase();
//                                                         String schoolId= value.schoolid ?? "";
//                                                         String schoolName= value.currentschool ?? "";
//                                                         DateTime createdAt= DateTime.now();
//                                                         String accessLevelTxt= _selectedAccessLevel ?? "";
//                                                         String departmentIdTxt = departmentIdController.text.trim();
//                                                         //get the next staffid
//                                                         await value.staffcount();
//                                                         String _staffcount=value.staffcount_in_school.toString();
//                                                         String _staffid= value.schoolid! + _staffcount;
//                                                         bool existstaffbyeamil=await value.staffexistbyemail(emailTxt);
//                                                         bool existstaffbyphone=await value.staffexistbyphone(phoneTxt);
//                                                         print("Number of docs: $schoolId");
//                                                         if(existstaffbyeamil || existstaffbyphone)
//                                                         {
//                                                           SnackBar snackBar = const SnackBar(
//                                                             content: Text('Staff with this Phone Number or Email already exists'),
//                                                             backgroundColor: Colors.red,
//                                                           );
//                                                           ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                                                           //await value.smsalert("Hello $nameTxt, you already exist in ${value.currentschool}", phoneTxt);
//                                                           progress.dismiss();
//                                                           return;
//                                                         }
//                                                         final staffdata=Staff(
//                                                             name: nameTxt,
//                                                             accessLevel: accessLevelTxt,
//                                                             phone: phoneTxt,
//                                                             email: emailTxt,
//                                                             sex: sexTxt,
//                                                             region: regionTxt,
//                                                             schoolId: schoolId,
//                                                             schoolname: schoolName,
//                                                             departmentId: departmentIdTxt,
//                                                             id: _staffid,
//                                                             createdAt: createdAt, teaching: '').toMap();
//                                                         final password ="123456";
//                                                         await value.db.collection('staff').doc(_staffid).set(staffdata, SetOptions(merge: true));
//                                                         await value.auth.createUserWithEmailAndPassword(email: emailTxt, password: password);
//                                                         await value.auth.currentUser!.sendEmailVerification();
//                                                         String message='Welcome to KologSoft MIS, $nameTxt. Your school ID is ${value.schoolid}. Please verify your email to complete the registration process.';
//                                                         await value.db.collection("smsQueue").add({
//                                                           'phone': phoneTxt,
//                                                           'message': message,
//                                                           'senderId': "KologSoft",
//                                                           'createdat': DateTime.now(),
//                                                           'status': 'pending',
//                                                         });
//                                                         await Future.delayed(const Duration(seconds: 1));
//                                                         progress.dismiss();
//
//                                                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                                                           content: Text(isEdit ? 'Data Updated Successfully' : 'Data Saved Successfully'),
//                                                           backgroundColor: Colors.green,
//                                                         ));
//                                                         //await value.smsalert("Hello $nameTxt, you have been added successfully to  ${value.currentschool}, please visit  www.kologsoft.com/mis to login", phoneTxt);
//
//
//                                                       }
//                                                     },
//                                                     icon: Icon(isEdit ? Icons.update : Icons.save),
//                                                     label: Text(isEdit ? 'Update Staff' : 'Register Staff', style: TextStyle(fontSize: 12),),
//                                                     style: _btnStyle(),
//                                                   ),
//                                                   ElevatedButton.icon(
//                                                     onPressed: (){
//                                                       Navigator.pushNamed(context, Routes.staffview);
//                                                     },
//                                                     //=> Navigator.pushNamed(context, Routes.viewstaff),
//                                                     icon: const Icon(Icons.view_list),
//                                                     label: const Text('View Staff', style: TextStyle(fontSize: 12),),
//                                                     style: _btnStyle(),
//                                                   ),
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//
//                               if (_showStaffContainer)
//                                 Container(
//                                   width: 800,
//                                   //height: 400,
//                                   padding: const EdgeInsets.all(12),
//                                   color: Colors.white,
//                                   child: FutureBuilder<QuerySnapshot>(
//                                     future: value.db.collection('staff').where('schoolId',isEqualTo:value.schoolid ).get(),
//                                     builder: (context, snapshot) {
//                                       if (snapshot.connectionState == ConnectionState.waiting) {
//                                         return const Center(child: CircularProgressIndicator());
//                                       }
//
//                                       if (snapshot.hasError) {
//                                         return Center(
//                                           child: Text('Error: ${snapshot.error}',
//                                               style: const TextStyle(color: Colors.red)),
//                                         );
//                                       }
//
//                                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                                         return const Center(
//                                           child: Text(
//                                             'No staff found.',
//                                             style: TextStyle(color: Colors.black54),
//                                           ),
//                                         );
//                                       }
//
//                                       final staffDocs = snapshot.data!.docs;
//
//
//                                       if (isWideScreen){
//                                         return SingleChildScrollView(
//                                           scrollDirection: Axis.horizontal,
//                                           child: DataTable(
//                                             columnSpacing: 25,
//                                             headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
//                                             border: TableBorder.all(color: Colors.grey.shade300),
//                                             columns: const [
//                                               DataColumn(label: Text('Staff Name', style: TextStyle(color: Colors.white),)),
//                                               DataColumn(label: Text('Phone', style: TextStyle(color: Colors.white))),
//                                               DataColumn(label: Text('Email', style: TextStyle(color: Colors.white))),
//                                               DataColumn(label: Text('Sex', style: TextStyle(color: Colors.white))),
//                                               DataColumn(label: Text('Region', style: TextStyle(color: Colors.white))),
//                                               DataColumn(label: Text('Access Level', style: TextStyle(color: Colors.white))),
//                                               DataColumn(label: Text('Action', style: TextStyle(color: Colors.white))),
//                                             ],
//                                             rows: staffDocs.map((doc) {
//                                               final data = doc.data() as Map<String, dynamic>;
//                                               return DataRow(cells: [
//                                                 DataCell(Text(data['name'] ?? '')),
//                                                 DataCell(Text(data['phone'] ?? '')),
//                                                 DataCell(Text(data['email'] ?? '')),
//                                                 DataCell(Text(data['sex'] ?? '')),
//                                                 DataCell(Text(data['region'] ?? '')),
//                                                 DataCell(Text(data['accessLevel'] ?? '')),
//                                                 DataCell(
//                                                     Row(
//                                                       children: [
//                                                         Icon(Icons.delete_forever, color: Colors.red, size: 20,),
//                                                         SizedBox(width: 8),
//                                                         Icon(Icons.edit, color: Colors.orangeAccent, size: 20,),
//                                                       ],
//                                                     )
//                                                 ),
//                                               ]);
//                                             }).toList(),
//                                           ),
//                                         );
//                                       }
//                                       else{
//                                         return Card(
//                                           color: Colors.white,
//                                           margin: EdgeInsets.all(8),
//                                           child: Column(
//                                             children: [
//                                               Container(
//                                                 color: Colors.deepPurple.shade100,
//                                                 width: double.infinity,
//                                                 child: Padding(
//                                                   padding: const EdgeInsets.all(8.0),
//                                                   child: Center(
//                                                       child: Text("Staff Lists", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 child: ListView.builder(
//                                                     shrinkWrap: true,
//                                                     physics: NeverScrollableScrollPhysics(),
//                                                     itemCount: staffDocs.length,
//                                                     itemBuilder: (context, index){
//                                                       final data = staffDocs[index].data() as Map<String, dynamic>;
//
//                                                       return Column(
//                                                         children: [
//                                                           ListTile(
//                                                             title: Text(
//                                                               data['name'] ?? '',
//                                                             ),
//                                                             subtitle: Column(
//                                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                                               children: [
//                                                                 Text('Phone: ${data['phone'] ?? ''}'),
//                                                                 Text('Email: ${data['email'] ?? ''}'),
//                                                                 Text('Sex: ${data['sex'] ?? ''}'),
//                                                                 Text('Region: ${data['region'] ?? ''}'),
//                                                                 Text('Access Level: ${data['accessLevel'] ?? ''}'),
//                                                               ],
//                                                             ),
//                                                             trailing: const Row(
//                                                               mainAxisSize: MainAxisSize.min,
//                                                               children: [
//                                                                 Icon(Icons.edit, color: Colors.orangeAccent),
//                                                                 SizedBox(width: 8),
//                                                                 Icon(Icons.delete_forever, color: Colors.red),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           Divider()
//                                                         ],
//                                                       );
//
//                                                     }
//                                                 ),
//                                               )
//                                             ],
//                                           ),
//                                         );
//                                       }
//                                     },
//                                   ),
//                                 ),
//
//                             ],
//                           ),
//                         );
//                       }
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   InputDecoration _inputDecoration(String label, String? hint, Color fill) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
//       hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
//       border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
//       enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
//       focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00496d))),
//       contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//       filled: false,
//       fillColor: fill,
//     );
//   }
//
//   ButtonStyle _btnStyle() {
//     return ElevatedButton.styleFrom(
//       backgroundColor: Color(0xFF00496d),
//       foregroundColor: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//       textStyle: const TextStyle(fontSize: 18),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       elevation: 5,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ksoftsms/controller/loginprovider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/staffmodel.dart';
import '../controller/routes.dart';

class Regstaff extends StatefulWidget {
  final Staff? staffData;
  const Regstaff({Key? key, this.staffData}) : super(key: key);

  @override
  State<Regstaff> createState() => _RegstaffState();
}

class _RegstaffState extends State<Regstaff> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _sex = ['Male', "Female"];
  String? myRegion;
  String? _selectedSex;
  String? _selectedAccessLevel;
  final departmentIdController = TextEditingController();
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
  bool _showStaffContainer = true; // was stuck false — list never rendered
  bool _isSaving = false;

  /// Non-null while editing an existing staff record.
  String? _editingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().getdata();
      context.read<Myprovider>().getfetchRegions();
      context.read<Myprovider>().staffcount();
    });

    if (widget.staffData != null) {
      _populateForEdit(widget.staffData!);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    departmentIdController.dispose();
    super.dispose();
  }

  void _populateForEdit(Staff staff) {
    _editingId = staff.id;
    nameController.text = staff.name;
    phoneController.text = staff.phone;
    emailController.text = staff.email;
    _selectedSex = staff.sex.isNotEmpty ? staff.sex : null;
    myRegion = staff.region.isNotEmpty ? staff.region : null;
    _selectedAccessLevel = staff.accessLevel.isNotEmpty ? staff.accessLevel : null;
    departmentIdController.text = staff.departmentId;
  }

  void _startEditFromMap(Map<String, dynamic> data, String id) {
    setState(() {
      _editingId = id;
      nameController.text = data['name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      emailController.text = data['email'] ?? '';
      final sex = (data['sex'] ?? '').toString();
      _selectedSex = sex.isNotEmpty ? sex : null;
      final region = (data['region'] ?? '').toString();
      myRegion = region.isNotEmpty ? region : null;
      final access = (data['accessLevel'] ?? '').toString();
      _selectedAccessLevel = access.isNotEmpty ? access : null;
      departmentIdController.text = (data['departmentId'] ?? '').toString();
    });
  }

  void _clearForm() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    departmentIdController.clear();
    setState(() {
      _selectedSex = null;
      myRegion = null;
      _selectedAccessLevel = null;
      _editingId = null;
    });
  }

  /// Checks for an existing staff with the same email/phone in this school,
  /// excluding [excludeId] so editing a record doesn't flag itself.
  Future<bool> _isDuplicate({
    required Myprovider value,
    required String email,
    required String phone,
    String? excludeId,
  }) async {
    final schoolId = value.schoolid ?? "";

    final emailSnap = await value.db
        .collection('staff')
        .where('schoolId', isEqualTo: schoolId)
        .where('email', isEqualTo: email)
        .get();

    final phoneSnap = await value.db
        .collection('staff')
        .where('schoolId', isEqualTo: schoolId)
        .where('phone', isEqualTo: phone)
        .get();

    final emailDup = emailSnap.docs.any((d) => d.id != excludeId);
    final phoneDup = phoneSnap.docs.any((d) => d.id != excludeId);

    return emailDup || phoneDup;
  }

  Future<void> _saveStaff(Myprovider value) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final nameTxt = nameController.text.trim();
      final phoneTxt = phoneController.text.trim();
      final sexTxt = _selectedSex ?? "";
      final regionTxt = myRegion ?? "";
      final emailTxt = emailController.text.trim().toLowerCase();
      final schoolId = value.schoolid ?? "";
      final schoolName = value.currentschool ?? "";
      final accessLevelTxt = _selectedAccessLevel ?? "";
      final departmentIdTxt = departmentIdController.text.trim();

      final duplicate = await _isDuplicate(
        value: value,
        email: emailTxt,
        phone: phoneTxt,
        excludeId: _editingId,
      );

      if (duplicate) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Staff with this Phone Number or Email already exists'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      if (_editingId != null) {
        // ---- UPDATE existing staff ----
        final staffForUpdate = Staff(
          id: _editingId,
          name: nameTxt,
          accessLevel: accessLevelTxt,
          teaching: '',
          phone: phoneTxt,
          email: emailTxt,
          sex: sexTxt,
          region: regionTxt,
          schoolId: schoolId,
          schoolname: schoolName,
          departmentId: departmentIdTxt,
          createdAt: DateTime.now(), // unused by toMapForUpdate
        ).toMapForUpdate();

        await value.db
            .collection('staff')
            .doc(_editingId)
            .set(staffForUpdate, SetOptions(merge: true));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Data Updated Successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        // ---- REGISTER new staff ----
        await value.staffcount();
        final staffCount = value.staffcount_in_school.toString();
        final staffId = value.schoolid! + staffCount;
        final createdAt = DateTime.now();

        final staffData = Staff(
          id: staffId,
          name: nameTxt,
          accessLevel: accessLevelTxt,
          teaching: '',
          phone: phoneTxt,
          email: emailTxt,
          sex: sexTxt,
          region: regionTxt,
          schoolId: schoolId,
          schoolname: schoolName,
          departmentId: departmentIdTxt,
          createdAt: createdAt,
        ).toMapForRegister();

        const password = "123456";
        await value.db
            .collection('staff')
            .doc(staffId)
            .set(staffData, SetOptions(merge: true));
        await value.auth.createUserWithEmailAndPassword(
          email: emailTxt,
          password: password,
        );
        await value.auth.currentUser!.sendEmailVerification();

        final message =
            'Welcome to KologSoft MIS, $nameTxt. Your school ID is ${value.schoolid}. Please verify your email to complete the registration process.';
        await value.db.collection("smsQueue").add({
          'phone': phoneTxt,
          'message': message,
          'senderId': "KologSoft",
          'createdat': DateTime.now(),
          'status': 'pending',
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Data Saved Successfully'),
          backgroundColor: Colors.green,
        ));
      }

      _clearForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteStaff(Myprovider value, String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      await value.db.collection('staff').doc(id).delete();
      if (_editingId == id) _clearForm();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Staff Deleted'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFFffffff);

    return Builder(
      builder: (context) {
        return Consumer<Myprovider>(
          builder: (context, value, child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFF00273a),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  value.currentschool,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: LayoutBuilder(builder: (context, constraints) {
                      bool isWideScreen = constraints.maxWidth > 500;

                      return Center(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            Container(
                              color: const Color(0xFFffffff),
                              margin: const EdgeInsets.all(20),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 500),
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        if (_editingId != null)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Editing existing staff',
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: _clearForm,
                                                  child: const Text('Cancel edit'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        // Name
                                        TextFormField(
                                          controller: nameController,
                                          decoration: _inputDecoration(
                                              "Staff Name", "Enter Staff Name", inputFill),
                                          style: const TextStyle(fontSize: 16),
                                          validator: (value) => value == null || value.trim().isEmpty
                                              ? 'Staff name cannot be empty'
                                              : null,
                                        ),
                                        const SizedBox(height: 20),
                                        // Phone
                                        TextFormField(
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          controller: phoneController,
                                          decoration: _inputDecoration(
                                              "Phone", "Enter Phone Number", inputFill),
                                          style: const TextStyle(fontSize: 16),
                                          validator: (value) => value == null || value.trim().isEmpty
                                              ? 'Phone number cannot be empty'
                                              : null,
                                        ),
                                        const SizedBox(height: 20),

                                        TextFormField(
                                          keyboardType: TextInputType.emailAddress,
                                          controller: emailController,
                                          decoration: _inputDecoration(
                                              "Email", "Enter Email Address", inputFill),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                          ],
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Please enter your email";
                                            }
                                            if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                                              return "Enter a valid email";
                                            }
                                            return null;
                                          },
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 20),
                                        // Sex
                                        DropdownButtonFormField<String>(
                                          value: _selectedSex,
                                          items: _sex.map((cat) {
                                            return DropdownMenuItem(
                                              value: cat,
                                              child: Text(cat, style: const TextStyle(color: Colors.black54)),
                                            );
                                          }).toList(),
                                          dropdownColor: inputFill,
                                          onChanged: (value) => setState(() => _selectedSex = value),
                                          decoration: _inputDecoration("Sex", null, inputFill),
                                          validator: (value) => value == null ? 'Please select sex' : null,
                                        ),
                                        const SizedBox(height: 20),

                                        // Region
                                        DropdownButtonFormField<String>(
                                          value: myRegion,
                                          items: value.regionList.map((cat) {
                                            return DropdownMenuItem(
                                              value: cat.regionname,
                                              child: Text(cat.regionname, style: const TextStyle(color: Colors.black54)),
                                            );
                                          }).toList(),
                                          dropdownColor: inputFill,
                                          onChanged: (val) => setState(() => myRegion = val),
                                          decoration: _inputDecoration("Region", null, inputFill),
                                          validator: (value) => value == null ? 'Please select region' : null,
                                        ),
                                        const SizedBox(height: 20),

                                        TextFormField(
                                          controller: departmentIdController,
                                          decoration: _inputDecoration(
                                            "Department ID",
                                            "Required for HOD staff",
                                            inputFill,
                                          ),
                                          style: const TextStyle(fontSize: 16),
                                          validator: (value) {
                                            if ((_selectedAccessLevel ?? '').toLowerCase() == 'hod' &&
                                                (value == null || value.trim().isEmpty)) {
                                              return 'Department ID is required for HOD';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),

                                        // Access Level
                                        DropdownButtonFormField<String>(
                                          value: _selectedAccessLevel,
                                          items: staffaccesslevel.map((accesslevel) {
                                            return DropdownMenuItem(
                                              value: accesslevel,
                                              child: Text(accesslevel, style: const TextStyle(color: Colors.black54)),
                                            );
                                          }).toList(),
                                          onChanged: (val) => setState(() => _selectedAccessLevel = val),
                                          decoration: _inputDecoration("Access Level", null, inputFill),
                                          validator: (value) => value == null ? 'Please select access level' : null,
                                        ),
                                        const SizedBox(height: 30),
                                        // Buttons
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: _isSaving ? null : () => _saveStaff(value),
                                              icon: Icon(_editingId != null ? Icons.update : Icons.save),
                                              label: Text(
                                                _editingId != null ? 'Update Staff' : 'Register Staff',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              style: _btnStyle(),
                                            ),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.pushNamed(context, Routes.staffview);
                                              },
                                              icon: const Icon(Icons.view_list),
                                              label: const Text('View Staff', style: TextStyle(fontSize: 12)),
                                              style: _btnStyle(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            if (_showStaffContainer)
                              Container(
                                width: 800,
                                padding: const EdgeInsets.all(12),
                                color: Colors.white,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: value.db
                                      .collection('staff')
                                      .where('schoolId', isEqualTo: value.schoolid)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting &&
                                        !snapshot.hasData) {
                                      return const Center(child: CircularProgressIndicator());
                                    }

                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}',
                                            style: const TextStyle(color: Colors.red)),
                                      );
                                    }

                                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'No staff found.',
                                          style: TextStyle(color: Colors.black54),
                                        ),
                                      );
                                    }

                                    final staffDocs = snapshot.data!.docs;

                                    if (isWideScreen) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 25,
                                          headingRowColor:
                                          WidgetStateProperty.all(const Color(0xFF00496d)),
                                          border: TableBorder.all(color: Colors.grey.shade300),
                                          columns: const [
                                            DataColumn(label: Text('Staff Name', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Phone', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Email', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Sex', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Region', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Access Level', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Action', style: TextStyle(color: Colors.white))),
                                          ],
                                          rows: staffDocs.map((doc) {
                                            final data = doc.data() as Map<String, dynamic>;
                                            return DataRow(cells: [
                                              DataCell(Text(data['name'] ?? '')),
                                              DataCell(Text(data['phone'] ?? '')),
                                              DataCell(Text(data['email'] ?? '')),
                                              DataCell(Text(data['sex'] ?? '')),
                                              DataCell(Text(data['region'] ?? '')),
                                              DataCell(Text(data['accessLevel'] ?? '')),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () => _deleteStaff(
                                                          value, doc.id, data['name'] ?? ''),
                                                      child: const Icon(Icons.delete_forever,
                                                          color: Colors.red, size: 20),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    InkWell(
                                                      onTap: () => _startEditFromMap(data, doc.id),
                                                      child: const Icon(Icons.edit,
                                                          color: Colors.orangeAccent, size: 20),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]);
                                          }).toList(),
                                        ),
                                      );
                                    } else {
                                      return Card(
                                        color: Colors.white,
                                        margin: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            Container(
                                              color: Colors.deepPurple.shade100,
                                              width: double.infinity,
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: Text("Staff Lists",
                                                      style: TextStyle(
                                                          color: Colors.deepPurple,
                                                          fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: staffDocs.length,
                                              itemBuilder: (context, index) {
                                                final data =
                                                staffDocs[index].data() as Map<String, dynamic>;
                                                final id = staffDocs[index].id;

                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      title: Text(data['name'] ?? ''),
                                                      subtitle: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('Phone: ${data['phone'] ?? ''}'),
                                                          Text('Email: ${data['email'] ?? ''}'),
                                                          Text('Sex: ${data['sex'] ?? ''}'),
                                                          Text('Region: ${data['region'] ?? ''}'),
                                                          Text('Access Level: ${data['accessLevel'] ?? ''}'),
                                                        ],
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          InkWell(
                                                            onTap: () => _startEditFromMap(data, id),
                                                            child: const Icon(Icons.edit,
                                                                color: Colors.orangeAccent),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          InkWell(
                                                            onTap: () => _deleteStaff(
                                                                value, id, data['name'] ?? ''),
                                                            child: const Icon(Icons.delete_forever,
                                                                color: Colors.red),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Divider(),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  if (_isSaving)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, String? hint, Color fill) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
      hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00496d))),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      filled: false,
      fillColor: fill,
    );
  }

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00496d),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      textStyle: const TextStyle(fontSize: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
    );
  }
}
