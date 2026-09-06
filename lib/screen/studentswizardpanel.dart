// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../controller/dbmodels/contestantsmodel.dart';
// import '../controller/myprovider.dart';
//
// class StudentsWizardPanel extends StatefulWidget {
//   const StudentsWizardPanel({super.key});
//
//   @override
//   State<StudentsWizardPanel> createState() => _StudentsWizardPanelState();
// }
//
// class _StudentsWizardPanelState extends State<StudentsWizardPanel> {
//   String _search = '';
//   String? _departmentFilterId;
//   String? _classFilterId;
//
//   Myprovider get _provider => context.read<Myprovider>();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _load());
//   }
//
//   Future<void> _load() async {
//     await Future.wait([_provider.fetchstudents(), _provider.fetchdepart(), _provider.fetchclass()]);
//     if (mounted) setState(() {});
//   }
//
//   List<StudentModel> _filtered(Myprovider provider) {
//     final query = _search.toLowerCase();
//     return provider.studentlist.where((s) {
//       final matchesSearch = query.isEmpty ||
//           s.name.toLowerCase().contains(query) ||
//           s.studentid.toLowerCase().contains(query);
//       final matchesDepartment = _departmentFilterId == null || s.departmentid == _departmentFilterId;
//       final matchesClass = _classFilterId == null || s.classid == _classFilterId;
//       return matchesSearch && matchesDepartment && matchesClass;
//     }).toList();
//   }
//
//   Future<void> _openStudentModal({StudentModel? initial}) async {
//     final provider = _provider;
//     final nameController = TextEditingController(text: initial?.name ?? '');
//     final idController = TextEditingController(text: initial?.studentid ?? '');
//
//    String? departmentId = initial != null && (initial.departmentid)!.isNotEmpty
//         ? initial.departmentid
//         : provider.departments.firstWhereOrNull((d) => d.name == initial?.department)?.id;
//     String? classId = initial != null && (initial.classid)!.isNotEmpty
//         ? initial.classid
//         : provider.classdata.firstWhereOrNull((c) => c.name == initial?.level)?.id;
//
//     String? sex = initial != null && initial.sex.isNotEmpty ? initial.sex : null;
//     String status = initial != null && initial.status.isNotEmpty ? initial.status : 'active';
//
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setModalState) => AlertDialog(
//           title: Text(initial == null ? 'Add student' : 'Edit student'),
//           content: SizedBox(
//             width: 480,
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(controller: idController, enabled: initial == null, decoration: const InputDecoration(labelText: 'Student ID')),
//                   const SizedBox(height: 12),
//                   TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Student name')),
//                   const SizedBox(height: 12),
//                   DropdownButtonFormField<String>(
//                     initialValue: sex,
//                     decoration: const InputDecoration(labelText: 'Sex'),
//                     items: const ['male', 'female'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
//                     onChanged: (v) => setModalState(() => sex = v),
//                   ),
//                   const SizedBox(height: 12),
//                   DropdownButtonFormField<String>(
//                     initialValue: provider.departments.any((d) => d.id == departmentId) ? departmentId : null,
//                     decoration: const InputDecoration(labelText: 'Department'),
//                     items: provider.departments
//                         .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
//                         .toList(),
//                     onChanged: (v) => setModalState(() => departmentId = v),
//                   ),
//                   const SizedBox(height: 12),
//                   DropdownButtonFormField<String>(
//                     initialValue: provider.classdata.any((c) => c.id == classId) ? classId : null,
//                     decoration: const InputDecoration(labelText: 'Class / Level'),
//                     items: provider.classdata
//                         .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
//                         .toList(),
//                     onChanged: (v) => setModalState(() => classId = v),
//                   ),
//                   const SizedBox(height: 12),
//                   DropdownButtonFormField<String>(
//                     initialValue: status,
//                     decoration: const InputDecoration(labelText: 'Status'),
//                     items: const ['active', 'completed'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
//                     onChanged: (v) => setModalState(() => status = v ?? 'active'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
//             FilledButton.icon(
//               onPressed: nameController.text.trim().isEmpty ||
//                   idController.text.trim().isEmpty ||
//                   departmentId == null ||
//                   classId == null ||
//                   sex == null
//                   ? null
//                   : () async {
//                 final studentId = idController.text.trim().toUpperCase();
//                 final id = initial?.id ?? '${provider.schoolid}_$studentId'.toUpperCase();
//
//                final selectedDepartment =
//                 provider.departments.firstWhereOrNull((d) => d.id == departmentId);
//                 final selectedClass =
//                 provider.classdata.firstWhereOrNull((c) => c.id == classId);
//
//                 final model = StudentModel(
//                   id: id,
//                   studentid: studentId,
//                   name: nameController.text.trim(),
//                   sex: sex ?? '',
//                   school: provider.currentschool,
//                   region: initial?.region ?? '',
//                   guardiancontact: initial?.guardiancontact ?? [],
//                   parentname: initial?.parentname ?? [],
//                   level: selectedClass?.name ?? '',
//                   previousclass: initial?.previousclass ?? '',
//                   nextclass: initial?.nextclass ?? '',
//                   currentclass: selectedClass?.name ?? '',
//                   term: provider.term,
//                   schoolId: provider.schoolid,
//                   dob: initial?.dob ?? '',
//                   address: initial?.address ?? '',
//                   email: initial?.email,
//                   phone: initial?.phone ?? '',
//                   timestamp: initial?.timestamp ?? DateTime.now().toIso8601String(),
//                   photourl: initial?.photourl ?? '',
//                   status: status,
//                   accessLevel: 'student',
//                   department: selectedDepartment?.name ?? '',
//                   yeargroup: initial?.yeargroup ?? DateTime.now().year.toString(),
//                   academicyr: provider.year,
//                   facultyid: initial?.facultyid ?? '',
//                   facultyname: initial?.facultyname ?? '',
//                   departmentid: departmentId ?? '',
//                   departmentname: selectedDepartment?.name ?? '',
//                   classid: classId ?? '',
//                   classname: selectedClass?.name ?? '',
//                 );
//                 await provider.db.collection('students').doc(id).set(model.toMap(), SetOptions(merge: true));
//                 provider.upsertStudent(model);
//                 if (dialogContext.mounted) Navigator.pop(dialogContext);
//               },
//               icon: const Icon(Icons.save),
//               label: Text(initial == null ? 'Add student' : 'Update student'),
//             ),
//           ],
//         ),
//       ),
//     );
//     if (mounted) setState(() {});
//   }
//
//   Future<void> _delete(StudentModel student) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete ${student.name}?'),
//         content: const Text('This action cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//     await _provider.deleteStudents(student.id);
//     if (mounted) setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final provider = context.watch<Myprovider>();
//     final students = _filtered(provider);
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Wrap(
//             spacing: 8,
//             runSpacing: 10,
//             crossAxisAlignment: WrapCrossAlignment.center,
//             children: [
//               Text('Students', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
//               FilledButton.icon(onPressed: () => _openStudentModal(), icon: const Icon(Icons.person_add_alt), label: const Text('Add student')),
//             ],
//           ),
//           const SizedBox(height: 12),
//           LayoutBuilder(
//             builder: (context, constraints) {
//               final wide = constraints.maxWidth > 700;
//               final fields = [
//                 TextField(
//                   onChanged: (v) => setState(() => _search = v),
//                   decoration: const InputDecoration(labelText: 'Search students', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
//                 ),
//                 DropdownButtonFormField<String>(
//                   initialValue: provider.departments.any((d) => d.id == _departmentFilterId) ? _departmentFilterId : null,
//                   decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
//                   items: [
//                     const DropdownMenuItem(value: null, child: Text('All departments')),
//                     ...provider.departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
//                   ],
//                   onChanged: (v) => setState(() => _departmentFilterId = v),
//                 ),
//                 DropdownButtonFormField<String>(
//                   initialValue: provider.classdata.any((c) => c.id == _classFilterId) ? _classFilterId : null,
//                   decoration: const InputDecoration(labelText: 'Class / Level', border: OutlineInputBorder()),
//                   items: [
//                     const DropdownMenuItem(value: null, child: Text('All classes')),
//                     ...provider.classdata.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
//                   ],
//                   onChanged: (v) => setState(() => _classFilterId = v),
//                 ),
//               ];
//               return wide
//                   ? Row(children: fields.map((f) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: f))).toList())
//                   : Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList());
//             },
//           ),
//           const SizedBox(height: 12),
//           Text('${students.length} student(s)', style: TextStyle(color: scheme.onSurfaceVariant)),
//           const SizedBox(height: 8),
//           ConstrainedBox(
//             constraints: const BoxConstraints(maxHeight: 420),
//             child: students.isEmpty
//                 ? Padding(padding: const EdgeInsets.all(20), child: Text('No students found.', style: TextStyle(color: scheme.onSurfaceVariant)))
//                 : ListView.builder(
//               shrinkWrap: true,
//               itemCount: students.length,
//               itemBuilder: (context, i) {
//                 final s = students[i];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   child: ListTile(
//                     leading: CircleAvatar(backgroundColor: scheme.primaryContainer, child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?')),
//                     title: Text(s.name),
//                     subtitle: Text('${s.studentid} • ${s.department} • ${s.level}'),
//                     trailing: Wrap(
//                       children: [
//                         IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Edit', onPressed: () => _openStudentModal(initial: s)),
//                         IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), tooltip: 'Delete', onPressed: () => _delete(s)),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/contestantsmodel.dart';
import '../controller/myprovider.dart';

class StudentsWizardPanel extends StatefulWidget {
  const StudentsWizardPanel({super.key});

  @override
  State<StudentsWizardPanel> createState() => _StudentsWizardPanelState();
}

class _StudentsWizardPanelState extends State<StudentsWizardPanel> {
  String _search = '';
  // Filters are keyed by ID — names can repeat across documents, IDs can't,
  // so this can never hit the DropdownButtonFormField duplicate-value
  // assertion regardless of what the underlying data looks like.
  String? _departmentFilterId;
  String? _classFilterId;

  Myprovider get _provider => context.read<Myprovider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await Future.wait([_provider.fetchstudents(), _provider.fetchdepart(), _provider.fetchclass()]);
    if (mounted) setState(() {});
  }

  List<StudentModel> _filtered(Myprovider provider) {
    final query = _search.toLowerCase();
    return provider.studentlist.where((s) {
      final matchesSearch = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          s.studentid.toLowerCase().contains(query);
      final matchesDepartment = _departmentFilterId == null || s.departmentid == _departmentFilterId;
      final matchesClass = _classFilterId == null || s.classid == _classFilterId;
      return matchesSearch && matchesDepartment && matchesClass;
    }).toList();
  }

  Future<void> _openStudentModal({StudentModel? initial}) async {
    final provider = _provider;
    final nameController = TextEditingController(text: initial?.name ?? '');
    final idController = TextEditingController(text: initial?.studentid ?? '');

    // departmentid/classid on StudentModel are String? — nullable at
    // compile time even though the model defaults them to '' rather than
    // null. Use ?? '' instead of ! so a genuinely-null legacy record can
    // never throw a null-check error here; it just falls through to the
    // name-based lookup below.
    String? departmentId = (initial?.departmentid ?? '').isNotEmpty
        ? initial!.departmentid
        : provider.departments.firstWhereOrNull((d) => d.name == initial?.department)?.id;
    String? classId = (initial?.classid ?? '').isNotEmpty
        ? initial!.classid
        : provider.classdata.firstWhereOrNull((c) => c.name == initial?.level)?.id;

    String? sex = initial != null && initial.sex.isNotEmpty ? initial.sex : null;
    String status = initial != null && initial.status.isNotEmpty ? initial.status : 'active';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(initial == null ? 'Add student' : 'Edit student'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: idController, enabled: initial == null, decoration: const InputDecoration(labelText: 'Student ID')),
                  const SizedBox(height: 12),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Student name')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: sex,
                    decoration: const InputDecoration(labelText: 'Sex'),
                    items: const ['male', 'female'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setModalState(() => sex = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: provider.departments.any((d) => d.id == departmentId) ? departmentId : null,
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: provider.departments
                        .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                        .toList(),
                    onChanged: (v) => setModalState(() => departmentId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: provider.classdata.any((c) => c.id == classId) ? classId : null,
                    decoration: const InputDecoration(labelText: 'Class / Level'),
                    items: provider.classdata
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setModalState(() => classId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const ['active', 'completed'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setModalState(() => status = v ?? 'active'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton.icon(
              onPressed: nameController.text.trim().isEmpty ||
                  idController.text.trim().isEmpty ||
                  departmentId == null ||
                  classId == null ||
                  sex == null
                  ? null
                  : () async {
                final studentId = idController.text.trim().toUpperCase();
                final id = initial?.id ?? '${provider.schoolid}_$studentId'.toUpperCase();

                // Resolve the actual model objects from the chosen IDs
                // so every *name* field on StudentModel always holds a
                // real display name, never a raw ID.
                final selectedDepartment =
                provider.departments.firstWhereOrNull((d) => d.id == departmentId);
                final selectedClass =
                provider.classdata.firstWhereOrNull((c) => c.id == classId);

                final model = StudentModel(
                  id: id,
                  studentid: studentId,
                  name: nameController.text.trim(),
                  sex: sex ?? '',
                  school: provider.currentschool,
                  region: initial?.region ?? '',
                  guardiancontact: initial?.guardiancontact ?? [],
                  parentname: initial?.parentname ?? [],
                  level: selectedClass?.name ?? '',
                  previousclass: initial?.previousclass ?? '',
                  nextclass: initial?.nextclass ?? '',
                  currentclass: selectedClass?.name ?? '',
                  term: provider.term,
                  schoolId: provider.schoolid,
                  dob: initial?.dob ?? '',
                  address: initial?.address ?? '',
                  email: initial?.email,
                  phone: initial?.phone ?? '',
                  timestamp: initial?.timestamp ?? DateTime.now().toIso8601String(),
                  photourl: initial?.photourl ?? '',
                  status: status,
                  accessLevel: 'student',
                  department: selectedDepartment?.name ?? '',
                  yeargroup: initial?.yeargroup ?? DateTime.now().year.toString(),
                  academicyr: provider.year,
                  facultyid: initial?.facultyid ?? '',
                  facultyname: initial?.facultyname ?? '',
                  departmentid: departmentId ?? '',
                  departmentname: selectedDepartment?.name ?? '',
                  classid: classId ?? '',
                  classname: selectedClass?.name ?? '',
                );
                await provider.db.collection('students').doc(id).set(model.toMap(), SetOptions(merge: true));
                provider.upsertStudent(model);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              icon: const Icon(Icons.save),
              label: Text(initial == null ? 'Add student' : 'Update student'),
            ),
          ],
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _delete(StudentModel student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${student.name}?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    await _provider.deleteStudents(student.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<Myprovider>();
    final students = _filtered(provider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Students', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              FilledButton.icon(onPressed: () => _openStudentModal(), icon: const Icon(Icons.person_add_alt), label: const Text('Add student')),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 700;
              final fields = [
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: const InputDecoration(labelText: 'Search students', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                ),
                DropdownButtonFormField<String>(
                  initialValue: provider.departments.any((d) => d.id == _departmentFilterId) ? _departmentFilterId : null,
                  decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All departments')),
                    ...provider.departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                  ],
                  onChanged: (v) => setState(() => _departmentFilterId = v),
                ),
                DropdownButtonFormField<String>(
                  initialValue: provider.classdata.any((c) => c.id == _classFilterId) ? _classFilterId : null,
                  decoration: const InputDecoration(labelText: 'Class / Level', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All classes')),
                    ...provider.classdata.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => _classFilterId = v),
                ),
              ];
              return wide
                  ? Row(children: fields.map((f) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: f))).toList())
                  : Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList());
            },
          ),
          const SizedBox(height: 12),
          Text('${students.length} student(s)', style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: students.isEmpty
                ? Padding(padding: const EdgeInsets.all(20), child: Text('No students found.', style: TextStyle(color: scheme.onSurfaceVariant)))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              itemBuilder: (context, i) {
                final s = students[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: scheme.primaryContainer, child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?')),
                    title: Text(s.name),
                    subtitle: Text('${s.studentid} • ${s.department} • ${s.level}'),
                    trailing: Wrap(
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Edit', onPressed: () => _openStudentModal(initial: s)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), tooltip: 'Delete', onPressed: () => _delete(s)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}