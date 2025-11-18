/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/componentmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import 'dropdown.dart';

class AccessComponent extends StatefulWidget {
  final ComponentModel? component;
  const AccessComponent({super.key,this.component});


  @override
  State<AccessComponent> createState() => _RevenueGridPageState();
}

class _RevenueGridPageState extends State<AccessComponent> {
  final componentname = TextEditingController();
  final totalmark = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? level;

  @override
  void dispose() {
    componentname.dispose();
    totalmark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFF2C2C3C);
    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<Myprovider>(
            builder: (BuildContext context, Myprovider value, Widget? child) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xFF2D2F45),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(Routes.dashboard),
                  ),
                  title: const Text(
                    'Access Components',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 40,
                    left: 16,
                    right: 16,
                    bottom: 20,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      color: const Color(0xFF2D2F45),
                      margin: const EdgeInsets.all(30.0),
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(10.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: componentname,
                                decoration: InputDecoration(
                                  labelText: "Component Name",
                                  hintText: "Enter Component Name",
                                  labelStyle:
                                  const TextStyle(color: Colors.white),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
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
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  filled: true,
                                  fillColor: inputFill,
                                ),
                                style: const TextStyle(fontSize: 16),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Component name cannot be empty';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: totalmark,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Total Mark",
                                  hintText: "Enter Total Mark",
                                  labelStyle:
                                  const TextStyle(color: Colors.white),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
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
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  filled: true,
                                  fillColor: inputFill,
                                ),
                                style: const TextStyle(fontSize: 16),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Total mark cannot be empty';
                                  }
                                  if (int.tryParse(value.trim()) == null) {
                                    return 'Total mark must be a number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Save + View Buttons
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final progress =
                                            ProgressHUD.of(context);
                                            progress!.show();

                                            try {
                                              String categoryName =componentname.text.trim();
                                              String totalMark = totalmark.text.trim();
                                              String totalMar = totalmark.text.trim();
                                              String id = "${value.schoolid}_${categoryName.replaceAll(RegExp(r'\s+'), '').toLowerCase()}${totalMar.replaceAll(RegExp(r'\s+'), '').toLowerCase()}";

                                              final data = ComponentModel(
                                                name: categoryName,
                                                totalMark: totalMark,
                                                type: categoryName,
                                                dateCreated: DateTime.now(),
                                                schoolId: value.schoolid,
                                                staff: value.name,
                                                id: categoryName,
                                              );

                                              // Save as Map
                                              await value.db.collection("assesscomponent").doc(id).set(data.toJson());
                                              progress.dismiss();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Data Saved Successfully"),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );

                                              setState(() {
                                                level = null;
                                              });
                                              componentname.clear();
                                              totalmark.clear();
                                            } catch (e) {
                                              progress.dismiss();
                                              debugPrint(
                                                  "❌ Error saving data: $e");
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Failed to save data: $e"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.save,
                                                color: Colors.white),
                                            SizedBox(width: 8),
                                            Text(
                                              'Save Access',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        context.go(Routes.accesslist),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2D2F45),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.blueAccent, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.list, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            "View Access",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
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
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/componentmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class AccessComponent extends StatefulWidget {
  final ComponentModel? component; // null = insert, not null = edit
  const AccessComponent({super.key, this.component});

  @override
  State<AccessComponent> createState() => _AccessComponentState();
}

class _AccessComponentState extends State<AccessComponent> {
  final componentname = TextEditingController();
  final totalmark = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? level;

  @override
  void initState() {
    super.initState();
    // Prefill if editing
    if (widget.component != null) {
      componentname.text = widget.component!.name;
      totalmark.text = widget.component!.totalMark;
    }
  }

  @override
  void dispose() {
    componentname.dispose();
    totalmark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFFffffff);

    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<Myprovider>(
            builder: (BuildContext context, Myprovider value, Widget? child) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xFF2D2F45),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(Routes.dashboard),
                  ),
                  title: Text(
                    widget.component == null
                        ? 'Add Access Component'
                        : 'Edit Access Component',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      color: const Color(0xFFffffff),
                      margin: const EdgeInsets.all(20.0),
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: componentname,
                                decoration: _inputDecoration(
                                  "Component Name",
                                  inputFill,
                                ),
                                style: const TextStyle(color: Colors.black54),
                                validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Component name cannot be empty'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: totalmark,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  "Total Mark",
                                  inputFill,
                                ),
                                style: const TextStyle(color: Colors.black54),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Total mark cannot be empty';
                                  }
                                  if (int.tryParse(value.trim()) == null) {
                                    return 'Total mark must be a number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),

                              // Save Button
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF00496d),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                ),
                                icon: const Icon(Icons.save),
                                label: Text(widget.component == null
                                    ? "Save Access"
                                    : "Update Access"),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final progress = ProgressHUD.of(context);
                                      progress?.show();
                                      try {
                                        String name = componentname.text.trim();
                                        String mark = totalmark.text.trim();
                                        String id = widget.component?.id ??
                                            "${value.schoolid}_${name.replaceAll(RegExp(r'\\s+'), '').toLowerCase()}_${mark}";

                                        final data = ComponentModel(
                                          id: id,
                                          name: name,
                                          totalMark: mark,
                                          type: name,
                                          dateCreated: DateTime.now(),
                                          schoolId: value.schoolid,
                                          staff: value.name,
                                        );

                                        if (widget.component == null) {
                                          // Insert new
                                          await value.db
                                              .collection("assesscomponent")
                                              .doc(id)
                                              .set(data.toJson());
                                        } else {
                                          // Update existing
                                          await value.db
                                              .collection("assesscomponent")
                                              .doc(widget.component!.id)
                                              .update(data.toJson());
                                        }

                                        progress?.dismiss();

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(widget.component == null
                                                  ? "Data Saved Successfully"
                                                  : "Data Updated Successfully"),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          context.go(Routes.accesslist);
                                        }
                                      } catch (e) {
                                        progress?.dismiss();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Failed to save data: $e"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }

                              ),
                              const SizedBox(height: 20),

                              // View Button
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side:
                                  const BorderSide(color: Color(0xFF00496d)),
                                  foregroundColor: Colors.black54,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                ),
                                icon: const Icon(Icons.list),
                                label: const Text("View Access"),
                                onPressed: () => context.go(Routes.accesslist),
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

  InputDecoration _inputDecoration(String label, Color fillColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),

      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF2C2C3C)),
      ),
      filled: true,
      fillColor: fillColor,
    );
  }
}
