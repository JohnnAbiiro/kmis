import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

enum AssessmentType { ca, exams }

extension AssessmentTypeX on AssessmentType {
  String get label => this == AssessmentType.ca ? "CA" : "Exams";
}

class AssessmentComponent {
  String name;
  double maxMarks;

  AssessmentComponent({this.name = "", this.maxMarks = 0});

  Map<String, dynamic> toMap() => {
    "name": name,
    "maxMarks": maxMarks,
  };
}

class AssessmentGroup {
  AssessmentType type;

  double totalMarks;
  double scalePercentage;

  List<AssessmentComponent> components;

  AssessmentGroup({
    required this.type,
    required this.totalMarks,
    required this.scalePercentage,
    required this.components,
  });

  Map<String, dynamic> toMap() => {
    "type": type.label,
    "totalMarks": totalMarks,
    "scalePercentage": scalePercentage,
    "components": components.map((e) => e.toMap()).toList(),
  };
}

class AssessentComponents extends StatefulWidget {
  const AssessentComponents({super.key});

  @override
  State<AssessentComponents> createState() => _AssessentComponentsState();
}

class _AssessentComponentsState extends State<AssessentComponents> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedDepartment;
  bool _isDefault = false;

  late final Map<AssessmentType, AssessmentGroup> _assessments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchdepart();
    });

    _assessments = {
      AssessmentType.ca: AssessmentGroup(
        type: AssessmentType.ca,
        totalMarks: 30,
        scalePercentage: 40,
        components: [],
      ),
      AssessmentType.exams: AssessmentGroup(
        type: AssessmentType.exams,
        totalMarks: 70,
        scalePercentage: 60,
        components: [],
      ),
    };

  }
  double _componentsTotal(AssessmentGroup group) {
    return group.components.fold<double>(
      0,
          (sum, c) => sum + c.maxMarks,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Widget _buildAssessmentSection(AssessmentGroup group) {
    final componentsTotal = _componentsTotal(group);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.type.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),


            TextFormField(
              initialValue: group.totalMarks.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Total ${group.type.label} Marks",
                helperText:
                "Components total: ${componentsTotal.toStringAsFixed(1)}",
              ),
              validator: (v) {
                final val = double.tryParse(v ?? "");
                if (val == null || val <= 0) {
                  return "Enter valid total marks";
                }
                if (componentsTotal > val) {
                  return "Components exceed total marks";
                }
                return null;
              },
              onChanged: (v) {
                setState(() {
                  group.totalMarks =
                      double.tryParse(v) ?? group.totalMarks;
                });
              },
            ),

            const SizedBox(height: 8),

            /// SCALE %
            TextFormField(
              initialValue: group.scalePercentage.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Scale to (%)",
              ),
              validator: (v) {
                final val = double.tryParse(v ?? "");
                if (val == null || val <= 0 || val > 100) {
                  return "Invalid percentage";
                }
                return null;
              },
              onChanged: (v) {
                group.scalePercentage =
                    double.tryParse(v) ?? group.scalePercentage;
              },
            ),

            const Divider(height: 24),

            /// COMPONENTS
            ...group.components.asMap().entries.map((entry) {
              final index = entry.key;
              final component = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: component.name,
                        decoration:
                        const InputDecoration(labelText: "Component"),
                        validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                        onChanged: (v) => component.name = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: component.maxMarks.toString(),
                        keyboardType: TextInputType.number,
                        decoration:
                        const InputDecoration(labelText: "Max Marks"),
                        validator: (v) {
                          final val = double.tryParse(v ?? "");
                          if (val == null || val <= 0) return "Invalid";
                          return null;
                        },
                        onChanged: (v) {
                          setState(() {
                            component.maxMarks =
                                double.tryParse(v) ?? component.maxMarks;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          group.components.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Component"),
                onPressed: () {
                  setState(() {
                    group.components.add(AssessmentComponent());
                  });
                },
              ),
            ),

            /// WARNING
            if (componentsTotal > group.totalMarks)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "⚠ Components exceed total marks",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSystem(Myprovider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final ca = _assessments[AssessmentType.ca]!;
    final exams = _assessments[AssessmentType.exams]!;

    if (_componentsTotal(ca) > ca.totalMarks) {
      _showError("CA components exceed total CA marks");
      return;
    }

    if (_componentsTotal(exams) > exams.totalMarks) {
      _showError("Exam components exceed total Exam marks");
      return;
    }

    final pre_id = "${provider.schoolid}_${_selectedDepartment}";
    final id=provider.normalizeAndSanitize(pre_id);
    final assessmentSystem = {
      "id": id,
      "schoolId": provider.schoolid,
      "level": _selectedDepartment,
      "isDefault": _isDefault,
      "createdBy": provider.name,
      "createdAt": DateTime.now().toIso8601String(),

      /// 🔥 KEYED BY CA / Exams
      "assessments": {
        for (final entry in _assessments.entries)
          entry.key.label: entry.value.toMap(),
      },
    };

    await provider.db
        .collection("assessmentSystems")
        .doc(id)
        .set(assessmentSystem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Assessment system saved successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Assessment System Setup"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    items: provider.departments
                        .map(
                          (d) => DropdownMenuItem(
                        value: d.name,
                        child: Text(d.name),
                      ),
                    )
                        .toList(),
                    onChanged:
                    _isDefault ? null : (v) => setState(() => _selectedDepartment = v),
                    validator: (v) =>
                    !_isDefault && v == null ? "Select level" : null,
                    decoration:
                    const InputDecoration(labelText: "Level"),
                  ),

                  const SizedBox(height: 20),

                  _buildAssessmentSection(_assessments[AssessmentType.ca]!),
                  _buildAssessmentSection(_assessments[AssessmentType.exams]!),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: () => _saveSystem(provider),
                    icon: const Icon(Icons.save),
                    label: const Text("Save Grading System"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
