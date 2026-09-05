import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/controller/dbmodels/feeSetUpModel.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';

class FeesSetup extends StatefulWidget {
  const FeesSetup({super.key});

  @override
  State<FeesSetup> createState() => _FeesSetupState();
}

class _FeesSetupState extends State<FeesSetup> {
  final feeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<Myprovider>(
            builder: (BuildContext context, value, Widget? child) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    '${value.currentschool.toUpperCase()} FEES NAMES ',
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: feeNameController,
                                decoration: const InputDecoration(
                                  labelText: "Fee Name",
                                  hintText: "e.g. Tuition Fee",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty ? "Fee Name is required" : null,
                              ),
                              const SizedBox(height: 32),
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
                                      String feename = feeNameController.text.trim();
                                      String id = feename.replaceAll(RegExp(r'\s+'), '').toLowerCase();

                                      try {
                                        final data = FeeSetUpModel(
                                          name: feename,
                                          staff: value.name,
                                          schoolId: value.schoolid,
                                          dateCreated: DateTime.now(),
                                        ).toJson();
                                        await value.db.collection("feeSetup").doc(id).set(data);
                                        progress.dismiss();
                                        feeNameController.clear();

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Fee Name Saved Successfully"),
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
                                  icon: const Icon(Icons.save),
                                  label: const Text(
                                    "Save Fee Name",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
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
