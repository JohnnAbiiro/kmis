import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/teachermodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
class TeacherListPage extends StatefulWidget {
  const TeacherListPage({super.key});

  @override
  State<TeacherListPage> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String _sortColumn = "staffname";
  bool _isAscending = true;

  /// Track which rows are expanded
  final Set<int> _expandedRows = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchTeacherSetupList(reset: true);
    });
    _searchController.addListener(() => setState(() => _currentPage = 0));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeacherSetup> _applySearchAndSort(List<TeacherSetup> list) {
    final query = _searchController.text.trim().toLowerCase();

    // Filter
    var filtered = query.isEmpty
        ? List<TeacherSetup>.from(list)
        : list.where((item) {
      final fields = [
        item.staffname,
        item.classname.map((c) => c.name).join(","),
      ].map((e) => e.toLowerCase()).toList();
      return fields.any((f) => f.contains(query));
    }).toList();

    // Sort
    filtered.sort((a, b) {
      late String aVal;
      late String bVal;

      switch (_sortColumn) {
        case "staffid":
          aVal = a.staffid;
          bVal = b.staffid;
          break;
        case "staffname":
          aVal = a.staffname;
          bVal = b.staffname;
          break;
        case "schoolId":
          aVal = a.schoolId;
          bVal = b.schoolId;
          break;
        default:
          aVal = a.staffname;
          bVal = b.staffname;
      }

      return _isAscending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    });
    return filtered;
  }

  void _toggleSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = column;
        _isAscending = true;
      }
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = 1100;

    return Consumer<Myprovider>(
      builder: (context, value, child) {
        final teachers = value.teacherSetupList;
        final filteredTeachers = _applySearchAndSort(teachers);

        // Pagination
        int startIndex = _currentPage * _rowsPerPage;
        int endIndex = (startIndex + _rowsPerPage).clamp(0, filteredTeachers.length);
        final pageItems = filteredTeachers.sublist(startIndex, endIndex);

        return Scaffold(
          //backgroundColor: const Color(0xFF1B1D2A),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go(Routes.dashboard),
            ),
            backgroundColor: const Color(0xFF2D2F45),
            title: const Text(
              "Teacher Setup List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          body: value.isLoadingTeacherList
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: maxWidth,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Search Teachers",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _currentPage = 0);
                        },
                      )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      fillColor: Colors.white60,
                      filled: true,
                    ),
                  ),
                ),
              ),
                const SizedBox(height: 16),
                Expanded(
                child: pageItems.isEmpty
                    ? const Center(
                      child: Text(
                    "No Teachers Found",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ) : ListView.builder(
                    itemCount: pageItems.length,
                    itemBuilder: (context, idx) {
                    final index = idx + startIndex;
                    final item = pageItems[idx];


                    final classes = item.classname.map((c) => c.name).toList();
                    final subjects = item.subjects.map((s) => s.name).toList();

                    final isExpanded = _expandedRows.contains(index);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedRows.remove(index);
                          } else {
                            _expandedRows.add(index);
                          }
                        });
                      },
                      child: Card(
                        color: const Color(0xFF2D2F45),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row summary
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${index + 1}. ${item.staffname}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Expanded section
                              if (isExpanded) ...[
                                const Divider(color: Colors.white38, height: 16),
                                const SizedBox(height: 8),
                                Text("Classes:",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  children: classes
                                      .map((cls) => Chip(
                                    label: Text(cls,
                                        style: const TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.deepPurple.shade700,
                                  ))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                                Text("Subjects:",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  children: subjects
                                      .map((sub) => Chip(
                                    label: Text(sub,
                                        style: const TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.teal.shade700,
                                  )).toList(),
                                ),
                                const SizedBox(height: 12),
                                // Action buttons
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () {
                                        context.go(Routes.setupteacher, extra: item);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            backgroundColor: const Color(0xFF2D2F45),
                                            title: const Text("Confirm Delete",
                                                style: TextStyle(color: Colors.white)),
                                            content: Text(
                                              "Are you sure you want to delete Teacher '${item.staffname}'?",
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: const Text("Cancel",
                                                    style: TextStyle(color: Colors.white70)),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red),
                                                child: const Text("Delete",
                                                    style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          try {
                                             await value.deleteteacher(
                                                 item.staffid
                                                );

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Teacher '${item.staffname}' deleted successfully"),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(e.toString().replaceAll("Exception: ", "")),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(seconds: 4),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Pagination
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                    icon: const Icon(Icons.chevron_left, color: Colors.black54),
                  ),
                  Text(
                    "Page ${_currentPage + 1} of ${((filteredTeachers.length - 1) / _rowsPerPage).floor() + 1}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  IconButton(
                    onPressed: endIndex < filteredTeachers.length
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: const Icon(Icons.chevron_right, color: Colors.black54),
                  ),
                ],
              ),
                const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
