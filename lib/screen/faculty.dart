import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.faculty;
    if (data != null) {
      facultyController.text = data.name;
    }
  }

  @override
  void dispose() {
    facultyController.dispose();
    super.dispose();
  }

  Future<void> _save(Myprovider value) async {
    if (!_formKey.currentState!.validate() || _saving) return;
    final isEdit = widget.faculty != null;

    setState(() => _saving = true);
    try {
      final facultyName = facultyController.text.trim();
 final docId = isEdit
          ? widget.faculty!.id
          : value.db.collection('faculties').doc().id;

     final nameUnchanged = isEdit && widget.faculty!.name == facultyName;

      if (!nameUnchanged) {
      final dupQuery = await value.db
            .collection('faculties')
            .where('schoolId', isEqualTo: value.schoolid)
            .where('name', isEqualTo: facultyName)
            .limit(1)
            .get();
     final hasClash =
            dupQuery.docs.isNotEmpty && dupQuery.docs.first.id != docId;

        if (hasClash) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('A faculty named "$facultyName" already exists'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _saving = false);
          return;
        }
      }

      final data = FacultyModel(
        id: docId,
        name: facultyName,
        schoolId: value.schoolid,
        timestamp: DateTime.now(),
        staff: value.name,
      ).toMap();

      await value.db
          .collection('faculties')
          .doc(docId)
          .set(data, SetOptions(merge: true));
      value.upsertFaculty(FacultyModel.fromMap(data, docId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Faculty updated successfully'
                : 'Faculty registered successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      if (!isEdit) {
        facultyController.clear();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save faculty: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
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
                  onPressed: () => context.go(Routes.dashboard),
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
                              enabled: !_saving,
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
                                  return 'Faculty name cannot be empty';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _saving ? null : () => _save(value),
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
                                        ? 'Update Faculty'
                                        : 'Register Faculty',
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
                                  onPressed: _saving
                                      ? null
                                      : () {
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