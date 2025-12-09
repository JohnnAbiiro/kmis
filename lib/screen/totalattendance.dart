import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
class Totalattend extends StatefulWidget {
  const Totalattend({super.key});

  @override
  State<Totalattend> createState() => _TotalattendState();
}

class _TotalattendState extends State<Totalattend> {
  String selectedClass = "";
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

    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Attendance"),
              backgroundColor: const Color(0xFF2D2F45),
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.go(Routes.dashboard);
                },
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
                      value:
                      selectedClass.isEmpty ? null : selectedClass,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedClass = value);
                        provider.fetchstudent(selectedClass);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: attendanceController,
                      style: const TextStyle(),
                      decoration: const InputDecoration(
                        labelText: "Total Attendance",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        final value = double.tryParse(val.trim());
                        if (value == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final progress =
                          ProgressHUD.of(context);

                          progress?.show();

                          try {
                            String attend =
                            attendanceController.text.trim();

                            await provider.bulkupdateattendance(
                                attend, selectedClass);

                            if (!mounted) return;
                            progress?.dismiss();

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text("Attendance Saved"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            progress?.dismiss();

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text("Error: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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
    );
  }
}
