import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/components/academicyrmodel.dart';
import '../controller/dbmodels/termmodel.dart';
import '../controller/routes.dart';

class Currenttermyr extends StatefulWidget {
  @override
  State<Currenttermyr> createState() => _CurrenttermyrState();
}

class _CurrenttermyrState extends State<Currenttermyr> {
  final _formKey = GlobalKey<FormState>();

  AcademicModel? selectedYear;
  TermModel? selectedTerm;
  bool isSaving = false; // 🔹 Track saving state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<Myprovider>();
      await provider.fetchsubjects();
      await provider.fetchacademicyear();
      await provider.fetchterms();
      setState(() {
        if (provider.academicyears.isNotEmpty) {
          selectedYear = provider.academicyears.first;
        }
        if (provider.terms.isNotEmpty) {
          selectedTerm = provider.terms.first;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Myprovider>();
    final years = provider.academicyears;
    final terms = provider.terms;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1D2A),
      appBar: AppBar(
        title: const Text("Academic Settings",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF2D2F45),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(Routes.dashboard),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Academic Year
              const Text(
                "Select Academic Year:",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<AcademicModel>(
                value: selectedYear,
                items: years
                    .map((year) => DropdownMenuItem(
                  value: year,
                  child: Text(year.name),
                ))
                    .toList(),
                onChanged: (value) => setState(() => selectedYear = value),
                validator: (value) =>
                value == null ? "Please select academic year" : null,
                hint: const Text(
                  "Choose Academic Year",
                  style: TextStyle(color: Colors.white70),
                ),
                dropdownColor: const Color(0xFF2D2F45),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFF2D2F45),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Term
              const Text(
                "Select Term:",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<TermModel>(
                value: selectedTerm,
                items: terms
                    .map((term) => DropdownMenuItem(
                  value: term,
                  child: Text(term.name),
                ))
                    .toList(),
                onChanged: (value) => setState(() => selectedTerm = value),
                validator: (value) =>
                value == null ? "Please select term" : null,
                hint: const Text(
                  "Choose Term",
                  style: TextStyle(color: Colors.white70),
                ),
                dropdownColor: const Color(0xFF2D2F45),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFF2D2F45),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                  ),
                  onPressed: isSaving
                      ? null // Disable button while saving
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => isSaving = true);
                      try {
                        await provider.updateSchoolsetting(
                          selectedYear!.name,
                          selectedTerm!.name,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "School academic settings updated successfully"),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                          ),
                        );
                      } finally {
                        setState(() => isSaving = false);
                      }
                    }
                  },
                  child: Text(
                    isSaving ? "Saving..." : "SAVE",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
