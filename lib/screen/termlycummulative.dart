import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../components/academicyrmodel.dart';
import '../controller/dbmodels/termmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class Termcummulative extends StatefulWidget {
  const Termcummulative({super.key});

  @override
  State<Termcummulative> createState() => _TermcummulativeState();
}

class _TermcummulativeState extends State<Termcummulative> {
  String searchQuery = "";
  final Map<String, Set<String>> selectedYears = {};
  final Map<String, Set<String>> selectedTerms = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<Myprovider>();
      p.fetchsubjects();
      p.fetchacademicyear();
      p.fetchterms();
    });
  }

  /// MULTI-SELECT YEAR POPUP
  Future<void> _showYearSelector(String rowKey, List<AcademicModel> years) async {
    selectedYears[rowKey] ??= {};

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setSB) => AlertDialog(
          backgroundColor: const Color(0xFF2D2F45),
          title: const Text("Select Academic Years", style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ListView(
              children: years.map((y) {
                final checked = selectedYears[rowKey]!.contains(y.name);
                return CheckboxListTile(
                  value: checked,
                  title: Text(y.name, style: const TextStyle(color: Colors.white70)),
                  checkColor: Colors.black,
                  activeColor: Colors.white,
                  onChanged: (v) {
                    setSB(() {
                      setState(() {
                        if (v == true) {
                          selectedYears[rowKey]!.add(y.name);
                        } else {
                          selectedYears[rowKey]!.remove(y.name);
                        }
                      });
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close", style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
  /// MULTI-SELECT TERM POPUP
  Future<void> _showTermSelector(String rowKey, List<TermModel> terms) async {
    selectedTerms[rowKey] ??= {};

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setSB) => AlertDialog(
          backgroundColor: const Color(0xFF2D2F45),
          title: const Text("Select Terms", style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ListView(
              children: terms.map((t) {
                final checked = selectedTerms[rowKey]!.contains(t.name);
                return CheckboxListTile(
                  value: checked,
                  title: Text(t.name, style: const TextStyle(color: Colors.white70)),
                  checkColor: Colors.black,
                  activeColor: Colors.white,
                  onChanged: (v) {
                    setSB(() {
                      setState(() {
                        if (v == true) {
                          selectedTerms[rowKey]!.add(t.name);
                        } else {
                          selectedTerms[rowKey]!.remove(t.name);
                        }
                      });
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close", style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    const double maxWidth = 1100;
    final double colSpacing = screenWidth > 800 ? 20 : screenWidth > 600 ? 15 : 8;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2F45),
        title: const Text("Term Cummulative Report", style: TextStyle(color: Colors.white60)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(Routes.dashboard),
        ),
      ),

      body: Consumer<Myprovider>(
        builder: (context, provider, _) {
          if (provider.loadclassdata || provider.loadsubject) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.subjectList.isEmpty) {
            return const Center(
              child: Text("No subjects found", style: TextStyle(color: Colors.white60)),
            );
          }

          final filtered = provider.subjectList.where((s) {
            final q = searchQuery.toLowerCase();
            return s.name.toLowerCase().contains(q) ||
                (s.code?.toLowerCase().contains(q) ?? false) ||
                (s.level?.toLowerCase().contains(q) ?? false);
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                /// SEARCH
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search subject or code...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white60,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),

                /// TABLE
                Container(
                  width: maxWidth,
                  color: const Color(0xFF2D2F45),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: colSpacing,
                      headingTextStyle: const TextStyle(color: Colors.white),
                      dataTextStyle: const TextStyle(color: Colors.white60),

                      columns: const [
                        DataColumn(label: Text("No")),
                        DataColumn(label: Text("Subject Code")),
                        DataColumn(label: Text("Subject")),
                        DataColumn(label: Text("Academic Year")),
                        DataColumn(label: Text("Term")),
                        DataColumn(label: Text("Generate")),
                      ],

                      rows: List.generate(filtered.length, (index) {
                        final s = filtered[index];
                        final rowKey = s.id;

                        final years = provider.academicyears;
                        final terms = provider.terms;

                        selectedYears[rowKey] ??= {};
                        selectedTerms[rowKey] ??= {};

                        return DataRow(
                          cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(Text(s.code ?? "—")),
                            DataCell(Text(s.name)),
                            /// MULTI SELECT YEARS
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
                                        ? "Select Years" : years
                                        .where((y) => selectedYears[rowKey]!.contains(y.name))
                                        .map((e) => e.name).join(", "),
                                    style: const TextStyle(color: Colors.white70),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            /// MULTI SELECT TERMS
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
                                        : terms
                                        .where((t) => selectedTerms[rowKey]!.contains(t.name))
                                        .map((e) => e.name)
                                        .join(", "),
                                    style: const TextStyle(color: Colors.white70),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            /// GENERATE BUTTON
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                                tooltip: "Generate Report",
                                  onPressed: () async {
                                    try {
                                      // Validate Years
                                      if (selectedYears[rowKey] == null || selectedYears[rowKey]!.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please select at least 1 year.')),
                                        );
                                        return;
                                      }

                                      // Validate Terms
                                      if (selectedTerms[rowKey] == null || selectedTerms[rowKey]!.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please select at least 1 term.')),
                                        );
                                        return;
                                      }

                                      // --- Safe to use .toList() now ---
                                      await provider.generatebestsubject(
                                        subject: s.name,
                                        subjectcode: s.code,
                                        years: selectedYears[rowKey]!.toList(),
                                        terms: selectedTerms[rowKey]!.toList(),
                                        context: context,
                                      );

                                      // Success feedback
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Best subject report generated successfully!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                    } catch (e, stackTrace) {
                                      // Catch any errors
                                      debugPrint('Error generating best subject report: $e');
                                      debugPrint('$stackTrace');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Failed to generate report"),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
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
