import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';

class RemarksPage extends StatefulWidget {
  const RemarksPage({super.key});

  @override
  State<RemarksPage> createState() => _RemarksPageState();
}

class _RemarksPageState extends State<RemarksPage> {
  String selectedClass = "";
  final Map<String, String> attendanceMap = {};
  final _formKey = GlobalKey<FormState>();
  final TextEditingController attendanceController = TextEditingController();
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
    final List<Map<String, dynamic>>  students = provider.studentlistattend;
    bool isSaving = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remarks"),
        backgroundColor: const Color(0xFF2D2F45),
        foregroundColor: Colors.white,
      ),

      body: provider.loadclassdata
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// --------------------------
              /// SELECT CLASS
              /// --------------------------
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
              provider.loadStudentone ? const CircularProgressIndicator()
              : Expanded(
                child: students.isEmpty  ? const Center(
                child: Text("No students found.",  style: TextStyle(color: Colors.black54),),)
                : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final s = students[index];

                    return Card(
                      elevation: 1,
                      child: ListTile(
                          title: Text(s["studentName"]),
                          subtitle: Text("ID: ${s['id']}"),

                          trailing: Wrap(
                            children: [
                              SizedBox(
                                width: 250,
                                child: TextFormField(
                                  controller: attendanceController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    hintText: "0",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(8),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return "";
                                    if (int.tryParse(v) == null) return "";
                                    return null;
                                  },
                                  onChanged: (value) {
                                    attendanceMap[s['id']] = value;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                ),
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => isSaving = true);

                                    try {
                                      String attend = attendanceController.text.trim();
                                      String id = s['id'];

                                      await provider.updateattendance(attend, id);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Attendance Saved")),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    } finally {
                                      setState(() => isSaving = false);
                                    }
                                  }
                                },
                                child: isSaving
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : const Text("Save"),
                              ),
                            ],
                          )
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
