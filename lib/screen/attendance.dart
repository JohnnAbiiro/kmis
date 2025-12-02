import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String selectedClass = "";
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};

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
    final students = provider.studentlistattend;

    return ProgressHUD(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Attendance Manager"),
          backgroundColor: const Color(0xFF2D2F45),
          foregroundColor: Colors.white,
          leading:IconButton(
         icon: const Icon(Icons.arrow_back),
         onPressed: () {
          context.go(Routes.dashboard);
        },
      ),
        ),

        body: provider.loadclassdata ? const Center(child: CircularProgressIndicator())
          : Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Class",
                    border: OutlineInputBorder(),
                  ),
                  items: classes
                      .map((c) => DropdownMenuItem(
                    value: c.name,
                    child: Text(c.name),
                  ))
                      .toList(),
                  value:
                  selectedClass.isEmpty ? null : selectedClass,
                  onChanged: (value) async {
                    if (value == null) return;

                    setState(() => selectedClass = value);

                    await provider.fetchstudent(selectedClass);

                    /// Preload attendance values
                    for (var s in provider.studentlistattend) {
                      String id = s['id'];
                      String attend = (s['attendance'] ?? "0").toString();

                      controllers[id] =
                          TextEditingController(text: attend);
                    }

                    setState(() {});
                  },
                ),

                const SizedBox(height: 16),

                provider.loadStudentone
                    ? const CircularProgressIndicator()
                    : Expanded(
                  child: students.isEmpty
                      ? const Center(
                    child: Text(
                      "No students found.",
                      style:
                      TextStyle(color: Colors.black54),
                    ),
                  )
                      : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final s = students[index];
                      String id = s["id"];
                      String name = s["studentName"];
                      controllers[id] ??= TextEditingController(text: (s['attendance'] ?? "0").toString());

                      return Card(
                        child: ListTile(
                          title: Text(name),
                          subtitle: Text("ID: $id"),

                          trailing: Wrap(
                            children: [
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  controller:
                                  controllers[id],
                                  keyboardType:
                                  TextInputType.number,
                                  decoration:
                                  const InputDecoration(
                                    hintText: "0",
                                    border:
                                    OutlineInputBorder(),
                                    contentPadding:
                                    EdgeInsets.all(8),
                                  ),
                                  validator: (v) {
                                    if (v == null ||
                                        v.isEmpty) {
                                      return " ";
                                    }
                                    if (int.tryParse(v) ==
                                        null) {
                                      return " ";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style:
                                ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.blueGrey,
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!
                                      .validate()) {
                                    final progress =
                                    ProgressHUD.of(
                                        context);
                                    progress?.show();

                                    String attend =
                                    controllers[id]!
                                        .text
                                        .trim();

                                    await provider
                                        .updateattendance(
                                        attend, id);

                                    progress?.dismiss();

                                    ScaffoldMessenger.of(
                                        context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Attendance Updated"),
                                        backgroundColor:
                                        Colors.green,
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Save"),
                              ),
                            ],
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
      ),
    );
  }
}
