import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/staffmodel.dart';
import '../controller/myprovider.dart';

const _accessLevels = ['teacher', 'admin', 'hod', 'staff'];

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

 List<T> _dedupeBy<T>(List<T> items, Object Function(T) keyOf) {
    final seen = <Object>{};
    final result = <T>[];
    for (final item in items) {
      if (seen.add(keyOf(item))) result.add(item);
    }
    return result;
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

    final storedAccessLevel = (initial?.accessLevel ?? '').trim().toLowerCase();
    String accessLevel = _accessLevels.contains(storedAccessLevel) ? storedAccessLevel : 'teacher';

    bool saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final faculties = _dedupeBy(provider.faculties, (f) => f.id as Object);
          final departmentOptions = _dedupeBy(
            provider.departments.where((d) => facultyId == null || d.faculty == _facultyName(provider, facultyId)).toList(),
                (d) => d.id as Object,
          );
          final classOptions = _dedupeBy(
            provider.classdata.where((c) => departmentId == null || c.department == _departmentName(provider, departmentId)).toList(),
                (c) => c.name as Object,
          );

          Future<void> handleSave() async {
            if (nameController.text.trim().isEmpty ||
                emailController.text.trim().isEmpty ||
                departmentId == null ||
                saving) {
              return;
            }

            setModalState(() => saving = true);
            try {
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
            } catch (e) {
              setModalState(() => saving = false);
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Could not save staff: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }

          return AlertDialog(
            title: Text(initial == null ? 'Add staff' : 'Edit staff'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      enabled: !saving,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      enabled: !saving,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      enabled: !saving,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: faculties.any((f) => f.id == facultyId) ? facultyId : null,
                      decoration: const InputDecoration(labelText: 'Faculty'),
                      items: faculties.map((f) => DropdownMenuItem(value: f.id as String, child: Text(f.name))).toList(),
                      onChanged: saving
                          ? null
                          : (v) => setModalState(() {
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
                      onChanged: saving
                          ? null
                          : (v) => setModalState(() {
                        departmentId = v;
                        classOrLevel = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: classOptions.any((c) => c.name == classOrLevel) ? classOrLevel : null,
                      decoration: const InputDecoration(labelText: 'Class / Level'),
                      items: classOptions.map((c) => DropdownMenuItem(value: c.name as String, child: Text(c.name))).toList(),
                      onChanged: saving ? null : (v) => setModalState(() => classOrLevel = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: accessLevel,
                      decoration: const InputDecoration(labelText: 'Access level'),
                      items: _accessLevels.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: saving ? null : (v) => setModalState(() => accessLevel = v ?? 'teacher'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: (nameController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty ||
                    departmentId == null ||
                    saving)
                    ? null
                    : handleSave,
                icon: saving
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.save),
                label: Text(saving ? 'Saving...' : (initial == null ? 'Add staff' : 'Update staff')),
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
    if (confirmed != true || !mounted) return;

    try {
      await _provider.db.collection('staff').doc(staff.id).delete();
      await _provider.fetchstaff();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete staff: $e'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<Myprovider>();
    final staff = _filtered(provider);
    final faculties = _dedupeBy(provider.faculties, (f) => f.id as Object);
    final departments = _dedupeBy(provider.departments, (d) => d.id as Object);

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
                  initialValue: faculties.any((f) => f.id == _facultyFilter) ? _facultyFilter : null,
                  decoration: const InputDecoration(labelText: 'Faculty', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All faculties')),
                    ...faculties.map((f) => DropdownMenuItem(value: f.id as String, child: Text(f.name))),
                  ],
                  onChanged: (v) => setState(() {
                    _facultyFilter = v;
                    _departmentFilter = null;
                  }),
                ),
                DropdownButtonFormField<String>(
                  initialValue: departments.any((d) => d.id == _departmentFilter) ? _departmentFilter : null,
                  decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All departments')),
                    ..._dedupeBy(
                      departments.where((d) => _facultyFilter == null || d.faculty == _facultyName(provider, _facultyFilter)).toList(),
                          (d) => d.id as Object,
                    ).map((d) => DropdownMenuItem(value: d.id as String, child: Text(d.name))),
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