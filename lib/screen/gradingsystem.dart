/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';
import '../controller/routes.dart';

class GradingSystemFormPage extends StatefulWidget {
  const GradingSystemFormPage({super.key});

  @override
  State<GradingSystemFormPage> createState() => _GradingSystemFormPageState();
}

class _GradingSystemFormPageState extends State<GradingSystemFormPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> grades = [];

  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchdepart();
    });
  }

  void _addGrade() {
    setState(() {
      grades.add({"min": "", "max": "", "grade": "", "remark": ""});
    });
  }
  void _removeGrade(int index) {
    setState(() {
      grades.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<Myprovider>(
            builder: (context, provider, _) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xFF00273a),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    "Grading System",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      color: const Color(0xFFffffff),
                      margin: const EdgeInsets.all(30.0),
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              //Dropdown for selecting department
                              DropdownButtonFormField<String>(
                                value: _selectedLevel,
                                items: provider.departments.map((dept) {
                                  return DropdownMenuItem(
                                    value: dept.name,
                                    child: Text(dept.name),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedLevel = val),
                                decoration: InputDecoration(
                                  labelText: "Department",
                                  hintText: "Select department",
                                  labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
                                  hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
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
                                ),
                                validator: (value) => value == null
                                    ? 'Please select department'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FloatingActionButton(
                                  mini: true, // smaller button
                                  backgroundColor: Color(0xFF00496d).withOpacity(0.7),
                                  onPressed: _addGrade,
                                  child: const Icon(Icons.add, color: Colors.white,),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // ✅ Grades List
                              Column(
                                children: List.generate(grades.length, (index) {
                                  final grade = grades[index];
                                  return Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: grade["min"],
                                                  decoration:
                                                  const InputDecoration(
                                                      labelText: "Min"),
                                                  keyboardType:
                                                  TextInputType.number,
                                                  onChanged: (val) =>
                                                  grade["min"] = val,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: grade["max"],
                                                  decoration:
                                                  const InputDecoration(
                                                      labelText: "Max"),
                                                  keyboardType:
                                                  TextInputType.number,
                                                  onChanged: (val) =>
                                                  grade["max"] = val,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: grade["grade"],
                                                  decoration:
                                                  const InputDecoration(
                                                      labelText: "Grade"),
                                                  onChanged: (val) =>
                                                  grade["grade"] = val,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: grade["remark"],
                                                  decoration:
                                                  const InputDecoration(
                                                      labelText: "Remark"),
                                                  onChanged: (val) =>
                                                  grade["remark"] = val,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              onPressed: () =>
                                                  _removeGrade(index),
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),




                              const SizedBox(height: 30),

                              // Save Button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final progress = ProgressHUD.of(context);
                                    progress?.show();

                                    try {
                                      final systemName = _selectedLevel!;
                                // final id ="${provider.companyid}${systemName.toLowerCase()}";
                                      final rawsystemname = _selectedLevel!;
                                      final systemname = rawsystemname.replaceAll(RegExp(r'\s+'), ''); //remove
                                      final id = "${provider.schoolid}_${systemname.toLowerCase()}"; //safe id

                                      final systemData = {
                                        "id": id,
                                        "name": systemName,
                                        "grades": grades,
                                      };

                                      final gradingSystem = {
                                        "schoolid": provider.schoolid,
                                        "name": systemName,
                                        "datecreated":
                                        DateTime.now().toIso8601String(),
                                        "gradingsystem": [systemData],
                                      };

                                      await provider.db
                                          .collection("gradingsystems")
                                          .doc(id)
                                          .set(gradingSystem,
                                          SetOptions(merge: true));

                                      progress?.dismiss();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Grading system saved successfully"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      setState(() {
                                        _selectedLevel = null;
                                        grades.clear();
                                      });
                                    } catch (e) {
                                      progress?.dismiss();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("Error: $e"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.save),
                                label: const Text("Save System"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF00496d),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
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
          );
        },
      ),
    );
  }
}*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';
import '../controller/routes.dart';

class GradingSystemFormPage extends StatefulWidget {
  const GradingSystemFormPage({super.key});

  @override
  State<GradingSystemFormPage> createState() => _GradingSystemFormPageState();
}

class _GradingSystemFormPageState extends State<GradingSystemFormPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> grades = [];

  String? _selectedLevel;
  bool _isDefault = false; // ✅ toggle for default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchdepart();
    });
  }

  void _addGrade() {
    setState(() {
      grades.add({"min": "", "max": "", "grade": "", "remark": ""});
    });
  }

  void _removeGrade(int index) {
    setState(() {
      grades.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<Myprovider>(
            builder: (context, provider, _) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xFF00273a),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(Routes.dashboard),
                  ),
                  title: Text(
                    "Grading System${provider.name}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      color: const Color(0xFFffffff),
                      margin: const EdgeInsets.all(30.0),
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // ✅ Default switch
                              SwitchListTile(
                                title: const Text("Set as Default Grading System"),
                                value: _isDefault,
                                onChanged: (val) {
                                  setState(() {
                                    _isDefault = val;
                                    if (val) _selectedLevel = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),


                              DropdownButtonFormField<String>(
                                value: _selectedLevel,
                                items: provider.departments.map((dept) {
                                  return DropdownMenuItem(
                                    value: dept.name,
                                    child: Text(dept.name),
                                  );
                                }).toList(),
                                onChanged: _isDefault
                                    ? null
                                    : (val) => setState(() => _selectedLevel = val),
                                decoration: InputDecoration(
                                  labelText: "Department",
                                  hintText: _isDefault
                                      ? "Disabled (Default selected)"
                                      : "Select department",
                                  labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
                                  hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
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
                                ),
                                validator: (value) {
                                  if (!_isDefault && value == null) {
                                    return 'Please select department';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              Align(
                                alignment: Alignment.centerRight,
                                child: FloatingActionButton(
                                  mini: true,
                                  backgroundColor: Color(0xFF00496d).withOpacity(0.7),
                                  onPressed: _addGrade,
                                  child: const Icon(Icons.add, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 20),


                              Column(
                                children: List.generate(grades.length, (index) {
                                  final grade = grades[index];
                                  return Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: grade["min"],
                                                  decoration: const InputDecoration(
                                                      labelText: "Min"),
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (val) => grade["min"] = val,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: grade["max"],
                                                  decoration: const InputDecoration(
                                                      labelText: "Max"),
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (val) => grade["max"] = val,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: grade["grade"],
                                                  decoration: const InputDecoration(
                                                      labelText: "Grade"),
                                                  onChanged: (val) => grade["grade"] = val,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: grade["remark"],
                                                  decoration: const InputDecoration(
                                                      labelText: "Remark"),
                                                  onChanged: (val) => grade["remark"] = val,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              onPressed: () => _removeGrade(index),
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 30),

                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final progress = ProgressHUD.of(context);
                                    progress?.show();
                                    try {
                                      final systemName = _isDefault ? "Default" : _selectedLevel!;
                                      final rawsystemname = systemName;
                                      final systemname =
                                      rawsystemname.replaceAll(RegExp(r'\s+'), ''); // strip spaces
                                      final id = "${provider.schoolid}_${systemname.toLowerCase()}";
                                      final Map<String, dynamic> gradingMap = {};
                                      for (var grade in grades) {
                                        final gradeKey = grade["grade"] ?? "";
                                        if (gradeKey.isNotEmpty) {
                                          gradingMap[gradeKey] = {
                                            "min": grade["min"],
                                            "max": grade["max"],
                                            "remark": grade["remark"],
                                          };
                                        }
                                      }

                                      // ✅ final gradingSystem structure
                                      final gradingSystem = {
                                        "id": id,
                                        "schoolid": provider.schoolid,
                                        "name": systemName,
                                        "isDefault": _isDefault,
                                        "datecreated": DateTime.now().toIso8601String(),
                                        "gradingsystem": gradingMap,
                                        "staff":provider.name,
                                      };

                                      await provider.db .collection("gradingsystems").doc(id)
                                          .set(gradingSystem, SetOptions(merge: true));

                                      progress?.dismiss();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Grading system saved successfully (${_isDefault ? 'Default' : systemName})"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      setState(() {
                                        _selectedLevel = null;
                                        _isDefault = false;
                                        grades.clear();
                                      });
                                    } catch (e) {
                                      progress?.dismiss();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Error: $e"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.save),
                                label: const Text("Save System"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF00496d),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
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
          );
        },
      ),
    );
  }
}

