// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../controller/myprovider.dart';
// import '../controller/routes.dart';
//
// class CourseAllocationPage extends StatefulWidget {
//   const CourseAllocationPage({super.key});
//
//   @override
//   State<CourseAllocationPage> createState() => _CourseAllocationPageState();
// }
//
// class _CourseAllocationPageState extends State<CourseAllocationPage> {
//   bool _loading = true;
//   List<Map<String, dynamic>> _allocations = [];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _load());
//   }
//
//   Future<void> _load() async {
//     final provider = context.read<Myprovider>();
//     await Future.wait([
//       provider.fetchdepart(),
//       provider.fetchstaff(),
//       provider.fetchsubjects(),
//       provider.fetchclass(),
//     ]);
//     final snapshot = await provider.db
//         .collection('courseAllocation')
//         .where('schoolId', isEqualTo: provider.schoolid)
//         .get();
//     if (!mounted) return;
//     setState(() {
//       _allocations = snapshot.docs
//           .map((doc) => {...doc.data(), 'id': doc.id})
//           .toList();
//       _loading = false;
//     });
//   }
//
//   String _period(Myprovider provider) =>
//       provider.term.isNotEmpty ? provider.term : 'current';
//
//   Future<void> _openAllocationModal({Map<String, dynamic>? initial}) async {
//     final provider = context.read<Myprovider>();
//     String? departmentId = initial?['departmentId']?.toString();
//     String? group = initial?['classOrLevel']?.toString();
//     String? teacherId = initial?['staffId']?.toString();
//     String teacherSearch = '';
//     String courseSearch = '';
//     final selected = <String>{
//       if (initial != null)
//         ..._allocations
//             .where(
//               (item) =>
//           item['staffId'] == teacherId &&
//               item['departmentId'] == departmentId &&
//               item['classOrLevel'] == group,
//         )
//             .map((item) => item['courseCode'].toString()),
//     };
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setModalState) {
//           final department = provider.departments.where(
//                 (d) => d.id == departmentId,
//           );
//           final departmentName = department.isEmpty
//               ? ''
//               : department.first.name;
//           final groups = provider.classdata
//               .map((item) => item.name)
//               .whereType<String>()
//               .toSet()
//               .toList();
//           final teachers = provider.stafflist.where((teacher) {
//             final query = teacherSearch.toLowerCase();
//             return query.isEmpty ||
//                 teacher.name.toLowerCase().contains(query) ||
//                 teacher.email.toLowerCase().contains(query);
//           }).toList();
//           final courses = provider.subjectList.where((course) {
//             final query = courseSearch.toLowerCase();
//             final departmentMatches =
//                 departmentId == null ||
//                     course.department?.toLowerCase() ==
//                         departmentName.toLowerCase() ||
//                     course.scope == 'All departments';
//             return departmentMatches &&
//                 (query.isEmpty ||
//                     course.name.toLowerCase().contains(query) ||
//                     (course.code ?? '').toLowerCase().contains(query));
//           }).toList();
//           return AlertDialog(
//             title: Text(
//               initial == null
//                   ? 'Open $_courseTitle allocation'
//                   : 'Edit $_courseTitle allocation',
//             ),
//             content: SizedBox(
//               width: 1100,
//               height: 640,
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           initialValue: provider.departments.any(
//                                 (d) => d.id == departmentId,
//                           )
//                               ? departmentId
//                               : null,
//                           decoration: const InputDecoration(
//                             labelText: 'Department / programme',
//                           ),
//                           items: provider.departments
//                               .map(
//                                 (d) => DropdownMenuItem(
//                               value: d.id,
//                               child: Text(d.name),
//                             ),
//                           )
//                               .toList(),
//                           onChanged: (value) => setModalState(() {
//                             departmentId = value;
//                             group = null;
//                             selected.clear();
//                           }),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           initialValue: groups.contains(group) ? group : null,
//                           decoration: InputDecoration(
//                             labelText: provider.schoolType == 'Pre-tertiary'
//                                 ? 'Class'
//                                 : 'Level',
//                           ),
//                           items: groups
//                               .map(
//                                 (value) => DropdownMenuItem(
//                               value: value,
//                               child: Text(value),
//                             ),
//                           )
//                               .toList(),
//                           onChanged: (value) => setModalState(() {
//                             group = value;
//                             selected.clear();
//                           }),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 14),
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: _modalColumn(
//                             'Teachers',
//                             'Search teachers',
//                                 (value) =>
//                                 setModalState(() => teacherSearch = value),
//                             ListView(
//                               children: teachers
//                                   .map(
//                                     (teacher) => ListTile(
//                                   selected: teacher.id == teacherId,
//                                   title: Text(teacher.name),
//                                   subtitle: Text(teacher.email),
//                                   onTap: () => setModalState(() {
//                                     teacherId = teacher.id;
//                                     selected.clear();
//                                   }),
//                                 ),
//                               )
//                                   .toList(),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _modalColumn(
//                             'Available $_courseTitle records',
//                             'Search $_courseTitle',
//                                 (value) =>
//                                 setModalState(() => courseSearch = value),
//                             ListView(
//                               children: courses
//                                   .map(
//                                     (course) => ListTile(
//                                   title: Text(
//                                     '${course.code ?? ''}  ${course.name}',
//                                   ),
//                                   subtitle: Text(
//                                     '${course.department ?? 'All departments'} | ${course.level ?? ''}',
//                                   ),
//                                   trailing: IconButton(
//                                     icon: const Icon(
//                                       Icons.add_circle_outline,
//                                     ),
//                                     onPressed:
//                                     teacherId == null ||
//                                         selected.contains(course.code)
//                                         ? null
//                                         : () => setModalState(
//                                           () => selected.add(
//                                         course.code ?? '',
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                                   .toList(),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _modalColumn(
//                             'Selected $_courseTitle (${selected.length})',
//                             null,
//                             null,
//                             ListView(
//                               children: courses
//                                   .where(
//                                     (course) => selected.contains(course.code),
//                               )
//                                   .map(
//                                     (course) => ListTile(
//                                   title: Text(
//                                     '${course.code ?? ''}  ${course.name}',
//                                   ),
//                                   trailing: IconButton(
//                                     icon: const Icon(
//                                       Icons.remove_circle_outline,
//                                       color: Colors.red,
//                                     ),
//                                     onPressed: () => setModalState(
//                                           () => selected.remove(course.code),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                                   .toList(),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(dialogContext),
//                 child: const Text('Cancel'),
//               ),
//               FilledButton.icon(
//                 onPressed:
//                 teacherId == null || departmentId == null || group == null
//                     ? null
//                     : () async {
//                   await _saveModalAllocation(
//                     provider,
//                     teacherId!,
//                     departmentId!,
//                     group!,
//                     selected,
//                   );
//                   if (dialogContext.mounted) Navigator.pop(dialogContext);
//                 },
//                 icon: const Icon(Icons.save),
//                 label: const Text('Save assignments'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//     await _load();
//   }
//
//   Widget _modalColumn(
//       String title,
//       String? label,
//       ValueChanged<String>? onChanged,
//       Widget child,
//       ) => Container(
//     decoration: BoxDecoration(
//       border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
//       borderRadius: BorderRadius.circular(10),
//     ),
//     padding: const EdgeInsets.all(10),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
//         if (label != null) ...[
//           const SizedBox(height: 8),
//           TextField(
//             onChanged: onChanged,
//             decoration: InputDecoration(
//               labelText: label,
//               prefixIcon: const Icon(Icons.search),
//             ),
//           ),
//         ],
//         const SizedBox(height: 8),
//         Expanded(child: child),
//       ],
//     ),
//   );
//
//   Future<void> _saveModalAllocation(
//       Myprovider provider,
//       String teacherId,
//       String departmentId,
//       String group,
//       Set<String> selected,
//       ) async {
//     final existing = _allocations.where(
//           (item) =>
//       item['staffId'] == teacherId &&
//           item['departmentId'] == departmentId &&
//           item['classOrLevel'] == group,
//     );
//     for (final item in existing) {
//       if (!selected.contains(item['courseCode'].toString())) {
//         await provider.db
//             .collection('courseAllocation')
//             .doc(item['id'])
//             .delete();
//       }
//     }
//     for (final code in selected) {
//       final id =
//           '${provider.schoolid}_${teacherId}_${departmentId}_${group}_$code';
//       await provider.db.collection('courseAllocation').doc(id).set({
//         'id': id,
//         'schoolId': provider.schoolid,
//         'staffId': teacherId,
//         'departmentId': departmentId,
//         'classOrLevel': group,
//         'courseCode': code,
//         'academicYear': provider.year,
//         'termOrSemester': _period(provider),
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//     }
//   }
//
//   Future<void> _viewAllocations() async {
//     final provider = context.read<Myprovider>();
//     String? departmentId;
//     String? group;
//     String search = '';
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setModalState) {
//           final groups = provider.classdata
//               .map((item) => item.name)
//               .whereType<String>()
//               .toSet()
//               .toList();
//           final records = _allocations.where((item) {
//             final text =
//             '${item['courseCode']} ${item['courseName']} ${item['staffId']}'
//                 .toLowerCase();
//             return (departmentId == null ||
//                 item['departmentId'] == departmentId) &&
//                 (group == null || item['classOrLevel'] == group) &&
//                 text.contains(search.toLowerCase());
//           }).toList();
//           return AlertDialog(
//             title: Text('View $_courseTitle allocation'),
//             content: SizedBox(
//               width: 1000,
//               height: 600,
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           initialValue: provider.departments.any(
//                                 (d) => d.id == departmentId,
//                           )
//                               ? departmentId
//                               : null,
//                           decoration: const InputDecoration(
//                             labelText: 'Select department',
//                           ),
//                           items: provider.departments
//                               .map(
//                                 (d) => DropdownMenuItem(
//                               value: d.id,
//                               child: Text(d.name),
//                             ),
//                           )
//                               .toList(),
//                           onChanged: (value) => setModalState(() {
//                             departmentId = value;
//                             group = null;
//                           }),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           initialValue: groups.contains(group) ? group : null,
//                           decoration: InputDecoration(
//                             labelText: provider.schoolType == 'Pre-tertiary'
//                                 ? 'Select class'
//                                 : 'Select level',
//                           ),
//                           items: groups
//                               .map(
//                                 (value) => DropdownMenuItem(
//                               value: value,
//                               child: Text(value),
//                             ),
//                           )
//                               .toList(),
//                           onChanged: (value) =>
//                               setModalState(() => group = value),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextField(
//                           onChanged: (value) =>
//                               setModalState(() => search = value),
//                           decoration: const InputDecoration(
//                             labelText: 'Search allocation',
//                             prefixIcon: Icon(Icons.search),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 14),
//                   Expanded(
//                     child: records.isEmpty
//                         ? const Center(
//                       child: Text(
//                         'Select department and class/level to view assignments.',
//                       ),
//                     )
//                         : ListView.builder(
//                       itemCount: records.length,
//                       itemBuilder: (context, index) {
//                         final item = records[index];
//                         return ListTile(
//                           title: Text(
//                             '${item['courseCode']}  ${item['courseName'] ?? ''}',
//                           ),
//                           subtitle: Text(
//                             'Teacher: ${item['staffId']} | Department: ${item['departmentId']} | ${item['classOrLevel']}',
//                           ),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.edit_outlined),
//                                 tooltip: 'Edit allocation',
//                                 onPressed: () {
//                                   Navigator.pop(dialogContext);
//                                   _openAllocationModal(initial: item);
//                                 },
//                               ),
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.delete_outline,
//                                   color: Colors.red,
//                                 ),
//                                 tooltip: 'Delete allocation',
//                                 onPressed: () async {
//                                   final allocationId =
//                                       item['id']?.toString() ?? '';
//                                   if (allocationId.isEmpty) return;
//                                   await provider.db
//                                       .collection('courseAllocation')
//                                       .doc(allocationId)
//                                       .delete();
//                                   await _load();
//                                   setModalState(() {});
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(dialogContext),
//                 child: const Text('Close'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$_courseTitle allocation'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.go(Routes.setupWizard),
//         ),
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 900),
//           child: Padding(
//             padding: const EdgeInsets.all(28),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '$_courseTitle allocation',
//                   style: Theme.of(context).textTheme.headlineSmall
//                       ?.copyWith(fontWeight: FontWeight.w800),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Choose how registered records are assigned to teachers.',
//                   style: TextStyle(color: scheme.onSurfaceVariant),
//                 ),
//                 const SizedBox(height: 28),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: FilledButton.icon(
//                         onPressed: _openAllocationModal,
//                         icon: const Icon(Icons.add_link),
//                         label: const Text('Open allocation'),
//                       ),
//                     ),
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: _viewAllocations,
//                         icon: const Icon(Icons.table_view_outlined),
//                         label: const Text('View allocation'),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Text(
//                       '${_allocations.length} allocation records saved.',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String get _courseTitle {
//     final provider = context.read<Myprovider>();
//     return provider.schoolType == 'Pre-tertiary' ? 'Subject' : 'Course';
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/courseallocationmodel.dart';
import '../controller/dbmodels/coursemountmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import 'viewcourseallocation.dart';

class CourseAllocationPage extends StatefulWidget {
  const CourseAllocationPage({super.key});

  @override
  State<CourseAllocationPage> createState() => _CourseAllocationPageState();
}

class _CourseAllocationPageState extends State<CourseAllocationPage> {
  bool _loading = true;
  String? _facultyId;
  String? _departmentId;
  String? _classOrLevel;
  String? _staffId;
  String _staffSearch = '';
  final Set<String> _checkedAvailable = {};
  final Set<String> _checkedSelected = {};
  final Set<String> _selectedCodes = {};
  List<CourseMountModel> _mounts = [];
  List<CourseAllocationModel> _allocations = [];

  Myprovider get _provider => context.read<Myprovider>();

  String get _courseTitle => _provider.schoolType == 'Pre-tertiary' ? 'Subject' : 'Course';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = _provider;
    await Future.wait([
      provider.fetchdepart(),
      provider.fetchstaff(),
      provider.fetchsubjects(),
      provider.fetchclass(),
    ]);
    final mountsSnap = await provider.db
        .collection('courseMounting')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('academicYear', isEqualTo: provider.year)
        .where('termOrSemester', isEqualTo: provider.term)
        .get();
    final allocSnap = await provider.db
        .collection('courseAllocation')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('academicYear', isEqualTo: provider.year)
        .where('termOrSemester', isEqualTo: provider.term)
        .get();
    if (!mounted) return;
    setState(() {
      _mounts = mountsSnap.docs.map((d) => CourseMountModel.fromMap({...d.data(), 'id': d.id})).toList();
      _allocations = allocSnap.docs.map((d) => CourseAllocationModel.fromMap({...d.data(), 'id': d.id})).toList();
      _loading = false;
    });
  }

  String? get _selectedFacultyName =>
      _provider.faculties.where((f) => f.id == _facultyId).map((f) => f.name as String).firstOrNull;

  String? get _selectedDepartmentName =>
      _provider.departments.where((d) => d.id == _departmentId).map((d) => d.name as String).firstOrNull;

  List<dynamic> get _availableDepartments =>
      _provider.departments.where((d) => _facultyId == null || d.faculty == _selectedFacultyName).toList();

  CourseMountModel? get _mountForSelection {
    if (_departmentId == null || _classOrLevel == null) return null;
    return _mounts.where((m) => m.departmentId == _departmentId && m.classOrLevel == _classOrLevel).firstOrNull;
  }

  List<dynamic> get _availableLevels {
    final ids = _mounts.where((m) => _departmentId == null || m.departmentId == _departmentId).map((m) => m.classOrLevel).toSet();
    return _provider.classdata.where((c) => ids.contains(c.name)).toList();
  }

  List<dynamic> get _staffOptions {
    final query = _staffSearch.toLowerCase();
    return _provider.stafflist.where((s) {
      final departmentMatches = _departmentId == null || s.departmentId == _departmentId;
      final searchMatches = query.isEmpty || s.name.toLowerCase().contains(query) || s.email.toLowerCase().contains(query);
      return departmentMatches && searchMatches;
    }).toList();
  }

  List<dynamic> get _mountedCourses {
    final mount = _mountForSelection;
    if (mount == null) return [];
    return _provider.subjectList.where((c) => mount.allCourseCodes.contains(c.code)).toList();
  }

  Set<String> get _allocatedElsewhereCodes {
    if (_departmentId == null || _classOrLevel == null) return {};
    return _allocations
        .where((a) => a.departmentId == _departmentId && a.classOrLevel == _classOrLevel && a.staffId != _staffId)
        .map((a) => a.courseCode)
        .toSet();
  }

  List<dynamic> get _availableCourses => _mountedCourses
      .where((c) => !_selectedCodes.contains(c.code) && !_allocatedElsewhereCodes.contains(c.code))
      .toList();

  List<dynamic> get _selectedCourses => _mountedCourses.where((c) => _selectedCodes.contains(c.code)).toList();

  void _onSelectionChanged() {
    setState(() {
      _selectedCodes.clear();
      if (_staffId != null && _departmentId != null && _classOrLevel != null) {
        _selectedCodes.addAll(
          _allocations
              .where((a) => a.staffId == _staffId && a.departmentId == _departmentId && a.classOrLevel == _classOrLevel)
              .map((a) => a.courseCode),
        );
      }
      _checkedAvailable.clear();
      _checkedSelected.clear();
    });
  }

  void _addChecked() {
    setState(() {
      _selectedCodes.addAll(_checkedAvailable);
      _checkedAvailable.clear();
    });
  }

  void _removeChecked() {
    setState(() {
      _selectedCodes.removeAll(_checkedSelected);
      _checkedSelected.clear();
    });
  }

  Future<void> _save() async {
    final provider = _provider;
    final staffId = _staffId;
    final departmentId = _departmentId;
    final classOrLevel = _classOrLevel;
    if (staffId == null || departmentId == null || classOrLevel == null) return;
    final staff = provider.stafflist.firstWhere((s) => s.id == staffId);
    final existing = _allocations.where(
          (a) => a.staffId == staffId && a.departmentId == departmentId && a.classOrLevel == classOrLevel,
    );
    for (final item in existing) {
      if (!_selectedCodes.contains(item.courseCode)) {
        await provider.db.collection('courseAllocation').doc(item.id).delete();
      }
    }
    for (final code in _selectedCodes) {
      final course = _provider.subjectList.firstWhere((c) => c.code == code);
      final id = '${provider.schoolid}_${staffId}_${departmentId}_${classOrLevel}_$code';
      final model = CourseAllocationModel(
        id: id,
        schoolId: provider.schoolid,
        staffId: staffId,
        staffName: staff.name,
        facultyId: _facultyId ?? '',
        departmentId: departmentId,
        classOrLevel: classOrLevel,
        academicYear: provider.year,
        termOrSemester: provider.term,
        courseCode: code,
        courseName: course.name,
      );
      await provider.db.collection('courseAllocation').doc(id).set(model.toMap(), SetOptions(merge: true));
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allocation saved.'), backgroundColor: Colors.green),
      );
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('$_courseTitle allocation'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(Routes.setupWizard)),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_view_outlined),
            tooltip: 'View allocation',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ViewCourseAllocationPage()),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 700;
                final fields = [
                  _dropdown('Faculty', _facultyId, _provider.faculties.map((f) => f.id as String).toList(),
                      _provider.faculties.map((f) => f.name as String).toList(), (v) {
                        setState(() {
                          _facultyId = v;
                          _departmentId = null;
                          _classOrLevel = null;
                          _staffId = null;
                        });
                        _onSelectionChanged();
                      }),
                  _dropdown('Department', _departmentId, _availableDepartments.map((d) => d.id as String).toList(),
                      _availableDepartments.map((d) => d.name as String).toList(), (v) {
                        setState(() {
                          _departmentId = v;
                          _classOrLevel = null;
                          _staffId = null;
                        });
                        _onSelectionChanged();
                      }),
                  _dropdown('Class / Level', _classOrLevel, _availableLevels.map((c) => c.name as String).toList(),
                      _availableLevels.map((c) => c.name as String).toList(), (v) {
                        setState(() => _classOrLevel = v);
                        _onSelectionChanged();
                      }),
                ];
                return wide
                    ? Row(children: fields.map((f) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: f))).toList())
                    : Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList());
              },
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (v) => setState(() => _staffSearch = v),
              decoration: const InputDecoration(labelText: 'Search staff', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _staffOptions.any((s) => s.id == _staffId) ? _staffId : null,
              decoration: const InputDecoration(labelText: 'Staff / tutor', border: OutlineInputBorder()),
              items: _staffOptions.map((s) => DropdownMenuItem(value: s.id as String, child: Text('${s.name} (${s.accessLevel})'))).toList(),
              onChanged: (v) {
                setState(() => _staffId = v);
                _onSelectionChanged();
              },
            ),
            const SizedBox(height: 12),
            if (_mountForSelection == null && _departmentId != null && _classOrLevel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('No mounted $_courseTitle records for this class.', style: const TextStyle(color: Colors.red)),
              ),
            if (_staffId != null && _mountForSelection != null)
              Expanded(child: _pickerBody(scheme))
            else
              Expanded(child: Center(child: Text('Select department, class and staff to allocate.', style: TextStyle(color: scheme.onSurfaceVariant)))),
            if (_staffId != null && _mountForSelection != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save assignments')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> ids, List<String> names, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: ids.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: List.generate(ids.length, (i) => DropdownMenuItem(value: ids[i], child: Text(names[i]))),
      onChanged: onChanged,
    );
  }

  Widget _pickerBody(ColorScheme scheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 640;
        final available = _list('Available $_courseTitle records', _availableCourses, _checkedAvailable, scheme);
        final buttons = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: wide
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(onPressed: _checkedAvailable.isEmpty ? null : _addChecked, child: const Text('Add >>')),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: _checkedSelected.isEmpty ? null : _removeChecked, child: const Text('<< Remove')),
          ])
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(onPressed: _checkedAvailable.isEmpty ? null : _addChecked, child: const Text('Add >>')),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: _checkedSelected.isEmpty ? null : _removeChecked, child: const Text('<< Remove')),
          ]),
        );
        final selected = _list('Allocated $_courseTitle records', _selectedCourses, _checkedSelected, scheme);
        return wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: available), buttons, Expanded(child: selected)])
            : Column(children: [Expanded(child: available), buttons, Expanded(child: selected)]);
      },
    );
  }

  Widget _list(String title, List<dynamic> courses, Set<String> checked, ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(10), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
          const Divider(height: 1),
          Expanded(
            child: courses.isEmpty
                ? Center(child: Text('No records', style: TextStyle(color: scheme.onSurfaceVariant)))
                : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, i) {
                final course = courses[i];
                return CheckboxListTile(
                  dense: true,
                  value: checked.contains(course.code),
                  title: Text('${course.code}  ${course.name}'),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      checked.add(course.code);
                    } else {
                      checked.remove(course.code);
                    }
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}