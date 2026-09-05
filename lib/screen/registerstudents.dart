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
  const RegisterStudent({super.key, this.studentData});

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

  String? selectedIdFormat;

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
      if (!mounted) return;
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
      studentName.text = data.name;
      studentId.text = data.studentid;
      dob.text = data.dob;
      address.text = data.address;
      email.text = data.email ?? '';
      phone.text = data.phone;

      selectedTerm = data.term;
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
    for (var c in parentNames) {
      c.dispose();
    }
    for (var c in guardianContacts) {
      c.dispose();
    }
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
      final formatCount = value.idFormats.length;
      if (formatCount > 1 && selectedIdFormat == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select an ID format'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (formatCount == 0) {
        if (!context.mounted) return;
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
        finalStudentId = widget.studentData!.studentid;
        finalId = widget.studentData!.id;
      } else if (showStudentId) {
        final sid = studentId.text.trim().toUpperCase();
        final candidateId = "${value.schoolid}_$sid".toUpperCase();

        final existing = await value.db.collection('students').doc(candidateId).get();
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
    final colors = Theme.of(context).colorScheme;
    final inputFill = colors.surface;
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
                          if (!isEdit && !showStudentId && value.idFormats.length > 1)
                            SizedBox(
                              child: DropdownWidget.buildDropdown(
                                dropdownContext: context,
                                value: selectedIdFormat,
                                items: value.idFormats.map((f) => f.name).toList(),
                                label: "ID Format",
                                fillColor: inputFill,
                                onChanged: (v) => setState(() => selectedIdFormat = v),
                                validatorMsg: 'Select an ID format',
                              ),
                            ),
                          const SizedBox(height: 10),
                          DropdownWidget.buildDropdown(
                            dropdownContext: context,
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
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: selectedDay,
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
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedMonth,
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
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: selectedYear,
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
                          DropdownWidget.buildDropdown(dropdownContext: context, value: selectedSex, items: _sex, label: "Sex", fillColor: inputFill, onChanged: (v) => setState(() => selectedSex = v), validatorMsg: 'Select sex',),
                          const SizedBox(height: 10),
                          DropdownWidget.buildDropdown(
                            dropdownContext: context,
                            value: selectedRegion,
                            items: value.regionList.map((c) => c.regionname).toList(),
                            label: "Region",
                            fillColor: inputFill,
                            onChanged: (v) => setState(() => selectedRegion = v),
                            validatorMsg: 'Select region',
                          ),
                          const SizedBox(height: 10),
                          DropdownWidget.buildDropdown(
                            dropdownContext: context,
                            value: selectedLevel,
                            items: value.classdata.map((e) => e.name).toList(),
                            label: "Class",
                            fillColor: inputFill,
                            onChanged: (v) => setState(() => selectedLevel = v),
                            validatorMsg: 'Select class',
                          ),
                          const SizedBox(height: 10),
                          DropdownWidget.buildDropdown(
                            dropdownContext: context,
                            value: selecteddepart,
                            items: value.departments.map((e) => e.name).toList(),
                            label: "Department",
                            fillColor: inputFill,
                            onChanged: (v) => setState(() => selecteddepart = v),
                            validatorMsg: 'Select department',
                          ),
                          const SizedBox(height: 10),
                          DropdownWidget.buildDropdown(
                            dropdownContext: context,
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
                                    backgroundColor: const Color(0xFF00496d),
                                    foregroundColor: Colors.white
                                ),
                              ),
                              const SizedBox(width: 16),
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
        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
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
