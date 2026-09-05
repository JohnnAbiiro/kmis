// import 'package:go_router/go_router.dart';
// import 'package:ksoftsms/controller/myprovider.dart';
// import 'package:flutter/material.dart';
// import 'package:ksoftsms/screen/subject.dart';
// import 'package:provider/provider.dart';
// import '../controller/routes.dart';
//
// class ViewSubjectPage extends StatefulWidget {
//   const ViewSubjectPage({super.key});
//
//   @override
//   State<ViewSubjectPage> createState() => _ViewSubjectPageState();
// }
//
// class _ViewSubjectPageState extends State<ViewSubjectPage> {
//   bool _sortAscending = true;
//   String searchQuery = "";
//   bool _isLoading = true;
//   String? _deletingId;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final provider = Provider.of<Myprovider>(context, listen: false);
//       await provider.fetchsubjects();
//       if (mounted) setState(() => _isLoading = false);
//     });
//   }
//
//   Future<void> _confirmDelete(Myprovider provider, String id, String name) async {
//     final colorScheme = Theme.of(context).colorScheme;
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: colorScheme.surface,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         title: Text("Delete Subject", style: TextStyle(color: colorScheme.onSurface)),
//         content: Text(
//           'Delete "$name"? This cannot be undone.',
//           style: TextStyle(color: colorScheme.onSurfaceVariant),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant)),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: Text("Delete", style: TextStyle(color: colorScheme.error)),
//           ),
//         ],
//       ),
//     );
//     if (confirm != true) return;
//
//     setState(() => _deletingId = id);
//     try {
//       await provider.deleteSubject(id);
//       provider.removeSubjectLocal(id);
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Subject deleted successfully"), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to delete subject: $e"), backgroundColor: Colors.red),
//       );
//     } finally {
//       if (mounted) setState(() => _deletingId = null);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return Consumer<Myprovider>(
//       builder: (context, provider, _) {
//         final subjects = List.of(provider.subjectList);
//         final filteredSubjects = subjects.where((subj) {
//           final query = searchQuery.toLowerCase();
//           return subj.name.toLowerCase().contains(query) ||
//               (subj.code ?? "").toLowerCase().contains(query) ||
//               (subj.level ?? "").toLowerCase().contains(query);
//         }).toList()
//           ..sort((a, b) =>
//           _sortAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
//
//         return Scaffold(
//           // No explicit backgroundColor — inherits scaffoldBackgroundColor
//           // from the app theme in main.dart.
//           appBar: AppBar(
//             title: const Text("Subjects List"),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () {
//                 if (context.canPop()) {
//                   context.pop();
//                 } else {
//                   context.go(Routes.dashboard);
//                 }
//               },
//             ),
//           ),
//           floatingActionButton: FloatingActionButton.extended(
//             backgroundColor: colorScheme.primary,
//             foregroundColor: colorScheme.onPrimary,
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const SubjectRegistration()),
//             ),
//             icon: const Icon(Icons.add),
//             label: const Text('New subject'),
//           ),
//           body: _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : LayoutBuilder(
//             builder: (context, constraints) {
//               final isWideScreen = constraints.maxWidth > 700;
//
//               return Align(
//                 alignment: Alignment.topCenter,
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 900),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: "Search subject, code, or level...",
//                             prefixIcon: const Icon(Icons.search),
//                             filled: true,
//                             fillColor: colorScheme.surfaceContainerHighest,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
//                             ),
//                           ),
//                           onChanged: (value) => setState(() => searchQuery = value),
//                         ),
//                       ),
//                       Expanded(
//                         child: filteredSubjects.isEmpty
//                             ? Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: Text(
//                               "No matching results",
//                               style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
//                             ),
//                           ),
//                         )
//                             : isWideScreen
//                             ? _buildTableList(provider, filteredSubjects)
//                             : _buildCardList(provider, filteredSubjects),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   /// Wide-screen "table" — a header row plus a ListView.builder of rows,
//   /// laid out with Expanded columns instead of a DataTable.
//   Widget _buildTableList(Myprovider provider, List filteredSubjects) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     const flexIndex = 1;
//     const flexSubject = 4;
//     const flexCode = 2;
//     const flexLevel = 2;
//     const flexActions = 2;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Card(
//         color: colorScheme.surface,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           children: [
//             // Header row
//             Container(
//               color: colorScheme.primary,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: flexIndex,
//                     child: Text("#", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
//                   ),
//                   Expanded(
//                     flex: flexSubject,
//                     child: InkWell(
//                       onTap: () => setState(() => _sortAscending = !_sortAscending),
//                       child: Row(
//                         children: [
//                           Text("Subject",
//                               style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
//                           const SizedBox(width: 4),
//                           Icon(
//                             _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
//                             size: 14,
//                             color: colorScheme.onPrimary,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: flexCode,
//                     child: Text("Code", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
//                   ),
//                   Expanded(
//                     flex: flexLevel,
//                     child: Text("Level", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
//                   ),
//                   Expanded(
//                     flex: flexActions,
//                     child: Text("Actions",
//                         textAlign: TextAlign.end,
//                         style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
//                   ),
//                 ],
//               ),
//             ),
//             // Rows
//             Flexible(
//               child: ListView.separated(
//                 shrinkWrap: true,
//                 itemCount: filteredSubjects.length,
//                 separatorBuilder: (context, index) => Divider(height: 1, color: colorScheme.outlineVariant),
//                 itemBuilder: (context, index) {
//                   final subj = filteredSubjects[index];
//                   final isBusy = _deletingId == subj.id;
//
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: flexIndex,
//                           child: Text("${index + 1}", style: TextStyle(color: colorScheme.onSurfaceVariant)),
//                         ),
//                         Expanded(
//                           flex: flexSubject,
//                           child: Text(subj.name, style: TextStyle(color: colorScheme.onSurface)),
//                         ),
//                         Expanded(
//                           flex: flexCode,
//                           child: Text(subj.code ?? "-", style: TextStyle(color: colorScheme.onSurfaceVariant)),
//                         ),
//                         Expanded(
//                           flex: flexLevel,
//                           child: _levelChip(subj.level),
//                         ),
//                         Expanded(
//                           flex: flexActions,
//                           child: isBusy
//                               ? const Align(
//                             alignment: Alignment.centerRight,
//                             child: SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             ),
//                           )
//                               : Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.edit),
//                                 color: Colors.amber,
//                                 onPressed: () => Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => SubjectRegistration(subject: subj))),
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete),
//                                 color: colorScheme.error,
//                                 onPressed: () => _confirmDelete(provider, subj.id, subj.name),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Mobile card list — unchanged in spirit, still ListView.builder.
//   Widget _buildCardList(Myprovider provider, List filteredSubjects) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
//       itemCount: filteredSubjects.length,
//       itemBuilder: (context, index) {
//         final subj = filteredSubjects[index];
//         final isBusy = _deletingId == subj.id;
//
//         return Card(
//           color: colorScheme.surface,
//           margin: const EdgeInsets.only(bottom: 10),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           child: ListTile(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             leading: CircleAvatar(
//               backgroundColor: colorScheme.primary,
//               child: Text(
//                 subj.name.isNotEmpty ? subj.name[0].toUpperCase() : '?',
//                 style: TextStyle(color: colorScheme.onPrimary),
//               ),
//             ),
//             title: Text(
//               subj.name,
//               style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
//             ),
//             subtitle: Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Wrap(
//                 spacing: 8,
//                 runSpacing: 4,
//                 children: [
//                   Text(subj.code ?? "-", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
//                   _levelChip(subj.level),
//                 ],
//               ),
//             ),
//             trailing: isBusy
//                 ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                 : PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert),
//               onSelected: (choice) {
//                 if (choice == 'edit') {
//                   Navigator.push(
//                       context, MaterialPageRoute(builder: (context) => SubjectRegistration(subject: subj)));
//                 } else if (choice == 'delete') {
//                   _confirmDelete(provider, subj.id, subj.name);
//                 }
//               },
//               itemBuilder: (context) => const [
//                 PopupMenuItem(value: 'edit', child: Text('Edit')),
//                 PopupMenuItem(value: 'delete', child: Text('Delete')),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _levelChip(String? level) {
//     final colorScheme = Theme.of(context).colorScheme;
//     if (level == null || level.isEmpty) {
//       return Text('-', style: TextStyle(color: colorScheme.onSurfaceVariant));
//     }
//     return Chip(
//       label: Text(level, style: TextStyle(fontSize: 11, color: colorScheme.onSecondaryContainer)),
//       backgroundColor: colorScheme.secondaryContainer,
//       visualDensity: VisualDensity.compact,
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//     );
//   }
// }

import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:flutter/material.dart';
import 'package:ksoftsms/screen/subject.dart';
import 'package:provider/provider.dart';
import '../controller/routes.dart';

class ViewSubjectPage extends StatefulWidget {

  final bool embedded;

  const ViewSubjectPage({super.key, this.embedded = false});

  @override
  State<ViewSubjectPage> createState() => _ViewSubjectPageState();
}

class _ViewSubjectPageState extends State<ViewSubjectPage> {
  bool _sortAscending = true;
  String searchQuery = "";
  bool _isLoading = true;
  String? _deletingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<Myprovider>(context, listen: false);
      await provider.fetchsubjects();
      if (mounted) setState(() => _isLoading = false);
    });
  }
 Future<void> _openRegistration({dynamic subject}) async {
    if (widget.embedded) {
      await showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          child: SizedBox(
            width: 720,
            height: 640,
            child: SubjectRegistration(subject: subject, embedded: true),
          ),
        ),
      );
      if (mounted) setState(() {});
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SubjectRegistration(subject: subject)),
      );
    }
  }

  Future<void> _confirmDelete(Myprovider provider, String id, String name) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text("Delete Subject", style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          'Delete "$name"? This cannot be undone.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Delete", style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _deletingId = id);
    try {
      await provider.deleteSubject(id);
      provider.removeSubjectLocal(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subject deleted successfully"), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete subject: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _deletingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<Myprovider>(
      builder: (context, provider, _) {
        final subjects = List.of(provider.subjectList);
        final filteredSubjects = subjects.where((subj) {
          final query = searchQuery.toLowerCase();
          return subj.name.toLowerCase().contains(query) ||
              (subj.code ?? "").toLowerCase().contains(query) ||
              (subj.level ?? "").toLowerCase().contains(query);
        }).toList()
          ..sort((a, b) =>
          _sortAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));

        final content = _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 700;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    if (widget.embedded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          children: [
                            Icon(Icons.menu_book_outlined, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Registered courses / subjects',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () => _openRegistration(),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('New'),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search subject, code, or level...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                        ),
                        onChanged: (value) => setState(() => searchQuery = value),
                      ),
                    ),
                    Expanded(
                      child: filteredSubjects.isEmpty
                          ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "No matching results",
                            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      )
                          : isWideScreen
                          ? _buildTableList(provider, filteredSubjects)
                          : _buildCardList(provider, filteredSubjects),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (widget.embedded) return content;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Subjects List"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.dashboard);
                }
              },
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            onPressed: () => _openRegistration(),
            icon: const Icon(Icons.add),
            label: const Text('New subject'),
          ),
          body: content,
        );
      },
    );
  }

  /// Wide-screen "table" — a header row plus a ListView.builder of rows,
  /// laid out with Expanded columns instead of a DataTable.
  Widget _buildTableList(Myprovider provider, List filteredSubjects) {
    final colorScheme = Theme.of(context).colorScheme;

    const flexIndex = 1;
    const flexSubject = 4;
    const flexCode = 2;
    const flexLevel = 2;
    const flexActions = 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header row
            Container(
              color: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: flexIndex,
                    child: Text("#", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: flexSubject,
                    child: InkWell(
                      onTap: () => setState(() => _sortAscending = !_sortAscending),
                      child: Row(
                        children: [
                          Text("Subject",
                              style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Icon(
                            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 14,
                            color: colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: flexCode,
                    child: Text("Code", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: flexLevel,
                    child: Text("Level", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: flexActions,
                    child: Text("Actions",
                        textAlign: TextAlign.end,
                        style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            // Rows
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filteredSubjects.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: colorScheme.outlineVariant),
                itemBuilder: (context, index) {
                  final subj = filteredSubjects[index];
                  final isBusy = _deletingId == subj.id;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: flexIndex,
                          child: Text("${index + 1}", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ),
                        Expanded(
                          flex: flexSubject,
                          child: Text(subj.name, style: TextStyle(color: colorScheme.onSurface)),
                        ),
                        Expanded(
                          flex: flexCode,
                          child: Text(subj.code ?? "-", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ),
                        Expanded(
                          flex: flexLevel,
                          child: _levelChip(subj.level),
                        ),
                        Expanded(
                          flex: flexActions,
                          child: isBusy
                              ? const Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.amber,
                                onPressed: () => _openRegistration(subject: subj),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: colorScheme.error,
                                onPressed: () => _confirmDelete(provider, subj.id, subj.name),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile card list — unchanged in spirit, still ListView.builder.
  Widget _buildCardList(Myprovider provider, List filteredSubjects) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(12, 4, 12, widget.embedded ? 12 : 90),
      itemCount: filteredSubjects.length,
      itemBuilder: (context, index) {
        final subj = filteredSubjects[index];
        final isBusy = _deletingId == subj.id;

        return Card(
          color: colorScheme.surface,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Text(
                subj.name.isNotEmpty ? subj.name[0].toUpperCase() : '?',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
            title: Text(
              subj.name,
              style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(subj.code ?? "-", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  _levelChip(subj.level),
                ],
              ),
            ),
            trailing: isBusy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (choice) {
                if (choice == 'edit') {
                  _openRegistration(subject: subj);
                } else if (choice == 'delete') {
                  _confirmDelete(provider, subj.id, subj.name);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _levelChip(String? level) {
    final colorScheme = Theme.of(context).colorScheme;
    if (level == null || level.isEmpty) {
      return Text('-', style: TextStyle(color: colorScheme.onSurfaceVariant));
    }
    return Chip(
      label: Text(level, style: TextStyle(fontSize: 11, color: colorScheme.onSecondaryContainer)),
      backgroundColor: colorScheme.secondaryContainer,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}