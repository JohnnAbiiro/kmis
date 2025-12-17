import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/contestantsmodel.dart';
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
    });

    final now = DateTime.now().year;
    _years = List.generate(now - 1899, (i) => now - i);

    final data = widget.studentData;
    if (data != null) {
      studentName.text = data.name;
      studentId.text = data.studentid;
      dob.text = data.dob;
      address.text = data.address;
      email.text = data.email ?? '';
      phone.text = data.phone;
      selectedSex = data.sex;
      selectedLevel = data.level;
      selectedRegion = data.region;
      selectedStatus = data.status;
      selectedTerm = data.term;
      _uploadedImageUrl = data.photourl;

      // parse DOB into dropdowns
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

      // populate multiple guardians/parents
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
                          /*
                          SizedBox(
                            child: _buildTextField(
                              controller: studentId,
                              label: "Student ID",
                              hint: "Auto-generated or enter manually",
                              validatorMsg: 'Student ID required',
                              fillColor: inputFill,
                            ),
                          ),
                          */
                          Switch(
                            value: showStudentId,
                            onChanged: (val) {
                              setState(() {
                                showStudentId = val;
                              });
                            },
                          ),
                          if (showStudentId)
                            SizedBox(
                              child: _buildTextField(
                                controller: studentId,
                                label: "Student ID",
                                hint: "Auto-generated or enter manually",
                                validatorMsg: 'Student ID required',
                                fillColor: inputFill,
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
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  final progress = ProgressHUD.of(context);
                                  progress?.show();
                                  final query = await value.db
                                      .collection('idformats').where('schoolId', isEqualTo: value.schoolid)
                                      .limit(1)
                                      .get();

                                  if (query.docs.isEmpty) {
                                    throw Exception("No ID format found for school ${value.schoolid}");
                                  }
                                  final formatRef = query.docs.first.reference;
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
                                  final sid = showStudentId
                                      ? studentId.text.trim() // use typed ID
                                      : generatedId;
                                  //final id = "${value.schoolid}_$generatedId";
                                  final id = "${value.schoolid}_$sid";
                                  await value.uploadImage(sid);
                                  final student = StudentModel(
                                    id: widget.studentData?.id ?? id,
                                    studentid: generatedId,
                                    name: studentName.text.trim(),
                                    sex: selectedSex ?? "",
                                    school: value.currentschool,
                                    region: selectedRegion ?? "",
                                    guardiancontact: guardianContacts.map((c) => c.text.trim()).toList(),
                                    parentname: parentNames.map((c) => c.text.trim()).toList(),
                                    level: selectedLevel ?? "",
                                    term: value.term,
                                    schoolId: value.schoolid,
                                    dob: dob.text.trim(),
                                    address: address.text.trim(),
                                    email: email.text.trim().isEmpty ? null : email.text.trim(),
                                    phone: phone.text.trim(),
                                    timestamp: DateTime.now().toIso8601String(),
                                    photourl: value.imageUrl.isNotEmpty
                                        ? value.imageUrl
                                        : _uploadedImageUrl ?? "",
                                    status: selectedStatus ?? "active",
                                    department: selecteddepart ?? "",
                                    yeargroup: '2025',
                                  );
                                  await value.db.collection("students")
                                      .doc(student.id)
                                      .set(student.toMap(), SetOptions(merge: true));
                                  progress?.dismiss();
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
                                },
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
                                  context.go(Routes.viewstudentlist);
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
