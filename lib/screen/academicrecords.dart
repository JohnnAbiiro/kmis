import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../controller/routes.dart';

class AcademicRecordsPage extends StatefulWidget {
  const AcademicRecordsPage({super.key});

  @override
  State<AcademicRecordsPage> createState() => _AcademicRecordsPageState();
}

class _AcademicRecordsPageState extends State<AcademicRecordsPage> {
  final List<_ResitRecord> _resits = [
    _ResitRecord(
      'STU-0008',
      'Ama Mensah',
      'Computer Science',
      'CSC 204',
      'Pending',
    ),
    _ResitRecord('STU-0015', 'Kojo Asare', 'Business', 'ACC 112', 'Scheduled'),
  ];
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final records = _filter == 'All'
        ? _resits
        : _resits.where((item) => item.status == _filter).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic records',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          tooltip: 'Back to dashboard',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.dashboard),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: ListView(
              padding: EdgeInsets.all(constraints.maxWidth < 600 ? 16 : 28),
              children: [
                Text(
                  'Results & academic records',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage published results, transcripts, course allocation and resit records.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 22),
                _actionGrid(constraints.maxWidth, colors),
                const SizedBox(height: 24),
                _resitPanel(records, colors),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editResit(),
        icon: const Icon(Icons.add),
        label: const Text('Add resit'),
      ),
    );
  }

  Widget _actionGrid(double width, ColorScheme colors) {
    final actions = [
      _RecordAction(
        'School information',
        'Profile, contact and school identity.',
        Icons.school_outlined,
        Routes.registerschool,
      ),
      _RecordAction(
        'Terminal reports',
        'Generate result sheets for a period.',
        Icons.summarize_outlined,
        Routes.terminalreport,
      ),
      _RecordAction(
        'Transcript',
        'Generate a student academic transcript.',
        Icons.article_outlined,
        Routes.transcript,
      ),
      _RecordAction(
        'Course allocation',
        'Assign courses to teachers and classes.',
        Icons.assignment_ind_outlined,
        Routes.setupteacher,
      ),
      _RecordAction(
        'Term report',
        'Review totals and publish results.',
        Icons.assessment_outlined,
        Routes.termtotal,
      ),
      _RecordAction(
        'Student report',
        'View an individual student report.',
        Icons.person_search_outlined,
        Routes.individualreport,
      ),
    ];
    final columns = width >= 900
        ? 3
        : width >= 560
        ? 2
        : 1;
    final tileWidth = (width - (columns - 1) * 12) / columns;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions
          .map(
            (action) =>
                SizedBox(width: tileWidth, child: _actionTile(action, colors)),
          )
          .toList(),
    );
  }

  Widget _actionTile(_RecordAction action, ColorScheme colors) => Card(
    margin: EdgeInsets.zero,
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: CircleAvatar(
        backgroundColor: colors.secondaryContainer,
        foregroundColor: colors.onSecondaryContainer,
        child: Icon(action.icon),
      ),
      title: Text(
        action.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(action.subtitle),
      trailing: IconButton(
        tooltip: 'Open',
        icon: const Icon(Icons.open_in_new),
        onPressed: () => Navigator.pushNamed(context, action.route),
      ),
    ),
  );

  Widget _resitPanel(List<_ResitRecord> records, ColorScheme colors) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Resit / repeat records',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              DropdownButton<String>(
                value: _filter,
                items: const ['All', 'Pending', 'Scheduled', 'Completed']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _filter = value!),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Track students repeating a course and keep the original result unchanged.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No resit records found.')),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, index) =>
                  _resitRow(records[index], colors),
            ),
        ],
      ),
    ),
  );

  Widget _resitRow(_ResitRecord record, ColorScheme colors) => Card(
    elevation: 0,
    color: colors.surfaceContainerLow,
    child: ListTile(
      leading: CircleAvatar(child: Text(record.name.substring(0, 1))),
      title: Text(
        '${record.name}  •  ${record.course}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('${record.studentId}  •  ${record.department}'),
      trailing: Wrap(
        spacing: 2,
        children: [
          Chip(label: Text(record.status)),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editResit(record),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => setState(() => _resits.remove(record)),
          ),
        ],
      ),
    ),
  );

  Future<void> _editResit([_ResitRecord? existing]) async {
    final studentController = TextEditingController(text: existing?.name ?? '');
    final idController = TextEditingController(text: existing?.studentId ?? '');
    final courseController = TextEditingController(
      text: existing?.course ?? '',
    );
    String status = existing?.status ?? 'Pending';
    final result = await showDialog<_ResitRecord>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existing == null ? 'Add resit record' : 'Edit resit record',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentController,
                decoration: const InputDecoration(labelText: 'Student name'),
              ),
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'Student ID'),
              ),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(
                  labelText: 'Course / subject',
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const ['Pending', 'Scheduled', 'Completed']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => status = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              _ResitRecord(
                idController.text.trim(),
                studentController.text.trim(),
                'Academic department',
                courseController.text.trim(),
                status,
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    studentController.dispose();
    idController.dispose();
    courseController.dispose();
    if (result == null ||
        result.name.isEmpty ||
        result.course.isEmpty ||
        !mounted) {
      return;
    }
    setState(() {
      if (existing == null) {
        _resits.add(result);
      } else {
        final index = _resits.indexOf(existing);
        if (index >= 0) _resits[index] = result;
      }
    });
  }
}

class _RecordAction {
  const _RecordAction(this.title, this.subtitle, this.icon, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

class _ResitRecord {
  _ResitRecord(
    this.studentId,
    this.name,
    this.department,
    this.course,
    this.status,
  );
  final String studentId;
  final String name;
  final String department;
  final String course;
  final String status;
}
