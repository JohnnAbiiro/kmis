import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class Reopening extends StatefulWidget {
  const Reopening({super.key});

  @override
  State<Reopening> createState() => _ReopeningState();
}

class _ReopeningState extends State<Reopening> {
  String selectedClass = "";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController reopeningController = TextEditingController();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchclass();
    });
  }

  Future<void> pickReopeningDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)), // future only
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      reopeningController.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Myprovider>();
    final classes = provider.classdata;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reopening"),
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
                    .map((c) => DropdownMenuItem(
                  value: c.name,
                  child: Text(c.name),
                ))
                    .toList(),
                value: selectedClass.isEmpty ? null : selectedClass,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedClass = value);
                },
                validator: (v) =>
                (v == null || v.isEmpty) ? "Please select a class" : null,
              ),

              const SizedBox(height: 20),

              /// --------------------------
              /// SELECT DATE (Future Only)
              /// --------------------------
              TextFormField(
                controller: reopeningController,
                readOnly: true,
                onTap: () => pickReopeningDate(),
                decoration: const InputDecoration(
                  labelText: "Select Reopening Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Pick a date" : null,
              ),

              const SizedBox(height: 25),

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
                      await provider.reopening(
                        reopeningController.text.trim(),
                        selectedClass,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Reopening updated")),
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
