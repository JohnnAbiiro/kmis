import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/controller/dbmodels/billedModel.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/componentmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../widgets/dropdown.dart';

class Billing extends StatefulWidget {
  final ComponentModel? component;
  const Billing({super.key, this.component});

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  final accountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedLevel;
  String? selectedTerm;
  String? selecteddepart;
  String? selectedfee;
  String? selectedYearGroup;
  final List<String> _yeargroup = List.generate(5, (i) => (2022 + i).toString());

  String schoolid = "";
  String schoolname = "";
  String userid = "";

  @override
  void dispose() {
    accountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<Myprovider>(context, listen: false);
      provider.getdata();
      provider.getfetchRegions();
      provider.fetchdepart();
      provider.fetchclass();
      provider.fetchterms();
      provider.fetchFess();
    });
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final inputFill = colors.surface;
    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<Myprovider>(
            builder: (BuildContext context,  value, Widget? child) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    '${value.currentschool.toUpperCase()} BULK FEES BILLING ',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                body: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                controller: accountController,
                                decoration: InputDecoration(
                                  labelText: "Billed Amount ",
                                  hintText: "Billed  Amount ",
                                  border: const OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
                                  ),
                                  labelStyle: TextStyle(color: colors.onSurface),
                                  hintStyle: TextStyle(color: colors.onSurfaceVariant),
                                ),
                                validator: (value) =>
                                value == null || value.trim().isEmpty ? "Amount is required" : null,
                              ),
                              const SizedBox(height: 20),
                              // Debit Account Dropdown
                              DropdownWidget.buildDropdown(dropdownContext: context, value: selectedfee, items: value.fees.map((e) => e.name).toList(), label: "FEES", fillColor: inputFill, onChanged: (v) => setState(() => selectedfee = v), validatorMsg: 'Select Fees',),
                              const SizedBox(height: 20),
                              DropdownWidget.buildDropdown(dropdownContext: context, value: selectedLevel, items: value.classdata.map((e) => e.name).toList(), label: "Class", fillColor: inputFill, onChanged: (v) => setState(() => selectedLevel = v), validatorMsg: 'Select class',),
                              const SizedBox(height: 20),
                              DropdownWidget.buildDropdown(dropdownContext: context, value: selecteddepart, items: value.departments.map((e) => e.name).toList(), label: "Department", fillColor: inputFill, onChanged: (v) => setState(() => selecteddepart = v), validatorMsg: 'Select Department',),
                              // Credit Account Dropdown
                              const SizedBox(height: 20),
                              DropdownWidget.buildDropdown(dropdownContext: context, value: selectedTerm, items: value.terms.map((e)=>e.name).toList(), label: "Term", fillColor: inputFill, onChanged: (v) => setState(() => selectedTerm = v), validatorMsg: "Select year group"),
                              const SizedBox(height: 20),
                              DropdownWidget.buildDropdown(dropdownContext: context, value: selectedYearGroup, items: _yeargroup, label: "Year Group", fillColor: inputFill, onChanged: (v) => setState(() => selectedYearGroup = v), validatorMsg: "Select year group"),
                              const SizedBox(height: 32),
                              // Save & View Buttons
                              Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colors.primary,
                                        foregroundColor: colors.onPrimary,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          final progress = ProgressHUD.of(context);
                                          progress!.show();
                                          String amount=accountController.text.trim();
                                          String ids="${value.schoolid}$selectedYearGroup$selectedTerm$selecteddepart$selectedLevel$selectedfee";
                                          String id = ids.replaceAll(RegExp(r'\s+'), '').toLowerCase();

                                          try {
                                            final dataexist=await value.db.collection("billed").doc(id).get();
                                            if(dataexist.exists){
                                              progress.dismiss();
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("$selectedfee has been billed already"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                              return;
                                            }
                                            final data=BilledModel(level: selectedLevel.toString(), yeargroup: selectedYearGroup.toString(), amount: amount, activityType: "Fee Billing", term: selectedTerm.toString(), schoolId: value.schoolid, dateCreated: DateTime.now(), feeName:selectedfee.toString()).toJson();
                                            await value.db.collection("billed").doc(id).set(data);

                                            progress.dismiss();

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("$selectedfee - GHS$amount Saved Successfully"),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            progress.dismiss();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Failed to save data: $e"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.save),
                                      label: const Text("Save Activity", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(context, Routes.billingview);
                                      },
                                      icon: const Icon(Icons.list_alt),
                                      label: const Text("View All Activities"),
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
          );
        },
      ),
    );
  }
}