import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';
import '../widgets/dropdown.dart';

class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key});
  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  final _formKey = GlobalKey<FormState>();
  String? selectedClass,
      selectedDepartment,
      selectedTerm,
      selectedAcademicYear,
      selectedAcademicyr;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<Myprovider>();
      provider.fetchclass();
      provider.fetchterms();
      provider.fetchacademicyear();
      provider.getdata();
    });
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Terminal Reports"),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownWidget.buildDropdown(
                        dropdownContext: context,
                        value: selectedAcademicYear,
                        items: provider.academicyears.map((e) => e.name).toList(),
                        label: "Academic Year",
                        fillColor: colors.surface,
                        onChanged: (val) {
                          setState(() {
                            final yr = provider.academicyears
                                .firstWhere((e) => e.name == val);
                            selectedAcademicyr = yr.idd;
                            selectedAcademicYear = yr.name;
                          });
                        },
                        validatorMsg: "Please select an academic year",
                      ),
                      const SizedBox(height: 16),
                      DropdownWidget.buildDropdown(
                        dropdownContext: context,
                        value: selectedTerm,
                        items: provider.terms.map((e) => e.name).toList(),
                        label: "Term",
                        fillColor: colors.surface,
                        onChanged: (val) => setState(() => selectedTerm = val),
                        validatorMsg: "Please select a term",
                      ),
                      const SizedBox(height: 16),
                      DropdownWidget.buildDropdown(
                        dropdownContext: context,
                        value: selectedClass,
                        items: provider.classdata.map((e) => e.name).toList(),
                        label: "Class",
                        fillColor: colors.surface,
                        onChanged: (val) {
                          setState(() {
                            selectedClass = val;
                            final classObj = provider.classdata
                                .firstWhere((c) => c.name == val);
                            selectedDepartment = classObj.department ?? "";
                          });
                        },
                        validatorMsg: "Please select a class",
                      ),
                      const SizedBox(height: 16),
                      if (selectedDepartment != null &&
                          selectedDepartment!.isNotEmpty)
                        TextFormField(
                          initialValue: selectedDepartment,
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: "Department",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: _isGenerating
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text("Generate Reports", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isGenerating
                              ? null 
                              : () async {
                            if (!_formKey.currentState!.validate()) return;

                            setState(() => _isGenerating = true);

                            try {
                             await provider.generateReports(
                                level: selectedClass!,
                                term: selectedTerm!,
                                academyear: selectedAcademicYear!,
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Reports generated successfully"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                            catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("$e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                            finally {
                              setState(() => _isGenerating = false);
                            }
                          },
                        ),
                      ),
                    ],
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
