import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class NextFees extends StatefulWidget {
  const NextFees({super.key});

  @override
  State<NextFees> createState() => _NextFeesState();
}

class _NextFeesState extends State<NextFees> {
  String selectedClass = "";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController feesController = TextEditingController();
  bool isSaving = false;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Next Fees Update"),
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
                validator: (v) =>
                (v == null || v.isEmpty) ? "Please select a class" : null,
              ),

              const SizedBox(height: 20),

              /// --------------------------
              /// FEES INPUT (NO DATE PICKER)
              /// --------------------------
              TextFormField(
                controller: feesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter Next Fees",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter amount";
                  }
                  if (double.tryParse(v) == null) {
                    return "Enter a valid number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              /// --------------------------
              /// SAVE BUTTON
              /// --------------------------
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: isSaving ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => isSaving = true);
                    try {
                      await provider.nextfees(
                        feesController.text.trim(),
                        selectedClass,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar( content: Text("Next Fees Updated")),
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
