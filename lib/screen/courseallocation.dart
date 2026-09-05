import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controller/myprovider.dart';
import '../controller/routes.dart';

class CourseAllocationPage extends StatefulWidget {
  const CourseAllocationPage({super.key});

  @override
  State<CourseAllocationPage> createState() => _CourseAllocationPageState();
}

class _CourseAllocationPageState extends State<CourseAllocationPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _allocations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<Myprovider>();
    await Future.wait([
      provider.fetchdepart(),
      provider.fetchstaff(),
      provider.fetchsubjects(),
      provider.fetchclass(),
    ]);
    final snapshot = await provider.db
        .collection('courseAllocation')
        .where('schoolId', isEqualTo: provider.schoolid)
        .get();
    if (!mounted) return;
    setState(() {
      _allocations = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
      _loading = false;
    });
  }

  String _period(Myprovider provider) =>
      provider.term.isNotEmpty ? provider.term : 'current';

  Future<void> _openAllocationModal({Map<String, dynamic>? initial}) async {
    final provider = context.read<Myprovider>();
    String? departmentId = initial?['departmentId']?.toString();
    String? group = initial?['classOrLevel']?.toString();
    String? teacherId = initial?['staffId']?.toString();
    String teacherSearch = '';
    String courseSearch = '';
    final selected = <String>{
      if (initial != null)
        ..._allocations
            .where(
              (item) =>
          item['staffId'] == teacherId &&
              item['departmentId'] == departmentId &&
              item['classOrLevel'] == group,
        )
            .map((item) => item['courseCode'].toString()),
    };
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final department = provider.departments.where(
                (d) => d.id == departmentId,
          );
          final departmentName = department.isEmpty
              ? ''
              : department.first.name;
          final groups = provider.classdata
              .map((item) => item.name)
              .whereType<String>()
              .toSet()
              .toList();
          final teachers = provider.stafflist.where((teacher) {
            final query = teacherSearch.toLowerCase();
            return query.isEmpty ||
                teacher.name.toLowerCase().contains(query) ||
                teacher.email.toLowerCase().contains(query);
          }).toList();
          final courses = provider.subjectList.where((course) {
            final query = courseSearch.toLowerCase();
            final departmentMatches =
                departmentId == null ||
                    course.department?.toLowerCase() ==
                        departmentName.toLowerCase() ||
                    course.scope == 'All departments';
            return departmentMatches &&
                (query.isEmpty ||
                    course.name.toLowerCase().contains(query) ||
                    (course.code ?? '').toLowerCase().contains(query));
          }).toList();
          return AlertDialog(
            title: Text(
              initial == null
                  ? 'Open $_courseTitle allocation'
                  : 'Edit $_courseTitle allocation',
            ),
            content: SizedBox(
              width: 1100,
              height: 640,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: provider.departments.any(
                                (d) => d.id == departmentId,
                          )
                              ? departmentId
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Department / programme',
                          ),
                          items: provider.departments
                              .map(
                                (d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(d.name),
                            ),
                          )
                              .toList(),
                          onChanged: (value) => setModalState(() {
                            departmentId = value;
                            group = null;
                            selected.clear();
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: groups.contains(group) ? group : null,
                          decoration: InputDecoration(
                            labelText: provider.schoolType == 'Pre-tertiary'
                                ? 'Class'
                                : 'Level',
                          ),
                          items: groups
                              .map(
                                (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                              .toList(),
                          onChanged: (value) => setModalState(() {
                            group = value;
                            selected.clear();
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _modalColumn(
                            'Teachers',
                            'Search teachers',
                                (value) =>
                                setModalState(() => teacherSearch = value),
                            ListView(
                              children: teachers
                                  .map(
                                    (teacher) => ListTile(
                                  selected: teacher.id == teacherId,
                                  title: Text(teacher.name),
                                  subtitle: Text(teacher.email),
                                  onTap: () => setModalState(() {
                                    teacherId = teacher.id;
                                    selected.clear();
                                  }),
                                ),
                              )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _modalColumn(
                            'Available $_courseTitle records',
                            'Search $_courseTitle',
                                (value) =>
                                setModalState(() => courseSearch = value),
                            ListView(
                              children: courses
                                  .map(
                                    (course) => ListTile(
                                  title: Text(
                                    '${course.code ?? ''}  ${course.name}',
                                  ),
                                  subtitle: Text(
                                    '${course.department ?? 'All departments'} | ${course.level ?? ''}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                    ),
                                    onPressed:
                                    teacherId == null ||
                                        selected.contains(course.code)
                                        ? null
                                        : () => setModalState(
                                          () => selected.add(
                                        course.code ?? '',
                                      ),
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _modalColumn(
                            'Selected $_courseTitle (${selected.length})',
                            null,
                            null,
                            ListView(
                              children: courses
                                  .where(
                                    (course) => selected.contains(course.code),
                              )
                                  .map(
                                    (course) => ListTile(
                                  title: Text(
                                    '${course.code ?? ''}  ${course.name}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => setModalState(
                                          () => selected.remove(course.code),
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed:
                teacherId == null || departmentId == null || group == null
                    ? null
                    : () async {
                  await _saveModalAllocation(
                    provider,
                    teacherId!,
                    departmentId!,
                    group!,
                    selected,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save assignments'),
              ),
            ],
          );
        },
      ),
    );
    await _load();
  }

  Widget _modalColumn(
      String title,
      String? label,
      ValueChanged<String>? onChanged,
      Widget child,
      ) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        if (label != null) ...[
          const SizedBox(height: 8),
          TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Expanded(child: child),
      ],
    ),
  );

  Future<void> _saveModalAllocation(
      Myprovider provider,
      String teacherId,
      String departmentId,
      String group,
      Set<String> selected,
      ) async {
    final existing = _allocations.where(
          (item) =>
      item['staffId'] == teacherId &&
          item['departmentId'] == departmentId &&
          item['classOrLevel'] == group,
    );
    for (final item in existing) {
      if (!selected.contains(item['courseCode'].toString())) {
        await provider.db
            .collection('courseAllocation')
            .doc(item['id'])
            .delete();
      }
    }
    for (final code in selected) {
      final id =
          '${provider.schoolid}_${teacherId}_${departmentId}_${group}_$code';
      await provider.db.collection('courseAllocation').doc(id).set({
        'id': id,
        'schoolId': provider.schoolid,
        'staffId': teacherId,
        'departmentId': departmentId,
        'classOrLevel': group,
        'courseCode': code,
        'academicYear': provider.year,
        'termOrSemester': _period(provider),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _viewAllocations() async {
    final provider = context.read<Myprovider>();
    String? departmentId;
    String? group;
    String search = '';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final groups = provider.classdata
              .map((item) => item.name)
              .whereType<String>()
              .toSet()
              .toList();
          final records = _allocations.where((item) {
            final text =
            '${item['courseCode']} ${item['courseName']} ${item['staffId']}'
                .toLowerCase();
            return (departmentId == null ||
                item['departmentId'] == departmentId) &&
                (group == null || item['classOrLevel'] == group) &&
                text.contains(search.toLowerCase());
          }).toList();
          return AlertDialog(
            title: Text('View $_courseTitle allocation'),
            content: SizedBox(
              width: 1000,
              height: 600,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: provider.departments.any(
                                (d) => d.id == departmentId,
                          )
                              ? departmentId
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Select department',
                          ),
                          items: provider.departments
                              .map(
                                (d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(d.name),
                            ),
                          )
                              .toList(),
                          onChanged: (value) => setModalState(() {
                            departmentId = value;
                            group = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: groups.contains(group) ? group : null,
                          decoration: InputDecoration(
                            labelText: provider.schoolType == 'Pre-tertiary'
                                ? 'Select class'
                                : 'Select level',
                          ),
                          items: groups
                              .map(
                                (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                              .toList(),
                          onChanged: (value) =>
                              setModalState(() => group = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (value) =>
                              setModalState(() => search = value),
                          decoration: const InputDecoration(
                            labelText: 'Search allocation',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: records.isEmpty
                        ? const Center(
                      child: Text(
                        'Select department and class/level to view assignments.',
                      ),
                    )
                        : ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final item = records[index];
                        return ListTile(
                          title: Text(
                            '${item['courseCode']}  ${item['courseName'] ?? ''}',
                          ),
                          subtitle: Text(
                            'Teacher: ${item['staffId']} | Department: ${item['departmentId']} | ${item['classOrLevel']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Edit allocation',
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  _openAllocationModal(initial: item);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete allocation',
                                onPressed: () async {
                                  final allocationId =
                                      item['id']?.toString() ?? '';
                                  if (allocationId.isEmpty) return;
                                  await provider.db
                                      .collection('courseAllocation')
                                      .doc(allocationId)
                                      .delete();
                                  await _load();
                                  setModalState(() {});
                                },
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('$_courseTitle allocation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.setupWizard),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_courseTitle allocation',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how registered records are assigned to teachers.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openAllocationModal,
                        icon: const Icon(Icons.add_link),
                        label: const Text('Open allocation'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _viewAllocations,
                        icon: const Icon(Icons.table_view_outlined),
                        label: const Text('View allocation'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '${_allocations.length} allocation records saved.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _courseTitle {
    final provider = context.read<Myprovider>();
    return provider.schoolType == 'Pre-tertiary' ? 'Subject' : 'Course';
  }
}