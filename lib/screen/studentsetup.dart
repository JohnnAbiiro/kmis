import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/classmodel.dart';
import '../controller/dbmodels/componentmodel.dart';
import '../controller/dbmodels/contestantsmodel.dart';
import '../controller/dbmodels/staffmodel.dart';
import '../controller/dbmodels/subjectmodel.dart';
import '../controller/myprovider.dart';

class MultiSelectItem<T> {
  final T value;
  final String label;
  MultiSelectItem({required this.value, required this.label});
}

class MultiSelectSearchField<T> extends StatefulWidget {
  final String label;
  final List<MultiSelectItem<T>> items;
  final List<T> selectedValues;
  final Function(List<T>) onConfirm;
  final String hintText;

  const MultiSelectSearchField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValues,
    required this.onConfirm,
    this.hintText = "",
  });

  @override
  State<MultiSelectSearchField<T>> createState() =>
      _MultiSelectSearchFieldState<T>();
}

class _MultiSelectSearchFieldState<T> extends State<MultiSelectSearchField<T>> {
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items
        .where((item) =>
        item.label.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    final tempValues = List<T>.from(widget.selectedValues);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => StatefulBuilder(
            builder: (ctx2, setStateDialog) {
              return AlertDialog(
                backgroundColor: const Color(0xFF2D2F45),
                title:
                Text(widget.label, style: const TextStyle(color: Colors.white)),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: Column(
                    children: [
                      // SEARCH BAR
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Search...",
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                        onChanged: (txt) {
                          setStateDialog(() => _searchText = txt);
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: filteredItems.map((item) {
                              final selected = tempValues.contains(item.value);
                              return CheckboxListTile(
                                value: selected,
                                activeColor: Colors.blueAccent,
                                checkColor: Colors.white,
                                title: Text(item.label,
                                    style: const TextStyle(color: Colors.white70)),
                                onChanged: (val) {
                                  setStateDialog(() {
                                    if (val == true) {
                                      tempValues.add(item.value);
                                    } else {
                                      tempValues.remove(item.value);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                  ElevatedButton(
                    child: const Text("OK"),
                    onPressed: () {
                      widget.onConfirm(tempValues);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.selectedValues.isEmpty
                    ? widget.hintText
                    : widget.items
                    .where((i) => widget.selectedValues.contains(i.value))
                    .map((x) => x.label)
                    .join(", "),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
    );
  }
}

/// STUDENT SETUP PAGE
class StudentSetupPage extends StatefulWidget {
  const StudentSetupPage({super.key});

  @override
  State<StudentSetupPage> createState() => _StudentSetupPageState();
}

class _StudentSetupPageState extends State<StudentSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final studentcontroller = TextEditingController();
  Timer? _debounce;

  List<StudentModel> selectedStudents = [];
  List<String> selectedTeachers = [];
  List<String> selectedSubjects = [];
  List<Staff> selectedTeacherModels = [];
  List<SubjectModel> selectedSubjectModels = [];
  List<ComponentModel> selectedComponents = [];
  List<ClassModel> selectedLevels = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<Myprovider>(context, listen: false);
      p.fetchstudents();
      p.fetchsubjects();
      p.fetchstaff();
      p.fetchclass();
      p.fetchomponents();
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
         final stu = values.searchedStudentModel;
          final filteredComponents = values.accessComponents;
          final leveldata = values.classdata;
          return Scaffold(
            backgroundColor: const Color(0xFF2D2F45),
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text("Student Setup", style: TextStyle(color: Colors.white)),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: studentcontroller,
                      decoration: InputDecoration(
                        labelText: "Enter student ID",
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
                        if (val == null || val.trim().isEmpty) {
                          return "Contestant ID is required";
                        }
                        if (val.trim().length < 2) {
                          return "Enter at least 2 characters";
                        }
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
                                await values.searchStudent(id.toUpperCase());
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
                            onPressed: () {
                              setState(() {
                                if (!selectedStudents.any((s) => s.id == stu.id)) {
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
                                      "${stu.name} (${stu.id})",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      stu.level,
                                      style: const TextStyle(fontSize: 10, color: Colors.white60),
                                    ),
                                  ],
                                ),
                                deleteIcon: const Icon(Icons.close, color: Colors.redAccent),
                                onDeleted: () {
                                  setState(() {
                                    selectedStudents.removeWhere(
                                            (x) => x.id == stu.id);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    const SizedBox(height: 15),

                    const Text(
                      "Select Teachers:",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
      
                    const SizedBox(height: 10),
      
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: values.stafflist.map((teacher) {
                        final isSelected = selectedTeachers.contains(teacher.id);
      
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedTeachers.remove(teacher.id);
                                selectedTeacherModels.remove(teacher);
                              } else {
                                selectedTeachers.add(teacher.id!);
                                selectedTeacherModels.add(teacher);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange.shade700 : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.orange : Colors.white54,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              teacher.name.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),

                    const SizedBox(height: 20),
                    const Text(
                      "Select Subjects:",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
      
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select Class:",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: leveldata.map((compModel) {
                            bool isSelected =
                            selectedLevels.any((c) => c.id == compModel.id);

                            return ChoiceChip(
                              label: Text(
                                compModel.name,
                                style: const TextStyle(color: Colors.black),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedLevels.add(compModel);
                                  } else {
                                    selectedLevels.removeWhere((c) => c.id == compModel.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select Components:",style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        ),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filteredComponents.map((compModel) {
                            bool isSelected = selectedComponents
                                .any((c) => c.id == compModel.id);

                            return ChoiceChip(
                              label: Text(
                                "${compModel.name}",
                                style: const TextStyle(),
                              ),
                              selected: isSelected,
                              onSelected: (sel) {
                                setState(() {
                                  if (sel) {
                                    selectedComponents.add(compModel);
                                  } else {
                                    selectedComponents.removeWhere(
                                            (c) => c.id == compModel.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: values.subjectList.map((sub) {
                        final isSelected = selectedSubjects.contains(sub.code);
      
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedSubjects.remove(sub.code);
                                selectedSubjectModels.remove(sub);
                              } else {
                                selectedSubjects.add(sub.code!);
                                selectedSubjectModels.add(sub);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange.shade700 : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.orange : Colors.white54,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              "${sub.name.toUpperCase()} (${sub.level})",
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),
      
                    // SAVE BUTTON
                    ElevatedButton.icon(
                      icon: values.savingSetup ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.save),
                      label: Text(values.savingSetup ? "Saving..." : "Save"),
                      onPressed: () async {
                        if (selectedStudents.isEmpty|| selectedTeachers.isEmpty||selectedSubjects.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("Please select all fields"),
                              backgroundColor: Colors.red,
                            ),);
                          return;
                        }
                            try {
                         await values.saveStudentSetupMulti(
                        students: selectedStudents,
                        selectedTeachers: selectedTeacherModels,
                        selectedSubjects: selectedSubjectModels,
                        selectedClasses: selectedLevels,
                        selectedComponents: selectedComponents,
                        academicYear: values.year,
                        term: values.term,
                        schoolId: values.schoolid,
                          );
      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Saved Successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
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
