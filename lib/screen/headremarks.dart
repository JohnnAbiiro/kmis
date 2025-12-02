import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';

class HeadremarkPage extends StatefulWidget {
  const HeadremarkPage({super.key});

  @override
  State<HeadremarkPage> createState() => _HeadremarkPageState();
}

class _HeadremarkPageState extends State<HeadremarkPage> {
  String selectedClass = "";

  /// Each student gets its own controller
  final Map<String, TextEditingController> headControllers = {};

  /// Each student gets its own Form key
  final Map<String, GlobalKey<FormState>> formKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchclass();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Myprovider>();
    final classes = provider.classdata;
    final List<Map<String, dynamic>> students = provider.studentlistattend;

    return ProgressHUD(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Head Remarks"),
          backgroundColor: const Color(0xFF2D2F45),
          foregroundColor: Colors.white,
        ),

        body: provider.loadclassdata
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              /// ----------- SELECT CLASS -----------
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Class",
                  border: OutlineInputBorder(),
                ),
                items: classes
                    .map(
                      (c) =>
                      DropdownMenuItem(value: c.name, child: Text(c.name)),
                )
                    .toList(),
                value: selectedClass.isEmpty ? null : selectedClass,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedClass = value);
                  provider.fetchstudent(selectedClass);
                },
              ),

              const SizedBox(height: 16),

              /// ----------- STUDENTS -----------
              provider.loadStudentone
                  ? const CircularProgressIndicator()
                  : Expanded(
                child: students.isEmpty
                    ? const Center(
                  child: Text(
                    "No students found.",
                    style: TextStyle(color: Colors.black54),
                  ),
                )
                    : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final s = students[index];
                    final String id = s["id"];
                    final String oldHeadRemark =
                        s["headremarks"]?.toString() ?? "";

                    // Initialize controller if not exist
                    headControllers.putIfAbsent(
                      id,
                          () => TextEditingController(text: oldHeadRemark),
                    );

                    // Initialize a FormKey for each student
                    formKeys.putIfAbsent(
                        id, () => GlobalKey<FormState>());

                    return Card(
                      elevation: 1,
                      child: Form(
                        key: formKeys[id],
                        child: ListTile(
                          title: Text(s["studentName"]),
                          subtitle: Text("ID: $id"),

                          trailing: Wrap(
                            children: [
                              SizedBox(
                                width: 250,
                                child: TextFormField(
                                  controller:
                                  headControllers[id],
                                  decoration:
                                  const InputDecoration(
                                    hintText:
                                    "Enter Head Remark",
                                    border:
                                    OutlineInputBorder(),
                                    contentPadding:
                                    EdgeInsets.all(8),
                                  ),
                                  validator: (v) {
                                    if (v == null ||
                                        v.trim().isEmpty) {
                                      return "Required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),

                              /// ------ SAVE BUTTON ------
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.blueGrey,
                                ),
                                onPressed: () async {
                                  final form =
                                  formKeys[id]!
                                      .currentState!;
                                  if (!form.validate()) return;

                                  final progress =
                                  ProgressHUD.of(context);
                                  progress?.show();

                                  try {
                                    String remark =
                                    headControllers[id]!
                                        .text
                                        .trim();

                                    await provider.headremarks(
                                        remark, id);

                                    ScaffoldMessenger.of(
                                        context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Saved for ${s['studentName']}"),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(
                                        context)
                                        .showSnackBar(
                                      SnackBar(
                                        content:
                                        Text("Error: $e"),
                                      ),
                                    );
                                  } finally {
                                    progress?.dismiss();
                                  }
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
