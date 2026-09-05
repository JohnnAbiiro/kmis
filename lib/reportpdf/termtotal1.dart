import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/subjectmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class Termtotal1Sheet extends StatefulWidget {
  const Termtotal1Sheet({super.key});

  @override
  State<Termtotal1Sheet> createState() => _Termtotal1SheetState();
}

class _Termtotal1SheetState extends State<Termtotal1Sheet> {
  String searchQuery = "";

  /// Store year + term selections for each subject
  Map<String, Map<String, String?>> rowSelections = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final p = context.read<Myprovider>();
      p.fetchsubjects();
      p.fetchacademicyear();
      p.fetchterms();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double colSpacing = screenWidth > 800 ? 24 : 8;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2F45),
        title: const Text("Student Score Sheet",
            style: TextStyle(color: Colors.white60)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, Routes.dashboard),
        ),
      ),

      body: Consumer<Myprovider>(
        builder: (context, provider, _) {
          if (provider.loadsubject) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.subjectList.isEmpty) {
            return const Center(
              child: Text("No subjects found.",
                  style: TextStyle(color: Colors.white60)),
            );
          }

          /// FILTER USING subject.name or code
          List<SubjectModel> filtered = provider.subjectList.where((s) {
            final q = searchQuery.toLowerCase();
            return s.name.toLowerCase().contains(q) ||
                (s.code?.toLowerCase().contains(q) ?? false) ||
                (s.level?.toLowerCase().contains(q) ?? false);
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                /// SEARCH FIELD
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search subject or code...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white60,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),

                /// TABLE
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: colSpacing,
                    headingTextStyle: const TextStyle(color: Colors.white),
                    dataTextStyle: const TextStyle(color: Colors.white60),

                    columns: const [
                      DataColumn(label: Text("No.")),
                      DataColumn(label: Text("Subject code")),
                      DataColumn(label: Text("Subject")),
                      DataColumn(label: Text("Year")),
                      DataColumn(label: Text("Term")),
                      DataColumn(label: Text("Has Data")),
                    ],

                    rows: List.generate(filtered.length, (i) {
                      final SubjectModel s = filtered[i];

                      final years = provider.academicyears;
                      final terms = provider.terms;

                      /// Initialize selection storage for this subject
                      rowSelections.putIfAbsent(s.id, () {
                        return {
                          "year": years.isNotEmpty ? years.first.id : null,
                          "term": terms.isNotEmpty ? terms.first.id : null,
                        };
                      });

                      return DataRow(
                        cells: [
                          DataCell(Text("${i + 1}")),

                          /// Subject Code
                          DataCell(Text(s.code ?? "—")),

                          /// Subject Name
                          DataCell(Text(s.name)),

                          /// YEAR DROPDOWN
                          DataCell(
                            DropdownButton<String>(
                              dropdownColor: const Color(0xFF2D2F45),
                              value: rowSelections[s.id]!['year'],
                              style: const TextStyle(color: Colors.white60),
                              items: years.map((y) {
                                return DropdownMenuItem(
                                  value: y.id,
                                  child: Text(y.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  rowSelections[s.id]!['year'] = value;
                                });
                              },
                            ),
                          ),

                          /// TERM DROPDOWN
                          DataCell(
                            DropdownButton<String>(
                              dropdownColor: const Color(0xFF2D2F45),
                              value: rowSelections[s.id]!['term'],
                              style: const TextStyle(color: Colors.white60),
                              items: terms.map((t) {
                                return DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  rowSelections[s.id]!['term'] = value;
                                });
                              },
                            ),
                          ),

                          /// HAS DATA ICON
                          DataCell(
                            Icon(Icons.check_circle, color: Colors.green),
                          ),
                        ],

                        onSelectChanged: (_) {
                          /// NOW YOU CAN SEND THE DATA EASILY
                          final selectedYear = rowSelections[s.id]!['year'];
                          final selectedTerm = rowSelections[s.id]!['term'];

                          // provider.fetchSubjectSheet(
                          //   subject: s,
                          //   yearId: selectedYear!,
                          //   termId: selectedTerm!,
                          //   context: context,
                          // );
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
