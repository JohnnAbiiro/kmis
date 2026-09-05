// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_progress_hud/flutter_progress_hud.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../controller/dbmodels/contestantsmodel.dart';
// import '../controller/myprovider.dart';
// import '../controller/routes.dart';
// import '../widgets/dropdown.dart';
//
// class RegisterStudent extends StatefulWidget {
//   final StudentModel? studentData;
//   const RegisterStudent({Key? key, this.studentData}) : super(key: key);
//
//   @override
//   State<RegisterStudent> createState() => _RegisterStudentState();
// }
//
// class _RegisterStudentState extends State<RegisterStudent> {
//   final _formKey = GlobalKey<FormState>();
//   final studentName = TextEditingController();
//   final studentId = TextEditingController();
//   final dob = TextEditingController();
//   final address = TextEditingController();
//   final email = TextEditingController();
//   final phone = TextEditingController();
//
//   // allow multiple guardians/parents
//   final List<TextEditingController> parentNames = [TextEditingController()];
//   final List<TextEditingController> guardianContacts = [TextEditingController()];
//
//   final List<String> _sex = ['male', "female"];
//   final List<String> _status = ['active', 'completed',];
//   final List<String> _yeargroup = List.generate(5, (i) => (2022 + i).toString());
//
//   String? selectedSex;
//   String? selectedLevel;
//   String? selectedTerm;
//   String? selecteddepart;
//   String? selectedYearGroup;
//
//   String? selectedRegion;
//   String? selectedStatus;
//   bool showStudentId = false;
//   String? _uploadedImageUrl = '';
//
//   // 🔹 DOB dropdowns
//   int? selectedDay;
//   String? selectedMonth;
//   int? selectedYear;
//   final List<String> _months = [
//     "01", "02", "03", "04", "05", "06",
//     "07", "08", "09", "10", "11", "12"
//   ];
//   List<int> _years = [];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final provider = Provider.of<Myprovider>(context, listen: false);
//       await provider.getfetchRegions();
//       await provider.fetchdepart();
//       await provider.fetchclass();
//     });
//
//     final now = DateTime.now().year;
//     _years = List.generate(now - 1899, (i) => now - i);
//
//     final data = widget.studentData;
//     print(data);
//     if (data != null) {
//       studentName.text = data.name ?? '';
//       studentId.text = data.studentid ??'';
//       dob.text = data.dob ?? '';
//       address.text = data.address ?? '';
//       email.text = data.email ?? '';
//       phone.text = data.phone ?? '';
//
//       selectedTerm = data.term ?? '';
//       selecteddepart = (data.department.isNotEmpty) ? data.department : null;
//       selectedYearGroup = (data.yeargroup.isNotEmpty) ? data.yeargroup : null;
//       selectedRegion = (data.region.isNotEmpty) ? data.region : null;
//       selectedLevel = (data.level.isNotEmpty) ? data.level : null;
//       selectedStatus = (data.status.isNotEmpty) ? data.status : null;
//       selectedSex = (data.sex.isNotEmpty) ? data.sex : null;
//
//       _uploadedImageUrl = data.photourl;
//       if (dob.text.isNotEmpty) {
//         try {
//           final parts = dob.text.split("-");
//           if (parts.length == 3) {
//             selectedYear = int.tryParse(parts[0]);
//             selectedMonth = parts[1];
//             selectedDay = int.tryParse(parts[2]);
//           }
//         } catch (_) {}
//       }
//       parentNames.clear();
//       for (var p in data.parentname) {
//         parentNames.add(TextEditingController(text: p));
//       }
//
//       guardianContacts.clear();
//       for (var g in data.guardiancontact) {
//         guardianContacts.add(TextEditingController(text: g));
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     studentName.dispose();
//     studentId.dispose();
//     dob.dispose();
//     address.dispose();
//     email.dispose();
//     phone.dispose();
//     for (var c in parentNames) c.dispose();
//     for (var c in guardianContacts) c.dispose();
//     super.dispose();
//   }
//
//   void _updateDob() {
//     if (selectedYear != null && selectedMonth != null && selectedDay != null) {
//       dob.text =
//       "${selectedYear.toString().padLeft(4, '0')}-${selectedMonth!}-${selectedDay.toString().padLeft(2, '0')}";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final inputFill = const Color(0xFFffffff);
//     final isEdit = widget.studentData != null;
//
//     return ProgressHUD(
//       child: Consumer<Myprovider>(
//         builder: (context, value, child) {
//           return Scaffold(
//             appBar: AppBar(
//               backgroundColor: const Color(0xFF2D2F45),
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => context.go(Routes.dashboard),
//               ),
//               title: Text(
//                 isEdit ? 'Edit Student' : 'Register Student',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             body: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
//               child: Align(
//                 alignment: Alignment.topCenter,
//                 child: Container(
//                   color: Colors.white,
//                   margin: const EdgeInsets.all(30.0),
//                   constraints: const BoxConstraints(maxWidth: 800),
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Switch(
//                             value: showStudentId,
//                             onChanged: (val) {
//                               setState(() {
//                                 showStudentId = val;
//                               });
//                             },
//                           ),
//                           if (showStudentId)
//                             SizedBox(
//                               child: _buildTextField(
//                                 controller: studentId,
//                                 label: "Student ID",
//                                 hint: "Auto-generated or enter manually",
//                                 validatorMsg: 'Student ID required',
//                                 fillColor: inputFill,
//                               ),
//                             ),
//                           const SizedBox(height: 10),
//                           buildDropdown(
//                             value: selectedYearGroup,
//                             items: _yeargroup,
//                             label: "Year Group",
//                             fillColor: inputFill,
//                             onChanged: (v) => setState(() => selectedYearGroup = v),
//                             validatorMsg: "Select year group",
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             child: _buildTextField(
//                               controller: studentName,
//                               label: "Student Name",
//                               hint: "Enter student name",
//                               validatorMsg: 'Student name required',
//                               fillColor: inputFill,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           // 🔹 DOB Dropdowns
//                           Row(
//                             children: [
//                               // Day
//                               Expanded(
//                                 child: DropdownButtonFormField<int>(
//                                   value: selectedDay,
//                                   items: List.generate(31, (i) => i + 1)
//                                       .map((d) => DropdownMenuItem(
//                                     value: d,
//                                     child: Text(d.toString(),
//                                         style: const TextStyle(color: Colors.black54)),
//                                   ))
//                                       .toList(),
//                                   onChanged: (v) {
//                                     setState(() {
//                                       selectedDay = v;
//                                       _updateDob();
//                                     });
//                                   },
//                                   decoration: InputDecoration(
//                                     labelText: "Day",
//                                     labelStyle: const TextStyle(color: Colors.black54),
//
//                                     border: const OutlineInputBorder(),
//                                     filled: false,
//                                     fillColor: inputFill,
//                                   ),
//                                   validator: (v) => v == null ? "Select day" : null,
//                                   dropdownColor: inputFill,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//
//                               // Month
//                               Expanded(
//                                 child: DropdownButtonFormField<String>(
//                                   value: selectedMonth,
//                                   items: _months
//                                       .map((m) => DropdownMenuItem(
//                                     value: m,
//                                     child: Text(m,
//                                         style: const TextStyle(color: Colors.black54)),
//                                   ))
//                                       .toList(),
//                                   onChanged: (v) {
//                                     setState(() {
//                                       selectedMonth = v;
//                                       _updateDob();
//                                     });
//                                   },
//                                   decoration: InputDecoration(
//                                     labelText: "Month",
//                                     labelStyle: const TextStyle(color: Colors.black54),
//                                     border: const OutlineInputBorder(),
//                                     filled: false,
//                                     fillColor: inputFill,
//                                   ),
//                                   validator: (v) => v == null ? "Select month" : null,
//                                   dropdownColor: inputFill,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//
//                               // Year
//                               Expanded(
//                                 child: DropdownButtonFormField<int>(
//                                   value: selectedYear,
//                                   items: _years
//                                       .map((y) => DropdownMenuItem(
//                                     value: y,
//                                     child: Text(y.toString(),
//                                         style: const TextStyle(color: Colors.black54)),
//                                   ))
//                                       .toList(),
//                                   onChanged: (v) {
//                                     setState(() {
//                                       selectedYear = v;
//                                       _updateDob();
//                                     });
//                                   },
//                                   decoration: InputDecoration(
//                                     labelText: "Year",
//                                     labelStyle: const TextStyle(color: Colors.black54),
//                                     border: const OutlineInputBorder(),
//                                     filled: false,
//                                     fillColor: inputFill,
//                                   ),
//                                   validator: (v) => v == null ? "Select year" : null,
//                                   dropdownColor: inputFill,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 10),
//                           buildDropdown(value: selectedSex, items: _sex, label: "Sex", fillColor: inputFill, onChanged: (v) => setState(() => selectedSex = v), validatorMsg: 'Select sex',),
//                           const SizedBox(height: 10),
//                           buildDropdown(
//                             value: selectedRegion,
//                             items: value.regionList.map((c) => c.regionname).toList(),
//                             label: "Region",
//                             fillColor: inputFill,
//                             onChanged: (v) => setState(() => selectedRegion = v),
//                             validatorMsg: 'Select region',
//                           ),
//                           const SizedBox(height: 10),
//                           buildDropdown(
//                             value: selectedLevel,
//                             items: value.classdata.map((e) => e.name).toList(),
//                             label: "Class",
//                             fillColor: inputFill,
//                             onChanged: (v) => setState(() => selectedLevel = v),
//                             validatorMsg: 'Select class',
//                           ),
//                           const SizedBox(height: 10),
//                           buildDropdown(
//                             value: selecteddepart,
//                             items: value.departments.map((e) => e.name).toList(),
//                             label: "Department",
//                             fillColor: inputFill,
//                             onChanged: (v) => setState(() => selecteddepart = v),
//                             validatorMsg: 'Select department',
//                           ),
//                           const SizedBox(height: 10),
//                           buildDropdown(
//                             value: selectedStatus,
//                             items: _status,
//                             label: "Status",
//                             fillColor: inputFill,
//                             onChanged: (v) => setState(() => selectedStatus = v),
//                             validatorMsg: 'Select status',
//                           ),
//                           const SizedBox(height: 10),
//                           _buildTextField(
//                             controller: address,
//                             label: "Home Address",
//                             hint: "Enter home address",
//                             validatorMsg: 'Address required',
//                             fillColor: inputFill,
//                           ),
//                           const SizedBox(height: 10),
//
//                           // multiple parent names
//                           Column(
//                             children: [
//                               for (int i = 0; i < parentNames.length; i++)
//                                 Padding(
//                                   padding: const EdgeInsets.only(bottom: 10),
//                                   child: _buildTextField(
//                                     controller: parentNames[i],
//                                     label: "Guardian Name ${i + 1}",
//                                     hint: "Enter guardian name",
//                                     validatorMsg: 'Required',
//                                     fillColor: inputFill,
//                                   ),
//                                 ),
//                               TextButton.icon(
//                                 onPressed: () {
//                                   setState(() => parentNames.add(TextEditingController()));
//                                 },
//                                 icon: const Icon(Icons.add, color: Colors.black54),
//                                 label: const Text("Add another guardian",
//                                     style: TextStyle(color: Colors.black54)),
//                               )
//                             ],
//                           ),
//
//                           // multiple guardian phones
//                           Column(
//                             children: [
//                               for (int i = 0; i < guardianContacts.length; i++)
//                                 Padding(
//                                   padding: const EdgeInsets.only(bottom: 10),
//                                   child: _buildTextField(
//                                     controller: guardianContacts[i],
//                                     label: "Guardian Phone ${i + 1}",
//                                     hint: "Enter guardian phone",
//                                     validatorMsg: 'Required',
//                                     fillColor: inputFill,
//                                     keyboardType: TextInputType.phone,
//                                   ),
//                                 ),
//                               TextButton.icon(
//                                 onPressed: () {
//                                   setState(() => guardianContacts.add(TextEditingController()));
//                                 },
//                                 icon: const Icon(Icons.add, color: Colors.black54),
//                                 label: const Text("Add another phone",
//                                     style: TextStyle(color: Colors.black54)),
//                               )
//                             ],
//                           ),
//
//                           const SizedBox(height: 10),
//                           _buildTextField(
//                             controller: phone,
//                             label: "Student hometown",
//                             hint: "Enter student hometown",
//                             validatorMsg: 'Student hometown required',
//                             fillColor: inputFill,
//                             keyboardType: TextInputType.phone,
//                           ),
//                           const SizedBox(height: 10),
//                           _buildTextField(
//                             controller: email,
//                             label: "Email (optional)",
//                             hint: "Enter student email",
//                             validatorMsg: 'Invalid email',
//                             fillColor: inputFill,
//                             keyboardType: TextInputType.emailAddress,
//                           ),
//                           const SizedBox(height: 20),
//                           _buildImagePicker(value),
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ElevatedButton.icon(
//                                 // onPressed: () async {
//                                 //   if (!_formKey.currentState!.validate()) return;
//                                 //   final progress = ProgressHUD.of(context);
//                                 //   progress?.show();
//                                 //   final query = await value.db .collection('idformats').where('schoolId', isEqualTo: value.schoolid).limit(1).get();
//                                 //  if (query.docs.isEmpty) {
//                                 //     throw Exception("No ID format found for school ${value.schoolid}");
//                                 //   }
//                                 //   final formatRef = query.docs.first.reference;
//                                 //   final generatedId = await value.db.runTransaction((transaction) async {
//                                 //     final snapshot = await transaction.get(formatRef);
//                                 //     final data = snapshot.data() as Map<String, dynamic>;
//                                 //     final prefix = data['name'] as String;
//                                 //     final lastNumber = (data['lastnumber'] ?? 0) as int;
//                                 //     final newNumber = lastNumber + 1;
//                                 //     final newId = '$prefix${newNumber.toString().padLeft(4, '0')}';
//                                 //     transaction.update(formatRef, {"lastnumber": newNumber});
//                                 //     return newId;
//                                 //   });
//                                 //   final nextclass = await value.getnextclass(currentLevel: selectedLevel!);
//                                 //   final sid = showStudentId
//                                 //       ? studentId.text.trim() // use typed ID
//                                 //       : generatedId;
//                                 //   //final id = "${value.schoolid}_$generatedId";
//                                 //   final id = "${value.schoolid}_$sid".toUpperCase();
//                                 //   await value.uploadImage(sid);
//                                 //   final student = StudentModel(
//                                 //     id: widget.studentData?.id ?? id,
//                                 //     studentid: generatedId.toUpperCase(),
//                                 //     name: studentName.text.trim(),
//                                 //     sex: selectedSex ?? "",
//                                 //     school: value.currentschool,
//                                 //     region: selectedRegion ?? "",
//                                 //     guardiancontact: guardianContacts.map((c) => c.text.trim()).toList(),
//                                 //     parentname: parentNames.map((c) => c.text.trim()).toList(),
//                                 //     level: selectedLevel ?? "",
//                                 //     previousclass: nextclass['previous']??'',
//                                 //     nextclass: nextclass["next"] ?? "",
//                                 //     currentclass: selectedLevel ?? "",
//                                 //     term: value.term,
//                                 //     schoolId: value.schoolid,
//                                 //     dob: dob.text.trim(),
//                                 //     address: address.text.trim(),
//                                 //     email: email.text.trim().isEmpty ? null : email.text.trim(),
//                                 //     phone: phone.text.trim(),
//                                 //     timestamp: DateTime.now().toIso8601String(),
//                                 //     photourl: value.imageUrl.isNotEmpty
//                                 //         ? value.imageUrl
//                                 //         : _uploadedImageUrl ?? "",
//                                 //     status: selectedStatus ?? "active",
//                                 //     department: selecteddepart ?? "",
//                                 //     yeargroup: DateTime.now().year.toString(),
//                                 //     academicyr: value.year,
//                                 //
//                                 //   );
//                                 //   await value.db.collection("students")
//                                 //       .doc(student.id)
//                                 //       .set(student.toMap(), SetOptions(merge: true));
//                                 //   progress?.dismiss();
//                                 //   ScaffoldMessenger.of(context).showSnackBar(
//                                 //     SnackBar(
//                                 //       content: Text(isEdit
//                                 //           ? 'Student Updated Successfully'
//                                 //           : 'Student Registered Successfully'),
//                                 //       backgroundColor: Colors.green,
//                                 //     ),
//                                 //   );
//                                 //
//                                 //   value.imagefile = null;
//                                 //
//                                 //   if (!isEdit) {
//                                 //     setState(() {
//                                 //       value.imageUrl = "";
//                                 //       _uploadedImageUrl = "";
//                                 //     });
//                                 //     studentName.clear();
//                                 //     studentId.clear();
//                                 //     dob.clear();
//                                 //     address.clear();
//                                 //     email.clear();
//                                 //     phone.clear();
//                                 //     parentNames.clear();
//                                 //     guardianContacts.clear();
//                                 //     parentNames.add(TextEditingController());
//                                 //     guardianContacts.add(TextEditingController());
//                                 //     selectedDay = null;
//                                 //     selectedMonth = null;
//                                 //     selectedYear = null;
//                                 //   }
//                                 // },
//                                 onPressed: () async {
//                                   if (!_formKey.currentState!.validate()) return;
//                                   final progress = ProgressHUD.of(context);
//                                   progress?.show();
//
//                                   String finalStudentId;
//                                   String finalId;
//
//                                   if (isEdit) {
//                                     finalStudentId = widget.studentData!.studentid;
//                                     finalId = widget.studentData!.id;
//                                   } else {
//                                     final query = await value.db
//                                         .collection('idformats')
//                                         .where('schoolId', isEqualTo: value.schoolid)
//                                         .limit(1)
//                                         .get();
//                                     if (query.docs.isEmpty) {
//                                       throw Exception("No ID format found for school ${value.schoolid}");
//                                     }
//                                     final formatRef = query.docs.first.reference;
//                                     final generatedId = await value.db.runTransaction((transaction) async {
//                                       final snapshot = await transaction.get(formatRef);
//                                       final data = snapshot.data() as Map<String, dynamic>;
//                                       final prefix = data['name'] as String;
//                                       final lastNumber = (data['lastnumber'] ?? 0) as int;
//                                       final newNumber = lastNumber + 1;
//                                       final newId = '$prefix${newNumber.toString().padLeft(4, '0')}';
//                                       transaction.update(formatRef, {"lastnumber": newNumber});
//                                       return newId;
//                                     });
//                                     final sid = showStudentId ? studentId.text.trim() : generatedId;
//                                     finalStudentId = generatedId.toUpperCase();
//                                     finalId = "${value.schoolid}_$sid".toUpperCase();
//                                   }
//
//                                   final nextclass = await value.getnextclass(currentLevel: selectedLevel!);
//                                   await value.uploadImage(finalStudentId);
//                                   final student = StudentModel(
//                                     id: finalId,
//                                     studentid: finalStudentId,
//                                     name: studentName.text.trim(),
//                                     sex: selectedSex ?? "",
//                                     school: value.currentschool,
//                                     region: selectedRegion ?? "",
//                                     guardiancontact: guardianContacts.map((c) => c.text.trim()).toList(),
//                                     parentname: parentNames.map((c) => c.text.trim()).toList(),
//                                     level: selectedLevel ?? "",
//                                     previousclass: nextclass['previous'] ?? '',
//                                     nextclass: nextclass["next"] ?? "",
//                                     currentclass: selectedLevel ?? "",
//                                     term: value.term,
//                                     schoolId: value.schoolid,
//                                     dob: dob.text.trim(),
//                                     address: address.text.trim(),
//                                     email: email.text.trim().isEmpty ? null : email.text.trim(),
//                                     phone: phone.text.trim(),
//                                     timestamp: DateTime.now().toIso8601String(),
//                                     photourl: value.imageUrl.isNotEmpty ? value.imageUrl : _uploadedImageUrl ?? "",
//                                     status: selectedStatus ?? "active",
//                                     accessLevel: "student",
//                                     department: selecteddepart ?? "",
//                                     yeargroup: DateTime.now().year.toString(),
//                                     academicyr: value.year,
//                                   );
//                                   await value.db
//                                       .collection("students")
//                                       .doc(student.id)
//                                       .set(student.toMap(), SetOptions(merge: true));
//                                   progress?.dismiss();
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(isEdit
//                                           ? 'Student Updated Successfully'
//                                           : 'Student Registered Successfully'),
//                                       backgroundColor: Colors.green,
//                                     ),
//                                   );
//
//                                   value.imagefile = null;
//
//                                   if (!isEdit) {
//                                     setState(() {
//                                       value.imageUrl = "";
//                                       _uploadedImageUrl = "";
//                                     });
//                                     studentName.clear();
//                                     studentId.clear();
//                                     dob.clear();
//                                     address.clear();
//                                     email.clear();
//                                     phone.clear();
//                                     parentNames.clear();
//                                     guardianContacts.clear();
//                                     parentNames.add(TextEditingController());
//                                     guardianContacts.add(TextEditingController());
//                                     selectedDay = null;
//                                     selectedMonth = null;
//                                     selectedYear = null;
//                                   }
//                                 },
//                                 icon: Icon(isEdit ? Icons.update : Icons.save),
//                                 label: Text(isEdit ? 'Update Student' : 'Register Student'),
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Color(0xFF00496d),
//                                     foregroundColor: Colors.white
//                                 ),
//                               ),
//                               SizedBox(width: 16),
//                               OutlinedButton.icon(
//                                 style: OutlinedButton.styleFrom(
//                                   side:
//                                   const BorderSide(color: Color(0xFF00496d)),
//                                   foregroundColor: Colors.black54,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 14),
//                                 ),
//                                 icon: const Icon(Icons.list),
//                                 label: const Text("View Students"),
//                                 onPressed: () {
//                                   Navigator.pushNamed(context, Routes.viewstudentlist);
//                                 },
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required String validatorMsg,
//     required Color fillColor,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         labelStyle: const TextStyle(color: Colors.black54),
//         hintStyle: const TextStyle(color: Colors.grey),
//         border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
//         enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
//         focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00496d))),
//         contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//         filled: false,
//         fillColor: fillColor,
//       ),
//       style: const TextStyle(fontSize: 16, color: Colors.black),
//       validator: (value) {
//         if (value == null || value.trim().isEmpty) return validatorMsg;
//         return null;
//       },
//     );
//   }
//
//
//
//   Widget _buildImagePicker(Myprovider value) {
//     return InkWell(
//       onTap: () => value.pickImageFromGallery(context),
//       borderRadius: BorderRadius.circular(50),
//       child: SizedBox(
//         width: 100,
//         height: 100,
//         child: ClipOval(
//             child: kIsWeb
//                 ? (value.imagefile != null
//                 ? Image.network(value.imagefile!.path, fit: BoxFit.cover)
//                 : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty
//                 ? CachedNetworkImage(imageUrl: _uploadedImageUrl!, fit: BoxFit.cover)
//                 : const Icon(Icons.person, size: 40, color: Colors.black54)))
//                 : (value.imagefile != null
//                 ? Image.file(File(value.imagefile!.path), fit: BoxFit.cover)
//                 : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty
//                 ? CachedNetworkImage(imageUrl: _uploadedImageUrl!, fit: BoxFit.cover)
//                 : const Icon(Icons.person, size: 40, color: Colors.white54)))),
//       ),
//
//     );
//   }
// }

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/contestantsmodel.dart';
import '../controller/dbmodels/idformatmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../widgets/dropdown.dart';

class RegisterStudent extends StatefulWidget {
  final StudentModel? studentData;
  const RegisterStudent({Key? key, this.studentData}) : super(key: key);

  @override
  State<RegisterStudent> createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {
  final _formKey = GlobalKey<FormState>();
  final studentName = TextEditingController();
  final studentId = TextEditingController();
  final dob = TextEditingController();
  final address = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  // allow multiple guardians/parents
  final List<TextEditingController> parentNames = [TextEditingController()];
  final List<TextEditingController> guardianContacts = [TextEditingController()];

  final List<String> _sex = ['male', "female"];
  final List<String> _status = ['active', 'completed',];
  final List<String> _yeargroup = List.generate(5, (i) => (2022 + i).toString());

  String? selectedSex;
  String? selectedLevel;
  String? selectedTerm;
  String? selecteddepart;
  String? selectedYearGroup;

  String? selectedRegion;
  String? selectedStatus;
  bool showStudentId = false;
  String? _uploadedImageUrl = '';

  // A school can have more than one id format (e.g. schoolId "KS0002" owns
  // both "KS0002_FF" and "KS0002_LAMP"), so the registrar has to pick which
  // one to use when auto-generating — it can't be inferred with a blind
  // `.limit(1)` query. Stores the selected format's display name; resolved
  // back to its IdformatModel (and doc id) at submit time.
  String? selectedIdFormat;

  // 🔹 DOB dropdowns
  int? selectedDay;
  String? selectedMonth;
  int? selectedYear;
  final List<String> _months = [
    "01", "02", "03", "04", "05", "06",
    "07", "08", "09", "10", "11", "12"
  ];
  List<int> _years = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<Myprovider>(context, listen: false);
      await provider.getfetchRegions();
      await provider.fetchdepart();
      await provider.fetchclass();
      await provider.fetchIdFormats();
    });

    final now = DateTime.now().year;
    _years = List.generate(now - 1899, (i) => now - i);

    final data = widget.studentData;
    if (data != null) {
      studentName.text = data.name ?? '';
      studentId.text = data.studentid ??'';
      dob.text = data.dob ?? '';
      address.text = data.address ?? '';
      email.text = data.email ?? '';
      phone.text = data.phone ?? '';

      selectedTerm = data.term ?? '';
      selecteddepart = (data.department.isNotEmpty) ? data.department : null;
      selectedYearGroup = (data.yeargroup.isNotEmpty) ? data.yeargroup : null;
      selectedRegion = (data.region.isNotEmpty) ? data.region : null;
      selectedLevel = (data.level.isNotEmpty) ? data.level : null;
      selectedStatus = (data.status.isNotEmpty) ? data.status : null;
      selectedSex = (data.sex.isNotEmpty) ? data.sex : null;

      _uploadedImageUrl = data.photourl;
      if (dob.text.isNotEmpty) {
        try {
          final parts = dob.text.split("-");
          if (parts.length == 3) {
            selectedYear = int.tryParse(parts[0]);
            selectedMonth = parts[1];
            selectedDay = int.tryParse(parts[2]);
          }
        } catch (_) {}
      }
      parentNames.clear();
      for (var p in data.parentname) {
        parentNames.add(TextEditingController(text: p));
      }

      guardianContacts.clear();
      for (var g in data.guardiancontact) {
        guardianContacts.add(TextEditingController(text: g));
      }
    }
  }

  @override
  void dispose() {
    studentName.dispose();
    studentId.dispose();
    dob.dispose();
    address.dispose();
    email.dispose();
    phone.dispose();
    for (var c in parentNames) c.dispose();
    for (var c in guardianContacts) c.dispose();
    super.dispose();
  }

  void _updateDob() {
    if (selectedYear != null && selectedMonth != null && selectedDay != null) {
      dob.text =
      "${selectedYear.toString().padLeft(4, '0')}-${selectedMonth!}-${selectedDay.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _handleSubmit(Myprovider value, bool isEdit) async {
    if (!_formKey.currentState!.validate()) return;

    if (!isEdit && !showStudentId) {
      // Only require a manual pick when the school actually has more than
      // one id format to choose between — with exactly one, there's
      // nothing to decide and no reason to make the registrar select it.
      final formatCount = value.idFormats.length;
      if (formatCount > 1 && selectedIdFormat == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select an ID format'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (formatCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No ID format found for school ${value.schoolid}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final progress = ProgressHUD.of(context);
    progress?.show();

    try {
      String finalStudentId;
      String finalId;

      if (isEdit) {
        // Student ID is permanent once a record exists — the "Student ID"
        // field is disabled in edit mode (see build()), but even so we
        // never derive the id from it here. This guarantees a rename can
        // never accidentally move the record to a different doc.
        finalStudentId = widget.studentData!.studentid;
        finalId = widget.studentData!.id;
      } else if (showStudentId) {
        // Manual entry: this id is deterministic (schoolid_studentid), so
        // check whether it's already taken before writing — otherwise a
        // typed duplicate would silently overwrite an existing student via
        // merge: true.
        final sid = studentId.text.trim().toUpperCase();
        final candidateId = "${value.schoolid}_$sid".toUpperCase();

        final existing =
        await value.db.collection('students').doc(candidateId).get();
        if (existing.exists) {
          progress?.dismiss();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('A student with ID "$sid" already exists'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        finalStudentId = sid;
        finalId = candidateId;
      } else {
        // Auto-generated: driven by an atomic counter transaction on the
        // selected id format doc, so the generated id is unique by
        // construction — no separate duplicate check is needed for this
        // path. A school can own more than one id format (e.g. "FF" and
        // "LAMP" both under schoolId "KS0002"); when it does, we resolve
        // exactly the one the registrar picked. When it only has one, we
        // use that one directly without requiring a pick.
        final available = value.idFormats;
        final format = available.length == 1
            ? available.first
            : available.firstWhere(
              (f) => f.name == selectedIdFormat,
          orElse: () => throw Exception('Select an ID format'),
        );
        final formatRef = value.db.collection('idformats').doc(format.id);
        final generatedId = await value.db.runTransaction((transaction) async {
          final snapshot = await transaction.get(formatRef);
          final data = snapshot.data() as Map<String, dynamic>;
          final prefix = data['name'] as String;
          final lastNumber = (data['lastnumber'] ?? 0) as int;
          final newNumber = lastNumber + 1;
          final newId = '$prefix${newNumber.toString().padLeft(4, '0')}';
          transaction.update(formatRef, {"lastnumber": newNumber});
          return newId;
        });
        finalStudentId = generatedId.toUpperCase();
        finalId = "${value.schoolid}_$generatedId".toUpperCase();
      }

      final nextclass = await value.getnextclass(currentLevel: selectedLevel!);
      await value.uploadImage(finalStudentId);
      final student = StudentModel(
        id: finalId,
        studentid: finalStudentId,
        name: studentName.text.trim(),
        sex: selectedSex ?? "",
        school: value.currentschool,
        region: selectedRegion ?? "",
        guardiancontact: guardianContacts.map((c) => c.text.trim()).toList(),
        parentname: parentNames.map((c) => c.text.trim()).toList(),
        level: selectedLevel ?? "",
        previousclass: nextclass['previous'] ?? '',
        nextclass: nextclass["next"] ?? "",
        currentclass: selectedLevel ?? "",
        term: value.term,
        schoolId: value.schoolid,
        dob: dob.text.trim(),
        address: address.text.trim(),
        email: email.text.trim().isEmpty ? null : email.text.trim(),
        phone: phone.text.trim(),
        timestamp: DateTime.now().toIso8601String(),
        photourl: value.imageUrl.isNotEmpty ? value.imageUrl : _uploadedImageUrl ?? "",
        status: selectedStatus ?? "active",
        accessLevel: "student",
        department: selecteddepart ?? "",
        yeargroup: DateTime.now().year.toString(),
        academicyr: value.year,
      );

      await value.db
          .collection("students")
          .doc(student.id)
          .set(student.toMap(), SetOptions(merge: true));

      // Keep the in-memory list in sync so the student list view reflects
      // this save immediately, without waiting on a fresh fetch — same
      // write-then-mutate-in-memory pattern as upsertClass / upsertDepartment
      // / upsertFaculty / upsertIdFormat already in Myprovider.
      value.upsertStudent(student);

      progress?.dismiss();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit
              ? 'Student Updated Successfully'
              : 'Student Registered Successfully'),
          backgroundColor: Colors.green,
        ),
      );

      value.imagefile = null;

      if (!isEdit) {
        setState(() {
          value.imageUrl = "";
          _uploadedImageUrl = "";
        });
        studentName.clear();
        studentId.clear();
        dob.clear();
        address.clear();
        email.clear();
        phone.clear();
        parentNames.clear();
        guardianContacts.clear();
        parentNames.add(TextEditingController());
        guardianContacts.add(TextEditingController());
        selectedDay = null;
        selectedMonth = null;
        selectedYear = null;
      }
    } catch (e) {
      progress?.dismiss();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFFffffff);
    final isEdit = widget.studentData != null;

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, value, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF2D2F45),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go(Routes.dashboard),
              ),
              title: Text(
                isEdit ? 'Edit Student' : 'Register Student',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: Colors.white,
                  margin: const EdgeInsets.all(30.0),
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Switch(
                            // Toggling manual Student ID entry only makes
                            // sense when creating a new student — on edit
                            // the id is permanent, so the switch (and the
                            // field below) are locked to reflect that.
                            value: isEdit ? true : showStudentId,
                            onChanged: isEdit
                                ? null
                                : (val) {
                              setState(() {
                                showStudentId = val;
                              });
                            },
                          ),
                          if (showStudentId || isEdit)
                            SizedBox(
                              child: _buildTextField(
                                controller: studentId,
                                label: "Student ID",
                                hint: "Auto-generated or enter manually",
                                validatorMsg: 'Student ID required',
                                fillColor: inputFill,
                                enabled: !isEdit,
                              ),
                            ),
                          // Only shown when there's an actual decision to
                          // make — a school with just one id format uses it
                          // automatically (see _handleSubmit), no picker
                          // needed. Shown when the school has more than one
                          // (e.g. "FF" vs "LAMP") and we're auto-generating.
                          if (!isEdit && !showStudentId && value.idFormats.length > 1)
                            SizedBox(
                              child: buildDropdown(
                                value: selectedIdFormat,
                                items: value.idFormats.map((f) => f.name).toList(),
                                label: "ID Format",
                                fillColor: inputFill,
                                onChanged: (v) => setState(() => selectedIdFormat = v),
                                validatorMsg: 'Select an ID format',
                              ),
                            ),
                          const SizedBox(height: 10),
                          buildDropdown(
                            value: selectedYearGroup,
                            items: _yeargroup,
                            label: "Year Group",
                            fillColor: inputFill,
                            onChanged: (v) => setState(() => selectedYearGroup = v),
                            validatorMsg: "Select year group",
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            child: _buildTextField(
                              controller: studentName,
                              label: "Student Name",
                              hint: "Enter student name",
                              validatorMsg: 'Student name required',
                              fillColor: inputFill,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 🔹 DOB Dropdowns
                          Row(
                            children: [
                              // Day
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: selectedDay,
                                  items: List.generate(31, (i) => i + 1)
                                      .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d.toString(),
                                        style: const TextStyle(color: Colors.black54)),
                                  ))
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      selectedDay = v;
                                      _updateDob();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Day",
                                    labelStyle: const TextStyle(color: Colors.black54),

                                    border: const OutlineInputBorder(),
                                    filled: false,
                                    fillColor: inputFill,
                                  ),
                                  validator: (v) => v == null ? "Select day" : null,
                                  dropdownColor: inputFill,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Month
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedMonth,
                                  items: _months
                                      .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m,
                                        style: const TextStyle(color: Colors.black54)),
                                  ))
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      selectedMonth = v;
                                      _updateDob();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Month",
                                    labelStyle: const TextStyle(color: Colors.black54),
                                    border: const OutlineInputBorder(),
                                    filled: false,
                                    fillColor: inputFill,
                                  ),
                                  validator: (v) => v == null ? "Select month" : null,
                                  dropdownColor: inputFill,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Year
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: selectedYear,
                                  items: _years
                                      .map((y) => DropdownMenuItem(
                                    value: y,
                                    child: Text(y.toString(),
                                        style: const TextStyle(color: Colors.black54)),
                                  ))
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      selectedYear = v;
                                      _updateDob();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Year",
                                    labelStyle: const TextStyle(color: Colors.black54),
                                    border: const OutlineInputBorder(),
                                    filled: false,
                                    fillColor: inputFill,
                                  ),
                                  validator: (v) => v == null ? "Select year" : null,
                                  dropdownColor: inputFill,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          buildDropdown(value: selectedSex, items: _sex, label: "Sex", fillColor: inputFill, onChanged: (v) => setState(() => selectedSex = v), validatorMsg: 'Select sex',),
                          const SizedBox(height: 10),
                          buildDropdown(
                            value: selectedRegion,
                            items: value.regionList.map((c) => c.regionname).toList(),
                            label: "Region",
                            fillColor: inputFill,
                            onChanged: (v) => setState(() => selectedRegion = v),
                            validatorMsg: 'Select region',
                          ),
                          const SizedBox(height: 10),
                          buildDropdown(
                            value: selectedLevel,
                            items: value.classdata.map((e) => e.name).toList(),
                            label: "Class",
                            fillColor: inputFill,
                            onChanged: (v) => setState(() => selectedLevel = v),
                            validatorMsg: 'Select class',
                          ),
                          const SizedBox(height: 10),
                          buildDropdown(
                            value: selecteddepart,
                            items: value.departments.map((e) => e.name).toList(),
                            label: "Department",
                            fillColor: inputFill,
                            onChanged: (v) => setState(() => selecteddepart = v),
                            validatorMsg: 'Select department',
                          ),
                          const SizedBox(height: 10),
                          buildDropdown(
                            value: selectedStatus,
                            items: _status,
                            label: "Status",
                            fillColor: inputFill,
                            onChanged: (v) => setState(() => selectedStatus = v),
                            validatorMsg: 'Select status',
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: address,
                            label: "Home Address",
                            hint: "Enter home address",
                            validatorMsg: 'Address required',
                            fillColor: inputFill,
                          ),
                          const SizedBox(height: 10),

                          // multiple parent names
                          Column(
                            children: [
                              for (int i = 0; i < parentNames.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _buildTextField(
                                    controller: parentNames[i],
                                    label: "Guardian Name ${i + 1}",
                                    hint: "Enter guardian name",
                                    validatorMsg: 'Required',
                                    fillColor: inputFill,
                                  ),
                                ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => parentNames.add(TextEditingController()));
                                },
                                icon: const Icon(Icons.add, color: Colors.black54),
                                label: const Text("Add another guardian",
                                    style: TextStyle(color: Colors.black54)),
                              )
                            ],
                          ),

                          // multiple guardian phones
                          Column(
                            children: [
                              for (int i = 0; i < guardianContacts.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _buildTextField(
                                    controller: guardianContacts[i],
                                    label: "Guardian Phone ${i + 1}",
                                    hint: "Enter guardian phone",
                                    validatorMsg: 'Required',
                                    fillColor: inputFill,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => guardianContacts.add(TextEditingController()));
                                },
                                icon: const Icon(Icons.add, color: Colors.black54),
                                label: const Text("Add another phone",
                                    style: TextStyle(color: Colors.black54)),
                              )
                            ],
                          ),

                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: phone,
                            label: "Student hometown",
                            hint: "Enter student hometown",
                            validatorMsg: 'Student hometown required',
                            fillColor: inputFill,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: email,
                            label: "Email (optional)",
                            hint: "Enter student email",
                            validatorMsg: 'Invalid email',
                            fillColor: inputFill,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          _buildImagePicker(value),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _handleSubmit(value, isEdit),
                                icon: Icon(isEdit ? Icons.update : Icons.save),
                                label: Text(isEdit ? 'Update Student' : 'Register Student'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00496d),
                                    foregroundColor: Colors.white
                                ),
                              ),
                              SizedBox(width: 16),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side:
                                  const BorderSide(color: Color(0xFF00496d)),
                                  foregroundColor: Colors.black54,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                ),
                                icon: const Icon(Icons.list),
                                label: const Text("View Students"),
                                onPressed: () {
                                  Navigator.pushNamed(context, Routes.viewstudentlist);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String validatorMsg,
    required Color fillColor,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00496d))),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        filled: false,
        fillColor: fillColor,
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return validatorMsg;
        return null;
      },
    );
  }



  Widget _buildImagePicker(Myprovider value) {
    return InkWell(
      onTap: () => value.pickImageFromGallery(context),
      borderRadius: BorderRadius.circular(50),
      child: SizedBox(
        width: 100,
        height: 100,
        child: ClipOval(
            child: kIsWeb
                ? (value.imagefile != null
                ? Image.network(value.imagefile!.path, fit: BoxFit.cover)
                : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty
                ? CachedNetworkImage(imageUrl: _uploadedImageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.person, size: 40, color: Colors.black54)))
                : (value.imagefile != null
                ? Image.file(File(value.imagefile!.path), fit: BoxFit.cover)
                : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty
                ? CachedNetworkImage(imageUrl: _uploadedImageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.person, size: 40, color: Colors.white54)))),
      ),

    );
  }
}