import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/classmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../widgets/dropdown.dart';

class ClassPromotion extends StatefulWidget {
  final ClassModel? classes;
  const ClassPromotion({super.key, this.classes});

  @override
  State<ClassPromotion> createState() => _ClassPromotionState();
}

class _ClassPromotionState extends State<ClassPromotion> {
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
    final colors = Theme.of(context).colorScheme;
    final isEdit = widget.classes != null;

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (BuildContext context, Myprovider value, Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(isEdit ? 'Edit Class' : 'Register Class'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownWidget.buildDropdown(
                            dropdownContext: context,
                            value: selecteddepart,
                            items: value.departments.map((e) => e.name).toList(),
                            label: "Department",
                            fillColor: colors.surface,
                            onChanged: (v) => setState(() => selecteddepart = v),
                            validatorMsg: 'Select department',
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: classController,
                            decoration: const InputDecoration(
                              labelText: "Class Name",
                              hintText: "e.g. Class 1",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Class name required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final progress = ProgressHUD.of(context);
                                      progress!.show();

                                      String className = classController.text.trim();
                                      String idd = className.replaceAll(RegExp(r'\s+'), '').toLowerCase();
                                      final id = "${value.schoolid}_$idd".toUpperCase();
                                      
                                      final data = ClassModel(
                                        id: id,
                                        name: className,
                                        schoolId: value.schoolid,
                                        department: selecteddepart,
                                        timestamp: DateTime.now(),
                                        staff: value.name,
                                      ).toMap();

                                      await value.db.collection('classes').doc(id).set(data, SetOptions(merge: true));
                                      progress.dismiss();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(isEdit ? 'Class updated' : 'Class registered'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }

                                      if (!isEdit) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  icon: Icon(isEdit ? Icons.update : Icons.save),
                                  label: Text(isEdit ? 'Update Class' : 'Register Class', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => Navigator.pushNamed(context, Routes.viewclass),
                                  icon: const Icon(Icons.list_alt),
                                  label: const Text("View Classes"),
                                ),
                              ),
                            ],
                          ),
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
}
