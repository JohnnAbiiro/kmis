import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/dbmodels/contestantsmodel.dart';
import '../controller/dbmodels/coursemountmodel.dart';
import '../controller/dbmodels/coursematerialmodel.dart';
import '../controller/dbmodels/courseregmodel.dart';
import '../controller/dbmodels/departmodel.dart';
import '../controller/myprovider.dart';


class StudentPortalPage extends StatefulWidget {
  final String studentId;
  const StudentPortalPage({super.key, required this.studentId});

  @override
  State<StudentPortalPage> createState() => _StudentPortalPageState();
}

class _StudentPortalPageState extends State<StudentPortalPage> {
  bool _loading = true;
  String? _error;

  StudentModel? _student;
  DepartmentModel? _department;
  CourseMountModel? _mount;
  CourseRegistrationModel? _existingReg;
  List<SubjectLike> _subjects = [];
  Map<String, dynamic>? _resultsDoc;
  List<CourseMaterialModel> _materials = [];

  final Set<String> _selectedElectives = {};
  bool _saving = false;
  int _section = 0; // 0 = Register, 1 = Fees, 2 = Results, 3 = Materials

  Myprovider get _provider => context.read<Myprovider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final provider = _provider;
      final studentSnap = await provider.db.collection('students').doc(widget.studentId).get();
      if (!studentSnap.exists) {
        setState(() {
          _error = 'Student record not found.';
          _loading = false;
        });
        return;
      }
      final student = StudentModel.fromMap({...studentSnap.data()!, 'id': studentSnap.id});

      DepartmentModel? department;
      final deptId = student.departmentid ?? '';
      if (deptId.isNotEmpty) {
        final deptSnap = await provider.db.collection('department').doc(deptId).get();
        if (deptSnap.exists) {
          department = DepartmentModel.fromMap(deptSnap.data()!, deptSnap.id);
        }
      }

      await provider.fetchsubjects();

      final classOrLevel = (student.classname?.isNotEmpty ?? false) ? student.classname! : student.level;
      final mountSnap = await provider.db
          .collection('courseMounting')
          .where('schoolId', isEqualTo: provider.schoolid)
          .where('departmentId', isEqualTo: deptId)
          .where('classOrLevel', isEqualTo: classOrLevel)
          .where('academicYear', isEqualTo: provider.year)
          .where('termOrSemester', isEqualTo: provider.term)
          .limit(1)
          .get();
      CourseMountModel? mount;
      if (mountSnap.docs.isNotEmpty) {
        mount = CourseMountModel.fromMap({...mountSnap.docs.first.data(), 'id': mountSnap.docs.first.id});
      }

      final regId = '${provider.schoolid}_${student.id}_${provider.year}_${provider.term}';
      final regSnap = await provider.db.collection('coursereg').doc(regId).get();
      CourseRegistrationModel? existingReg;
      if (regSnap.exists) {
        existingReg = CourseRegistrationModel.fromMap(regSnap.data()!);
      }

      final subjects = provider.subjectList
          .where((s) => mount?.allCourseCodes.contains(s.code) ?? false)
          .map((s) => SubjectLike(code: s.code ?? '', name: s.name, creditHours: s.creditHours, type: s.type))
          .toList();

      Map<String, dynamic>? resultsDoc;
      final scoringId = '${student.id}_${provider.academicyrid}_${provider.term}';
      final scoringSnap = await provider.db.collection('subjectScoring').doc(scoringId).get();
      if (scoringSnap.exists) resultsDoc = scoringSnap.data();

      final registeredCodes = existingReg?.courseCodes ?? const <String>[];
      List<CourseMaterialModel> materials = [];
      if (registeredCodes.isNotEmpty) {
        final materialsSnap = await provider.db
            .collection('courseMaterials')
            .where('schoolId', isEqualTo: provider.schoolid)
            .where('courseCode', whereIn: registeredCodes.take(30).toList())
            .orderBy('timestamp', descending: true)
            .get();
        materials = materialsSnap.docs.map((d) => CourseMaterialModel.fromMap(d.data())).toList();
      }

      if (!mounted) return;
      setState(() {
        _student = student;
        _department = department;
        _mount = mount;
        _existingReg = existingReg;
        _subjects = subjects;
        _resultsDoc = resultsDoc;
        _materials = materials;
        _selectedElectives
          ..clear()
          ..addAll(existingReg?.courseCodes.where((c) => mount?.electiveCourseCodes.contains(c) ?? false) ?? const []);
        _loading = false;
      });

      if (mount != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showMountedCoursesModal(mount!));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your portal: $e';
        _loading = false;
      });
    }
  }

  List<SubjectLike> get _coreSubjects => _subjects.where((s) => s.type == 'Core').toList();

  List<SubjectLike> get _electiveSubjects => _subjects.where((s) => s.type != 'Core').toList();

  double get _coreCredits => _coreSubjects.fold(0.0, (a, s) => a + s.creditHours);

  double get _electiveCredits =>
      _electiveSubjects.where((s) => _selectedElectives.contains(s.code)).fold(0.0, (a, s) => a + s.creditHours);

  double get _totalCredits => _coreCredits + _electiveCredits;

  double get _minCredits => (_department?.minCreditHours ?? 0).toDouble();

  double get _maxCredits => (_department?.maxCreditHours ?? 999).toDouble();

  bool get _creditsValid => _totalCredits >= _minCredits && _totalCredits <= _maxCredits;

  bool get _registrationOpen => _mount?.isRegistrationOpen ?? false;

  bool get _canEdit => _mount != null && _registrationOpen;


  void _showMountedCoursesModal(CourseMountModel mount) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Courses mounted this term'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${mount.classOrLevel} • ${mount.termOrSemester} ${mount.academicYear}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _subjects.length,
                  itemBuilder: (context, i) {
                    final s = _subjects[i];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        s.type == 'Core' ? Icons.push_pin_outlined : Icons.list_alt_outlined,
                        color: scheme.primary,
                      ),
                      title: Text(s.name),
                      subtitle: Text('${s.code} • ${s.creditHours.toStringAsFixed(1)} credit hrs • ${s.type}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _toggleElective(String code, bool checked) {
    if (!_canEdit) return;
    setState(() {
      if (checked) {
        _selectedElectives.add(code);
      } else {
        _selectedElectives.remove(code);
      }
    });
  }

  Future<void> _saveRegistration() async {
    final student = _student;
    final mount = _mount;
    if (student == null || mount == null || _saving) return;
    if (!_canEdit) {
      _showSnack('Registration is closed for this term.', isError: true);
      return;
    }
    if (!_creditsValid) {
      _showSnack('Selected credit hours must be between $_minCredits and $_maxCredits.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final provider = _provider;
      final id = '${provider.schoolid}_${student.id}_${provider.year}_${provider.term}';
      final model = CourseRegistrationModel(
        id: id,
        schoolId: provider.schoolid,
        studentId: student.id,
        facultyId: mount.facultyId,
        departmentId: mount.departmentId,
        classOrLevel: mount.classOrLevel,
        academicYear: provider.year,
        termOrSemester: provider.term,
        courseCodes: [...mount.coreCourseCodes, ..._selectedElectives],
        totalCredits: _totalCredits,
      );
      await provider.db.collection('coursereg').doc(id).set(model.toMap(), SetOptions(merge: true));
      if (!mounted) return;
      setState(() => _existingReg = model);
      _showSnack('Course registration saved.');
    } catch (e) {
      _showSnack('Could not save registration: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? scheme.error : scheme.primary,
      ),
    );
  }

  Future<void> _submitMomoPayment({required String network, required String phone, required String amount}) async {
    final student = _student;
    if (student == null) return;
    try {
      final provider = _provider;
      await provider.db.collection('payments').add({
        'schoolId': provider.schoolid,
        'studentId': student.id,
        'method': 'momo',
        'network': network,
        'phone': phone,
        'amount': amount,
        'status': 'pending',
        'academicYear': provider.year,
        'termOrSemester': provider.term,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _showSnack('Payment request submitted. Approve the prompt on your phone.');
    } catch (e) {
      _showSnack('Could not submit payment: $e', isError: true);
    }
  }

  Future<void> _openMaterial(CourseMaterialModel m) async {
    final uri = Uri.tryParse(m.fileUrl);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnack('Could not open file.', isError: true);
    }
  }

  // ---- build -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Student Portal'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, style: TextStyle(color: scheme.error)),
        ),
      )
          : LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 800;
          final content = _sectionBody(scheme);
          if (!wide) {
            return content;
          }
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _section,
                onDestinationSelected: (i) => setState(() => _section = i),
                labelType: NavigationRailLabelType.all,
                backgroundColor: scheme.surfaceContainerLow,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.menu_book_outlined), label: Text('Register')),
                  NavigationRailDestination(icon: Icon(Icons.payments_outlined), label: Text('Fees')),
                  NavigationRailDestination(icon: Icon(Icons.grade_outlined), label: Text('Results')),
                  NavigationRailDestination(icon: Icon(Icons.folder_outlined), label: Text('Materials')),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: content),
            ],
          );
        },
      ),
      bottomNavigationBar: (_loading || _error != null || MediaQuery.of(context).size.width > 800)
          ? null
          : NavigationBar(
        selectedIndex: _section,
        onDestinationSelected: (i) => setState(() => _section = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Register'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Fees'),
          NavigationDestination(icon: Icon(Icons.grade_outlined), label: 'Results'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), label: 'Materials'),
        ],
      ),
    );
  }

  Widget _sectionBody(ColorScheme scheme) {
    switch (_section) {
      case 1:
        return _feesSection(scheme);
      case 2:
        return _resultsSection(scheme);
      case 3:
        return _materialsSection(scheme);
      default:
        return _registrationSection(scheme);
    }
  }

  // ---- Registration section -----------------------------------------

  Widget _registrationSection(ColorScheme scheme) {
    final student = _student;
    final mount = _mount;
    if (student == null || mount == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No courses have been mounted for your class this term yet.',
              style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: scheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${mount.classOrLevel} • ${mount.termOrSemester} ${mount.academicYear}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                const SizedBox(height: 8),
                Text(
                  'Credit hours: ${_totalCredits.toStringAsFixed(1)} / min $_minCredits, max $_maxCredits',
                  style: TextStyle(color: _creditsValid ? scheme.primary : scheme.error, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  _registrationOpen
                      ? (mount.regEndDate != null
                      ? 'Registration open until ${_formatDate(mount.regEndDate!)}.'
                      : 'Registration is open.')
                      : 'Registration is closed for this term.',
                  style: TextStyle(color: _registrationOpen ? scheme.onSurfaceVariant : scheme.error),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Core courses (auto-selected)', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
        const SizedBox(height: 6),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _coreSubjects.length,
          itemBuilder: (context, i) {
            final s = _coreSubjects[i];
            return CheckboxListTile(
              value: true,
              onChanged: null,
              title: Text(s.name),
              subtitle: Text('${s.code} • ${s.creditHours.toStringAsFixed(1)} credit hrs'),
            );
          },
        ),
        const SizedBox(height: 16),
        Text('Elective courses', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
        const SizedBox(height: 6),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _electiveSubjects.length,
          itemBuilder: (context, i) {
            final s = _electiveSubjects[i];
            final checked = _selectedElectives.contains(s.code);
            final wouldExceedMax = !checked && (_totalCredits + s.creditHours) > _maxCredits;
            return CheckboxListTile(
              value: checked,
              onChanged: (!_canEdit || wouldExceedMax) && !checked ? null : (v) => _toggleElective(s.code, v ?? false),
              title: Text(s.name),
              subtitle: Text('${s.code} • ${s.creditHours.toStringAsFixed(1)} credit hrs'),
            );
          },
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: (!_canEdit || !_creditsValid || _saving) ? null : _saveRegistration,
            icon: _saving
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onPrimary))
                : const Icon(Icons.save),
            label: Text(_existingReg == null ? 'Register courses' : 'Update registration'),
          ),
        ),
      ],
    );
  }

  // ---- Fees section ------------------------------------------------

  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  String _network = 'MTN';

  Widget _feesSection(ColorScheme scheme) {
    final student = _student;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: scheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('School fees', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                const SizedBox(height: 8),
                Text(
                  (student?.nextfees?.isNotEmpty ?? false)
                      ? 'Amount due: ${student!.nextfees}'
                      : 'No outstanding balance on file.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Pay with Mobile Money', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _network,
          decoration: const InputDecoration(labelText: 'Network', border: OutlineInputBorder()),
          items: const ['MTN', 'Vodafone', 'AirtelTigo']
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: (v) => setState(() => _network = v ?? 'MTN'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Mobile money number', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (GHS)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: _phoneController.text.trim().isEmpty || _amountController.text.trim().isEmpty
                  ? null
                  : () => _submitMomoPayment(
                network: _network,
                phone: _phoneController.text.trim(),
                amount: _amountController.text.trim(),
              ),
              icon: const Icon(Icons.payment),
              label: const Text('Pay with MoMo'),
            ),
            OutlinedButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('MoMo shortcut'),
                  content: const Text('Dial *170# on your phone and follow the prompts to pay your school fees.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
                  ],
                ),
              ),
              icon: const Icon(Icons.dialpad),
              label: const Text('Use MoMo shortcut'),
            ),
          ],
        ),
      ],
    );
  }

  // ---- Results section --------------------------------------------

  Widget _resultsSection(ColorScheme scheme) {
    final doc = _resultsDoc;
    final subjects = (doc?['subjects'] as Map<String, dynamic>?) ?? {};
    final rows = subjects.values
        .map((v) => Map<String, dynamic>.from(v as Map))
        .where((row) => row['isRegistered'] != false)
        .toList();

    if (rows.isEmpty) {
      return Center(
        child: Text('No results available yet.', style: TextStyle(color: scheme.onSurfaceVariant)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        final isComplete = row['isComplete']?.toString() == 'yes';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('${row['code'] ?? ''}  ${row['subjectName'] ?? ''}'),
            subtitle: Text('CA: ${row['CA'] ?? '0'} • Exams: ${row['Exams'] ?? '0'} • Total: ${row['totalScore'] ?? '0'}'),
            trailing: Chip(
              label: Text(isComplete ? 'Complete' : 'Pending'),
              backgroundColor: isComplete ? scheme.primaryContainer : scheme.surfaceContainerHighest,
            ),
          ),
        );
      },
    );
  }

  // ---- Materials section --------------------------------------------

  Widget _materialsSection(ColorScheme scheme) {
    if (_materials.isEmpty) {
      return Center(
        child: Text('No course materials available yet.', style: TextStyle(color: scheme.onSurfaceVariant)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _materials.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final m = _materials[i];
        return Card(
          child: ListTile(
            leading: Icon(Icons.description_outlined, color: scheme.primary),
            title: Text('${m.courseCode}  ${m.title}'),
            subtitle: Text('${m.fileName} • by ${m.staffName}'),
            trailing: IconButton(icon: const Icon(Icons.download), onPressed: () => _openMaterial(m)),
            onTap: () => _openMaterial(m),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

class SubjectLike {
  final String code;
  final String name;
  final double creditHours;
  final String type;
  const SubjectLike({required this.code, required this.name, required this.creditHours, required this.type});
}
