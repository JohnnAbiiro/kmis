

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/departmodel.dart';
import '../controller/dbmodels/facultymodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class FacultyPage extends StatefulWidget {
  final FacultyModel? faculty;
  const FacultyPage({super.key, this.faculty});

  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  final facultyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final data = widget.faculty;
    if (data != null) {
      facultyController.text = data.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFF2C2C3C);
    final isEdit = widget.faculty != null;

    return Builder(
      builder: (context) {
        return Consumer<Myprovider>(
          builder: (BuildContext context, Myprovider value, Widget? child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFF2D2F45),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context,true),
                ),
                title: Text(
                  isEdit ? 'Edit Faculty' : 'Register Faculty',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 16,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: const Color(0xFFffffff),
                    margin: const EdgeInsets.all(30.0),
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: facultyController,
                              decoration: InputDecoration(
                                labelText: "Faculty Name",
                                hintText: "Enter Faculty Name",
                                labelStyle: const TextStyle(color: Colors.black54),
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[700]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[700]!,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF00496d),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                filled: false,
                                //fillColor: inputFill,
                              ),
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Department name cannot be empty';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final progress = ProgressHUD.of(context);
                                      progress!.show();

                                      String departmentName = facultyController.text.trim();
                                      String idd = departmentName.replaceAll(RegExp(r'\s+'), '').toLowerCase();
                                      final id = "${value.schoolid}_$idd".replaceAll(" ", "");
                                      final data = DepartmentModel(
                                        id: id,
                                        name: departmentName,
                                        schoolId: value.schoolid,
                                        timestamp: DateTime.now(),
                                        staff: value.name,
                                      ).toMap();

                                      await value.db
                                          .collection('faculties')
                                          .doc(id)
                                          .set(data, SetOptions(merge: true));

                                      progress.dismiss();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEdit
                                                ? 'Department updated successfully'
                                                : 'Department registered successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      if (!isEdit) {
                                        facultyController.clear();
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    isEdit ? Icons.update : Icons.save,
                                  ),
                                  label: Text(
                                    isEdit ? 'Update Faculty' : 'Register Faculty',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00496d),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 15,
                                    ),
                                    //textStyle: const TextStyle(fontSize: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                ),
                                const SizedBox(width: 20),

                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side:
                                    const BorderSide(color: Color(0xFF00496d)),
                                    foregroundColor: Colors.black54,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 14),
                                  ),
                                  icon: const Icon(Icons.list),
                                  label: const Text("View Faculty"),
                                  onPressed: () {
                                    context.go(Routes.viewfaculty);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
