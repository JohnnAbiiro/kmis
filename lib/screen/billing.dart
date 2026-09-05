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
    final inputFill = const Color(0xFFffffff);
    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<Myprovider>(
            builder: (BuildContext context,  value, Widget? child) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xFF00273a),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    '${value.currentschool.toUpperCase()} BULK FEES BILLING ',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                body: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Container(
                      color: const Color(0xFFffffff),
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
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                controller: accountController,
                                decoration: InputDecoration(
                                  labelText: "Billed Amount ",
                                  hintText: "Billed  Amount ",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.trim().isEmpty ? "Amount is required" : null,
                              ),
                              const SizedBox(height: 20),
                              // Debit Account Dropdown
                              buildDropdown(value: selectedfee, items: value.fees.map((e) => e.name).toList(), label: "FEES", fillColor: inputFill, onChanged: (v) => setState(() => selectedfee = v), validatorMsg: 'Select Fees',),
                              const SizedBox(height: 20),
                              buildDropdown(value: selectedLevel, items: value.classdata.map((e) => e.name).toList(), label: "Class", fillColor: inputFill, onChanged: (v) => setState(() => selectedLevel = v), validatorMsg: 'Select class',),
                              const SizedBox(height: 20),
                              buildDropdown(value: selecteddepart, items: value.departments.map((e) => e.name).toList(), label: "Department", fillColor: inputFill, onChanged: (v) => setState(() => selecteddepart = v), validatorMsg: 'Select Department',),
                              // Credit Account Dropdown
                              const SizedBox(height: 20),
                              buildDropdown(value: selectedTerm, items: value.terms.map((e)=>e.name).toList(), label: "Term", fillColor: inputFill, onChanged: (v) => setState(() => selectedTerm = v), validatorMsg: "Select year group"),
                              const SizedBox(height: 20),
                              buildDropdown(value: selectedYearGroup, items: _yeargroup, label: "Year Group", fillColor: inputFill, onChanged: (v) => setState(() => selectedYearGroup = v), validatorMsg: "Select year group"),
                              const SizedBox(height: 20),
                              // Save Button
                              Row(
                                children: [
                                  ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00496d), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
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
                                            ScaffoldMessenger.of(context).showSnackBar(
                                               SnackBar(
                                                content: Text("$selectedfee  has been billed already"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          final data=BilledModel(level: selectedLevel.toString(), yeargroup: selectedYearGroup.toString(), amount: amount, activityType: "Fee Billing", term: selectedTerm.toString(), schoolId: value.schoolid, dateCreated: DateTime.now(), feeName:selectedfee.toString()).toJson();
                                          await value.db.collection("billed").doc(id).set(data);

                                          progress.dismiss();

                                          ScaffoldMessenger.of(context).showSnackBar(
                                             SnackBar(
                                              content: Text("$selectedfee - GHS$amount  Saved Successfully"),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          setState(() {
                                            // _selectedDebitAccount = null;
                                            // _selectedCreditAccount = null;
                                          });
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
                                    icon: const Icon(Icons.save, color: Colors.white),
                                    label: const Text("Save Activity",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00496d), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                                    onPressed: () {
                                      Navigator.pushNamed(context, Routes.billingview);
                                    },
                                    icon: const Icon(Icons.save, color: Colors.white),
                                    label: const Text("View Activity",
                                        style: TextStyle(color: Colors.white)),
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
