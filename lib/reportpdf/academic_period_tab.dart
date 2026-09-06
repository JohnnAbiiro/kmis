import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';


class AcademicPeriodTab extends StatefulWidget {

  const AcademicPeriodTab({super.key});

  @override
  State<AcademicPeriodTab> createState() => _AcademicPeriodTabState();
}

class _AcademicPeriodTabState extends State<AcademicPeriodTab> {
  bool _loading = true;
  bool _saving = false;
  final _yearCtrl = TextEditingController();
  String? _term;
  static const _terms = ['First Semester', 'Second Semester', 'Third Semester'];

  Myprovider get _provider => context.read<Myprovider>();

  DocumentReference<Map<String, dynamic>> get _doc =>
      _provider.db.collection('schools').doc(_provider.schoolid).collection('settings').doc('academicPeriod');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final snap = await _doc.get();
    final data = snap.data();
    if (!mounted) return;
    setState(() {
      _yearCtrl.text = data?['academicYear']?.toString() ?? _provider.year;
      _term = data?['termOrSemester']?.toString() ?? (_terms.contains(_provider.term) ? _provider.term : _terms.first);
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_yearCtrl.text.trim().isEmpty || _term == null) return;
    setState(() => _saving = true);
    await _doc.set({
      'academicYear': _yearCtrl.text.trim(),
      'termOrSemester': _term,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': '',
    }, SetOptions(merge: true));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Academic period updated')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current academic period', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                TextField(
                  controller: _yearCtrl,
                  decoration: const InputDecoration(labelText: 'Academic year', hintText: 'e.g. 2025/2026', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _term,
                  items: _terms.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  decoration: const InputDecoration(labelText: 'Term / Semester', border: OutlineInputBorder()),
                  onChanged: (v) => setState(() => _term = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save),
                    label: Text(_saving ? 'Saving...' : 'Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    super.dispose();
  }
}
