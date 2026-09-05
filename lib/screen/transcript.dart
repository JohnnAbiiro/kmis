import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/academicyrmodel.dart';
import '../controller/dbmodels/termmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class TranscriptReport extends StatefulWidget {
  const TranscriptReport({super.key});

  @override
  State<TranscriptReport> createState() => _TranscriptReportState();
}

class _TranscriptReportState extends State<TranscriptReport> {
  String searchQuery = "";
  String? selectedClassId;

  // studentId -> {yearName}
  final Map<String, Set<String>> selectedYears = {};

  // studentId -> {termName}
  final Map<String, Set<String>> selectedTerms = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<Myprovider>();
      provider.fetchclass();
      provider.fetchstudents();
      provider.fetchterms();
      provider.fetchacademicyear();
    });
  }

  // ---------------- TERM SELECTOR -----------------
  Future<void> _showTermSelector(String studentId, List<TermModel> terms) async {
    selectedTerms[studentId] ??= {};

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2F45),
          title: const Text("Select Terms", style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (_, setSB) {
              return SizedBox(
                width: 300,
                height: 300,
                child: ListView(
                  children: terms.map((t) {
                    final checked = selectedTerms[studentId]!.contains(t.name);
                    return CheckboxListTile(
                      value: checked,
                      title: Text(t.name, style: const TextStyle(color: Colors.white70)),
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      onChanged: (v) {
                        setSB(() {
                          if (v == true) {
                            selectedTerms[studentId]!.add(t.name);
                          } else {
                            selectedTerms[studentId]!.remove(t.name);
                          }
                          setState(() {});
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close", style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  // ---------------- YEAR SELECTOR -----------------
  Future<void> _showYearSelector(String studentId, List<AcademicModel> years) async {
    selectedYears[studentId] ??= {};

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2F45),
          title: const Text("Select Academic Years", style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (_, setSB) {
              return SizedBox(
                width: 300,
                height: 300,
                child: ListView(
                  children: years.map((y) {
                    final checked = selectedYears[studentId]!.contains(y.name);
                    return CheckboxListTile(
                      value: checked,
                      title: Text(y.name, style: const TextStyle(color: Colors.white70)),
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      onChanged: (v) {
                        setSB(() {
                          if (v == true) {
                            selectedYears[studentId]!.add(y.name);
                          } else {
                            selectedYears[studentId]!.remove(y.name);
                          }
                          setState(() {});
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close", style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  // ---------------------- UI -------------------------
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Myprovider>();

    if (provider.loadStudent || provider.loadclassdata) {
      return const Scaffold(
        backgroundColor: Color(0xFF1B1D2A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final classes = provider.classdata;
    final terms = provider.terms;
    final years = provider.academicyears;

    final students = provider.studentlist
        .where((s) =>
    (selectedClassId == null || s.level == selectedClassId) &&
        (searchQuery.isEmpty ||
            s.name.toLowerCase().contains(searchQuery.toLowerCase())))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2F45),
        title: const Text("Transcript Report",
            style: TextStyle(color: Colors.white60)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // //---------------- CLASS DROPDOWN ----------------
            // Padding(
            //   padding: const EdgeInsets.all(16),
            //   child: DropdownButtonFormField<String>(
            //     value: selectedClassId,
            //     decoration: const InputDecoration(
            //       labelText: "Select Class",
            //       filled: true,
            //       fillColor: Colors.white60,
            //     ),
            //     items: classes
            //         .map((c) => DropdownMenuItem(
            //       value: c.id, // FIXED: use ID again
            //       child: Text(c.name),
            //     ))
            //         .toList(),
            //     onChanged: (v) => setState(() => selectedClassId = v),
            //   ),
            // ),

            //------------------ SEARCH (ONE ONLY) -------------------
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search student...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white60,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => setState(() => searchQuery = v),
              ),
            ),

            //------------------ TABLE --------------------
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(color: Colors.white),
                dataTextStyle: const TextStyle(color: Colors.white60),
                columns: const [
                  DataColumn(label: Text("No")),
                  DataColumn(label: Text("Student Name")),
                  DataColumn(label: Text("Class")),
                  DataColumn(label: Text("Terms")),
                  DataColumn(label: Text("Years")),
                  DataColumn(label: Text("Generate")),
                ],
                rows: List.generate(students.length, (i) {
                  final s = students[i];
                  final rowKey = s.id;

                  selectedTerms[rowKey] ??= {};
                  selectedYears[rowKey] ??= {};

                  return DataRow(cells: [
                    DataCell(Text("${i + 1}")),
                    DataCell(Text(s.name)),
                    DataCell(Text(s.level ?? "")),

                    // ---------- Terms Cell ----------
                    DataCell(
                      InkWell(
                        onTap: () => _showTermSelector(rowKey, terms),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            selectedTerms[rowKey]!.isEmpty
                                ? "Select Terms"
                                : selectedTerms[rowKey]!.join(", "),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),

                    // ---------- Years Cell ----------
                    DataCell(
                      InkWell(
                        onTap: () => _showYearSelector(rowKey, years),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            selectedYears[rowKey]!.isEmpty
                                ? "Select Years"
                                : selectedYears[rowKey]!.join(", "),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),

                    // ---------- Generate Button ----------
                    DataCell(
                      IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                          onPressed: () async {
                            try {
                              // RUN your report generator
                              await provider.generatetranscriptReport(
                                student: s.name,
                                studentid: s.id,
                                academicYears: selectedYears[rowKey]!.toList(),
                                termIds: selectedTerms[rowKey]!.toList(),  // you asked to send NAMES
                              );

                              // IF SUCCESS
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Report generated successfully!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              // IF ERROR
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to generate report: $e"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
