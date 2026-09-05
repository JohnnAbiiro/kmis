import 'package:ksoftsms/controller/myprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/screen/subject.dart';
import 'package:provider/provider.dart';
import '../controller/routes.dart';

class ViewSubjectPage extends StatefulWidget {
  const ViewSubjectPage({super.key});

  @override
  State<ViewSubjectPage> createState() => _ViewSubjectPageState();
}

class _ViewSubjectPageState extends State<ViewSubjectPage> {
  int? sortColumnIndex;
  bool isAscending = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<Myprovider>(context, listen: false);
      await provider.fetchsubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double maxWidth = 900;
    double colSpacing =
    screenWidth > 800 ? 35 : screenWidth > 600 ? 25 : 10;

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, provider, _) {
          final subjects = provider.subjectList;
          final filteredSubjects = subjects.where((subj) {
            final query = searchQuery.toLowerCase();
            return subj.name.toLowerCase().contains(query) ||
                (subj.code ?? "").toLowerCase().contains(query) ||
                (subj.level ?? "").toLowerCase().contains(query);
          }).toList();

          return Scaffold(
            //backgroundColor: const Color(0xFF2D2F45),
            appBar: AppBar(
              backgroundColor: const Color(0xFF2D2F45),
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                "Subjects List",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(
                        width: maxWidth,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search subject, code, or level...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          onChanged: (value) =>
                              setState(() => searchQuery = value),
                        ),
                      ),
                    ),

                    /// Table
                    Container(
                      width: maxWidth,
                      color: const Color(0xFF2D2F45),
                      child: filteredSubjects.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No matching results",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey),
                        ),
                      )
                          : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: maxWidth),
                          child: DataTable(
                            columnSpacing: colSpacing,
                            sortColumnIndex: sortColumnIndex,
                            sortAscending: isAscending,
                            headingRowColor:
                            MaterialStateProperty.resolveWith(
                                    (states) =>
                                const Color(0xFF2D2F45)),
                            border: TableBorder.all(color: Colors.grey.shade300),
                            columns: [
                              const DataColumn(
                                label: Text("#",
                                    style:
                                    TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: const Text("Subject",
                                    style:
                                    TextStyle(color: Colors.white)),
                                onSort: (index, ascending) {
                                  setState(() {
                                    sortColumnIndex = index;
                                    isAscending = ascending;
                                    filteredSubjects.sort((a, b) =>
                                    ascending
                                        ? a.name.compareTo(b.name)
                                        : b.name.compareTo(a.name));
                                  });
                                },
                              ),
                              const DataColumn(
                                label: Text("Code",
                                    style:
                                    TextStyle(color: Colors.white)),
                              ),
                              const DataColumn(
                                label: Text("Level",
                                    style:
                                    TextStyle(color: Colors.white)),
                              ),
                              const DataColumn(
                                label: Text("Actions",
                                    style:
                                    TextStyle(color: Colors.white)),
                              ),
                            ],
                            rows: filteredSubjects
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key + 1;
                              final subj = entry.value;
                              return DataRow(
                                color: MaterialStateProperty.resolveWith(
                                        (states) =>
                                    const Color(0xFFffffff)),
                                cells: [
                                  DataCell(Text("$index",
                                      style: const TextStyle(
                                          color: Colors.black54))),
                                  DataCell(Text(subj.name,
                                      style: const TextStyle(
                                          color: Colors.black54))),
                                  DataCell(Text(subj.code ?? "-",
                                      style: const TextStyle(
                                          color: Colors.black54))),
                                  DataCell(Text(subj.level ?? "-",
                                      style: const TextStyle(
                                          color: Colors.black54))),
                                  DataCell(Row(
                                    children: [
                                      /// EDIT BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.amber),
                                        onPressed: () {
                                          Navigator.push(context,MaterialPageRoute(builder: (context) => SubjectRegistration(subject: subj)));
                                        },
                                      ),

                                      /// DELETE BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          final confirm =
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) =>
                                                AlertDialog(
                                                  backgroundColor:
                                                  const Color(0xFF2D2F45),
                                                  title: const Text(
                                                    "Delete Subject",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  content: const Text(
                                                    "Are you sure you want to delete this subject?",
                                                    style: TextStyle(
                                                        color:
                                                        Colors.white70),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, false),
                                                      child: const Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white70),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, true),
                                                      child: const Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .redAccent),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await provider.deleteSubject(subj.id);
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Subject deleted successfully"),
                                                    backgroundColor:
                                                    Colors.green,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                    context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Failed to delete subject: $e"),
                                                    backgroundColor:
                                                    Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
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
