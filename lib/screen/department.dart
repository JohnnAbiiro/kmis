import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/departmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../widgets/dropdown.dart';

class Department extends StatefulWidget {
  final DepartmentModel? depart;
  const Department({super.key, this.depart});

  @override
  State<Department> createState() => _DepartmentState();
}

class _DepartmentState extends State<Department> {
  final departController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedfaculty;
  bool _saving = false;

  // Live "already exists" warning, debounced since checking hits Firestore
  // (a single targeted doc lookup, not a full collection fetch).
  String? _duplicateWarning;
  bool _checkingDuplicate = false;
  Timer? _debounce;

  bool get isEdit => widget.depart != null;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final provider = context.read<Myprovider>();
      provider.fetchFaculty();
    });
    final data = widget.depart;
    if (data != null) {
      departController.text = data.name;
      selectedfaculty = data.faculty;
    }
    departController.addListener(_scheduleDuplicateCheck);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    departController.removeListener(_scheduleDuplicateCheck);
    departController.dispose();
    super.dispose();
  }

  // Normalizes a name for id/comparison purposes: lowercase, no whitespace.
  String _normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), '').toLowerCase();

 String _computeId(String schoolId, String faculty, String departmentName) {
    final normFaculty = _normalize(faculty);
    final normName = _normalize(departmentName);
    return "${schoolId}_${normFaculty}_$normName";
  }

  void _scheduleDuplicateCheck() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _checkDuplicate);
  }

  // Targeted single-document lookup — not a fetch/filter over the whole
  // departments list, so it works reliably regardless of whether that
  // list has been loaded yet.
  Future<void> _checkDuplicate() async {
    final name = departController.text.trim();
    if (name.isEmpty || selectedfaculty == null) {
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
    final targetId = _computeId(provider.schoolid, selectedfaculty!, name);

    if (mounted) setState(() => _checkingDuplicate = true);

    try {
      final snap = await provider.db.collection('department').doc(targetId).get();
      final isSelf = isEdit && widget.depart!.id == targetId;
      final clash = snap.exists && !isSelf;

      if (!mounted) return;
      setState(() {
        _duplicateWarning = clash
            ? 'A department with this name already exists under this faculty.'
            : null;
        _checkingDuplicate = false;
      });
    } catch (_) {
      if (mounted) setState(() => _checkingDuplicate = false);
    }
  }

  Future<void> _save(Myprovider value) async {
    if (!_formKey.currentState!.validate() || _saving) return;
    if (selectedfaculty == null) return; // dropdown has its own validatorMsg

    setState(() => _saving = true);
    try {
      final departmentName = departController.text.trim();
      final targetId = _computeId(value.schoolid, selectedfaculty!, departmentName);

      // Edit NEVER regenerates the id — always the original doc.
      // Add: id is generated from school + faculty + name.
      final id = isEdit ? widget.depart!.id : targetId;

      // Final safety-net check with a single targeted doc lookup.
      final existing = await value.db.collection('department').doc(targetId).get();
      final hasClash = existing.exists && existing.id != id;

      if (hasClash) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A department with this name already exists under this faculty.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final model = DepartmentModel(
        id: id,
        name: departmentName,
        schoolId: value.schoolid,
        faculty: selectedfaculty,
        timestamp: DateTime.now(),
        staff: value.name,
      );

      await value.db
          .collection('department')
          .doc(id)
          .set(model.toMap(), SetOptions(merge: true));

      // Update the cached list in place — no refetch needed.
      value.upsertDepartment(model);

      if (!mounted) return;
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

      if (isEdit) {
        Navigator.pop(context, model);
        return;
      }

      departController.clear();
      setState(() => selectedfaculty = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save department: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFFffffff);

    return Builder(
      builder: (context) {
        return Consumer<Myprovider>(
          builder: (BuildContext context, Myprovider value, Widget? child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFF2D2F45),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go(Routes.dashboard),
                ),
                title: Text(
                  isEdit ? 'Edit Department' : 'Register Department',
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

                            DropdownWidget.buildDropdown(
                              dropdownContext: context,
                              value: selectedfaculty,
                              items: value.faculties
                                  .map((e) => e.name)
                                  .toList(),
                              label: "Faculty",
                              fillColor: inputFill,
                              onChanged: (v) {
                                setState(() => selectedfaculty = v);
                                _scheduleDuplicateCheck();
                              },
                              validatorMsg: 'Select faculty',
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: departController,
                              enabled: !_saving,
                              decoration: InputDecoration(
                                labelText: "Department Name",
                                hintText: "Enter Department Name",
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
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Department name cannot be empty';
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
                                    style: const TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: (_saving ||
                                      _checkingDuplicate ||
                                      _duplicateWarning != null)
                                      ? null
                                      : () => _save(value),
                                  icon: _saving
                                      ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : Icon(
                                    isEdit ? Icons.update : Icons.save,
                                  ),
                                  label: Text(
                                    _saving
                                        ? 'Saving...'
                                        : isEdit
                                        ? 'Update Department'
                                        : 'Register Department',
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
                                  label: const Text("View Departments"),
                                  onPressed: _saving
                                      ? null
                                      : () {
                                    context.go(Routes.viewdepart);
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
