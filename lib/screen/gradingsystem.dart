// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
//
// import '../controller/dbmodels/grademodel.dart';
// import '../controller/dbmodels/gradingmodel.dart';
// import '../controller/myprovider.dart';
// import '../controller/routes.dart';
//
// class GradingSystemFormPage extends StatefulWidget {
//   final bool embedded;
//   const GradingSystemFormPage({super.key, this.embedded = false});
//
//   @override
//   State<GradingSystemFormPage> createState() => _GradingSystemFormPageState();
// }
//
// class _GradingSystemFormPageState extends State<GradingSystemFormPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   bool _loading = true;
//   bool _saving = false;
//   String? _deletingId;
//   bool _locked = false;
//
//   List<GradingModel> _scales = [];
//   GradingModel? _editing;
//
//   bool _isDefault = true;
//   String? _selectedFaculty;
//   String? _selectedDepartmentId;
//   List<Map<String, String>> _bands = [];
//
//   bool get _busy => _saving || _deletingId != null;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _init());
//   }
//
//   Future<void> _init() async {
//     final provider = context.read<Myprovider>();
//     try {
//       await Future.wait([provider.fetchdepart(), _checkLock()]);
//       await _loadScales();
//       _resetForm();
//     } catch (e) {
//       _toast('Could not load grading data: $e', error: true);
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }
//
//   Future<void> _checkLock() async {
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     if (schoolId.isEmpty) return;
//     final doc = await provider.db.collection('schools').doc(schoolId).get();
//     if (mounted) {
//       setState(() => _locked = doc.data()?['setupCompleted'] == true);
//     }
//   }
//
//   Future<void> _loadScales() async {
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     if (schoolId.isEmpty) return;
//     final snapshot = await provider.db
//         .collection('gradingsystems')
//         .where('schoolId', isEqualTo: schoolId)
//         .get();
//     if (!mounted) return;
//     setState(() {
//       _scales = snapshot.docs
//           .map((d) => GradingModel.fromMap({...d.data(), 'id': d.id}))
//           .toList()
//         ..sort((a, b) =>
//         a.isDefault == b.isDefault ? a.name.compareTo(b.name) : (a.isDefault ? -1 : 1));
//     });
//   }
//
//   static List<Map<String, String>> _defaultBands() => [
//     {'min': '0', 'max': '49.9', 'grade': 'F', 'weight': '0', 'remarks': 'Needs improvement'},
//     {'min': '50', 'max': '59.9', 'grade': 'C', 'weight': '1', 'remarks': 'Satisfactory'},
//     {'min': '60', 'max': '69.9', 'grade': 'B', 'weight': '2', 'remarks': 'Good'},
//     {'min': '70', 'max': '100', 'grade': 'A', 'weight': '3', 'remarks': 'Excellent'},
//   ];
//
//   void _resetForm() {
//     _editing = null;
//     _isDefault = true;
//     _selectedFaculty = null;
//     _selectedDepartmentId = null;
//     _bands = _defaultBands().map((e) => {...e}).toList();
//   }
//
//   void _loadIntoForm(GradingModel scale) {
//     final provider = context.read<Myprovider>();
//     setState(() {
//       _editing = scale;
//       _isDefault = scale.isDefault;
//       _selectedDepartmentId = scale.departmentId;
//       if (!scale.isDefault && scale.departmentId != null) {
//         final dept = provider.departments.where((d) => d.id == scale.departmentId);
//         _selectedFaculty = dept.isNotEmpty ? dept.first.faculty : null;
//       } else {
//         _selectedFaculty = null;
//       }
//       _bands = scale.bands
//           .map((b) => {
//         'min': _fmt(b.min),
//         'max': _fmt(b.max),
//         'grade': b.grade,
//         'weight': _fmt(b.weight),
//         'remarks': b.remarks,
//       })
//           .toList();
//     });
//   }
//
//   String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
//
//   List<GradeBand>? _parsedBands() {
//     try {
//       return _bands
//           .map((b) => GradeBand(
//         min: double.parse(b['min']!.trim()),
//         max: double.parse(b['max']!.trim()),
//         grade: b['grade']!.trim().toUpperCase(),
//         weight: double.parse(b['weight']!.trim()),
//         remarks: b['remarks']!.trim(),
//       ))
//           .toList();
//     } catch (_) {
//       return null;
//     }
//   }
//
//   String? get _validationMessage {
//     final parsed = _parsedBands();
//     if (parsed == null) return 'Fill in every band with valid numbers before saving.';
//     return GradingModel.validate(parsed);
//   }
//
//   Future<void> _save() async {
//     if (_locked || _busy) return;
//     if (!_isDefault && _selectedDepartmentId == null) {
//       _toast('Select a department for this scale.', error: true);
//       return;
//     }
//     final error = _validationMessage;
//     if (error != null) {
//       _toast(error, error: true);
//       return;
//     }
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     if (schoolId.isEmpty) {
//       _toast('Missing school id — cannot save.', error: true);
//       return;
//     }
//
//     setState(() => _saving = true);
//     try {
//       final bands = _parsedBands()!;
//       final id = GradingModel.buildId(
//         schoolId,
//         isDefault: _isDefault,
//         departmentId: _selectedDepartmentId,
//       );
//       // If we were editing an existing scale under a different id (e.g. it
//       // changed from default -> department), drop the stale document.
//       if (_editing != null && _editing!.id != id) {
//         await provider.db.collection('gradingsystems').doc(_editing!.id).delete();
//       }
//       final deptName = _isDefault
//           ? null
//           : provider.departments
//           .where((d) => d.id == _selectedDepartmentId)
//           .map((d) => d.name)
//           .firstOrNull;
//       final model = GradingModel(
//         id: id,
//         schoolId: schoolId,
//         scope: _isDefault ? 'default' : 'department',
//         departmentId: _isDefault ? null : _selectedDepartmentId,
//         facultyName: _isDefault ? null : _selectedFaculty,
//         name: _isDefault ? 'School default' : (deptName ?? 'Department'),
//         bands: bands,
//         staff: provider.name,
//       );
//       await provider.db.collection('gradingsystems').doc(id).set({
//         ...model.toMap(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//
//       await _loadScales();
//       if (!mounted) return;
//       setState(_resetForm);
//       _toast('Grading scale saved.');
//     } catch (e) {
//       _toast('Could not save: $e', error: true);
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   Future<void> _delete(GradingModel scale) async {
//     if (_locked || _busy) return;
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete grading scale?'),
//         content: Text('Remove "${scale.name}" permanently?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//
//     setState(() => _deletingId = scale.id);
//     try {
//       final provider = context.read<Myprovider>();
//       await provider.db.collection('gradingsystems').doc(scale.id).delete();
//       if (_editing?.id == scale.id) _resetForm();
//       await _loadScales();
//       _toast('Grading scale deleted.');
//     } catch (e) {
//       _toast('Could not delete: $e', error: true);
//     } finally {
//       if (mounted) setState(() => _deletingId = null);
//     }
//   }
//
//   void _toast(String message, {bool error = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(message),
//       backgroundColor: error ? Colors.red : Colors.green,
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final content = _loading
//         ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
//         : Stack(
//       children: [
//         SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (_locked) _lockedBanner(),
//               if (_locked) const SizedBox(height: 16),
//               AbsorbPointer(
//                 absorbing: _busy,
//                 child: Opacity(opacity: _busy ? 0.6 : 1, child: _formCard()),
//               ),
//               const SizedBox(height: 20),
//               AbsorbPointer(
//                 absorbing: _busy,
//                 child: Opacity(opacity: _busy ? 0.6 : 1, child: _scalesList()),
//               ),
//             ],
//           ),
//         ),
//         if (_busy)
//           Positioned.fill(
//             child: IgnorePointer(
//               ignoring: true,
//               child: Align(
//                 alignment: Alignment.topCenter,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 16),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.black87,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation(Colors.white),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Text(
//                           _saving ? 'Saving grading scale...' : 'Deleting grading scale...',
//                           style: const TextStyle(color: Colors.white, fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//
//     if (widget.embedded) return content;
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF00273a),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => context.go(Routes.dashboard),
//         ),
//         title: const Text('Grading scales', style: TextStyle(color: Colors.white)),
//       ),
//       body: content,
//     );
//   }
//
//   Widget _lockedBanner() => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: Colors.orange.withOpacity(.12),
//       borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: Colors.orange),
//     ),
//     child: const Row(
//       children: [
//         Icon(Icons.lock_outline, color: Colors.orange),
//         SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Setup is locked. Grading scales are view-only until an administrator unlocks it.',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _formCard() {
//     final scheme = Theme.of(context).colorScheme;
//     final provider = context.watch<Myprovider>();
//     final faculties = provider.faculties;
//     final departments = provider.departments
//         .where((d) => _selectedFaculty == null || d.faculty == _selectedFaculty)
//         .toList();
//     final error = _validationMessage;
//
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         border: Border.all(color: scheme.outlineVariant),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.rule_folder_outlined, color: scheme.primary),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     _editing == null ? 'New grading scale' : 'Edit "${_editing!.name}"',
//                     style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
//                   ),
//                 ),
//                 if (_editing != null)
//                   TextButton(
//                     onPressed: _locked || _busy ? null : () => setState(_resetForm),
//                     child: const Text('New scale'),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 14),
//
//             // Default vs department toggle
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: scheme.outlineVariant),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 children: [
//                   _scopeTab('Default (school-wide)', _isDefault, () {
//                     if (_locked || _busy) return;
//                     setState(() {
//                       _isDefault = true;
//                       _selectedDepartmentId = null;
//                       _selectedFaculty = null;
//                     });
//                   }),
//                   _scopeTab('Department scale', !_isDefault, () {
//                     if (_locked || _busy) return;
//                     setState(() => _isDefault = false);
//                   }),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 14),
//
//             if (!_isDefault) ...[
//               Row(
//                 children: [
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       initialValue: faculties.any((f) => f.name == _selectedFaculty) ? _selectedFaculty : null,
//                       decoration: const InputDecoration(labelText: 'Faculty (optional filter)'),
//                       items: faculties
//                           .map((f) => DropdownMenuItem(value: f.name, child: Text(f.name)))
//                           .toList(),
//                       onChanged: _locked || _busy
//                           ? null
//                           : (value) => setState(() {
//                         _selectedFaculty = value;
//                         if (_selectedDepartmentId != null &&
//                             !departments.any((d) => d.id == _selectedDepartmentId)) {
//                           _selectedDepartmentId = null;
//                         }
//                       }),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       initialValue: departments.any((d) => d.id == _selectedDepartmentId)
//                           ? _selectedDepartmentId
//                           : null,
//                       decoration: const InputDecoration(labelText: 'Department'),
//                       items: departments
//                           .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
//                           .toList(),
//                       onChanged: _locked || _busy
//                           ? null
//                           : (value) => setState(() => _selectedDepartmentId = value),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 14),
//             ],
//
//             Row(
//               children: [
//                 const Expanded(
//                   child: Text('Grade bands', style: TextStyle(fontWeight: FontWeight.w700)),
//                 ),
//                 OutlinedButton.icon(
//                   onPressed: _locked || _busy
//                       ? null
//                       : () => setState(() => _bands.add({
//                     'min': '',
//                     'max': '',
//                     'grade': '',
//                     'weight': '',
//                     'remarks': '',
//                   })),
//                   icon: const Icon(Icons.add, size: 17),
//                   label: const Text('Add band'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ..._bands.asMap().entries.map((entry) => _bandRow(entry.key, entry.value)),
//
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 Icon(error == null ? Icons.check_circle_outline : Icons.error_outline,
//                     size: 16, color: error == null ? Colors.green : Colors.red),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     error ?? 'Bands are valid — no overlapping ranges.',
//                     style: TextStyle(fontSize: 12, color: error == null ? Colors.green : Colors.red),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Align(
//               alignment: Alignment.centerRight,
//               child: FilledButton.icon(
//                 onPressed: _locked || _busy ? null : _save,
//                 icon: _saving
//                     ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                 )
//                     : const Icon(Icons.save),
//                 label: Text(_saving ? 'Saving...' : (_editing == null ? 'Save scale' : 'Update scale')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _scopeTab(String label, bool selected, VoidCallback onTap) {
//     final scheme = Theme.of(context).colorScheme;
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: selected ? scheme.primaryContainer : Colors.transparent,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           alignment: Alignment.center,
//           child: Text(
//             label,
//             style: TextStyle(
//               fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
//               color: selected ? scheme.primary : scheme.onSurfaceVariant,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _bandRow(int index, Map<String, String> band) {
//     final scheme = Theme.of(context).colorScheme;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: TextFormField(
//               key: ValueKey('min_$index${band['min']}'),
//               initialValue: band['min'],
//               enabled: !_locked && !_busy,
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               decoration: const InputDecoration(labelText: 'Min', isDense: true),
//               onChanged: (v) => band['min'] = v,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: TextFormField(
//               key: ValueKey('max_$index${band['max']}'),
//               initialValue: band['max'],
//               enabled: !_locked && !_busy,
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               decoration: const InputDecoration(labelText: 'Max', isDense: true),
//               onChanged: (v) => band['max'] = v,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: TextFormField(
//               key: ValueKey('grade_$index${band['grade']}'),
//               initialValue: band['grade'],
//               enabled: !_locked && !_busy,
//               textCapitalization: TextCapitalization.characters,
//               decoration: const InputDecoration(labelText: 'Grade', isDense: true),
//               onChanged: (v) => band['grade'] = v,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: TextFormField(
//               key: ValueKey('weight_$index${band['weight']}'),
//               initialValue: band['weight'],
//               enabled: !_locked && !_busy,
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               decoration: const InputDecoration(labelText: 'Weight', isDense: true),
//               onChanged: (v) => band['weight'] = v,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             flex: 2,
//             child: TextFormField(
//               key: ValueKey('remarks_$index${band['remarks']}'),
//               initialValue: band['remarks'],
//               enabled: !_locked && !_busy,
//               decoration: const InputDecoration(labelText: 'Remarks', isDense: true),
//               onChanged: (v) => band['remarks'] = v,
//             ),
//           ),
//           IconButton(
//             tooltip: 'Remove band',
//             icon: Icon(Icons.delete_outline,
//                 color: _bands.length <= 1 || _locked || _busy ? scheme.outlineVariant : Colors.red),
//             onPressed:
//             _bands.length <= 1 || _locked || _busy ? null : () => setState(() => _bands.removeAt(index)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _scalesList() {
//     final scheme = Theme.of(context).colorScheme;
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         border: Border.all(color: scheme.outlineVariant),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Registered scales (${_scales.length})',
//               style: const TextStyle(fontWeight: FontWeight.w800)),
//           const SizedBox(height: 6),
//           if (_scales.isEmpty)
//             Text('No grading scale registered yet.', style: TextStyle(color: scheme.onSurfaceVariant))
//           else
//             ..._scales.map((scale) {
//               final deleting = _deletingId == scale.id;
//               return ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: Icon(
//                   scale.isDefault ? Icons.stars_rounded : Icons.account_tree_outlined,
//                   color: scheme.primary,
//                 ),
//                 title: Text(scale.name),
//                 subtitle: Text(
//                     '${scale.isDefault ? "School default" : "Department scale"} • ${scale.bands.length} grades'),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       tooltip: 'Edit',
//                       icon: const Icon(Icons.edit_outlined),
//                       onPressed: _locked || _busy ? null : () => _loadIntoForm(scale),
//                     ),
//                     IconButton(
//                       tooltip: 'Delete',
//                       icon: deleting
//                           ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                           : const Icon(Icons.delete_outline, color: Colors.red),
//                       onPressed: _locked || _busy ? null : () => _delete(scale),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//         ],
//       ),
//     );
//   }
// }
//
// extension _FirstOrNull<T> on Iterable<T> {
//   T? get firstOrNull => isEmpty ? null : first;
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/grademodel.dart';
import '../controller/dbmodels/gradingmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class GradingSystemFormPage extends StatefulWidget {
  final bool embedded;
  const GradingSystemFormPage({super.key, this.embedded = false});

  @override
  State<GradingSystemFormPage> createState() => _GradingSystemFormPageState();
}

class _GradingSystemFormPageState extends State<GradingSystemFormPage> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = true;
  bool _saving = false;
  String? _deletingId;
  bool _locked = false;

  List<GradingModel> _scales = [];
  GradingModel? _editing;

  bool _isDefault = true;
  String? _selectedFaculty;
  String? _selectedDepartmentId;
  List<Map<String, String>> _bands = [];

  bool get _busy => _saving || _deletingId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final provider = context.read<Myprovider>();
    try {
      await Future.wait([provider.fetchdepart(), _checkLock()]);
      await _loadScales();
      _resetForm();
    } catch (e) {
      _toast('Could not load grading data: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkLock() async {
    final provider = context.read<Myprovider>();
    final schoolId = provider.schoolid.trim();
    if (schoolId.isEmpty) return;
    final doc = await provider.db.collection('schools').doc(schoolId).get();
    if (mounted) {
      setState(() => _locked = doc.data()?['setupCompleted'] == true);
    }
  }

  Future<void> _loadScales() async {
    final provider = context.read<Myprovider>();
    final schoolId = provider.schoolid.trim();
    if (schoolId.isEmpty) return;
    final snapshot = await provider.db
        .collection('gradingsystems')
        .where('schoolId', isEqualTo: schoolId)
        .get();
    if (!mounted) return;
    setState(() {
      _scales = snapshot.docs
          .map((d) => GradingModel.fromMap({...d.data(), 'id': d.id}))
          .toList()
        ..sort((a, b) =>
        a.isDefault == b.isDefault ? a.name.compareTo(b.name) : (a.isDefault ? -1 : 1));
    });
  }

  static List<Map<String, String>> _defaultBands() => [
    {'min': '0', 'max': '49.9', 'grade': 'F', 'weight': '0', 'remarks': 'Needs improvement'},
    {'min': '50', 'max': '59.9', 'grade': 'C', 'weight': '1', 'remarks': 'Satisfactory'},
    {'min': '60', 'max': '69.9', 'grade': 'B', 'weight': '2', 'remarks': 'Good'},
    {'min': '70', 'max': '100', 'grade': 'A', 'weight': '3', 'remarks': 'Excellent'},
  ];

  void _resetForm() {
    _editing = null;
    _isDefault = true;
    _selectedFaculty = null;
    _selectedDepartmentId = null;
    _bands = _defaultBands().map((e) => {...e}).toList();
  }

  void _loadIntoForm(GradingModel scale) {
    final provider = context.read<Myprovider>();
    setState(() {
      _editing = scale;
      _isDefault = scale.isDefault;
      _selectedDepartmentId = scale.departmentId;
      if (!scale.isDefault && scale.departmentId != null) {
        final dept = provider.departments.where((d) => d.id == scale.departmentId);
        _selectedFaculty = dept.isNotEmpty ? dept.first.faculty : null;
      } else {
        _selectedFaculty = null;
      }
      _bands = scale.bands
          .map((b) => {
        'min': _fmt(b.min),
        'max': _fmt(b.max),
        'grade': b.grade,
        'weight': _fmt(b.weight),
        'remarks': b.remarks,
      })
          .toList();
    });
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  List<GradeBand>? _parsedBands() {
    try {
      return _bands
          .map((b) => GradeBand(
        min: double.parse(b['min']!.trim()),
        max: double.parse(b['max']!.trim()),
        grade: b['grade']!.trim().toUpperCase(),
        weight: double.parse(b['weight']!.trim()),
        remarks: b['remarks']!.trim(),
      ))
          .toList();
    } catch (_) {
      return null;
    }
  }

  String? get _validationMessage {
    final parsed = _parsedBands();
    if (parsed == null) return 'Fill in every band with valid numbers before saving.';
    return GradingModel.validate(parsed);
  }

  Future<void> _save() async {
    if (_locked || _busy) return;
    if (!_isDefault && _selectedDepartmentId == null) {
      _toast('Select a department for this scale.', error: true);
      return;
    }
    final error = _validationMessage;
    if (error != null) {
      _toast(error, error: true);
      return;
    }
    final provider = context.read<Myprovider>();
    final schoolId = provider.schoolid.trim();
    if (schoolId.isEmpty) {
      _toast('Missing school id — cannot save.', error: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final bands = _parsedBands()!;
      final id = GradingModel.buildId(
        schoolId,
        isDefault: _isDefault,
        departmentId: _selectedDepartmentId,
      );
      // If we were editing an existing scale under a different id (e.g. it
      // changed from default -> department), drop the stale document.
      if (_editing != null && _editing!.id != id) {
        await provider.db.collection('gradingsystems').doc(_editing!.id).delete();
      }
      final deptName = _isDefault
          ? null
          : provider.departments
          .where((d) => d.id == _selectedDepartmentId)
          .map((d) => d.name)
          .firstOrNull;
      final model = GradingModel(
        id: id,
        schoolId: schoolId,
        scope: _isDefault ? 'default' : 'department',
        departmentId: _isDefault ? null : _selectedDepartmentId,
        facultyName: _isDefault ? null : _selectedFaculty,
        name: _isDefault ? 'School default' : (deptName ?? 'Department'),
        bands: bands,
        staff: provider.name,
      );
      await provider.db.collection('gradingsystems').doc(id).set({
        ...model.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Reload the full list from Firestore so both the form's "editing"
      // state and the scales list reflect exactly what was persisted —
      // not just an optimistic local guess.
      await _loadScales();
      if (!mounted) return;
      setState(_resetForm);
      _toast('Grading scale saved.');
    } catch (e) {
      _toast('Could not save: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(GradingModel scale) async {
    if (_locked || _busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete grading scale?'),
        content: Text('Remove "${scale.name}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deletingId = scale.id);
    try {
      final provider = context.read<Myprovider>();
      await provider.db.collection('gradingsystems').doc(scale.id).delete();
      if (_editing?.id == scale.id) _resetForm();
      await _loadScales();
      _toast('Grading scale deleted.');
    } catch (e) {
      _toast('Could not delete: $e', error: true);
    } finally {
      if (mounted) setState(() => _deletingId = null);
    }
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
        : Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_locked) _lockedBanner(),
              if (_locked) const SizedBox(height: 16),
              AbsorbPointer(
                absorbing: _busy,
                child: Opacity(opacity: _busy ? 0.6 : 1, child: _formCard()),
              ),
              const SizedBox(height: 20),
              AbsorbPointer(
                absorbing: _busy,
                child: Opacity(opacity: _busy ? 0.6 : 1, child: _scalesList()),
              ),
            ],
          ),
        ),
        if (_busy)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _saving ? 'Saving grading scale...' : 'Deleting grading scale...',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.embedded) return content;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00273a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(Routes.dashboard),
        ),
        title: const Text('Grading scales', style: TextStyle(color: Colors.white)),
      ),
      body: content,
    );
  }

  Widget _lockedBanner() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.orange),
    ),
    child: const Row(
      children: [
        Icon(Icons.lock_outline, color: Colors.orange),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Setup is locked. Grading scales are view-only until an administrator unlocks it.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _formCard() {
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<Myprovider>();
    final faculties = provider.faculties;
    final departments = provider.departments
        .where((d) => _selectedFaculty == null || d.faculty == _selectedFaculty)
        .toList();
    final error = _validationMessage;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rule_folder_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _editing == null ? 'New grading scale' : 'Edit "${_editing!.name}"',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                if (_editing != null)
                  TextButton(
                    onPressed: _locked || _busy ? null : () => setState(_resetForm),
                    child: const Text('New scale'),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Default vs department toggle
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _scopeTab('Default (school-wide)', _isDefault, () {
                    if (_locked || _busy) return;
                    setState(() {
                      _isDefault = true;
                      _selectedDepartmentId = null;
                      _selectedFaculty = null;
                    });
                  }),
                  _scopeTab('Department scale', !_isDefault, () {
                    if (_locked || _busy) return;
                    setState(() => _isDefault = false);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (!_isDefault) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: faculties.any((f) => f.name == _selectedFaculty) ? _selectedFaculty : null,
                      decoration: const InputDecoration(labelText: 'Faculty (optional filter)'),
                      items: faculties
                          .map((f) => DropdownMenuItem(value: f.name, child: Text(f.name)))
                          .toList(),
                      onChanged: _locked || _busy
                          ? null
                          : (value) => setState(() {
                        _selectedFaculty = value;
                        if (_selectedDepartmentId != null &&
                            !departments.any((d) => d.id == _selectedDepartmentId)) {
                          _selectedDepartmentId = null;
                        }
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: departments.any((d) => d.id == _selectedDepartmentId)
                          ? _selectedDepartmentId
                          : null,
                      decoration: const InputDecoration(labelText: 'Department'),
                      items: departments
                          .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                          .toList(),
                      onChanged: _locked || _busy
                          ? null
                          : (value) => setState(() => _selectedDepartmentId = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            Row(
              children: [
                const Expanded(
                  child: Text('Grade bands', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                OutlinedButton.icon(
                  onPressed: _locked || _busy
                      ? null
                      : () => setState(() => _bands.add({
                    'min': '',
                    'max': '',
                    'grade': '',
                    'weight': '',
                    'remarks': '',
                  })),
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('Add band'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._bands.asMap().entries.map((entry) => _bandRow(entry.key, entry.value)),

            const SizedBox(height: 6),
            Row(
              children: [
                Icon(error == null ? Icons.check_circle_outline : Icons.error_outline,
                    size: 16, color: error == null ? Colors.green : Colors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    error ?? 'Bands are valid — no overlapping ranges.',
                    style: TextStyle(fontSize: 12, color: error == null ? Colors.green : Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _locked || _busy ? null : _save,
                icon: _saving
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : (_editing == null ? 'Save scale' : 'Update scale')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scopeTab(String label, bool selected, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bandRow(int index, Map<String, String> band) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              key: ValueKey('min_$index${band['min']}'),
              initialValue: band['min'],
              enabled: !_locked && !_busy,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Min', isDense: true),
              onChanged: (v) => band['min'] = v,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              key: ValueKey('max_$index${band['max']}'),
              initialValue: band['max'],
              enabled: !_locked && !_busy,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Max', isDense: true),
              onChanged: (v) => band['max'] = v,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              key: ValueKey('grade_$index${band['grade']}'),
              initialValue: band['grade'],
              enabled: !_locked && !_busy,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Grade', isDense: true),
              onChanged: (v) => band['grade'] = v,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              key: ValueKey('weight_$index${band['weight']}'),
              initialValue: band['weight'],
              enabled: !_locked && !_busy,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight', isDense: true),
              onChanged: (v) => band['weight'] = v,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: TextFormField(
              key: ValueKey('remarks_$index${band['remarks']}'),
              initialValue: band['remarks'],
              enabled: !_locked && !_busy,
              decoration: const InputDecoration(labelText: 'Remarks', isDense: true),
              onChanged: (v) => band['remarks'] = v,
            ),
          ),
          IconButton(
            tooltip: 'Remove band',
            icon: Icon(Icons.delete_outline,
                color: _bands.length <= 1 || _locked || _busy ? scheme.outlineVariant : Colors.red),
            onPressed:
            _bands.length <= 1 || _locked || _busy ? null : () => setState(() => _bands.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _scalesList() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registered scales (${_scales.length})',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (_scales.isEmpty)
            Text('No grading scale registered yet.', style: TextStyle(color: scheme.onSurfaceVariant))
          else
            ..._scales.map((scale) {
              final deleting = _deletingId == scale.id;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  scale.isDefault ? Icons.stars_rounded : Icons.account_tree_outlined,
                  color: scheme.primary,
                ),
                title: Text(scale.name),
                subtitle: Text(
                    '${scale.isDefault ? "School default" : "Department scale"} • ${scale.bands.length} grades'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _locked || _busy ? null : () => _loadIntoForm(scale),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: deleting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _locked || _busy ? null : () => _delete(scale),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}