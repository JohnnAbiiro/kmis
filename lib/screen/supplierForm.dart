import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/dbmodels/SupplierModel.dart';

import 'package:ksoftsms/controller/dbmodels/feeSetUpModel.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/componentmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class SupplierForm extends StatefulWidget {
  final ComponentModel? component;
  const SupplierForm({super.key, this.component});

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final feeNameController = TextEditingController();
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String schoolid = "";
  String schoolname = "";
  String userid = "";

  @override
  void dispose() {
    feeNameController.dispose();
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
                    onPressed: () => context.go(Routes.dashboard),
                  ),
                  title: Text(
                    '${value.currentschool.toUpperCase()} FEES BILLING ',
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
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                controller: feeNameController,
                                decoration: InputDecoration(
                                  labelText: "Supplier Name ",
                                  hintText: "Supplier Name ",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.trim().isEmpty ? "Amount is required" : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, // ✅ only integers
                                ],
                                keyboardType: TextInputType.phone,
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: "Supplier Phone Number ",
                                  hintText: "Supplier Phone Number ",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.trim().isEmpty||value.length>14 ? "Valid Phone Number is required" : null,
                              ),
                              const SizedBox(height: 10),
                              // Save Button
                              ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00496d), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final progress = ProgressHUD.of(context);
                                    progress!.show();
                                    String name=feeNameController.text.trim();
                                    String phonetxt=feeNameController.text.trim();
                                    String id = name.replaceAll(RegExp(r'\s+'), '').toLowerCase();

                                    try {
                                      final data=SupplierModel(phone:phonetxt,name: name, staff: value.name,  dateCreated: DateTime.now(),  schoolId: value.schoolid).toJson();
                                      await value.db.collection("supplier").doc('${value.schoolid}_$id').set(data);
                                      progress.dismiss();
                                      feeNameController.clear();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Data Saved Successfully"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );


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
                                label: const Text("Save Supplier",
                                    style: TextStyle(color: Colors.white)),
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
