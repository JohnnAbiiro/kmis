import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/classmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../widgets/dropdown.dart';

class ClassScreen extends StatefulWidget {
  final ClassModel? classes;
  const ClassScreen({super.key, this.classes});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final classController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selecteddepart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<Myprovider>();
      provider.fetchdepart();
    });


    final data = widget.classes;
    if (data != null) {
      classController.text = data.name;
      selecteddepart = data.department;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFFffffff);
    final isEdit = widget.classes != null;

    return ProgressHUD(
      child: Builder(
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
                    isEdit ? 'Edit Class' : 'Register Class',
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
                              buildDropdown(
                                value: selecteddepart,
                                items: value.departments
                                    .map((e) => e.name)
                                    .toList(),
                                label: "Department",
                                fillColor: inputFill,
                                onChanged: (v) =>
                                    setState(() => selecteddepart = v),
                                validatorMsg: 'Select department',
                              ),
                              const SizedBox(height: 20),

                              // Class Name Input
                              TextFormField(
                                controller: classController,
                                decoration: InputDecoration(
                                  labelText: "Class Name",
                                  hintText: "Enter Class Name",
                                  labelStyle:
                                  const TextStyle(color: Colors.black54),
                                  hintStyle:
                                  const TextStyle(color: Colors.grey),
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
                                  fillColor: inputFill,
                                ),
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Class name cannot be empty';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final progress =
                                        ProgressHUD.of(context);
                                        progress!.show();

                                        String className =
                                        classController.text.trim();
                                        String idd = className
                                            .replaceAll(RegExp(r'\s+'), '')
                                            .toLowerCase();
                                        final id = "${value.schoolid}_$idd"
                                            .replaceAll(" ", "");
                                        final data = ClassModel(
                                          id: id,
                                          name: className,
                                          schoolId: value.schoolid,
                                          department: selecteddepart,
                                          timestamp: DateTime.now(),
                                          staff: value.name,
                                        ).toMap();

                                        await value.db
                                            .collection('classes')
                                            .doc(id)
                                            .set(data, SetOptions(merge: true));

                                        progress.dismiss();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isEdit
                                                  ? 'Class updated successfully'
                                                  : 'Class registered successfully',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );

                                        if (!isEdit) {
                                          classController.clear();
                                          setState(() => selecteddepart = null);
                                        }
                                      }
                                    },
                                    icon: Icon(
                                      isEdit ? Icons.update : Icons.save,
                                    ),
                                    label: Text(
                                      isEdit ? 'Update Class' : 'Register Class',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF00496d),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 15,
                                      ),
                                      textStyle:
                                      const TextStyle(fontSize: 15),
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
                                    label: const Text("View Classes"),
                                    onPressed: () {
                                      Navigator.pushNamed(context, Routes.viewclass);
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
      ),
    );
  }
}
