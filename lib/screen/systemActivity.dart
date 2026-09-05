import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/controller/accountProvider.dart';
import 'package:ksoftsms/controller/dbmodels/accountsModel.dart';
import 'package:ksoftsms/controller/dbmodels/activityModel.dart';
import 'package:ksoftsms/controller/loginprovider.dart';
import 'package:ksoftsms/screen/accountChart.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controller/dbmodels/componentmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class SystemActivity extends StatefulWidget {
  final ComponentModel? component;
  const SystemActivity({super.key, this.component});

  @override
  State<SystemActivity> createState() => _SystemActivityState();
}

class _SystemActivityState extends State<SystemActivity> {
  final accountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedDebitAccount;
  String? _selectedCreditAccount;
  String? _selectedCreditAccountClass;
  String? _selectedDebitAccountClass;
  String? _selectedDebitAccountSubClass;
  String? _selectedCreditAccountSubClass;

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
      context.read<LoginProvider>().getdata();
      context.read<LoginProvider>().fetchAccounts();
       // print(context.read<LoginProvider>().currentschool);

    });
  }


  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFFffffff);
    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<LoginProvider>(
            builder: (BuildContext context,  value, Widget? child) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xFF00273a),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    '${value.currentschool.toUpperCase()} SYSTEM ACTIVITY',
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
                                controller: accountController,
                                decoration: InputDecoration(
                                  labelText: "Activity Name ",
                                  hintText: "Activity Name ",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.trim().isEmpty ? "Account Name is required" : null,
                              ),
                              const SizedBox(height: 20),
                              // Debit Account Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedDebitAccount,
                                items: value.accounts.map((acc) {
                                  return DropdownMenuItem(
                                    value: acc,
                                    child: Text(acc),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  int dd=value.accounts.indexOf(val.toString());
                                  _selectedDebitAccountClass=value.accountclass[dd];
                                  _selectedDebitAccountSubClass=value.accountsubclass[dd];
                                  print(_selectedDebitAccountClass);
                                  setState(() => _selectedDebitAccount = val);
                                },
                                decoration: InputDecoration(
                                  labelText: "Select Debit Account",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null ? 'Please select a debit account' : null,
                              ),
                              const SizedBox(height: 20),
                              // Credit Account Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedCreditAccount,
                                items: value.accounts.map((acc) {
                                  return DropdownMenuItem(
                                    value: acc,
                                    child: Text(acc),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  int dd=value.accounts.indexOf(val.toString());
                                  _selectedCreditAccountClass=value.accountclass[dd];
                                  _selectedCreditAccountSubClass=value.accountsubclass[dd];
                                  print(_selectedCreditAccountClass);
                                  setState(() => _selectedCreditAccount = val);
                                },
                                decoration: InputDecoration(
                                  labelText: "Select Credit Account",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null ? 'Please select a credit account' : null,
                              ),
                              const SizedBox(height: 30),
                              // Save Button
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00496d),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 12),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final progress = ProgressHUD.of(context);
                                        progress!.show();
                                        String activityname=accountController.text.trim();
                                        //String id="${value.schoolid}";

                                        String ids = "${value.schoolid.toString().toLowerCase()}_${activityname.replaceAll(RegExp(r'\\s+'), '').toLowerCase()}";
                                        String id=ids.replaceAll(RegExp(r'[^\w\s]+'),'');

                                        try {
                                          final data=ActivityModel(name: activityname, schoolId: value.schoolid, drAccount: _selectedDebitAccount.toString(), crAccount: _selectedCreditAccount.toString(), staff: value.name, dateCreated: DateTime.now(), crAccountClass: _selectedCreditAccountClass.toString(), drAccountClass: _selectedDebitAccountClass.toString(), crAccountSubClass: _selectedCreditAccountSubClass.toString(), drAccountSubClass: _selectedDebitAccountSubClass.toString(), id: '').toJson();
                                          await value.db.collection("systemActivity").doc(id).set(data);

                                          progress.dismiss();

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Data Saved Successfully"),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          setState(() {
                                            _selectedDebitAccount = null;
                                            _selectedCreditAccount = null;
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
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00496d),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 12),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, Routes.systemactivityview);
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
