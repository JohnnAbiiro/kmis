import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/subjectmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class SubjectRegistration extends StatefulWidget {
  final SubjectModel? subject;
  const SubjectRegistration({super.key, this.subject});

  @override
  State<SubjectRegistration> createState() => _SubjectRegistrationState();
}

class _SubjectRegistrationState extends State<SubjectRegistration> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _weight = TextEditingController(text: '1');
  final _hours = TextEditingController();
  final _minHours = TextEditingController(text: '0');
  final _maxHours = TextEditingController(text: '30');
  String? _level;
  String? _department;
  String? _faculty;
  String _type = 'Core';
  String _scope = 'Single department';
  List<String> _facultyEntries = [];
  Map<String, String> _departmentFaculties = {};

  bool _isSaving = false;
  bool _isLoadingOptions = true;

  @override
  void initState() {
    super.initState();
    final data = widget.subject;
    if (data != null) {
      _name.text = data.name;
      _code.text = data.code ?? '';
      _level = data.level;
      _department = data.department;
      _weight.text = data.weight.toString();
      _hours.text = data.creditHours.toString();
      _minHours.text = data.creditHourMin.toString();
      _maxHours.text = data.creditHourMax.toString();
      _type = data.type;
      _scope = data.scope;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<Myprovider>();
      await Future.wait([
        provider.fetchclass(),
        provider.fetchdepart(),
      ]);
      await _loadFaculties(provider);
      if (mounted) setState(() => _isLoadingOptions = false);
    });
  }

  Future<void> _loadFaculties(Myprovider provider) async {
    final schoolId = provider.schoolid.trim();
    if (schoolId.isEmpty) return;
    final results = await Future.wait([
      provider.db.collection('faculties').where('schoolId', isEqualTo: schoolId).get(),
      provider.db.collection('department').where('schoolId', isEqualTo: schoolId).get(),
    ]);
    if (!mounted) return;
    final departmentFaculties = <String, String>{};
    for (final doc in results[1].docs) {
      final entry = doc.data();
      departmentFaculties[entry['name'].toString()] = entry['faculty']?.toString() ?? '';
    }
    setState(() {
      _facultyEntries = results[0].docs.map((doc) => (doc.data())['name'].toString()).toSet().toList();
      _departmentFaculties = departmentFaculties;
      _faculty ??= _departmentFaculties[_department];
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _weight.dispose();
    _hours.dispose();
    _minHours.dispose();
    _maxHours.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.subject != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<Myprovider>(
      builder: (context, provider, _) {
        final departmentOptions = provider.departments
            .map((item) => item.name)
            .where((name) => _faculty == null || _departmentFaculties[name] == _faculty)
            .toSet()
            .toList();

        return Scaffold(
          // No explicit backgroundColor — inherits scaffoldBackgroundColor
          // from the app's light/dark theme in main.dart.
          appBar: AppBar(
            title: Text(isEdit ? 'Edit course / subject' : 'Register course / subject'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.dashboard);
                }
              },
            ),
          ),
          body: _isLoadingOptions
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
            builder: (context, constraints) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth < 600 ? 12 : 24,
                      vertical: 20,
                    ),
                    children: [
                      _sectionCard(
                        title: 'Basic details',
                        icon: Icons.menu_book_outlined,
                        children: [
                          _text(_name, 'Course / subject name', icon: Icons.badge_outlined, required: true),
                          const SizedBox(height: 14),
                          _text(_code, 'Course code', icon: Icons.qr_code_2, required: true),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: 'Classification',
                        icon: Icons.account_tree_outlined,
                        children: [
                          _dropdown(
                            'Faculty',
                            Icons.account_balance_outlined,
                            _faculty,
                            _facultyEntries,
                                (value) => setState(() {
                              _faculty = value;
                              if (_department != null && _departmentFaculties[_department] != _faculty) {
                                _department = null;
                              }
                            }),
                            required: true,
                          ),
                          const SizedBox(height: 14),
                          _dropdown(
                            'Department',
                            Icons.apartment_outlined,
                            _department,
                            departmentOptions,
                                (value) => setState(() {
                              _department = value;
                              _faculty = _departmentFaculties[value] ?? _faculty;
                            }),
                            required: true,
                          ),
                          const SizedBox(height: 14),
                          _dropdown(
                            'Level / class',
                            Icons.stairs_outlined,
                            _level,
                            provider.classdata.map((item) => item.name).toList(),
                                (value) => setState(() => _level = value),
                            required: true,
                          ),
                          const SizedBox(height: 14),
                          _fieldGrid([
                            _dropdown('Course type', Icons.category_outlined, _type, const ['Core', 'Elective'],
                                    (value) => setState(() => _type = value!)),
                            _dropdown(
                                'Scope',
                                Icons.share_outlined,
                                _scope,
                                const ['Single department', 'All departments'],
                                    (value) => setState(() => _scope = value!)),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: 'Weight & credit hours',
                        icon: Icons.scale_outlined,
                        children: [
                          _fieldGrid([
                            _text(_weight, 'Weight', icon: Icons.scale_outlined, decimal: true),
                            _text(_hours, 'Credit hours', icon: Icons.timer_outlined, decimal: true),
                            _text(_minHours, 'Credit hours min', icon: Icons.south_outlined, decimal: true),
                            _text(_maxHours, 'Credit hours max', icon: Icons.north_outlined, decimal: true),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : () => _save(provider),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isSaving
                            ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                        )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving ? 'Saving...' : (isEdit ? 'Update course' : 'Register course'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => context.go(Routes.viewsubjects),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.list),
                        label: const Text('View courses'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold) ??
                      TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _text(
      TextEditingController controller,
      String label, {
        IconData? icon,
        bool required = false,
        bool decimal = false,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: decimal ? const TextInputType.numberWithOptions(decimal: true) : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20, color: colorScheme.onSurfaceVariant) : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      validator: required
          ? (value) => value == null || value.trim().isEmpty ? '$label is required' : null
          : null,
    );
  }

  Widget _dropdown(
      String label,
      IconData icon,
      String? value,
      List<String> items,
      ValueChanged<String?> onChanged, {
        bool required = false,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      dropdownColor: colorScheme.surface,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: required ? (selected) => selected == null ? '$label is required' : null : null,
    );
  }

  Widget _fieldGrid(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: fields
            .map((field) => SizedBox(
          width: constraints.maxWidth < 480 ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
          child: field,
        ))
            .toList(),
      ),
    );
  }

  double? _parse(TextEditingController controller) => double.tryParse(controller.text.trim());

  Future<void> _save(Myprovider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final weight = _parse(_weight);
    final hours = _parse(_hours);
    final minHours = _parse(_minHours);
    final maxHours = _parse(_maxHours);

    final isValid = weight != null &&
        hours != null &&
        minHours != null &&
        maxHours != null &&
        minHours <= maxHours &&
        hours >= minHours &&
        hours <= maxHours;

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credit hours must be valid and within the minimum and maximum.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final code = _code.text.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
      final id = '${provider.schoolid}_$code';

      if (widget.subject != null && widget.subject!.id != id) {
        await provider.db.collection('subjects').doc(widget.subject!.id).delete();
        provider.removeSubjectLocal(widget.subject!.id);
      }

      final subject = SubjectModel(
        id: id,
        name: _name.text.trim(),
        code: code,
        department: _department,
        level: _level,
        weight: weight,
        creditHours: hours,
        creditHourMin: minHours,
        creditHourMax: maxHours,
        type: _type,
        scope: _scope,
        staff: provider.name,
        schoolId: provider.schoolid,
      );

      final data = subject.toMap();
      data['code'] = code;
      data['faculty'] = _faculty; // not on SubjectModel yet — persisted directly

      await provider.db.collection('subjects').doc(id).set(data, SetOptions(merge: true));

      // Update the local list immediately instead of a full refetch.
      provider.upsertSubjectLocal(subject);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course saved successfully'), backgroundColor: Colors.green),
      );
      context.go(Routes.viewsubjects);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}