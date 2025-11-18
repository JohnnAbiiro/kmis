import 'package:ksoftsms/controller/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/subjectmodel.dart';
import '../controller/myprovider.dart';

class SubjectRegistration extends StatefulWidget {
  final SubjectModel? subject;

  const SubjectRegistration({super.key, this.subject});

  @override
  State<SubjectRegistration> createState() => _SubjectRegistrationState();
}

class _SubjectRegistrationState extends State<SubjectRegistration> {
  final subjectController = TextEditingController();
  final codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final inputFill = const Color(0xFF2C2C3C);

  String? selectedLevel;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<Myprovider>(context, listen: false);
      provider.fetchclass();
    });

    final data = widget.subject;
    if (data != null) {
      subjectController.text = data.name;
      codeController.text = data.code ?? '';
      selectedLevel = data.level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.subject != null;

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, value, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF2D2F45),
              title: Text(
                isEdit ? "Edit Subject" : "Register Subject",
                style: const TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go(Routes.dashboard),
              ),
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 700),
                child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          /// subject name
                          TextFormField(
                            controller: subjectController,
                            decoration: InputDecoration(
                              labelText: "Subject Name",

                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[700]!),
                              ),
                              filled: false,
                              fillColor: inputFill,
                            ),
                            validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Subject name cannot be empty"
                                : null,
                          ),
                          const SizedBox(height: 20),

                          /// subject code
                          TextFormField(
                            controller: codeController,
                            decoration: InputDecoration(
                              labelText: "Subject Code",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[700]!),
                              ),
                              filled: false,
                              fillColor: inputFill,
                            ),
                          ),
                          const SizedBox(height: 20),

                          /// level dropdown (from ClassModel)
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Select Level",
                              border: OutlineInputBorder(),
                            ),
                            value: selectedLevel,
                            items: value.classdata
                                .map((cls) => DropdownMenuItem(
                              value: cls.name,
                              child: Text(cls.name),
                            ))
                                .toList(),
                            onChanged: (val) => setState(() => selectedLevel = val),
                            validator: (val) =>
                            val == null ? "Please select a level" : null,
                          ),
                          const SizedBox(height: 20),

                          /// buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final progress = ProgressHUD.of(context);
                                    progress!.show();
                                   String subject = subjectController.text.trim().replaceAll(" ", "") .toLowerCase();
                                   String code = codeController.text.trim().replaceAll(" ", "") .toLowerCase();
                                    final id = "${value.schoolid}_$subject$code";

                                    final subjectData = SubjectModel(
                                      id:id,
                                      name: subjectController.text.trim(),
                                      code: codeController.text.trim(),
                                      level: selectedLevel ?? '',
                                      schoolId: value.schoolid,
                                      timestamp: DateTime.now(),
                                    ).toMap();


                                    await value.db
                                        .collection("subjects")
                                        .doc(id)
                                        .set(subjectData, SetOptions(merge: true));

                                    progress.dismiss();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isEdit
                                            ? "Subject updated successfully"
                                            : "Subject registered successfully"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    if (!isEdit) {
                                      subjectController.clear();
                                      codeController.clear();
                                      setState(() => selectedLevel = null);
                                    }
                                  }
                                },
                                icon: Icon(isEdit ? Icons.update : Icons.save),
                                label: Text(
                                    isEdit ? "Update Subject" : "Register Subject"),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () => context.go(Routes.viewsubjects),
                                icon: const Icon(Icons.list),
                                label: const Text("View Subjects"),
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
      ),
    );
  }
}
