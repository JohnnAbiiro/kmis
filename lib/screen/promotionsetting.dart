import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';
import '../controller/routes.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedClass;
  String? selectedNextClass;
  String? selectedpreviousClass;
  String? editingId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<Myprovider>();

      await provider.fetchclass();
      if (provider.editPromotionData != null) {
        final data = provider.editPromotionData!;
        setState(() {
          editingId = data["id"];
          selectedClass = data["current"];
          selectedNextClass = data["next"];
          selectedpreviousClass = data["previous"];
          print("Editing current: ${data['current']}");
          print("Editing next: ${data['next']}");
         // print("Available classes: $classes");
        });
      } else {
        setState(() {}); // rebuild after class load
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Myprovider>();
    final classes = provider.classdata.map((e) => e.name).toList();

    return ProgressHUD(
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2D2F45),
            title: Text( editingId == null ? "Promotion setting": "Edit Promotion setting",
              style: const TextStyle(color: Colors.white),),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                provider.setEditPromotionData(null);
                context.go(Routes.viewpromotionsetting);
              },
            ),
          ),
          body: provider.loadclassdata
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Previous Class (Optional)",
                      border: OutlineInputBorder(),
                    ),
                    items: classes
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ))
                        .toList(),
                    value: selectedpreviousClass,
                    onChanged: (value) {
                      setState(() => selectedpreviousClass = value);
                    },
                    validator: (v) => null,   // ❌ no validation, it is optional now
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Current Class",
                      border: OutlineInputBorder(),
                    ),
                    items: classes .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    value: selectedClass,
                    onChanged: (value) {
                      setState(() => selectedClass = value);
                    },
                    validator: (v) =>
                    v == null ? "Select a class" : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Next Class (Promotion To)",
                      border: OutlineInputBorder(),
                    ),
                    items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    value: selectedNextClass,
                    onChanged: (value) {
                      setState(() => selectedNextClass = value);
                    },
                    validator: (v) =>
                    v == null ? "Select next class" : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      if (selectedpreviousClass == null ||
                          selectedClass == null ||
                          selectedNextClass == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select all class fields")),
                        );
                        return;
                      }

                      final progress = ProgressHUD.of(context);
                      progress!.show();

                      final schoolId = provider.schoolid;
                      final staff = provider.name;
                      final academicYear = provider.year;
                      final term = provider.term;

                      String id ="promotionsettig";
                      final docId = "$schoolId-$id".toLowerCase();

                      /// Firestore reference
                      final docRef = provider.db.collection("promotion_settings").doc(docId);

                      /// Rule to add or update
                      final rule = {
                        "previous": selectedpreviousClass,
                        "current": selectedClass,
                        "next": selectedNextClass,
                      };

                      try {
                        final snap = await docRef.get();

                        if (!snap.exists) {
                          await docRef.set({
                            "schoolId": schoolId,
                            "academicyear": academicYear,
                            "term": term,
                            "staff": staff,
                            "timestamp": DateTime.now(),
                            "rules": [rule],
                          });
                        } else {
                          // SECOND OR MORE → UPDATE RULE INSIDE ARRAY
                          List<dynamic> rules = snap.data()?["rules"] ?? [];

                          // REMOVE any rule that has the same current class
                          rules.removeWhere((r) => r["current"] == selectedClass);

                          // ADD updated rule
                          rules.add(rule);

                          await docRef.update({
                            "rules": rules,
                            "staff": staff,
                            "timestamp": DateTime.now(),
                          });
                        }

                        progress.dismiss();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              editingId == null
                                  ? "Promotion rule saved: $selectedClass → $selectedNextClass"
                                  : "Promotion rule updated successfully",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );

                        provider.setEditPromotionData(null);

                        context.go(Routes.viewpromotionsetting);
                      } catch (e) {
                        progress.dismiss();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: Text(
                      editingId == null
                          ? "Save Promotion Setting"
                          : "Update Promotion Setting",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00496d),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 20,),
                  OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side:
                  const BorderSide(color: Color(0xFF00496d)),
                  foregroundColor: Colors.black54,
                  padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
                    ),
                    icon: const Icon(Icons.list),
                    label: const Text("View Promotion Settings"),
                    onPressed: () {
                      context.go(Routes.viewpromotionsetting);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
