
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/contestantsmodel.dart';
import '../controller/myprovider.dart';

class Singlepromotion extends StatefulWidget {
  const Singlepromotion({super.key});

  @override
  State<Singlepromotion> createState() => _SinglepromotionState();
}

class _SinglepromotionState extends State<Singlepromotion> {

  String? singleTarget;
  final singleKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  Timer? _debounce;
  final studentcontroller = TextEditingController();
  List<StudentModel> selectedStudents = [];
  final previousCtrl = TextEditingController();
  final currentCtrl = TextEditingController();
  final nextCtrl = TextEditingController();
  bool showClassFields = false;
  bool previousReadOnly = true;
  bool currentReadOnly = true;
  bool nextReadOnly = true;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = context.read<Myprovider>();
      await provider.fetchclass();
      await provider.fetchPromotionSettings();
      await provider.fetchstudents();
    });
  }
  @override
  void dispose() {
    _debounce?.cancel();
    studentcontroller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {


    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (BuildContext context, Myprovider values, Widget? child) {
          final classNames = values.classdata.map((e) => e.name).toList();
          final stu = values.searchedStudentModel;

          return Scaffold(
            backgroundColor: const Color(0xFF2D2F45),
            appBar: AppBar(
              title: const Text("Promotion - Single Student "),
              backgroundColor: const Color(0xFF2D2F45),
              foregroundColor: Colors.white,
            ),
            body: values.loadclassdata ? const Center(child: CircularProgressIndicator())
             : Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: singleKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                   "Single Student Promotion", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 15),
                  TextFormField(
                    controller: studentcontroller,
                    decoration: InputDecoration(
                      labelText: "Enter Student ID",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final hud = ProgressHUD.of(context);
                            hud?.showWithText("Searching...");

                            final id = studentcontroller.text.trim().toUpperCase();
                            await values.searchStudent(id);

                            hud?.dismiss();
                          } else {
                            values.clearSearchedStudent();
                          }
                        },
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    validator: (val) {
                      // if (val == null || val.trim().isEmpty) {
                      //   return "Student ID is required";
                      // }
                      // if (val.trim().length < 2) {
                      //   return "Enter at least 2 characters";
                      // }
                      return null;
                    },
                    onChanged: (id) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce =
                          Timer(const Duration(milliseconds: 100), () async {
                            if (id.trim().isEmpty || id.trim().length < 2) {
                              values.clearSearchedStudent();
                            } else {

                              final hud = ProgressHUD.of(context);
                              hud?.showWithText("Searching...");
                             await values.searchStudent(id);
                              hud?.dismiss();
                            }
                          });
                    },
                  ),

                    const SizedBox(height: 20),


                  if (stu != null)
                   Card(
            color: const Color(0xFF252638),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  stu.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                "${stu.name} (${stu.studentid})",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: Text(
                "${stu.department} - ${stu.currentclass}\n${stu.term}",
                style: const TextStyle(color: Colors.white60),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
                onPressed: () async{
                  setState(() {
                    if (!selectedStudents.any((s) => s.studentid == stu.studentid)) {
                      selectedStudents.add(stu);
                    }
                  });
                  values.clearSearchedStudent();
                  studentcontroller.clear();
                },
              ),
            ),
          ),

                   const SizedBox(height: 20),
                    if (selectedStudents.isNotEmpty)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selected Students:",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedStudents.map((stu) {
                              return Chip(
                                backgroundColor: const Color(0xFF30324A),
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Text(
                                    stu.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                label: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${stu.name} (${stu.studentid})",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      stu.region,
                                      style: const TextStyle(fontSize: 10, color: Colors.white60),
                                    ),
                                  ],
                                ),
                                deleteIcon: const Icon(Icons.close, color: Colors.redAccent),
                                onDeleted: () {
                                  setState(() {
                                    selectedStudents.removeWhere(
                                            (x) => x.studentid == stu.studentid);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Select Class",
                        border: OutlineInputBorder(),
                      ),
                      items: classNames.map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      )).toList(),
                      value: singleTarget,

                      onChanged: (selectedClass)  async {
                    setState(() => singleTarget = selectedClass);
                    if (selectedClass == null) return;

                    final db = values.db;
                    final String schoolId = values.schoolid;
                    final String academicYear = values.year;
                    try {
                    final qs = await db .collection('promotion_settings')
                    .where('schoolId', isEqualTo: schoolId)
                    .where('academicyear', isEqualTo: academicYear).get();

                    if (qs.docs.isEmpty) {
                    setState(() {
                    previousCtrl.text = '';
                    currentCtrl.text = '';
                    nextCtrl.text = '';
                    previousReadOnly = false;
                    currentReadOnly = false;
                    nextReadOnly = false;
                    showClassFields = true;
                    });
                    return;
                    }

                    Map<String, dynamic>? matchedRule;
                    for (final doc in qs.docs) {
                    final data = doc.data();
                    final rawRules = data['rules'];

                    if (rawRules is List) {
                    for (final r in rawRules) {
                    final rule = Map<String, dynamic>.from(r);

                    if (rule['current'] == selectedClass) {
                    matchedRule = rule;
                    break;
                       }
                      }
                    }

                    if (matchedRule != null) break;
                    }

                    if (matchedRule != null) {
                    setState(() {
                    previousCtrl.text = matchedRule!['previous'] ?? '';
                    currentCtrl.text = matchedRule!['current'] ?? '';
                    nextCtrl.text = matchedRule!['next'] ?? '';
                    showClassFields = true;
                    });

                 //   print("Loaded Rule → Previous: ${previousCtrl.text}, Current: ${currentCtrl.text}, Next: ${nextCtrl.text}");

                    } else {
                   // print(" No rule found for class $selectedClass");
                    setState(() {
                    previousCtrl.text = '';
                    currentCtrl.text = '';
                    nextCtrl.text = '';
                    });
                    }

                    } catch (e) {
                    print(e);
                    setState(() {
                    previousCtrl.text = '';
                    currentCtrl.text = '';
                    nextCtrl.text = '';
                    });

                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error fetching rules: $e')));
                    }
                    },


                      validator: (v) => v == null ? "Select class" : null,
                    ),

                    const SizedBox(height: 12),
                    if (showClassFields) ...[
                      TextFormField(
                        controller: previousCtrl,
                        readOnly: previousReadOnly,
                        decoration: const InputDecoration(
                          labelText: "Previous Class",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: currentCtrl,
                        readOnly: currentReadOnly,
                        decoration: const InputDecoration(
                          labelText: "Current Class",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nextCtrl,
                        readOnly: nextReadOnly,
                        decoration: const InputDecoration(
                          labelText: "Next Class",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!singleKey.currentState!.validate()) return;

                          final progress = ProgressHUD.of(context);
                          progress?.show();

                          try {

                            final selectedStudentModels = selectedStudents;
                            if (selectedStudentModels.isEmpty) {
                              progress?.dismiss();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("No students selected")),
                              );
                              return;
                            }

                            await values.singlepromotion(
                              students: selectedStudentModels,
                              selectedClass: singleTarget!,
                              previousClass: previousCtrl.text.trim(),
                              currentClass: currentCtrl.text.trim(),
                              nextClass: nextCtrl.text.trim(),
                            );

                            progress?.dismiss();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Promotion completed!")),
                            );
                            setState(() {
                              selectedStudents.clear();
                              selectedStudentModels.clear();
                              values.clearSearchedStudent();
                              singleTarget = null;
                              previousCtrl.clear();
                              currentCtrl.clear();
                              nextCtrl.clear();
                              showClassFields = false;
                            });

                          } catch (e) {
                            progress?.dismiss();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text("Error: $e")));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00496d),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Promote Student", style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },

      ),
    );
  }
}
