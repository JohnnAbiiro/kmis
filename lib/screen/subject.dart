import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
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
  String _type = 'Core';
  String _scope = 'Single department';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<Myprovider>();
      provider.fetchclass();
      provider.fetchdepart();
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
    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, provider, _) => Scaffold(
          appBar: AppBar(
            title: Text(
              widget.subject == null
                  ? 'Register course / subject'
                  : 'Edit course / subject',
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(
                      constraints.maxWidth < 600 ? 16 : 28,
                    ),
                    children: [
                      _text(_name, 'Course / subject name', required: true),
                      const SizedBox(height: 14),
                      _text(_code, 'Course code', required: true),
                      const SizedBox(height: 14),
                      _dropdown(
                        'Department',
                        _department,
                        provider.departments.map((item) => item.name).toList(),
                            (value) => setState(() => _department = value),
                        required: true,
                      ),
                      const SizedBox(height: 14),
                      _dropdown(
                        'Level / class',
                        _level,
                        provider.classdata.map((item) => item.name).toList(),
                            (value) => setState(() => _level = value),
                        required: true,
                      ),
                      const SizedBox(height: 14),
                      _fieldGrid([
                        _text(_weight, 'Weight', decimal: true),
                        _text(_hours, 'Credit hours', decimal: true),
                        _text(_minHours, 'Credit hours min', decimal: true),
                        _text(_maxHours, 'Credit hours max', decimal: true),
                      ]),
                      const SizedBox(height: 14),
                      _fieldGrid([
                        _dropdown(
                          'Course type',
                          _type,
                          const ['Core', 'Elective'],
                              (value) => setState(() => _type = value!),
                        ),
                        _dropdown('Scope', _scope, const [
                          'Single department',
                          'All departments',
                        ], (value) => setState(() => _scope = value!)),
                      ]),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: () => _save(provider),
                        icon: const Icon(Icons.save),
                        label: Text(
                          widget.subject == null
                              ? 'Register course'
                              : 'Update course',
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => context.go(Routes.viewsubjects),
                        icon: const Icon(Icons.list),
                        label: const Text('View courses'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _text(
      TextEditingController controller,
      String label, {
        bool required = false,
        bool decimal = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
          ? '$label is required'
          : null
          : null,
    );
  }

  Widget _dropdown(
      String label,
      String? value,
      List<String> items,
      ValueChanged<String?> onChanged, {
        bool required = false,
      }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: required
          ? (selected) => selected == null ? '$label is required' : null
          : null,
    );
  }

  Widget _fieldGrid(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: fields
            .map(
              (field) => SizedBox(
            width: constraints.maxWidth < 520
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2,
            child: field,
          ),
        )
            .toList(),
      ),
    );
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim());

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
        const SnackBar(
          content: Text(
            'Credit hours must be valid and within the minimum and maximum.',
          ),
        ),
      );
      return;
    }

    final code =
    _code.text.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final id = widget.subject?.id ?? code;
    final progress = ProgressHUD.of(context);
    progress?.show();

    await provider.db.collection('subjects').doc(id).set(
      SubjectModel(
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
      ).toMap(),
      SetOptions(merge: true),
    );

    progress?.dismiss();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course saved successfully')),
      );
    }
  }
}