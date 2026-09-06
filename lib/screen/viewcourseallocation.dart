// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../controller/dbmodels/courseallocationmodel.dart';
// import '../controller/dbmodels/coursemountmodel.dart';
// import '../controller/myprovider.dart';
// import 'courseallocation.dart';
//
// class ViewCourseAllocationPage extends StatefulWidget {
//   final bool embedded;
//   const ViewCourseAllocationPage({super.key, this.embedded = false});
//
//   @override
//   State<ViewCourseAllocationPage> createState() => _ViewCourseAllocationPageState();
// }
//
// class _ViewCourseAllocationPageState extends State<ViewCourseAllocationPage> {
//   bool _loading = true;
//   String _search = '';
//   bool _showUnallocated = false;
//   List<CourseAllocationModel> _allocations = [];
//   List<CourseMountModel> _mounts = [];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _load());
//   }
//
//   Future<void> _load() async {
//     final provider = context.read<Myprovider>();
//     final allocSnap = await provider.db
//         .collection('courseAllocation')
//         .where('schoolId', isEqualTo: provider.schoolid)
//         .where('academicYear', isEqualTo: provider.year)
//         .where('termOrSemester', isEqualTo: provider.term)
//         .get();
//     final mountsSnap = await provider.db
//         .collection('courseMounting')
//         .where('schoolId', isEqualTo: provider.schoolid)
//         .where('academicYear', isEqualTo: provider.year)
//         .where('termOrSemester', isEqualTo: provider.term)
//         .get();
//     if (!mounted) return;
//     setState(() {
//       _allocations = allocSnap.docs.map((d) => CourseAllocationModel.fromMap({...d.data(), 'id': d.id})).toList();
//       _mounts = mountsSnap.docs.map((d) => CourseMountModel.fromMap({...d.data(), 'id': d.id})).toList();
//       _loading = false;
//     });
//   }
//
//   List<Map<String, String>> get _unallocatedRows {
//     final rows = <Map<String, String>>[];
//     for (final mount in _mounts) {
//       for (final code in mount.allCourseCodes) {
//         final allocated = _allocations.any((a) => a.departmentId == mount.departmentId && a.classOrLevel == mount.classOrLevel && a.courseCode == code);
//         if (!allocated) {
//           rows.add({'departmentId': mount.departmentId, 'classOrLevel': mount.classOrLevel, 'courseCode': code});
//         }
//       }
//     }
//     return rows;
//   }
//
//   Future<void> _delete(CourseAllocationModel model) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete allocation?'),
//         content: Text('Remove ${model.courseCode} from ${model.staffName}?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//     await context.read<Myprovider>().db.collection('courseAllocation').doc(model.id).delete();
//     _load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final query = _search.toLowerCase();
//     final filtered = _allocations.where((a) {
//       final text = '${a.staffName} ${a.courseCode} ${a.courseName} ${a.classOrLevel}'.toLowerCase();
//       return text.contains(query);
//     }).toList();
//
//     final body = _loading
//         ? const Center(child: CircularProgressIndicator())
//         : Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Wrap(
//             spacing: 8,
//             runSpacing: 10,
//             crossAxisAlignment: WrapCrossAlignment.center,
//             children: [
//               Text('Course allocation', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
//               FilledButton.icon(
//                 onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourseAllocationPage())),
//                 icon: const Icon(Icons.add_link),
//                 label: const Text('Add allocation'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           SegmentedButton<bool>(
//             segments: const [
//               ButtonSegment(value: false, label: Text('Allocated')),
//               ButtonSegment(value: true, label: Text('Not allocated')),
//             ],
//             selected: {_showUnallocated},
//             onSelectionChanged: (v) => setState(() => _showUnallocated = v.first),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             onChanged: (v) => setState(() => _search = v),
//             decoration: const InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             child: _showUnallocated
//                 ? (_unallocatedRows.isEmpty
//                 ? Center(child: Text('All mounted records are allocated.', style: TextStyle(color: scheme.onSurfaceVariant)))
//                 : ListView.builder(
//               itemCount: _unallocatedRows.length,
//               itemBuilder: (context, i) {
//                 final row = _unallocatedRows[i];
//                 return Card(
//                   child: ListTile(
//                     title: Text(row['courseCode']!),
//                     subtitle: Text('Department: ${row['departmentId']} • Class: ${row['classOrLevel']}'),
//                   ),
//                 );
//               },
//             ))
//                 : (filtered.isEmpty
//                 ? Center(child: Text('No allocations yet.', style: TextStyle(color: scheme.onSurfaceVariant)))
//                 : ListView.builder(
//               itemCount: filtered.length,
//               itemBuilder: (context, i) {
//                 final a = filtered[i];
//                 return Card(
//                   child: ListTile(
//                     title: Text('${a.courseCode}  ${a.courseName}'),
//                     subtitle: Text('${a.staffName} • ${a.departmentId} • ${a.classOrLevel}'),
//                     trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _delete(a)),
//                   ),
//                 );
//               },
//             )),
//           ),
//         ],
//       ),
//     );
//
//     if (widget.embedded) return body;
//     return Scaffold(appBar: AppBar(title: const Text('Course allocation')), body: body);
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/courseallocationmodel.dart';
import '../controller/dbmodels/coursemountmodel.dart';
import '../controller/myprovider.dart';
import 'courseallocation.dart';

class ViewCourseAllocationPage extends StatefulWidget {
  final bool embedded;
  const ViewCourseAllocationPage({super.key, this.embedded = false});

  @override
  State<ViewCourseAllocationPage> createState() => _ViewCourseAllocationPageState();
}

class _ViewCourseAllocationPageState extends State<ViewCourseAllocationPage> {
  bool _loading = true;
  String _search = '';
  bool _showUnallocated = false;
  List<CourseAllocationModel> _allocations = [];
  List<CourseMountModel> _mounts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<Myprovider>();
    final allocSnap = await provider.db
        .collection('courseAllocation')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('academicYear', isEqualTo: provider.year)
        .where('termOrSemester', isEqualTo: provider.term)
        .get();
    final mountsSnap = await provider.db
        .collection('courseMounting')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('academicYear', isEqualTo: provider.year)
        .where('termOrSemester', isEqualTo: provider.term)
        .get();
    if (!mounted) return;
    setState(() {
      _allocations = allocSnap.docs.map((d) => CourseAllocationModel.fromMap({...d.data(), 'id': d.id})).toList();
      _mounts = mountsSnap.docs.map((d) => CourseMountModel.fromMap({...d.data(), 'id': d.id})).toList();
      _loading = false;
    });
  }

  Future<void> _openAddAllocation() async {
    // Wait for the allocation page to close, then refresh — otherwise
    // newly saved (or edited) allocations won't show until this whole
    // page is rebuilt from scratch.
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CourseAllocationPage()),
    );
    if (mounted) _load();
  }

  List<Map<String, String>> get _unallocatedRows {
    final rows = <Map<String, String>>[];
    for (final mount in _mounts) {
      for (final code in mount.allCourseCodes) {
        final allocated = _allocations.any((a) => a.departmentId == mount.departmentId && a.classOrLevel == mount.classOrLevel && a.courseCode == code);
        if (!allocated) {
          rows.add({'departmentId': mount.departmentId, 'classOrLevel': mount.classOrLevel, 'courseCode': code});
        }
      }
    }
    return rows;
  }

  Future<void> _delete(CourseAllocationModel model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete allocation?'),
        content: Text('Remove ${model.courseCode} from ${model.staffName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    await context.read<Myprovider>().db.collection('courseAllocation').doc(model.id).delete();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final query = _search.toLowerCase();
    final filtered = _allocations.where((a) {
      final text = '${a.staffName} ${a.courseCode} ${a.courseName} ${a.classOrLevel}'.toLowerCase();
      return text.contains(query);
    }).toList();

    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Course allocation', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              FilledButton.icon(
                onPressed: _openAddAllocation,
                icon: const Icon(Icons.add_link),
                label: const Text('Add allocation'),
              ),
              if (widget.embedded)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Allocated')),
              ButtonSegment(value: true, label: Text('Not allocated')),
            ],
            selected: {_showUnallocated},
            onSelectionChanged: (v) => setState(() => _showUnallocated = v.first),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: const InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _showUnallocated
                ? (_unallocatedRows.isEmpty
                ? Center(child: Text('All mounted records are allocated.', style: TextStyle(color: scheme.onSurfaceVariant)))
                : ListView.builder(
              itemCount: _unallocatedRows.length,
              itemBuilder: (context, i) {
                final row = _unallocatedRows[i];
                return Card(
                  child: ListTile(
                    title: Text(row['courseCode']!),
                    subtitle: Text('Department: ${row['departmentId']} • Class: ${row['classOrLevel']}'),
                  ),
                );
              },
            ))
                : (filtered.isEmpty
                ? Center(child: Text('No allocations yet.', style: TextStyle(color: scheme.onSurfaceVariant)))
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final a = filtered[i];
                return Card(
                  child: ListTile(
                    title: Text('${a.courseCode}  ${a.courseName}'),
                    subtitle: Text('${a.staffName} • ${a.departmentId} • ${a.classOrLevel}'),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _delete(a)),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Course allocation')), body: body);
  }
}