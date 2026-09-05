import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

import 'package:ksoftsms/controller/dbmodels/feeSetUpModel.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/componentmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class FeesSetup extends StatefulWidget {
  final ComponentModel? component;
  const FeesSetup({super.key, this.component});

  @override
  State<FeesSetup> createState() => _FeesSetupState();
}

class _FeesSetupState extends State<FeesSetup> {
  final feeNameController = TextEditingController();
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
                    onPressed: () => Navigator.pop(context),
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

                              // Save Button
                              ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00496d), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final progress = ProgressHUD.of(context);
                                    progress!.show();
                                    String feename=feeNameController.text.trim();
                                    String id = feename.replaceAll(RegExp(r'\s+'), '').toLowerCase();

                                    try {
                                      final data=FeeSetUpModel(name: feename, staff: value.name, schoolId: value.schoolid, dateCreated: DateTime.now()).toJson();
                                      await value.db.collection("feeSetup").doc(id).set(data);
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
                                label: const Text("Save Activity",
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
