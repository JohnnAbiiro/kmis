import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
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
  bool _isSubmitting = false;

  String? _duplicateWarning;
  bool _checkingDuplicate = false;
  Timer? _debounce;

  bool get isEdit => widget.classes != null;

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

    classController.addListener(_scheduleDuplicateCheck);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    classController.removeListener(_scheduleDuplicateCheck);
    classController.dispose();
    super.dispose();
  }

  String _normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), '').toLowerCase();

  String? _facultyForSelectedDepartment(Myprovider provider) {
    if (selecteddepart == null) return null;
    for (final d in provider.departments) {
      if (d.name == selecteddepart) return d.faculty;
    }
    return null;
  }

  String _computeId(String schoolId, String faculty, String department, String className) {
    final normFaculty = _normalize(faculty);
    final normDept = _normalize(department);
    final normName = _normalize(className);
    return "${schoolId}_${normFaculty}_${normDept}_$normName";
  }

  void _scheduleDuplicateCheck() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _checkDuplicate);
  }

  Future<void> _checkDuplicate() async {
    final name = classController.text.trim();
    if (name.isEmpty || selecteddepart == null) {
      if (_duplicateWarning != null || _checkingDuplicate) {
        if (mounted) {
          setState(() {
            _duplicateWarning = null;
            _checkingDuplicate = false;
          });
        }
      }
      return;
    }

    final provider = context.read<Myprovider>();
    final faculty = _facultyForSelectedDepartment(provider);
    if (faculty == null || faculty.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _duplicateWarning = 'Selected department has no faculty set.';
          _checkingDuplicate = false;
        });
      }
      return;
    }
    final targetId = _computeId(provider.schoolid, faculty, selecteddepart!, name);

    if (mounted) setState(() => _checkingDuplicate = true);

    try {
      final snap = await provider.db.collection('classes').doc(targetId).get();
      final isSelf = isEdit && widget.classes!.id == targetId;
      final clash = snap.exists && !isSelf;

      if (!mounted) return;
      setState(() {
        _duplicateWarning =
        clash ? 'A class with this name already exists in this department.' : null;
        _checkingDuplicate = false;
      });
    } catch (_) {
      if (mounted) setState(() => _checkingDuplicate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (BuildContext context, Myprovider value, Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(isEdit ? 'Edit Class' : 'Register Class'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(Routes.dashboard);
                  }
                },
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    color: colors.surface,
                    margin: const EdgeInsets.all(30.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownWidget.buildDropdown(
                              dropdownContext: context,
                              value: selecteddepart,
                              items: value.departments.map((e) => e.name).toList(),
                              label: "Department",
                              fillColor: colors.surfaceContainerHighest,
                              onChanged: (v) {
                                setState(() => selecteddepart = v);
                                _scheduleDuplicateCheck();
                              },
                              validatorMsg: 'Select department',
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: classController,
                              enabled: !_isSubmitting,
                              decoration: InputDecoration(
                                labelText: "Class Name",
                                hintText: "Enter Class Name",
                                filled: true,
                                fillColor: colors.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                                ),
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                suffixIcon: _checkingDuplicate
                                    ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                                    : null,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Class name cannot be empty';
                                }
                                if (_duplicateWarning != null) {
                                  return _duplicateWarning;
                                }
                                return null;
                              },
                            ),
                            if (_duplicateWarning != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _duplicateWarning!,
                                    style: TextStyle(color: colors.error, fontSize: 12),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),

                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 20,
                              runSpacing: 10,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: (_isSubmitting ||
                                      _checkingDuplicate ||
                                      _duplicateWarning != null)
                                      ? null
                                      : () => _handleSubmit(context, value),
                                  icon: Icon(isEdit ? Icons.update : Icons.save),
                                  label: Text(isEdit ? 'Update Class' : 'Register Class'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                    textStyle: const TextStyle(fontSize: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 5,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: colors.primary),
                                    foregroundColor: colors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  ),
                                  icon: const Icon(Icons.list),
                                  label: const Text("View Classes"),
                                  onPressed: () {
                                    context.pushNamed(Routes.viewclass);
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
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context, Myprovider value) async {
    if (!_formKey.currentState!.validate()) return;
    if (selecteddepart == null) return;

    setState(() => _isSubmitting = true);

    final progress = ProgressHUD.of(context);
    progress?.show();

    try {
      final className = classController.text.trim();
      final faculty = _facultyForSelectedDepartment(value);
      if (faculty == null || faculty.trim().isEmpty) {
        progress?.dismiss();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected department has no faculty set.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      final targetId = _computeId(value.schoolid, faculty, selecteddepart!, className);
      final docId = isEdit ? widget.classes!.id : targetId;

      final existing = await value.db.collection('classes').doc(targetId).get();
      final hasClash = existing.exists && existing.id != docId;

      if (hasClash) {
        progress?.dismiss();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A class with this name already exists in this department.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final model = ClassModel(
        id: docId,
        name: className,
        schoolId: value.schoolid,
        department: selecteddepart,
        faculty: faculty,
        timestamp: DateTime.now(),
        staff: value.name,
      );

      await value.db.collection('classes').doc(docId).set(model.toMap(), SetOptions(merge: true));

      value.upsertClass(model);

      progress?.dismiss();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Class updated successfully' : 'Class registered successfully'),
          backgroundColor: Colors.green,
        ),
      );

      if (isEdit) {
        Navigator.pop(context, model);
        return;
      }

      classController.clear();
      setState(() => selecteddepart = null);
    } catch (e) {
      progress?.dismiss();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save class: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
