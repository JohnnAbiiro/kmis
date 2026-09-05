import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';


class RowSelection {
  String yearName;
  String termName;
  String level;

  RowSelection({
    required this.yearName,
    required this.termName,
    required this.level,
  });
}

class TermScoreSheet extends StatefulWidget {
  const TermScoreSheet({super.key});

  @override
  State<TermScoreSheet> createState() => _TermScoreSheetState();
}

class _TermScoreSheetState extends State<TermScoreSheet> {
  String searchQuery = "";
  final Map<String, RowSelection> rowSelections = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final p = context.read<Myprovider>();
      p.fetchacademicyear();
      p.fetchterms();
      p.fetchclass();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Myprovider>();

    final screenWidth = MediaQuery.sizeOf(context).width;
    double columnSpacing =
    screenWidth >= 900 ? 26 : screenWidth >= 600 ? 12 : 5;

    /// Still loading data?
    if (provider.loadclassdata ||
        provider.loadterms ||
        provider.loadacademicyear) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2F45),
        title: const Text(
          "Terminal Sheet Student",
          style: TextStyle(color: Colors.white60),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<Myprovider>(
        builder: (context, provider, _) {
          final classes = provider.classdata;
          final filteredData = classes.where((row) {
            final q = searchQuery.toLowerCase();
            return row.department!.toLowerCase().contains(q) ||
                row.name.toLowerCase().contains(q) ||
                row.staff.toLowerCase().contains(q);
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by department or level...",
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
                Container(
                  width: double.infinity,
                  color: const Color(0xFF2D2F45),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: columnSpacing,
                      headingTextStyle:
                      const TextStyle(color: Colors.white),
                      dataTextStyle:
                      const TextStyle(color: Colors.white60),

                      columns: const [
                        DataColumn(label: Text("No.")),
                        DataColumn(label: Text("Department")),
                        DataColumn(label: Text("Level")),
                        DataColumn(label: Text("Year")),
                        DataColumn(label: Text("Term")),
                        DataColumn(label: Text("Has Data")),
                      ],

                      rows: List.generate(filteredData.length, (i) {
                        final row = filteredData[i];

                        /// Initialize row selection if not already initialized
                        rowSelections[row.name] ??= RowSelection(
                          yearName: provider.academicyears.isNotEmpty
                              ? provider.academicyears.first.name
                              : "",
                          termName: provider.terms.first.name,
                          level: row.name,
                        );

                        final selection = rowSelections[row.name]!;

                        return DataRow(
                          onSelectChanged: (selected) async {
                            if (selected == true) {
                               {
                                try {
                                 await  provider.generatetotal(
                                    {
                                      "academicYear": selection.yearName,
                                      "term": selection.termName,
                                      "className": row.name,
                                    },
                                    context,
                                  );

                                  // Success feedback
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Total report generated successfully!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e, stackTrace) {
                                  print('Error generating total report: $e');

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("$e"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          cells: [

                            DataCell(
                              InkWell(
                            onTap: () async {
                          try {
                            await provider.generatetotal(
                              {
                                "academicYear": selection.yearName,
                                "term": selection.termName,
                                "className": row.name,
                              },
                              context,
                            );

                            // Success feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Total report generated successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e, stackTrace) {
                           print('Error generating total report: $e');

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to generate total report: $e"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                                child: Text("${i + 1}"),
                              ),
                            ),

                            // Department — clickable
                            DataCell(
                              InkWell(
                                onTap: () async {
                                  try {
                                    await provider.generatetotal(
                                      {
                                        "academicYear": selection.yearName,
                                        "term": selection.termName,
                                        "className": row.name,
                                      },
                                      context,
                                    );

                                    // Success feedback
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Total report generated successfully!"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e, stackTrace) {
                                    print('Error generating total report: $e');

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Failed to generate total report: $e"),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                                child: Text(row.department ?? ""),
                              ),
                            ),

                            // Level Dropdown
                            DataCell(
                              DropdownButton<String>(
                                dropdownColor: const Color(0xFF2D2F45),
                                value: selection.level,
                                style: const TextStyle(color: Colors.white60),
                                items: [
                                  DropdownMenuItem(
                                    value: row.name,
                                    child: Text(row.name),
                                  )
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selection.level = value!;
                                  });
                                },
                              ),
                            ),


                            DataCell(
                              DropdownButton<String>(
                                dropdownColor: const Color(0xFF2D2F45),
                                value: selection.yearName,
                                style: const TextStyle(color: Colors.white60),
                                items: provider.academicyears.map((y) {
                                  return DropdownMenuItem(
                                    value: y.name,
                                    child: Text(y.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selection.yearName = value!;
                                  });
                                },
                              ),
                            ),

                            // Term Dropdown
                            DataCell(
                              DropdownButton<String>(
                                dropdownColor: const Color(0xFF2D2F45),
                                value: selection.termName,
                                style: const TextStyle(color: Colors.white60),
                                items: provider.terms.map((t) {
                                  return DropdownMenuItem(
                                    value: t.name,
                                    child: Text(t.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selection.termName = value!;
                                  });
                                },
                              ),
                            ),

                            // Has Data — clickable
                            DataCell(
                              FutureBuilder<bool>(
                                future: provider.checkHasData(
                                  row.name,
                                  selection.yearName,
                                  selection.termName,
                                ),
                                builder: (context, snapshot) {
                                  final hasData = snapshot.data ?? false;
                                  return InkWell(
                                    onTap: () async {
                                      try {
                                        await provider.generatetotal(
                                          {
                                            "academicYear": selection.yearName,
                                            "term": selection.termName,
                                            "className": row.name,
                                          },
                                          context,
                                        );

                                        // Success feedback
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Total report generated successfully!"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e, stackTrace) {
                                        print('Error generating total report: $e');

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Failed to generate total report: $e"),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                                    child: Icon(
                                      hasData ? Icons.check_circle : Icons.cancel,
                                      color: hasData ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
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
