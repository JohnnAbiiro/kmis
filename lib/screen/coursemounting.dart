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

import '../controller/myprovider.dart';

class CourseMountingPage extends StatefulWidget {
  final bool embedded;
  const CourseMountingPage({super.key, this.embedded = false});

  @override
  State<CourseMountingPage> createState() => _CourseMountingPageState();
}

class _CourseMountingPageState extends State<CourseMountingPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _mounts = [];
  double _minCredits = 0;
  double _maxCredits = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<Myprovider>();
    await Future.wait([
      provider.fetchdepart(),
      provider.fetchsubjects(),
      provider.fetchclass(),
    ]);
    final snapshot = await provider.db
        .collection('courseMounting')
        .where('schoolId', isEqualTo: provider.schoolid)
        .get();
    final schoolSnapshot = await provider.db
        .collection('schools')
        .doc(provider.schoolid)
        .get();
    final schoolData = schoolSnapshot.data() ?? <String, dynamic>{};
    if (!mounted) return;
    setState(() {
      _mounts = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
      _minCredits = (schoolData['creditHourMin'] as num?)?.toDouble() ?? 0;
      _maxCredits = (schoolData['creditHourMax'] as num?)?.toDouble() ?? 30;
      _loading = false;
    });
  }

  String get _groupLabel {
    final provider = context.read<Myprovider>();
    return provider.schoolType == 'Pre-tertiary' ? 'Class' : 'Level';
  }

  String get _recordLabel {
    final provider = context.read<Myprovider>();
    return provider.schoolType == 'Pre-tertiary' ? 'Subject' : 'Course';
  }

  Future<void> _openMountModal({Map<String, dynamic>? initial}) async {
    final provider = context.read<Myprovider>();
    String? departmentId = initial?['departmentId']?.toString();
    String? group = initial?['classOrLevel']?.toString();
    String? coreCode = initial?['coreCourseCode']?.toString();
    final electiveCodes = <String>{
      ...((initial?['electiveCourseCodes'] as List?)?.map(
            (item) => item.toString(),
      ) ??
          const []),
    };
    String search = '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final departmentName =
              provider.departments
                  .where((item) => item.id == departmentId)
                  .map((item) => item.name)
                  .firstOrNull ??
                  '';
          final groups = provider.classdata
              .map((item) => item.name)
              .whereType<String>()
              .toSet()
              .toList();
          final mountedElsewhere = _mounts
              .where(
                (item) =>
            item['departmentId'] == departmentId &&
                item['classOrLevel'] == group &&
                item['id'] != initial?['id'],
          )
              .expand((item) => (item['courseCodes'] as List?) ?? const [])
              .map((item) => item.toString())
              .toSet();
          final courses = provider.subjectList.where((course) {
            final query = search.toLowerCase().trim();
            final matchesDepartment =
                departmentId == null ||
                    course.department?.toLowerCase() ==
                        departmentName.toLowerCase() ||
                    course.scope == 'All departments';
            final matchesGroup = group == null || course.level == group;
            final matchesSearch =
                query.isEmpty ||
                    course.name.toLowerCase().contains(query) ||
                    (course.code ?? '').toLowerCase().contains(query);
            return matchesDepartment &&
                matchesGroup &&
                matchesSearch &&
                !mountedElsewhere.contains(course.code);
          }).toList();
          final coreCourses = courses
              .where((course) => course.type == 'Core')
              .toList();
          final electives = courses
              .where((course) => course.type != 'Core')
              .toList();
          final selectedElectives = electives.where(
                (course) => electiveCodes.contains(course.code),
          );
          final core = coreCourses
              .where((course) => course.code == coreCode)
              .firstOrNull;
          final totalCredits =
              (core?.creditHours ?? 0) +
                  selectedElectives.fold<double>(
                    0,
                        (total, item) => total + item.creditHours,
                  );
          final minCredits = _minCredits;
          final maxCredits = _maxCredits;
          final validCredits =
              totalCredits >= minCredits && totalCredits <= maxCredits;

          return AlertDialog(
            title: Text(
              initial == null
                  ? 'Mount $_recordLabel records'
                  : 'Edit mounted $_recordLabel records',
            ),
            content: SizedBox(
              width: 900,
              height: 650,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: departmentId,
                            decoration: const InputDecoration(
                              labelText: 'Department / programme',
                            ),
                            items: provider.departments
                                .map(
                                  (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                                .toList(),
                            onChanged: (value) => setModalState(() {
                              departmentId = value;
                              group = null;
                              coreCode = null;
                              electiveCodes.clear();
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: groups.contains(group) ? group : null,
                            decoration: InputDecoration(labelText: _groupLabel),
                            items: groups
                                .map(
                                  (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                                .toList(),
                            onChanged: (value) => setModalState(() {
                              group = value;
                              coreCode = null;
                              electiveCodes.clear();
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      onChanged: (value) => setModalState(() => search = value),
                      decoration: InputDecoration(
                        labelText: 'Search $_recordLabel records',
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Select core ${_recordLabel.toLowerCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue:
                      coreCourses.any((item) => item.code == coreCode)
                          ? coreCode
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Core $_recordLabel',
                      ),
                      items: coreCourses
                          .map(
                            (item) => DropdownMenuItem(
                          value: item.code,
                          child: Text(
                            '${item.code}  ${item.name} (${item.creditHours} credits)',
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => coreCode = value),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Add elective ${_recordLabel.toLowerCase()}s',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    ...electives.map(
                          (course) => CheckboxListTile(
                        dense: true,
                        value: electiveCodes.contains(course.code),
                        title: Text('${course.code}  ${course.name}'),
                        subtitle: Text('${course.creditHours} credits'),
                        onChanged: (value) => setModalState(() {
                          if (value == true) {
                            electiveCodes.add(course.code ?? '');
                          } else {
                            electiveCodes.remove(course.code);
                          }
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: validCredits
                            ? Colors.green.withValues(alpha: .1)
                            : Colors.red.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total credits: ${totalCredits.toStringAsFixed(2)} | Allowed: ${minCredits.toStringAsFixed(2)} - ${maxCredits.isFinite ? maxCredits.toStringAsFixed(2) : 'No limit'}',
                            ),
                          ),
                          Icon(
                            validCredits ? Icons.check_circle : Icons.error,
                            color: validCredits ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed:
                departmentId == null ||
                    group == null ||
                    coreCode == null ||
                    !validCredits
                    ? null
                    : () async {
                  await _saveMount(
                    provider,
                    initial,
                    departmentId!,
                    group!,
                    coreCode!,
                    electiveCodes,
                    totalCredits,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.save),
                label: Text(initial == null ? 'Mount records' : 'Update mount'),
              ),
            ],
          );
        },
      ),
    );
    await _load();
  }

  Future<void> _saveMount(
      Myprovider provider,
      Map<String, dynamic>? initial,
      String departmentId,
      String group,
      String coreCode,
      Set<String> electives,
      double totalCredits,
      ) async {
    final id =
    '${provider.schoolid}_${departmentId}_${group}_${provider.year}_${provider.term}'
        .replaceAll(RegExp(r'\s+'), '_');
    final data = {
      'id': id,
      'schoolId': provider.schoolid,
      'schoolType': provider.schoolType,
      'departmentId': departmentId,
      'classOrLevel': group,
      'academicYear': provider.year,
      'termOrSemester': provider.term,
      'coreCourseCode': coreCode,
      'electiveCourseCodes': electives.toList(),
      'courseCodes': [coreCode, ...electives],
      'totalCredits': totalCredits,
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await provider.db
        .collection('courseMounting')
        .doc(initial?['id']?.toString() ?? id)
        .set(data, SetOptions(merge: true));
    if (provider.schoolType == 'Pre-tertiary') {
      await _registerForPreTertiaryStudents(provider, group, departmentId, [
        coreCode,
        ...electives,
      ]);
    }
  }

  Future<void> _registerForPreTertiaryStudents(
      Myprovider provider,
      String group,
      String departmentId,
      List<String> codes,
      ) async {
    final students = await provider.db
        .collection('students')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('level', isEqualTo: group)
        .get();
    final subjects = provider.subjectList.where(
          (item) => codes.contains(item.code),
    );
    for (final student in students.docs) {
      final scoringId =
          '${student.id}_${provider.academicyrid}_${provider.term}';
      final reference = provider.db.collection('subjectScoring').doc(scoringId);
      final existing = await reference.get();
      final current = Map<String, dynamic>.from(
        existing.data()?['subjects'] ?? {},
      );
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
      await reference.set({
        'studentId': student.id,
        'level': group,
        'department': departmentId,
        'subjects': current,
        'academicYear': provider.year,
        'term': provider.term,
        'schoolId': provider.schoolid,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _viewMounts() async {
    String search = '';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final records = _mounts.where((item) {
            final text =
            '${item['classOrLevel']} ${item['departmentId']} ${item['courseCodes']}'
                .toLowerCase();
            return text.contains(search.toLowerCase());
          }).toList();
          return AlertDialog(
            title: Text('Mounted ${_recordLabel}s'),
            content: SizedBox(
              width: 900,
              height: 560,
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setModalState(() => search = value),
                    decoration: const InputDecoration(
                      labelText: 'Search mounted records',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) =>
                          _mountTile(records[index], dialogContext),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _mountTile(Map<String, dynamic> item, BuildContext dialogContext) {
    final codes =
        (item['courseCodes'] as List?)
            ?.map((value) => value.toString())
            .join(', ') ??
            '';
    return Card(
      child: ListTile(
        title: Text('${item['classOrLevel']}  |  $codes'),
        subtitle: Text(
          'Department: ${item['departmentId']} • Credits: ${item['totalCredits'] ?? 0}',
        ),
        trailing: Wrap(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit mount',
              onPressed: () {
                Navigator.pop(dialogContext);
                _openMountModal(initial: item);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete mount',
              onPressed: () async {
                await context
                    .read<Myprovider>()
                    .db
                    .collection('courseMounting')
                    .doc(item['id'])
                    .delete();
                await _load();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Course mounting',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              FilledButton.icon(
                onPressed: _openMountModal,
                icon: const Icon(Icons.add),
                label: const Text('Add mount'),
              ),
              OutlinedButton.icon(
                onPressed: _viewMounts,
                icon: const Icon(Icons.table_view_outlined),
                label: const Text('View mounts'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Mount core and elective ${_recordLabel.toLowerCase()}s for a department and ${_groupLabel.toLowerCase()}.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Course mounting')),
      body: body,
    );
  }
}