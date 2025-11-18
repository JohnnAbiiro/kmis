import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';

class Reopening extends StatefulWidget {
  const Reopening({super.key});

  @override
  State<Reopening> createState() => _ReopeningState();
}

class _ReopeningState extends State<Reopening> {
  String selectedClass = "";
  final Map<String, String> attendanceMap = {};
  final _formKey = GlobalKey<FormState>();
  final TextEditingController reopeningController = TextEditingController();
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
        title: const Text("Reopening"),
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
                },
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: 250,
                child: TextFormField(
                  controller: reopeningController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    hintText: "Enter date e.g 2025-09-24",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(8),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "";
                    if (int.tryParse(v) == null) return "";
                    return null;
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
                      String reopen = reopeningController.text.trim();


                      await provider.reopening(reopen,selectedClass);

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
          ),
        ),
      ),
    );
  }
}
