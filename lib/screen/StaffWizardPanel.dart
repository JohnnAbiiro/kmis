// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../controller/dbmodels/staffmodel.dart';
// import '../controller/myprovider.dart';
//
// class StaffWizardPanel extends StatefulWidget {
//   const StaffWizardPanel({super.key});
//
//   @override
//   State<StaffWizardPanel> createState() => _StaffWizardPanelState();
// }
//
// class _StaffWizardPanelState extends State<StaffWizardPanel> {
//   String _search = '';
//   String? _facultyFilter;
//   String? _departmentFilter;
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
//     await Future.wait([_provider.fetchstaff(), _provider.fetchdepart(), _provider.fetchclass()]);
//     if (mounted) setState(() {});
//   }
//
//   String? _facultyOf(Myprovider provider, String? departmentId) =>
//       provider.departments.where((d) => d.id == departmentId).map((d) => d.faculty as String?).firstOrNull;
//
//   List<Staff> _filtered(Myprovider provider) {
//     final query = _search.toLowerCase();
//     return provider.stafflist.where((s) {
//       final matchesSearch = query.isEmpty || s.name.toLowerCase().contains(query) || s.email.toLowerCase().contains(query);
//       final matchesFaculty = _facultyFilter == null || s.facultyId == _facultyFilter;
//       final matchesDepartment = _departmentFilter == null || s.departmentId == _departmentFilter;
//       return matchesSearch && matchesFaculty && matchesDepartment;
//     }).toList();
//   }
//
//   Future<void> _openStaffModal({Staff? initial}) async {
//     final provider = _provider;
//     final nameController = TextEditingController(text: initial?.name ?? '');
//     final emailController = TextEditingController(text: initial?.email ?? '');
//     final phoneController = TextEditingController(text: initial?.phone ?? '');
//     String? facultyId = initial != null && initial.facultyId.isNotEmpty ? initial.facultyId : null;
//     String? departmentId = initial != null && initial.departmentId.isNotEmpty ? initial.departmentId : null;
//     String? classOrLevel = initial != null && initial.classOrLevel.isNotEmpty ? initial.classOrLevel : null;
//     String accessLevel = initial != null && initial.accessLevel.isNotEmpty ? initial.accessLevel : 'teacher';
//
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setModalState) {
//           final departmentOptions = provider.departments.where((d) => facultyId == null || d.faculty == facultyId).toList();
//           final classOptions = provider.classdata.where((c) => departmentId == null || c.department == _departmentName(provider, departmentId)).toList();
//           return AlertDialog(
//             title: Text(initial == null ? 'Add staff' : 'Edit staff'),
//             content: SizedBox(
//               width: 480,
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full name')),
//                     const SizedBox(height: 12),
//                     TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
//                     const SizedBox(height: 12),
//                     TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue: provider.faculties.any((f) => f.id == facultyId) ? facultyId : null,
//                       decoration: const InputDecoration(labelText: 'Faculty'),
//                       items: provider.faculties.map((f) => DropdownMenuItem(value: f.id as String, child: Text(f.name))).toList(),
//                       onChanged: (v) => setModalState(() {
//                         facultyId = v;
//                         departmentId = null;
//                         classOrLevel = null;
//                       }),
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue: departmentOptions.any((d) => d.id == departmentId) ? departmentId : null,
//                       decoration: const InputDecoration(labelText: 'Department'),
//                       items: departmentOptions.map((d) => DropdownMenuItem(value: d.id as String, child: Text(d.name))).toList(),
//                       onChanged: (v) => setModalState(() {
//                         departmentId = v;
//                         classOrLevel = null;
//                       }),
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue: classOptions.any((c) => c.name == classOrLevel) ? classOrLevel : null,
//                       decoration: const InputDecoration(labelText: 'Class / Level'),
//                       items: classOptions.map((c) => DropdownMenuItem(value: c.name as String, child: Text(c.name))).toList(),
//                       onChanged: (v) => setModalState(() => classOrLevel = v),
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue: accessLevel,
//                       decoration: const InputDecoration(labelText: 'Access level'),
//                       items: const ['teacher', 'admin', 'hod', 'staff'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
//                       onChanged: (v) => setModalState(() => accessLevel = v ?? 'teacher'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
//               FilledButton.icon(
//                 onPressed: nameController.text.trim().isEmpty || emailController.text.trim().isEmpty || departmentId == null
//                     ? null
//                     : () async {
//                   final id = initial?.id ?? '${provider.schoolid}_${emailController.text.trim().toLowerCase()}';
//                   final staff = Staff(
//                     id: id,
//                     name: nameController.text.trim(),
//                     accessLevel: accessLevel,
//                     teaching: '',
//                     phone: phoneController.text.trim(),
//                     email: emailController.text.trim().toLowerCase(),
//                     sex: initial?.sex ?? '',
//                     region: initial?.region ?? '',
//                     schoolId: provider.schoolid,
//                     schoolname: provider.currentschool,
//                     facultyId: facultyId ?? '',
//                     departmentId: departmentId ?? '',
//                     classOrLevel: classOrLevel ?? '',
//                     createdAt: initial != null ? DateTime.now() : DateTime.now(),
//                   );
//                   await provider.db.collection('staff').doc(id).set(
//                     initial == null ? staff.toMapForRegister() : staff.toMapForUpdate(),
//                     SetOptions(merge: true),
//                   );
//                   await provider.fetchstaff();
//                   if (dialogContext.mounted) Navigator.pop(dialogContext);
//                 },
//                 icon: const Icon(Icons.save),
//                 label: Text(initial == null ? 'Add staff' : 'Update staff'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//     if (mounted) setState(() {});
//   }
//
//   String? _departmentName(Myprovider provider, String? departmentId) =>
//       provider.departments.where((d) => d.id == departmentId).map((d) => d.name as String).firstOrNull;
//
//   Future<void> _delete(Staff staff) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete ${staff.name}?'),
//         content: const Text('This action cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//     await _provider.db.collection('staff').doc(staff.id).delete();
//     await _provider.fetchstaff();
//     if (mounted) setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final provider = context.watch<Myprovider>();
//     final staff = _filtered(provider);
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
//               Text('Staff', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
//               FilledButton.icon(onPressed: () => _openStaffModal(), icon: const Icon(Icons.person_add_alt_1), label: const Text('Add staff')),
//             ],
//           ),
//           const SizedBox(height: 12),
//           LayoutBuilder(
//             builder: (context, constraints) {
//               final wide = constraints.maxWidth > 800;
//               final fields = [
//                 TextField(
//                   onChanged: (v) => setState(() => _search = v),
//                   decoration: const InputDecoration(labelText: 'Search staff', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
//                 ),
//                 DropdownButtonFormField<String>(
//                   initialValue: _facultyFilter,
//                   decoration: const InputDecoration(labelText: 'Faculty', border: OutlineInputBorder()),
//                   items: [const DropdownMenuItem(value: null, child: Text('All faculties')), ...provider.faculties.map((f) => DropdownMenuItem(value: f.id as String, child: Text(f.name)))],
//                   onChanged: (v) => setState(() {
//                     _facultyFilter = v;
//                     _departmentFilter = null;
//                   }),
//                 ),
//                 DropdownButtonFormField<String>(
//                   initialValue: _departmentFilter,
//                   decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
//                   items: [
//                     const DropdownMenuItem(value: null, child: Text('All departments')),
//                     ...provider.departments
//                         .where((d) => _facultyFilter == null || d.faculty == _facultyFilter)
//                         .map((d) => DropdownMenuItem(value: d.id as String, child: Text(d.name))),
//                   ],
//                   onChanged: (v) => setState(() => _departmentFilter = v),
//                 ),
//               ];
//               return wide
//                   ? Row(children: fields.map((f) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: f))).toList())
//                   : Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList());
//             },
//           ),
//           const SizedBox(height: 12),
//           Text('${staff.length} staff member(s)', style: TextStyle(color: scheme.onSurfaceVariant)),
//           const SizedBox(height: 8),
//           ConstrainedBox(
//             constraints: const BoxConstraints(maxHeight: 420),
//             child: staff.isEmpty
//                 ? Padding(padding: const EdgeInsets.all(20), child: Text('No staff found.', style: TextStyle(color: scheme.onSurfaceVariant)))
//                 : ListView.builder(
//               shrinkWrap: true,
//               itemCount: staff.length,
//               itemBuilder: (context, i) {
//                 final s = staff[i];
//                 final departmentName = _departmentName(provider, s.departmentId) ?? '';
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   child: ListTile(
//                     leading: CircleAvatar(backgroundColor: scheme.primaryContainer, child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?')),
//                     title: Text(s.name),
//                     subtitle: Text('${s.email} • $departmentName • ${s.classOrLevel} • ${s.accessLevel}'),
//                     trailing: Wrap(
//                       children: [
//                         IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Edit', onPressed: () => _openStaffModal(initial: s)),
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/staffmodel.dart';
import '../controller/myprovider.dart';

class StaffWizardPanel extends StatefulWidget {
  const StaffWizardPanel({super.key});

  @override
  State<StaffWizardPanel> createState() => _StaffWizardPanelState();
}

class _StaffWizardPanelState extends State<StaffWizardPanel> {
  String _search = '';
  String? _facultyFilter;
  String? _departmentFilter;

  Myprovider get _provider => context.read<Myprovider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await Future.wait([_provider.fetchstaff(), _provider.fetchdepart(), _provider.fetchclass()]);
    if (mounted) setState(() {});
  }

  List<Staff> _filtered(Myprovider provider) {
    final query = _search.toLowerCase();
    return provider.stafflist.where((s) {
      final matchesSearch = query.isEmpty || s.name.toLowerCase().contains(query) || s.email.toLowerCase().contains(query);
      final matchesFaculty = _facultyFilter == null || s.facultyId == _facultyFilter;
      final matchesDepartment = _departmentFilter == null || s.departmentId == _departmentFilter;
      return matchesSearch && matchesFaculty && matchesDepartment;
    }).toList();
  }

  String? _departmentName(Myprovider provider, String? departmentId) =>
      provider.departments.where((d) => d.id == departmentId).map((d) => d.name as String).firstOrNull;

  String? _facultyName(Myprovider provider, String? facultyId) =>
      provider.faculties.where((f) => f.id == facultyId).map((f) => f.name as String).firstOrNull;

  Future<void> _openStaffModal({Staff? initial}) async {
    final provider = _provider;
    final nameController = TextEditingController(text: initial?.name ?? '');
    final emailController = TextEditingController(text: initial?.email ?? '');
    final phoneController = TextEditingController(text: initial?.phone ?? '');
    String? facultyId = initial != null && initial.facultyId.isNotEmpty ? initial.facultyId : null;
    String? departmentId = initial != null && initial.departmentId.isNotEmpty ? initial.departmentId : null;
    String? classOrLevel = initial != null && initial.classOrLevel.isNotEmpty ? initial.classOrLevel : null;
    String accessLevel = initial != null && initial.accessLevel.isNotEmpty ? initial.accessLevel : 'teacher';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final departmentOptions = provider.departments.where((d) => facultyId == null || d.faculty == _facultyName(provider, facultyId)).toList();
          final classOptions = provider.classdata.where((c) => departmentId == null || c.department == _departmentName(provider, departmentId)).toList();
          return AlertDialog(
            title: Text(initial == null ? 'Add staff' : 'Edit staff'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full name')),
                    const SizedBox(height: 12),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: provider.faculties.any((f) => f.id == facultyId) ? facultyId : null,
                      decoration: const InputDecoration(labelText: 'Faculty'),
                      items: provider.faculties.map((f) => DropdownMenuItem(value: f.id as String, child: Text(f.name))).toList(),
                      onChanged: (v) => setModalState(() {
                        facultyId = v;
                        departmentId = null;
                        classOrLevel = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: departmentOptions.any((d) => d.id == departmentId) ? departmentId : null,
                      decoration: const InputDecoration(labelText: 'Department'),
                      items: departmentOptions.map((d) => DropdownMenuItem(value: d.id as String, child: Text(d.name))).toList(),
                      onChanged: (v) => setModalState(() {
                        departmentId = v;
                        classOrLevel = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: classOptions.any((c) => c.name == classOrLevel) ? classOrLevel : null,
                      decoration: const InputDecoration(labelText: 'Class / Level'),
                      items: classOptions.map((c) => DropdownMenuItem(value: c.name as String, child: Text(c.name))).toList(),
                      onChanged: (v) => setModalState(() => classOrLevel = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: accessLevel,
                      decoration: const InputDecoration(labelText: 'Access level'),
                      items: const ['teacher', 'admin', 'hod', 'staff'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setModalState(() => accessLevel = v ?? 'teacher'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              FilledButton.icon(
                onPressed: nameController.text.trim().isEmpty || emailController.text.trim().isEmpty || departmentId == null
                    ? null
                    : () async {
                  final id = initial?.id ?? '${provider.schoolid}_${emailController.text.trim().toLowerCase()}';
                  final staff = Staff(
                    id: id,
                    name: nameController.text.trim(),
                    accessLevel: accessLevel,
                    teaching: '',
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim().toLowerCase(),
                    sex: initial?.sex ?? '',
                    region: initial?.region ?? '',
                    schoolId: provider.schoolid,
                    schoolname: provider.currentschool,
                    facultyId: facultyId ?? '',
                    facultyName: _facultyName(provider, facultyId) ?? '',
                    departmentId: departmentId ?? '',
                    departmentName: _departmentName(provider, departmentId) ?? '',
                    classOrLevel: classOrLevel ?? '',
                    createdAt: DateTime.now(),
                  );
                  await provider.db.collection('staff').doc(id).set(
                    initial == null ? staff.toMapForRegister() : staff.toMapForUpdate(),
                    SetOptions(merge: true),
                  );
                  await provider.fetchstaff();
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.save),
                label: Text(initial == null ? 'Add staff' : 'Update staff'),
              ),
            ],
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _delete(Staff staff) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${staff.name}?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    await _provider.db.collection('staff').doc(staff.id).delete();
    await _provider.fetchstaff();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<Myprovider>();
    final staff = _filtered(provider);

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
              Text('Staff', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              FilledButton.icon(onPressed: () => _openStaffModal(), icon: const Icon(Icons.person_add_alt_1), label: const Text('Add staff')),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 800;
              final fields = [
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: const InputDecoration(labelText: 'Search staff', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _facultyFilter,
                  decoration: const InputDecoration(labelText: 'Faculty', border: OutlineInputBorder()),
                  items: [const DropdownMenuItem(value: null, child: Text('All faculties')), ...provider.faculties.map((f) => DropdownMenuItem(value: f.id as String, child: Text(f.name)))],
                  onChanged: (v) => setState(() {
                    _facultyFilter = v;
                    _departmentFilter = null;
                  }),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _departmentFilter,
                  decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All departments')),
                    ...provider.departments
                        .where((d) => _facultyFilter == null || d.faculty == _facultyName(provider, _facultyFilter))
                        .map((d) => DropdownMenuItem(value: d.id as String, child: Text(d.name))),
                  ],
                  onChanged: (v) => setState(() => _departmentFilter = v),
                ),
              ];
              return wide
                  ? Row(children: fields.map((f) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: f))).toList())
                  : Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList());
            },
          ),
          const SizedBox(height: 12),
          Text('${staff.length} staff member(s)', style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: staff.isEmpty
                ? Padding(padding: const EdgeInsets.all(20), child: Text('No staff found.', style: TextStyle(color: scheme.onSurfaceVariant)))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: staff.length,
              itemBuilder: (context, i) {
                final s = staff[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: scheme.primaryContainer, child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?')),
                    title: Text(s.name),
                    subtitle: Text('${s.email}\n${s.facultyName} • ${s.departmentName} • ${s.classOrLevel} • ${s.accessLevel}'),
                    isThreeLine: true,
                    trailing: Wrap(
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Edit', onPressed: () => _openStaffModal(initial: s)),
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