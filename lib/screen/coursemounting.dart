//
//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../controller/myprovider.dart';
//
// class CourseMountingPage extends StatefulWidget {
//   final bool embedded;
//   const CourseMountingPage({super.key, this.embedded = false});
//
//   @override
//   State<CourseMountingPage> createState() => _CourseMountingPageState();
// }
//
// class _CourseMountingPageState extends State<CourseMountingPage> {
//   bool _loading = true;
//   List<Map<String, dynamic>> _mounts = [];
//   double _minCredits = 0;
//   double _maxCredits = 30;
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
//       provider.fetchsubjects(),
//       provider.fetchclass(),
//     ]);
//     final snapshot = await provider.db
//         .collection('courseMounting')
//         .where('schoolId', isEqualTo: provider.schoolid)
//         .get();
//     final schoolSnapshot = await provider.db
//         .collection('schools')
//         .doc(provider.schoolid)
//         .get();
//     final schoolData = schoolSnapshot.data() ?? <String, dynamic>{};
//     if (!mounted) return;
//     setState(() {
//       _mounts = snapshot.docs
//           .map((doc) => {...doc.data(), 'id': doc.id})
//           .toList();
//       _minCredits = (schoolData['creditHourMin'] as num?)?.toDouble() ?? 0;
//       _maxCredits = (schoolData['creditHourMax'] as num?)?.toDouble() ?? 30;
//       _loading = false;
//     });
//   }
//
//   String get _groupLabel {
//     final provider = context.read<Myprovider>();
//     return provider.schoolType == 'Pre-tertiary' ? 'Class' : 'Level';
//   }
//
//   String get _recordLabel {
//     final provider = context.read<Myprovider>();
//     return provider.schoolType == 'Pre-tertiary' ? 'Subject' : 'Course';
//   }
//
//   Future<void> _openMountModal({Map<String, dynamic>? initial}) async {
//     final provider = context.read<Myprovider>();
//     String? departmentId = initial?['departmentId']?.toString();
//     String? group = initial?['classOrLevel']?.toString();
//     String? coreCode = initial?['coreCourseCode']?.toString();
//     final electiveCodes = <String>{
//       ...((initial?['electiveCourseCodes'] as List?)?.map(
//             (item) => item.toString(),
//       ) ??
//           const []),
//     };
//     String search = '';
//
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setModalState) {
//           final departmentName =
//               provider.departments
//                   .where((item) => item.id == departmentId)
//                   .map((item) => item.name)
//                   .firstOrNull ??
//                   '';
//           final groups = provider.classdata
//               .map((item) => item.name)
//               .whereType<String>()
//               .toSet()
//               .toList();
//           final mountedElsewhere = _mounts
//               .where(
//                 (item) =>
//             item['departmentId'] == departmentId &&
//                 item['classOrLevel'] == group &&
//                 item['id'] != initial?['id'],
//           )
//               .expand((item) => (item['courseCodes'] as List?) ?? const [])
//               .map((item) => item.toString())
//               .toSet();
//           final courses = provider.subjectList.where((course) {
//             final query = search.toLowerCase().trim();
//             final matchesDepartment =
//                 departmentId == null ||
//                     course.department?.toLowerCase() ==
//                         departmentName.toLowerCase() ||
//                     course.scope == 'All departments';
//             final matchesGroup = group == null || course.level == group;
//             final matchesSearch =
//                 query.isEmpty ||
//                     course.name.toLowerCase().contains(query) ||
//                     (course.code ?? '').toLowerCase().contains(query);
//             return matchesDepartment &&
//                 matchesGroup &&
//                 matchesSearch &&
//                 !mountedElsewhere.contains(course.code);
//           }).toList();
//           final coreCourses = courses
//               .where((course) => course.type == 'Core')
//               .toList();
//           final electives = courses
//               .where((course) => course.type != 'Core')
//               .toList();
//           final selectedElectives = electives.where(
//                 (course) => electiveCodes.contains(course.code),
//           );
//           final core = coreCourses
//               .where((course) => course.code == coreCode)
//               .firstOrNull;
//           final totalCredits =
//               (core?.creditHours ?? 0) +
//                   selectedElectives.fold<double>(
//                     0,
//                         (total, item) => total + item.creditHours,
//                   );
//           final minCredits = _minCredits;
//           final maxCredits = _maxCredits;
//           final validCredits =
//               totalCredits >= minCredits && totalCredits <= maxCredits;
//
//           return AlertDialog(
//             title: Text(
//               initial == null
//                   ? 'Mount $_recordLabel records'
//                   : 'Edit mounted $_recordLabel records',
//             ),
//             content: SizedBox(
//               width: 900,
//               height: 650,
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: DropdownButtonFormField<String>(
//                             initialValue: departmentId,
//                             decoration: const InputDecoration(
//                               labelText: 'Department / programme',
//                             ),
//                             items: provider.departments
//                                 .map(
//                                   (item) => DropdownMenuItem(
//                                 value: item.id,
//                                 child: Text(item.name),
//                               ),
//                             )
//                                 .toList(),
//                             onChanged: (value) => setModalState(() {
//                               departmentId = value;
//                               group = null;
//                               coreCode = null;
//                               electiveCodes.clear();
//                             }),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: DropdownButtonFormField<String>(
//                             initialValue: groups.contains(group) ? group : null,
//                             decoration: InputDecoration(labelText: _groupLabel),
//                             items: groups
//                                 .map(
//                                   (item) => DropdownMenuItem(
//                                 value: item,
//                                 child: Text(item),
//                               ),
//                             )
//                                 .toList(),
//                             onChanged: (value) => setModalState(() {
//                               group = value;
//                               coreCode = null;
//                               electiveCodes.clear();
//                             }),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 14),
//                     TextField(
//                       onChanged: (value) => setModalState(() => search = value),
//                       decoration: InputDecoration(
//                         labelText: 'Search $_recordLabel records',
//                         prefixIcon: const Icon(Icons.search),
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     Text(
//                       'Select core ${_recordLabel.toLowerCase()}',
//                       style: const TextStyle(fontWeight: FontWeight.w800),
//                     ),
//                     const SizedBox(height: 6),
//                     DropdownButtonFormField<String>(
//                       initialValue:
//                       coreCourses.any((item) => item.code == coreCode)
//                           ? coreCode
//                           : null,
//                       decoration: InputDecoration(
//                         labelText: 'Core $_recordLabel',
//                       ),
//                       items: coreCourses
//                           .map(
//                             (item) => DropdownMenuItem(
//                           value: item.code,
//                           child: Text(
//                             '${item.code}  ${item.name} (${item.creditHours} credits)',
//                           ),
//                         ),
//                       )
//                           .toList(),
//                       onChanged: (value) =>
//                           setModalState(() => coreCode = value),
//                     ),
//                     const SizedBox(height: 18),
//                     Text(
//                       'Add elective ${_recordLabel.toLowerCase()}s',
//                       style: const TextStyle(fontWeight: FontWeight.w800),
//                     ),
//                     const SizedBox(height: 6),
//                     ...electives.map(
//                           (course) => CheckboxListTile(
//                         dense: true,
//                         value: electiveCodes.contains(course.code),
//                         title: Text('${course.code}  ${course.name}'),
//                         subtitle: Text('${course.creditHours} credits'),
//                         onChanged: (value) => setModalState(() {
//                           if (value == true) {
//                             electiveCodes.add(course.code ?? '');
//                           } else {
//                             electiveCodes.remove(course.code);
//                           }
//                         }),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: validCredits
//                             ? Colors.green.withValues(alpha: .1)
//                             : Colors.red.withValues(alpha: .1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               'Total credits: ${totalCredits.toStringAsFixed(2)} | Allowed: ${minCredits.toStringAsFixed(2)} - ${maxCredits.isFinite ? maxCredits.toStringAsFixed(2) : 'No limit'}',
//                             ),
//                           ),
//                           Icon(
//                             validCredits ? Icons.check_circle : Icons.error,
//                             color: validCredits ? Colors.green : Colors.red,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(dialogContext),
//                 child: const Text('Cancel'),
//               ),
//               FilledButton.icon(
//                 onPressed:
//                 departmentId == null ||
//                     group == null ||
//                     coreCode == null ||
//                     !validCredits
//                     ? null
//                     : () async {
//                   await _saveMount(
//                     provider,
//                     initial,
//                     departmentId!,
//                     group!,
//                     coreCode!,
//                     electiveCodes,
//                     totalCredits,
//                   );
//                   if (dialogContext.mounted) Navigator.pop(dialogContext);
//                 },
//                 icon: const Icon(Icons.save),
//                 label: Text(initial == null ? 'Mount records' : 'Update mount'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//     await _load();
//   }
//
//   Future<void> _saveMount(
//       Myprovider provider,
//       Map<String, dynamic>? initial,
//       String departmentId,
//       String group,
//       String coreCode,
//       Set<String> electives,
//       double totalCredits,
//       ) async {
//     final id =
//     '${provider.schoolid}_${departmentId}_${group}_${provider.year}_${provider.term}'
//         .replaceAll(RegExp(r'\s+'), '_');
//     final data = {
//       'id': id,
//       'schoolId': provider.schoolid,
//       'schoolType': provider.schoolType,
//       'departmentId': departmentId,
//       'classOrLevel': group,
//       'academicYear': provider.year,
//       'termOrSemester': provider.term,
//       'coreCourseCode': coreCode,
//       'electiveCourseCodes': electives.toList(),
//       'courseCodes': [coreCode, ...electives],
//       'totalCredits': totalCredits,
//       'status': 'active',
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//     await provider.db
//         .collection('courseMounting')
//         .doc(initial?['id']?.toString() ?? id)
//         .set(data, SetOptions(merge: true));
//     if (provider.schoolType == 'Pre-tertiary') {
//       await _registerForPreTertiaryStudents(provider, group, departmentId, [
//         coreCode,
//         ...electives,
//       ]);
//     }
//   }
//
//   Future<void> _registerForPreTertiaryStudents(
//       Myprovider provider,
//       String group,
//       String departmentId,
//       List<String> codes,
//       ) async {
//     final students = await provider.db
//         .collection('students')
//         .where('schoolId', isEqualTo: provider.schoolid)
//         .where('level', isEqualTo: group)
//         .get();
//     final subjects = provider.subjectList.where(
//           (item) => codes.contains(item.code),
//     );
//     for (final student in students.docs) {
//       final scoringId =
//           '${student.id}_${provider.academicyrid}_${provider.term}';
//       final reference = provider.db.collection('subjectScoring').doc(scoringId);
//       final existing = await reference.get();
//       final current = Map<String, dynamic>.from(
//         existing.data()?['subjects'] ?? {},
//       );
//       for (final subject in subjects) {
//         current[subject.id] = {
//           'subjectId': subject.id,
//           'subjectName': subject.name,
//           'code': subject.code,
//           'isComplete': 'no',
//           'CA': '0',
//           'Exams': '0',
//           'totalScore': '0',
//         };
//       }
//       await reference.set({
//         'studentId': student.id,
//         'level': group,
//         'department': departmentId,
//         'subjects': current,
//         'academicYear': provider.year,
//         'term': provider.term,
//         'schoolId': provider.schoolid,
//       }, SetOptions(merge: true));
//     }
//   }
//
//   Future<void> _viewMounts() async {
//     String search = '';
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setModalState) {
//           final records = _mounts.where((item) {
//             final text =
//             '${item['classOrLevel']} ${item['departmentId']} ${item['courseCodes']}'
//                 .toLowerCase();
//             return text.contains(search.toLowerCase());
//           }).toList();
//           return AlertDialog(
//             title: Text('Mounted ${_recordLabel}s'),
//             content: SizedBox(
//               width: 900,
//               height: 560,
//               child: Column(
//                 children: [
//                   TextField(
//                     onChanged: (value) => setModalState(() => search = value),
//                     decoration: const InputDecoration(
//                       labelText: 'Search mounted records',
//                       prefixIcon: Icon(Icons.search),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: records.length,
//                       itemBuilder: (context, index) =>
//                           _mountTile(records[index], dialogContext),
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
//   Widget _mountTile(Map<String, dynamic> item, BuildContext dialogContext) {
//     final codes =
//         (item['courseCodes'] as List?)
//             ?.map((value) => value.toString())
//             .join(', ') ??
//             '';
//     return Card(
//       child: ListTile(
//         title: Text('${item['classOrLevel']}  |  $codes'),
//         subtitle: Text(
//           'Department: ${item['departmentId']} • Credits: ${item['totalCredits'] ?? 0}',
//         ),
//         trailing: Wrap(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit_outlined),
//               tooltip: 'Edit mount',
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//                 _openMountModal(initial: item);
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete_outline, color: Colors.red),
//               tooltip: 'Delete mount',
//               onPressed: () async {
//                 await context
//                     .read<Myprovider>()
//                     .db
//                     .collection('courseMounting')
//                     .doc(item['id'])
//                     .delete();
//                 await _load();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final body = _loading
//         ? const Center(child: CircularProgressIndicator())
//         : Padding(
//       padding: const EdgeInsets.all(18),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Wrap(
//             spacing: 8,
//             runSpacing: 10,
//             crossAxisAlignment: WrapCrossAlignment.center,
//             children: [
//               Text(
//                 'Course mounting',
//                 style: Theme.of(context).textTheme.headlineSmall
//                     ?.copyWith(fontWeight: FontWeight.w800),
//               ),
//               FilledButton.icon(
//                 onPressed: _openMountModal,
//                 icon: const Icon(Icons.add),
//                 label: const Text('Add mount'),
//               ),
//               OutlinedButton.icon(
//                 onPressed: _viewMounts,
//                 icon: const Icon(Icons.table_view_outlined),
//                 label: const Text('View mounts'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Mount core and elective ${_recordLabel.toLowerCase()}s for a department and ${_groupLabel.toLowerCase()}.',
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//             ),
//           ),
//         ],
//       ),
//     );
//     if (widget.embedded) return body;
//     return Scaffold(
//       appBar: AppBar(title: const Text('Course mounting')),
//       body: body,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/coursemountmodel.dart';
import '../controller/myprovider.dart';

class CourseMountingPage extends StatefulWidget {
  final CourseMountModel? initial;
  const CourseMountingPage({super.key, this.initial, required bool embedded});

  @override
  State<CourseMountingPage> createState() => _CourseMountingPageState();
}

class _CourseMountingPageState extends State<CourseMountingPage> {
  bool _loading = true;
  bool _saving = false;
  double _minCredits = 0;
  double _maxCredits = 30;
  List<CourseMountModel> _otherMounts = [];

  String? _facultyId;
  String? _departmentId;
  String? _classOrLevel;
  String _mode = 'Core';
  final Set<String> _coreCodes = {};
  final Set<String> _electiveCodes = {};
  final Set<String> _checkedAvailable = {};
  final Set<String> _checkedSelected = {};

  Myprovider get _provider => context.read<Myprovider>();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _facultyId = initial.facultyId;
      _departmentId = initial.departmentId;
      _classOrLevel = initial.classOrLevel;
      _coreCodes.addAll(initial.coreCourseCodes);
      _electiveCodes.addAll(initial.electiveCourseCodes);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = _provider;
    if (provider.schoolid.trim().isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    await Future.wait([
      provider.fetchdepart(),
      provider.fetchsubjects(),
      provider.fetchclass(),
    ]);
    final schoolDoc = await provider.db.collection('schools').doc(provider.schoolid).get();
    final schoolData = schoolDoc.data() ?? {};
    final mountsSnap = await provider.db
        .collection('courseMounting')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('academicYear', isEqualTo: provider.year)
        .where('termOrSemester', isEqualTo: provider.term)
        .get();
    if (!mounted) return;
    setState(() {
      _minCredits = (schoolData['creditHourMin'] as num?)?.toDouble() ?? 0;
      _maxCredits = (schoolData['creditHourMax'] as num?)?.toDouble() ?? 30;
      _otherMounts = mountsSnap.docs
          .map((d) => CourseMountModel.fromMap({...d.data(), 'id': d.id}))
          .where((m) => m.id != widget.initial?.id)
          .toList();
      _loading = false;
    });
  }

  double _creditsOf(String code) =>
      _provider.subjectList.where((c) => c.code == code).map((c) => c.creditHours.toDouble()).fold(0.0, (a, b) => a + b);

  double get _totalCredits {
    double total = 0;
    for (final code in {..._coreCodes, ..._electiveCodes}) {
      total += _creditsOf(code);
    }
    return total;
  }

  bool get _creditsValid => _totalCredits >= _minCredits && _totalCredits <= _maxCredits;

  List<String> get _usedCoursesElsewhere =>
      _otherMounts.expand((m) => m.allCourseCodes).toList();

  List<String> get _usedCombos => _otherMounts
      .map((m) => '${m.facultyId}_${m.departmentId}_${m.classOrLevel}')
      .toList();

  List<dynamic> get _availableFaculties {
    final all = _provider.faculties;
    return all.where((f) {
      final combo = '${f.id}_${_departmentId}_${_classOrLevel}';
      return f.id == _facultyId || !_usedCombos.contains(combo) || _departmentId == null;
    }).toList();
  }

  List<dynamic> get _availableDepartments {
    final all = _provider.departments;
    return all.where((d) => _facultyId == null || d.faculty == _selectedFacultyName).toList();
  }

  String? get _selectedFacultyName =>
      _provider.faculties.where((f) => f.id == _facultyId).map((f) => f.name as String).firstOrNull;

  String? get _selectedDepartmentName =>
      _provider.departments.where((d) => d.id == _departmentId).map((d) => d.name as String).firstOrNull;

  List<dynamic> get _availableLevels {
    final all = _provider.classdata;
    return all.where((c) => _departmentId == null || c.department == _selectedDepartmentName).toList();
  }

  bool get _selectionComplete => _facultyId != null && _departmentId != null && _classOrLevel != null;

  bool get _comboAlreadyMounted {
    if (!_selectionComplete) return false;
    return _usedCombos.contains('${_facultyId}_${_departmentId}_${_classOrLevel}');
  }

  List<dynamic> get _availableCourses {
    if (!_selectionComplete) return [];
    final selected = _mode == 'Core' ? _coreCodes : _electiveCodes;
    return _provider.subjectList.where((c) {
      final matchesDepartment = c.department == _selectedDepartmentName || c.scope == 'All departments';
      final matchesLevel = c.level == _classOrLevel;
      final matchesType = c.type == _mode;
      final notSelected = !selected.contains(c.code) && !_coreCodes.contains(c.code) && !_electiveCodes.contains(c.code);
      final notUsedElsewhere = !_usedCoursesElsewhere.contains(c.code);
      return matchesDepartment && matchesLevel && matchesType && notSelected && notUsedElsewhere;
    }).toList();
  }

  List<dynamic> get _selectedCourses {
    final selected = _mode == 'Core' ? _coreCodes : _electiveCodes;
    return _provider.subjectList.where((c) => selected.contains(c.code)).toList();
  }

  void _addChecked() {
    setState(() {
      final target = _mode == 'Core' ? _coreCodes : _electiveCodes;
      target.addAll(_checkedAvailable);
      _checkedAvailable.clear();
    });
  }

  void _removeChecked() {
    setState(() {
      final target = _mode == 'Core' ? _coreCodes : _electiveCodes;
      target.removeAll(_checkedSelected);
      _checkedSelected.clear();
    });
  }

  Future<void> _save() async {
    if (_saving || !_selectionComplete || !_creditsValid || _coreCodes.isEmpty) return;
    setState(() => _saving = true);
    final provider = _provider;
    final id = widget.initial?.id ??
        '${provider.schoolid}_${_facultyId}_${_departmentId}_${_classOrLevel}_${provider.year}_${provider.term}'
            .replaceAll(RegExp(r'\s+'), '_');
    final model = CourseMountModel(
      id: id,
      schoolId: provider.schoolid,
      schoolType: provider.schoolType,
      facultyId: _facultyId!,
      departmentId: _departmentId!,
      classOrLevel: _classOrLevel!,
      academicYear: provider.year,
      termOrSemester: provider.term,
      coreCourseCodes: _coreCodes.toList(),
      electiveCourseCodes: _electiveCodes.toList(),
      totalCredits: _totalCredits,
    );
    await provider.db.collection('courseMounting').doc(id).set(model.toMap(), SetOptions(merge: true));
    if (provider.schoolType == 'Pre-tertiary') {
      await _registerPreTertiaryStudents(provider, model);
    }
    if (mounted) Navigator.pop(context, model);
  }

  Future<void> _registerPreTertiaryStudents(Myprovider provider, CourseMountModel model) async {
    final students = await provider.db
        .collection('students')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('level', isEqualTo: model.classOrLevel)
        .get();
    final subjects = provider.subjectList.where((s) => model.allCourseCodes.contains(s.code));
    for (final student in students.docs) {
      final scoringId = '${student.id}_${provider.academicyrid}_${provider.term}';
      final ref = provider.db.collection('subjectScoring').doc(scoringId);
      final existing = await ref.get();
      final current = Map<String, dynamic>.from(existing.data()?['subjects'] ?? {});
      for (final subject in subjects) {
        current[subject.id] = {
          'subjectId': subject.id,
          'subjectName': subject.name,
          'code': subject.code,
          'isComplete': 'no',
          'CA': '0',
          'Exams': '0',
          'totalScore': '0',
        };
      }
      await ref.set({
        'studentId': student.id,
        'level': model.classOrLevel,
        'department': model.departmentId,
        'subjects': current,
        'academicYear': model.academicYear,
        'term': model.termOrSemester,
        'schoolId': model.schoolId,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final scheme = Theme.of(context).colorScheme;
    final provider =context.read<Myprovider>();
    if (provider.schoolid.trim().isEmpty) {
      return const Center(child: Text('No school selected yet.'));
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.initial == null ? 'Mount courses' : 'Edit mounted courses')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 700;
                final fields = [
                  _dropdown('Faculty', _facultyId, _availableFaculties.map((f) => f.id as String).toList(),
                      _availableFaculties.map((f) => f.name as String).toList(), (v) {
                        setState(() {
                          _facultyId = v;
                          _departmentId = null;
                          _classOrLevel = null;
                          _coreCodes.clear();
                          _electiveCodes.clear();
                        });
                      }),
                  _dropdown('Department', _departmentId, _availableDepartments.map((d) => d.id as String).toList(),
                      _availableDepartments.map((d) => d.name as String).toList(), (v) {
                        setState(() {
                          _departmentId = v;
                          _classOrLevel = null;
                          _coreCodes.clear();
                          _electiveCodes.clear();
                        });
                      }),
                  _dropdown('Class / Level', _classOrLevel, _availableLevels.map((c) => c.name as String).toList(),
                      _availableLevels.map((c) => c.name as String).toList(), (v) {
                        setState(() {
                          _classOrLevel = v;
                          _coreCodes.clear();
                          _electiveCodes.clear();
                        });
                      }),
                ];
                return wide
                    ? Row(children: fields.map((f) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: f))).toList())
                    : Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList());
              },
            ),
            const SizedBox(height: 8),
            if (_comboAlreadyMounted)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('This class is already mounted for this department.', style: TextStyle(color: Colors.red)),
              ),
            if (_selectionComplete && !_comboAlreadyMounted) ...[
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Core', label: Text('Core')),
                  ButtonSegment(value: 'Elective', label: Text('Elective')),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() {
                  _mode = v.first;
                  _checkedAvailable.clear();
                  _checkedSelected.clear();
                }),
              ),
              const SizedBox(height: 10),
              Expanded(child: _pickerBody(scheme)),
              const SizedBox(height: 12),
              _creditBanner(),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _creditsValid && _coreCodes.isNotEmpty && !_saving ? _save : null,
                  icon: const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save mount'),
                ),
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
        final available = _list('Available $_mode records', _availableCourses, _checkedAvailable, scheme);
        final buttons = _moveButtons(wide);
        final selected = _list('Mounted $_mode records', _selectedCourses, _checkedSelected, scheme);
        return wide
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: available),
            buttons,
            Expanded(child: selected),
          ],
        )
            : Column(
          children: [
            Expanded(child: available),
            buttons,
            Expanded(child: selected),
          ],
        );
      },
    );
  }

  Widget _moveButtons(bool wide) {
    final addBtn = OutlinedButton(onPressed: _checkedAvailable.isEmpty ? null : _addChecked, child: const Text('Add >>'));
    final removeBtn = OutlinedButton(onPressed: _checkedSelected.isEmpty ? null : _removeChecked, child: const Text('<< Remove'));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: wide
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [addBtn, const SizedBox(height: 10), removeBtn])
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [addBtn, const SizedBox(width: 10), removeBtn]),
    );
  }

  Widget _list(String title, List<dynamic> courses, Set<String> checked, ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
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
                  subtitle: Text('${course.creditHours} credits'),
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

  Widget _creditBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _creditsValid ? Colors.green.withValues(alpha: .1) : Colors.red.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total credits: ${_totalCredits.toStringAsFixed(2)} | Allowed: ${_minCredits.toStringAsFixed(2)} - ${_maxCredits.toStringAsFixed(2)}',
            ),
          ),
          Icon(_creditsValid ? Icons.check_circle : Icons.error, color: _creditsValid ? Colors.green : Colors.red),
        ],
      ),
    );
  }
}