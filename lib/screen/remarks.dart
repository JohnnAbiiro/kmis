// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../controller/myprovider.dart';
//
// class RemarksPage extends StatefulWidget {
//   const RemarksPage({super.key});
//
//   @override
//   State<RemarksPage> createState() => _RemarksPageState();
// }
//
// class _RemarksPageState extends State<RemarksPage> {
//   String selectedClass = "";
//   final Map<String, String> attendanceMap = {};
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController attendanceController = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<Myprovider>().fetchclass();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<Myprovider>();
//
//     final classes = provider.classdata;
//     final List<Map<String, dynamic>>  students = provider.studentlistattend;
//     bool isSaving = false;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Remarks"),
//         backgroundColor: const Color(0xFF2D2F45),
//         foregroundColor: Colors.white,
//       ),
//
//       body: provider.loadclassdata
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               /// --------------------------
//               /// SELECT CLASS
//               /// --------------------------
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: "Select Class",
//                   border: OutlineInputBorder(),
//                 ),
//                 items: classes
//                     .map(
//                       (c) => DropdownMenuItem(
//                     value: c.name,
//                     child: Text(c.name),
//                   ),
//                 )
//                     .toList(),
//                 value: selectedClass.isEmpty ? null : selectedClass,
//                 onChanged: (value) {
//                   if (value == null) return;
//
//                   setState(() => selectedClass = value);
//
//                   provider.fetchstudent(selectedClass);
//                 },
//               ),
//
//               const SizedBox(height: 16),
//               provider.loadStudentone ? const CircularProgressIndicator()
//               : Expanded(
//                 child: students.isEmpty  ? const Center(
//                 child: Text("No students found.",  style: TextStyle(color: Colors.black54),),)
//                 : ListView.builder(
//                   itemCount: students.length,
//                   itemBuilder: (context, index) {
//                     final s = students[index];
//
//                     return Card(
//                       elevation: 1,
//                       child: ListTile(
//                           title: Text(s["studentName"]),
//                           subtitle: Text("ID: ${s['id']}"),
//
//                           trailing: Wrap(
//                             children: [
//                               SizedBox(
//                                 width: 250,
//                                 child: TextFormField(
//                                   controller: attendanceController,
//                                   keyboardType: TextInputType.text,
//                                   decoration: const InputDecoration(
//                                     hintText: "0",
//                                     border: OutlineInputBorder(),
//                                     contentPadding: EdgeInsets.all(8),
//                                   ),
//                                   validator: (v) {
//                                     if (v == null || v.trim().isEmpty) return "";
//                                     if (int.tryParse(v) == null) return "";
//                                     return null;
//                                   },
//                                   onChanged: (value) {
//                                     attendanceMap[s['id']] = value;
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blueGrey,
//                                 ),
//                                 onPressed: isSaving
//                                     ? null
//                                     : () async {
//                                   if (_formKey.currentState!.validate()) {
//                                     setState(() => isSaving = true);
//
//                                     try {
//                                       String attend = attendanceController.text.trim();
//                                       String id = s['id'];
//
//                                       await provider.updateattendance(attend, id);
//
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         const SnackBar(content: Text("Attendance Saved")),
//                                       );
//                                     } catch (e) {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(content: Text("Error: $e")),
//                                       );
//                                     } finally {
//                                       setState(() => isSaving = false);
//                                     }
//                                   }
//                                 },
//                                 child: isSaving
//                                     ? const SizedBox(
//                                   width: 20,
//                                   height: 20,
//                                   child: CircularProgressIndicator(strokeWidth: 2),
//                                 )
//                                     : const Text("Save"),
//                               ),
//                             ],
//                           )
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class RemarksPage extends StatefulWidget {
  const RemarksPage({super.key});

  @override
  State<RemarksPage> createState() => _RemarksPageState();
}

class _RemarksPageState extends State<RemarksPage> {
  String selectedClass = "";

  /// Each student gets its own controller
  final Map<String, TextEditingController> remarkControllers = {};

  /// Each student gets its own Form key for per-student validation
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
          title: const Text("Remarks"),
          backgroundColor: const Color(0xFF2D2F45),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go(Routes.dashboard),
          ),
        ),
        body: provider.loadclassdata
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              /// SELECT CLASS
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Class",
                  border: OutlineInputBorder(),
                ),
                items: classes
                    .map(
                      (c) => DropdownMenuItem(
                    value: c.name,
                    child: Text(c.name),
                  ),
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

              /// STUDENT LIST
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
                    final String remark =
                        s["remarks"]?.toString() ?? "";

                    // Initialize controller if not exist
                    remarkControllers.putIfAbsent(
                      id,
                          () =>
                          TextEditingController(text: remark),
                    );

                    // Initialize per-student Form key
                    formKeys.putIfAbsent(id, () => GlobalKey<FormState>());

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
                                  controller: remarkControllers[id],
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    hintText: "Enter remark",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(8),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return "Required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                ),
                                onPressed: () async {
                                  final currentForm = formKeys[id]!.currentState!;
                                  if (!currentForm.validate()) return;

                                  final progress = ProgressHUD.of(context);
                                  progress?.show();

                                  try {
                                    String newRemark =
                                    remarkControllers[id]!.text.trim();
                                    await provider.updateremarks(newRemark, id);

                                    // Update controller with saved value
                                    remarkControllers[id]!.text = newRemark;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Saved for ${s['studentName']}"),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: $e"),
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
