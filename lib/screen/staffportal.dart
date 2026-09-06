//
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:excel/excel.dart' as xls;
// import 'package:file_selector/file_selector.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
//
// import '../controller/dbmodels/contestantsmodel.dart';
// import '../controller/dbmodels/courseallocationmodel.dart';
// import '../controller/dbmodels/coursematerialmodel1.dart';
// import '../controller/dbmodels/subjectmodel.dart';
// import '../controller/myprovider.dart';
//
// const int _maxUploadBytes = 10 * 1024 * 1024;
//
// class StaffPortalPage extends StatefulWidget {
//   final String staffId;
//   final VoidCallback? onLogout;
//   const StaffPortalPage({super.key, required this.staffId, this.onLogout});
//
//   @override
//   State<StaffPortalPage> createState() => _StaffPortalPageState();
// }
//
// class _StaffPortalPageState extends State<StaffPortalPage> {
//   bool _loading = true;
//   String? _error;
//   dynamic _staff;
//   List<CourseAllocationModel> _allocations = [];
//   String _search = '';
//   CourseAllocationModel? _selected;
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
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final provider = _provider;
//       await provider.fetchstaff();
//       dynamic staff = provider.stafflist.where((s) => s.id == widget.staffId).firstOrNull;
//       if (staff == null) {
//         final doc = await provider.db.collection('staff').doc(widget.staffId).get();
//         if (doc.exists) staff = {'id': doc.id, ...doc.data()!};
//       }
//       final allocSnap = await provider.db
//           .collection('courseAllocation')
//           .where('schoolId', isEqualTo: provider.schoolid)
//           .where('staffId', isEqualTo: widget.staffId)
//           .where('academicYear', isEqualTo: provider.year)
//           .where('termOrSemester', isEqualTo: provider.term)
//           .get();
//       final allocations = allocSnap.docs.map((d) => CourseAllocationModel.fromMap(d.data())).toList();
//       if (!mounted) return;
//       setState(() {
//         _staff = staff;
//         _allocations = allocations;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = 'Could not load your dashboard: $e';
//         _loading = false;
//       });
//     }
//   }
//
//   String get _staffName {
//     final s = _staff;
//     if (s == null) return 'Staff';
//     if (s is Map) return s['name']?.toString() ?? 'Staff';
//     try {
//       return (s.name as String?) ?? 'Staff';
//     } catch (_) {
//       return 'Staff';
//     }
//   }
//
//   List<CourseAllocationModel> get _filtered {
//     final q = _search.toLowerCase();
//     final list = [..._allocations];
//     list.sort((a, b) => b.courseCode.compareTo(a.courseCode));
//     if (q.isEmpty) return list;
//     return list.where((a) {
//       final text = '${a.courseCode} ${a.courseName} ${a.classOrLevel}'.toLowerCase();
//       return text.contains(q);
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       backgroundColor: scheme.surface,
//       appBar: AppBar(
//         backgroundColor: scheme.primary,
//         foregroundColor: scheme.onPrimary,
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: scheme.onPrimary,
//               foregroundColor: scheme.primary,
//               child: Text(_staffName.isNotEmpty ? _staffName[0].toUpperCase() : 'S'),
//             ),
//             const SizedBox(width: 12),
//             Expanded(child: Text(_staffName, overflow: TextOverflow.ellipsis)),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//             onPressed: widget.onLogout ?? () => Navigator.of(context).maybePop(),
//           ),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//           ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: TextStyle(color: scheme.error))))
//           : LayoutBuilder(
//         builder: (context, constraints) {
//           final wide = constraints.maxWidth > 900;
//           final list = _coursesPanel(scheme);
//           if (!wide) return list;
//           return Row(
//             children: [
//               SizedBox(width: 360, child: list),
//               const VerticalDivider(width: 1),
//               Expanded(
//                 child: _selected == null
//                     ? Center(child: Text('Select a course to begin.', style: TextStyle(color: scheme.onSurfaceVariant)))
//                     : _CourseEntryPanel(
//                   key: ValueKey(_selected!.id),
//                   allocation: _selected!,
//                   staffId: widget.staffId,
//                   staffName: _staffName,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _coursesPanel(ColorScheme scheme) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(12),
//           child: TextField(
//             onChanged: (v) => setState(() => _search = v),
//             decoration: const InputDecoration(labelText: 'Search course', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
//           ),
//         ),
//         Expanded(
//           child: _filtered.isEmpty
//               ? Center(child: Text('No courses allocated to you this term.', style: TextStyle(color: scheme.onSurfaceVariant)))
//               : ListView.builder(
//             itemCount: _filtered.length,
//             itemBuilder: (context, i) {
//               final a = _filtered[i];
//               final selected = _selected?.id == a.id;
//               return ListTile(
//                 selected: selected,
//                 selectedTileColor: scheme.primaryContainer,
//                 title: Text('${a.courseCode}  ${a.courseName}'),
//                 subtitle: Text('${a.classOrLevel} • ${a.termOrSemester} ${a.academicYear}'),
//                 onTap: () {
//                   if (MediaQuery.of(context).size.width > 900) {
//                     setState(() => _selected = a);
//                   } else {
//                     Navigator.of(context).push(MaterialPageRoute(
//                       builder: (_) => Scaffold(
//                         appBar: AppBar(title: Text(a.courseCode)),
//                         body: _CourseEntryPanel(allocation: a, staffId: widget.staffId, staffName: _staffName),
//                       ),
//                     ));
//                   }
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _CourseEntryPanel extends StatefulWidget {
//   final CourseAllocationModel allocation;
//   final String staffId;
//   final String staffName;
//   const _CourseEntryPanel({super.key, required this.allocation, required this.staffId, required this.staffName});
//
//   @override
//   State<_CourseEntryPanel> createState() => _CourseEntryPanelState();
// }
//
// class _CourseEntryPanelState extends State<_CourseEntryPanel> {
//   bool _loading = true;
//   bool _uploading = false;
//   String _exportFormat = 'csv';
//   List<StudentModel> _roster = [];
//   SubjectModel? _subject;
//   double _caMax = 40, _examMax = 60, _caPercent = 40, _examPercent = 60, _caMin = 0, _examMin = 0;
//   List<Map<String, dynamic>> _bands = [];
//   final Map<String, TextEditingController> _ca = {};
//   final Map<String, TextEditingController> _exam = {};
//   final Map<String, Map<String, dynamic>> _saved = {};
//   final Set<String> _saving = {};
//   final Set<String> _registeredStudentIds = {};
//   List<CourseMaterialModel> _materials = [];
//   final _titleController = TextEditingController();
//   final _urlController = TextEditingController();
//
//   Myprovider get _provider => context.read<Myprovider>();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _load());
//   }
//
//   @override
//   void dispose() {
//     for (final c in _ca.values) c.dispose();
//     for (final c in _exam.values) c.dispose();
//     _titleController.dispose();
//     _urlController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _load() async {
//     setState(() => _loading = true);
//     final provider = _provider;
//     final a = widget.allocation;
//     await provider.fetchsubjects();
//     final subject = provider.subjectList.where((s) => s.code == a.courseCode).firstOrNull;
//
//     final period = a.termOrSemester.toLowerCase().replaceAll(' ', '_');
//     final configSnap = await provider.db.collection('scoreConfig').doc('${provider.schoolid}_$period').get();
//     if (configSnap.exists) {
//       final data = configSnap.data()!;
//       _caMax = (data['caMax'] as num?)?.toDouble() ?? 40;
//       _examMax = (data['examMax'] as num?)?.toDouble() ?? 60;
//       _caMin = (data['caMin'] as num?)?.toDouble() ?? 0;
//       _examMin = (data['examMin'] as num?)?.toDouble() ?? 0;
//       _caPercent = (data['caPercent'] as num?)?.toDouble() ?? _caMax;
//       _examPercent = (data['examPercent'] as num?)?.toDouble() ?? _examMax;
//     }
//
//     final bands = await _loadGradingBands(provider.schoolid, a.departmentId);
//
//     final rosterSnap = await provider.db
//         .collection('students')
//         .where('schoolId', isEqualTo: provider.schoolid)
//         .where('departmentid', isEqualTo: a.departmentId)
//         .get();
//     final roster = rosterSnap.docs
//         .map((d) => StudentModel.fromMap({...d.data(), 'id': d.id}))
//         .where((s) => s.classname == a.classOrLevel || s.level == a.classOrLevel || s.currentclass == a.classOrLevel)
//         .toList()
//       ..sort((x, y) => x.name.compareTo(y.name));
//
//     final registered = <String>{};
//     final rosterIds = roster.map((s) => s.id).toList();
//     for (var i = 0; i < rosterIds.length; i += 10) {
//       final chunk = rosterIds.sublist(i, i + 10 > rosterIds.length ? rosterIds.length : i + 10);
//       if (chunk.isEmpty) continue;
//       final regSnap = await provider.db
//           .collection('coursereg')
//           .where('schoolId', isEqualTo: provider.schoolid)
//           .where('academicYear', isEqualTo: a.academicYear)
//           .where('termOrSemester', isEqualTo: a.termOrSemester)
//           .where('studentId', whereIn: chunk)
//           .get();
//       for (final doc in regSnap.docs) {
//         final data = doc.data();
//         final codes = List<String>.from(data['courseCodes'] ?? const []);
//         if (codes.contains(a.courseCode)) registered.add(data['studentId']?.toString() ?? '');
//       }
//     }
//
//     final materialsSnap = await provider.db
//         .collection('courseMaterials')
//         .where('schoolId', isEqualTo: provider.schoolid)
//         .where('courseCode', isEqualTo: a.courseCode)
//         .where('academicYear', isEqualTo: a.academicYear)
//         .where('termOrSemester', isEqualTo: a.termOrSemester)
//         .get();
//     final materials = materialsSnap.docs.map((d) => CourseMaterialModel.fromMap(d.data())).toList();
//
//     if (subject != null) {
//       final scoringIds = roster.map((s) => '${s.id}_${provider.academicyrid}_${provider.term}').toList();
//       final docs = await Future.wait(scoringIds.map((id) => provider.db.collection('subjectScoring').doc(id).get()));
//       for (var i = 0; i < roster.length; i++) {
//         final entry = (docs[i].data()?['subjects'] as Map<String, dynamic>?)?[subject.id];
//         _ca[roster[i].id] = TextEditingController(text: entry?['CA']?.toString() ?? '');
//         _exam[roster[i].id] = TextEditingController(text: entry?['Exams']?.toString() ?? '');
//         if (entry != null) _saved[roster[i].id] = Map<String, dynamic>.from(entry);
//       }
//     }
//
//     if (!mounted) return;
//     setState(() {
//       _subject = subject;
//       _bands = bands;
//       _roster = roster;
//       _materials = materials;
//       _registeredStudentIds
//         ..clear()
//         ..addAll(registered);
//       _loading = false;
//     });
//   }
//
//   Future<List<Map<String, dynamic>>> _loadGradingBands(String schoolId, String departmentId) async {
//     final db = _provider.db;
//     final deptSnap = await db
//         .collection('gradingsystems')
//         .where('schoolid', isEqualTo: schoolId)
//         .where('departmentId', isEqualTo: departmentId)
//         .limit(1)
//         .get();
//     var doc = deptSnap.docs.isNotEmpty ? deptSnap.docs.first : null;
//     if (doc == null) {
//       final defaultSnap = await db
//           .collection('gradingsystems')
//           .where('schoolid', isEqualTo: schoolId)
//           .where('scope', isEqualTo: 'default')
//           .limit(1)
//           .get();
//       doc = defaultSnap.docs.isNotEmpty ? defaultSnap.docs.first : null;
//     }
//     return doc != null ? List<Map<String, dynamic>>.from((doc.data()['bands'] as List?) ?? []) : <Map<String, dynamic>>[];
//   }
//
//   String? _caError(String? value) {
//     final parsed = double.tryParse((value ?? '').trim());
//     if (parsed == null) return null;
//     if (parsed < _caMin) return 'Min $_caMin';
//     if (parsed > _caMax) return 'Max $_caMax';
//     return null;
//   }
//
//   String? _examError(String? value) {
//     final parsed = double.tryParse((value ?? '').trim());
//     if (parsed == null) return null;
//     if (parsed < _examMin) return 'Min $_examMin';
//     if (parsed > _examMax) return 'Max $_examMax';
//     return null;
//   }
//
//   Map<String, dynamic> _grade(double total) {
//     for (final band in _bands) {
//       final min = (band['minScore'] as num?)?.toDouble() ?? 0;
//       final max = (band['maxScore'] as num?)?.toDouble() ?? 0;
//       if (total >= min && total <= max) {
//         return {'grade': band['grade']?.toString() ?? '-', 'remarks': band['remarks']?.toString() ?? ''};
//       }
//     }
//     return {'grade': '-', 'remarks': ''};
//   }
//
//   Future<void> _saveOne(StudentModel student) async {
//     final subject = _subject;
//     if (subject == null) return;
//     final ca = double.tryParse(_ca[student.id]?.text.trim() ?? '');
//     final exam = double.tryParse(_exam[student.id]?.text.trim() ?? '');
//     if (ca == null || exam == null) return;
//     if (ca < _caMin || ca > _caMax) {
//       _snack('CA for ${student.name} must be within $_caMin and $_caMax.', isError: true);
//       return;
//     }
//     if (exam < _examMin || exam > _examMax) {
//       _snack('Exam for ${student.name} must be within $_examMin and $_examMax.', isError: true);
//       return;
//     }
//     setState(() => _saving.add(student.id));
//     final provider = _provider;
//     final scaledCa = _caMax > 0 ? (ca / _caMax) * _caPercent : 0.0;
//     final scaledExam = _examMax > 0 ? (exam / _examMax) * _examPercent : 0.0;
//     final total = scaledCa + scaledExam;
//     final grade = _grade(total);
//     final entry = {
//       'subjectId': subject.id,
//       'subjectName': subject.name,
//       'code': subject.code,
//       'weight': subject.weight,
//       'creditHours': subject.creditHours,
//       'academicYear': widget.allocation.academicYear,
//       'termOrSemester': widget.allocation.termOrSemester,
//       'isComplete': 'yes',
//       'caMin': _caMin,
//       'caMax': _caMax,
//       'examMin': _examMin,
//       'examMax': _examMax,
//       'CAraw': ca.toString(),
//       'CA': scaledCa.toString(),
//       'Examsraw': exam.toString(),
//       'Exams': scaledExam.toString(),
//       'totalScore': total.toStringAsFixed(2),
//       'grade': grade['grade'],
//       'remarks': grade['remarks'],
//       'enteredBy': widget.staffName,
//       'enteredAt': DateTime.now().toIso8601String(),
//     };
//     final scoringId = '${student.id}_${provider.academicyrid}_${provider.term}';
//     await provider.db.collection('subjectScoring').doc(scoringId).set({
//       'studentId': student.id,
//       'level': widget.allocation.classOrLevel,
//       'department': widget.allocation.departmentId,
//       'academicYear': widget.allocation.academicYear,
//       'termOrSemester': widget.allocation.termOrSemester,
//       'subjects': {subject.id: entry},
//     }, SetOptions(merge: true));
//     if (!mounted) return;
//     setState(() {
//       _saved[student.id] = entry;
//       _saving.remove(student.id);
//     });
//   }
//
//   Future<void> _saveAll() async {
//     for (final student in _roster) {
//       final ca = _ca[student.id]?.text.trim() ?? '';
//       final exam = _exam[student.id]?.text.trim() ?? '';
//       if (ca.isNotEmpty && exam.isNotEmpty) await _saveOne(student);
//     }
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All entered scores saved.')));
//   }
//
//   List<List<String>> _buildRows() {
//     final rows = <List<String>>[
//       ['StudentID', 'Name', 'CA', 'Exams', 'Total', 'Grade', 'Registered'],
//     ];
//     for (final s in _roster) {
//       final saved = _saved[s.id];
//       rows.add([
//         s.studentid,
//         s.name,
//         saved?['CA']?.toString() ?? '',
//         saved?['Exams']?.toString() ?? '',
//         saved?['totalScore']?.toString() ?? '',
//         saved?['grade']?.toString() ?? '',
//         _registeredStudentIds.contains(s.id) ? 'Yes' : 'No',
//       ]);
//     }
//     return rows;
//   }
//
//   Uint8List _rowsToCsvBytes(List<List<String>> rows) {
//     final csv = rows.map((r) => r.map((c) => c.contains(',') ? '"$c"' : c).join(',')).join('\n');
//     return Uint8List.fromList(utf8.encode(csv));
//   }
//
//   Uint8List _rowsToXlsxBytes(List<List<String>> rows) {
//     final book = xls.Excel.createExcel();
//     final sheet = book['Scores'];
//     book.setDefaultSheet('Scores');
//     for (final row in rows) {
//       sheet.appendRow(row.map((c) => xls.TextCellValue(c)).toList());
//     }
//     final bytes = book.save();
//     return Uint8List.fromList(bytes ?? []);
//   }
//
//   Future<void> _download() async {
//     final rows = _buildRows();
//     final isCsv = _exportFormat == 'csv';
//     final bytes = isCsv ? _rowsToCsvBytes(rows) : _rowsToXlsxBytes(rows);
//     final extension = isCsv ? 'csv' : 'xlsx';
//     final fileName = '${widget.allocation.courseCode}_scores.$extension';
//     final mimeType = isCsv ? 'text/csv' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
//     try {
//       final location = await getSaveLocation(
//         suggestedName: fileName,
//         acceptedTypeGroups: [XTypeGroup(label: extension.toUpperCase(), extensions: [extension])],
//       );
//       if (location == null) return;
//       final file = XFile.fromData(bytes, mimeType: mimeType, name: fileName);
//       await file.saveTo(location.path);
//       _snack('${extension.toUpperCase()} saved.');
//     } catch (_) {
//       if (isCsv) {
//         await Clipboard.setData(ClipboardData(text: utf8.decode(bytes)));
//         _snack('Could not save file — CSV copied to clipboard instead.', isError: true);
//       } else {
//         _snack('Could not save the file on this device.', isError: true);
//       }
//     }
//   }
//
//   List<List<String>> _parseCsvBytes(Uint8List bytes) {
//     final lines = utf8.decode(bytes).split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
//     return lines.map((line) => line.split(',').map((c) => c.trim()).toList()).toList();
//   }
//
//   List<List<String>> _parseXlsxBytes(Uint8List bytes) {
//     final book = xls.Excel.decodeBytes(bytes);
//     final sheet = book.tables[book.tables.keys.first];
//     if (sheet == null) return [];
//     return sheet.rows
//         .map((row) => row.map((cell) => cell?.value?.toString().trim() ?? '').toList())
//         .where((row) => row.any((c) => c.isNotEmpty))
//         .toList();
//   }
//
//   Future<void> _uploadFile() async {
//     final file = await openFile(acceptedTypeGroups: const [
//       XTypeGroup(label: 'Scores', extensions: ['csv', 'xlsx']),
//     ]);
//     if (file == null) return;
//     final length = await file.length();
//     if (length > _maxUploadBytes) {
//       _snack('File exceeds the 10 MB upload limit.', isError: true);
//       return;
//     }
//     final extension = file.name.split('.').last.toLowerCase();
//     if (extension != 'csv' && extension != 'xlsx') {
//       _snack('Only .csv or .xlsx files are accepted.', isError: true);
//       return;
//     }
//     setState(() => _uploading = true);
//     final bytes = await file.readAsBytes();
//     final rows = extension == 'csv' ? _parseCsvBytes(bytes) : _parseXlsxBytes(bytes);
//     final dataRows = rows.isNotEmpty ? rows.sublist(1) : rows;
//     var matched = 0, skipped = 0;
//     for (final cols in dataRows) {
//       if (cols.length < 3) {
//         skipped++;
//         continue;
//       }
//       final studentId = cols[0].trim();
//       final student = _roster.where((s) => s.studentid == studentId || s.id == studentId).firstOrNull;
//       if (student == null) {
//         skipped++;
//         continue;
//       }
//       final ca = cols[2].trim();
//       final exam = cols.length > 3 ? cols[3].trim() : '';
//       if (ca.isEmpty || exam.isEmpty) {
//         skipped++;
//         continue;
//       }
//       _ca[student.id]?.text = ca;
//       _exam[student.id]?.text = exam;
//       await _saveOne(student);
//       matched++;
//     }
//     if (!mounted) return;
//     setState(() => _uploading = false);
//     _snack('Uploaded: $matched recorded, $skipped skipped.');
//   }
//
//   void _snack(String message, {bool isError = false}) {
//     if (!mounted) return;
//     final scheme = Theme.of(context).colorScheme;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? scheme.error : scheme.primary));
//   }
//
//   Future<void> _addMaterial() async {
//     if (_titleController.text.trim().isEmpty || _urlController.text.trim().isEmpty) return;
//     final provider = _provider;
//     final a = widget.allocation;
//     final id = '${provider.schoolid}_${a.courseCode}_${DateTime.now().millisecondsSinceEpoch}';
//     final model = CourseMaterialModel(
//       id: id,
//       schoolId: provider.schoolid,
//       courseCode: a.courseCode,
//       courseName: a.courseName,
//       departmentId: a.departmentId,
//       classOrLevel: a.classOrLevel,
//       academicYear: a.academicYear,
//       termOrSemester: a.termOrSemester,
//       title: _titleController.text.trim(),
//       url: _urlController.text.trim(),
//       staffId: widget.staffId,
//       staffName: widget.staffName,
//     );
//     await provider.db.collection('courseMaterials').doc(id).set(model.toMap());
//     _titleController.clear();
//     _urlController.clear();
//     if (!mounted) return;
//     setState(() => _materials = [model, ..._materials]);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     if (_loading) return const Center(child: CircularProgressIndicator());
//     final a = widget.allocation;
//
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Card(
//           color: scheme.surfaceContainerLow,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('${a.courseCode}  ${a.courseName}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: scheme.onSurface)),
//                 const SizedBox(height: 4),
//                 Text('${a.classOrLevel} • ${a.termOrSemester} ${a.academicYear}', style: TextStyle(color: scheme.onSurfaceVariant)),
//                 const SizedBox(height: 4),
//                 Text(
//                   'CA $_caMin–$_caMax (scaled to $_caPercent%) • Exam $_examMin–$_examMax (scaled to $_examPercent%)',
//                   style: TextStyle(color: scheme.onSurfaceVariant),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Wrap(
//           spacing: 10,
//           runSpacing: 10,
//           crossAxisAlignment: WrapCrossAlignment.center,
//           children: [
//             SegmentedButton<String>(
//               segments: const [
//                 ButtonSegment(value: 'csv', label: Text('CSV')),
//                 ButtonSegment(value: 'xlsx', label: Text('Excel')),
//               ],
//               selected: {_exportFormat},
//               onSelectionChanged: (v) => setState(() => _exportFormat = v.first),
//             ),
//             OutlinedButton.icon(onPressed: _download, icon: const Icon(Icons.download), label: const Text('Download roster')),
//             OutlinedButton.icon(
//               onPressed: _uploading ? null : _uploadFile,
//               icon: _uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload),
//               label: const Text('Upload scores'),
//             ),
//             FilledButton.icon(onPressed: _saveAll, icon: const Icon(Icons.save), label: const Text('Save all')),
//           ],
//         ),
//         const SizedBox(height: 16),
//         if (_subject == null)
//           Text('This course code has no registered subject record.', style: TextStyle(color: scheme.error))
//         else
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _roster.length,
//             itemBuilder: (context, i) {
//               final s = _roster[i];
//               final saved = _saved[s.id];
//               final busy = _saving.contains(s.id);
//               final isRegistered = _registeredStudentIds.contains(s.id);
//               return Opacity(
//                 opacity: isRegistered ? 1 : 0.55,
//                 child: Card(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(child: Text('${s.name} (${s.studentid})', style: const TextStyle(fontWeight: FontWeight.w700))),
//                             if (!isRegistered)
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 8),
//                                 child: Chip(
//                                   label: const Text('Not registered'),
//                                   visualDensity: VisualDensity.compact,
//                                   backgroundColor: scheme.errorContainer,
//                                   labelStyle: TextStyle(color: scheme.onErrorContainer, fontSize: 11),
//                                 ),
//                               ),
//                             if (saved != null) Chip(label: Text(saved['grade']?.toString() ?? '-')),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Wrap(
//                           spacing: 10,
//                           runSpacing: 10,
//                           crossAxisAlignment: WrapCrossAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 100,
//                               child: TextField(
//                                 controller: _ca[s.id],
//                                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                                 inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
//                                 onChanged: (_) => setState(() {}),
//                                 decoration: InputDecoration(
//                                   labelText: 'CA',
//                                   border: const OutlineInputBorder(),
//                                   errorText: _caError(_ca[s.id]?.text),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 100,
//                               child: TextField(
//                                 controller: _exam[s.id],
//                                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                                 inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
//                                 onChanged: (_) => setState(() {}),
//                                 decoration: InputDecoration(
//                                   labelText: 'Exam',
//                                   border: const OutlineInputBorder(),
//                                   errorText: _examError(_exam[s.id]?.text),
//                                 ),
//                               ),
//                             ),
//                             if (saved != null) Text('Total: ${saved['totalScore']}', style: TextStyle(color: scheme.onSurfaceVariant)),
//                             FilledButton(
//                               onPressed: (busy || _caError(_ca[s.id]?.text) != null || _examError(_exam[s.id]?.text) != null)
//                                   ? null
//                                   : () => _saveOne(s),
//                               child: busy
//                                   ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
//                                   : const Text('Save'),
//                             ),
//                           ],
//                         ),
//                         if (saved != null)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 6),
//                             child: Text('Entered by ${saved['enteredBy']} on ${saved['enteredAt']}',
//                                 style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         const SizedBox(height: 24),
//         Text('Course materials', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
//         const SizedBox(height: 8),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: _materials.length,
//           itemBuilder: (context, i) {
//             final m = _materials[i];
//             return ListTile(
//               leading: const Icon(Icons.link),
//               title: Text(m.title),
//               subtitle: SelectableText(m.url),
//               trailing: IconButton(
//                 icon: const Icon(Icons.copy),
//                 onPressed: () => Clipboard.setData(ClipboardData(text: m.url)),
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(child: TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Material title', border: OutlineInputBorder()))),
//             const SizedBox(width: 8),
//             Expanded(child: TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'Link (URL)', border: OutlineInputBorder()))),
//             const SizedBox(width: 8),
//             FilledButton(onPressed: _addMaterial, child: const Text('Add')),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as xls;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/contestantsmodel.dart';
import '../controller/dbmodels/courseallocationmodel.dart';
import '../controller/dbmodels/coursematerialmodel1.dart';
import '../controller/dbmodels/subjectmodel.dart';
import '../controller/myprovider.dart';

const int _maxUploadBytes = 10 * 1024 * 1024;

class StaffPortalPage extends StatefulWidget {
  final String staffId;
  final VoidCallback? onLogout;
  const StaffPortalPage({super.key, required this.staffId, this.onLogout});

  @override
  State<StaffPortalPage> createState() => _StaffPortalPageState();
}

class _StaffPortalPageState extends State<StaffPortalPage> {
  bool _loading = true;
  String? _error;
  dynamic _staff;
  List<CourseAllocationModel> _allocations = [];
  String _search = '';
  CourseAllocationModel? _selected;

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
      await provider.fetchstaff();
      dynamic staff = provider.stafflist.where((s) => s.id == widget.staffId).firstOrNull;
      if (staff == null) {
        final doc = await provider.db.collection('staff').doc(widget.staffId).get();
        if (doc.exists) staff = {'id': doc.id, ...doc.data()!};
      }
      final allocSnap = await provider.db
          .collection('courseAllocation')
          .where('schoolId', isEqualTo: provider.schoolid)
          .where('staffId', isEqualTo: widget.staffId)
          .where('academicYear', isEqualTo: provider.year)
          .where('termOrSemester', isEqualTo: provider.term)
          .get();
      final allocations = allocSnap.docs.map((d) => CourseAllocationModel.fromMap(d.data())).toList();
      if (!mounted) return;
      setState(() {
        _staff = staff;
        _allocations = allocations;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your dashboard: $e';
        _loading = false;
      });
    }
  }

  String get _staffName {
    final s = _staff;
    if (s == null) return 'Staff';
    if (s is Map) return s['name']?.toString() ?? 'Staff';
    try {
      return (s.name as String?) ?? 'Staff';
    } catch (_) {
      return 'Staff';
    }
  }

  List<CourseAllocationModel> get _filtered {
    final q = _search.toLowerCase();
    final list = [..._allocations];
    list.sort((a, b) => b.courseCode.compareTo(a.courseCode));
    if (q.isEmpty) return list;
    return list.where((a) {
      final text = '${a.courseCode} ${a.courseName} ${a.classOrLevel}'.toLowerCase();
      return text.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.onPrimary,
              foregroundColor: scheme.primary,
              child: Text(_staffName.isNotEmpty ? _staffName[0].toUpperCase() : 'S'),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(_staffName, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: widget.onLogout ?? () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: TextStyle(color: scheme.error))))
          : LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 900;
          final list = _coursesPanel(scheme);
          if (!wide) return list;
          return Row(
            children: [
              SizedBox(width: 360, child: list),
              const VerticalDivider(width: 1),
              Expanded(
                child: _selected == null
                    ? Center(child: Text('Select a course to begin.', style: TextStyle(color: scheme.onSurfaceVariant)))
                    : _CourseEntryPanel(
                  key: ValueKey(_selected!.id),
                  allocation: _selected!,
                  staffId: widget.staffId,
                  staffName: _staffName,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _coursesPanel(ColorScheme scheme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: const InputDecoration(labelText: 'Search course', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Text('No courses allocated to you this term.', style: TextStyle(color: scheme.onSurfaceVariant)))
              : ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (context, i) {
              final a = _filtered[i];
              final selected = _selected?.id == a.id;
              return ListTile(
                selected: selected,
                selectedTileColor: scheme.primaryContainer,
                title: Text('${a.courseCode}  ${a.courseName}'),
                subtitle: Text('${a.classOrLevel} • ${a.termOrSemester} ${a.academicYear}'),
                onTap: () {
                  if (MediaQuery.of(context).size.width > 900) {
                    setState(() => _selected = a);
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: Text(a.courseCode)),
                        body: _CourseEntryPanel(allocation: a, staffId: widget.staffId, staffName: _staffName),
                      ),
                    ));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CourseEntryPanel extends StatefulWidget {
  final CourseAllocationModel allocation;
  final String staffId;
  final String staffName;
  const _CourseEntryPanel({super.key, required this.allocation, required this.staffId, required this.staffName});

  @override
  State<_CourseEntryPanel> createState() => _CourseEntryPanelState();
}

class _CourseEntryPanelState extends State<_CourseEntryPanel> {
  bool _loading = true;
  bool _uploading = false;
  String _exportFormat = 'csv';
  List<StudentModel> _roster = [];
  SubjectModel? _subject;
  double _caMax = 40, _examMax = 60, _caPercent = 40, _examPercent = 60, _caMin = 0, _examMin = 0;
  List<Map<String, dynamic>> _bands = [];
  final Map<String, TextEditingController> _ca = {};
  final Map<String, TextEditingController> _exam = {};
  final Map<String, Map<String, dynamic>> _saved = {};
  final Set<String> _saving = {};
  final Set<String> _registeredStudentIds = {};
  List<CourseMaterialModel> _materials = [];
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();

  Myprovider get _provider => context.read<Myprovider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    for (final c in _ca.values) c.dispose();
    for (final c in _exam.values) c.dispose();
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final provider = _provider;
    final a = widget.allocation;
    await provider.fetchsubjects();
    final subject = provider.subjectList.where((s) => s.code == a.courseCode).firstOrNull;

    final period = a.termOrSemester.toLowerCase().replaceAll(' ', '_');
    final configSnap = await provider.db.collection('scoreConfig').doc('${provider.schoolid}_$period').get();
    if (configSnap.exists) {
      final data = configSnap.data()!;
      _caMax = (data['caMax'] as num?)?.toDouble() ?? 40;
      _examMax = (data['examMax'] as num?)?.toDouble() ?? 60;
      _caMin = (data['caMin'] as num?)?.toDouble() ?? 0;
      _examMin = (data['examMin'] as num?)?.toDouble() ?? 0;
      _caPercent = (data['caPercent'] as num?)?.toDouble() ?? _caMax;
      _examPercent = (data['examPercent'] as num?)?.toDouble() ?? _examMax;
    }

    final bands = await _loadGradingBands(provider.schoolid, a.departmentId);

    final rosterSnap = await provider.db
        .collection('students')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('departmentid', isEqualTo: a.departmentId)
        .get();
    final roster = rosterSnap.docs
        .map((d) => StudentModel.fromMap({...d.data(), 'id': d.id}))
        .where((s) => s.classname == a.classOrLevel || s.level == a.classOrLevel || s.currentclass == a.classOrLevel)
        .toList()
      ..sort((x, y) => x.name.compareTo(y.name));

    final registered = <String>{};
    final rosterIds = roster.map((s) => s.id).toList();
    for (var i = 0; i < rosterIds.length; i += 10) {
      final chunk = rosterIds.sublist(i, i + 10 > rosterIds.length ? rosterIds.length : i + 10);
      if (chunk.isEmpty) continue;
      final regSnap = await provider.db
          .collection('coursereg')
          .where('schoolId', isEqualTo: provider.schoolid)
          .where('academicYear', isEqualTo: a.academicYear)
          .where('termOrSemester', isEqualTo: a.termOrSemester)
          .where('studentId', whereIn: chunk)
          .get();
      for (final doc in regSnap.docs) {
        final data = doc.data();
        final codes = List<String>.from(data['courseCodes'] ?? const []);
        if (codes.contains(a.courseCode)) registered.add(data['studentId']?.toString() ?? '');
      }
    }

    final materialsSnap = await provider.db
        .collection('courseMaterials')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('courseCode', isEqualTo: a.courseCode)
        .where('academicYear', isEqualTo: a.academicYear)
        .where('termOrSemester', isEqualTo: a.termOrSemester)
        .get();
    final materials = materialsSnap.docs.map((d) => CourseMaterialModel.fromMap(d.data())).toList();

    if (subject != null) {
      final scoringIds = roster.map((s) => '${s.id}_${provider.academicyrid}_${provider.term}').toList();
      final docs = await Future.wait(scoringIds.map((id) => provider.db.collection('subjectScoring').doc(id).get()));
      for (var i = 0; i < roster.length; i++) {
        final entry = (docs[i].data()?['subjects'] as Map<String, dynamic>?)?[subject.id];
        _ca[roster[i].id] = TextEditingController(text: entry?['CA']?.toString() ?? '');
        _exam[roster[i].id] = TextEditingController(text: entry?['Exams']?.toString() ?? '');
        if (entry != null) _saved[roster[i].id] = Map<String, dynamic>.from(entry);
      }
    }

    if (!mounted) return;
    setState(() {
      _subject = subject;
      _bands = bands;
      _roster = roster;
      _materials = materials;
      _registeredStudentIds
        ..clear()
        ..addAll(registered);
      _loading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _loadGradingBands(String schoolId, String departmentId) async {
    final db = _provider.db;
    final deptSnap = await db
        .collection('gradingsystems')
        .where('schoolid', isEqualTo: schoolId)
        .where('departmentId', isEqualTo: departmentId)
        .limit(1)
        .get();
    var doc = deptSnap.docs.isNotEmpty ? deptSnap.docs.first : null;
    if (doc == null) {
      final defaultSnap = await db
          .collection('gradingsystems')
          .where('schoolid', isEqualTo: schoolId)
          .where('scope', isEqualTo: 'default')
          .limit(1)
          .get();
      doc = defaultSnap.docs.isNotEmpty ? defaultSnap.docs.first : null;
    }
    return doc != null ? List<Map<String, dynamic>>.from((doc.data()['bands'] as List?) ?? []) : <Map<String, dynamic>>[];
  }

  String? _caError(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null) return null;
    if (parsed < _caMin) return 'Min $_caMin';
    if (parsed > _caMax) return 'Max $_caMax';
    return null;
  }

  String? _examError(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null) return null;
    if (parsed < _examMin) return 'Min $_examMin';
    if (parsed > _examMax) return 'Max $_examMax';
    return null;
  }

  Map<String, dynamic> _grade(double total) {
    for (final band in _bands) {
      final min = (band['minScore'] as num?)?.toDouble() ?? 0;
      final max = (band['maxScore'] as num?)?.toDouble() ?? 0;
      if (total >= min && total <= max) {
        return {'grade': band['grade']?.toString() ?? '-', 'remarks': band['remarks']?.toString() ?? ''};
      }
    }
    return {'grade': '-', 'remarks': ''};
  }

  Future<void> _saveOne(StudentModel student) async {
    final subject = _subject;
    if (subject == null) return;
    final ca = double.tryParse(_ca[student.id]?.text.trim() ?? '');
    final exam = double.tryParse(_exam[student.id]?.text.trim() ?? '');
    if (ca == null || exam == null) return;
    if (ca < _caMin || ca > _caMax) {
      _snack('CA for ${student.name} must be within $_caMin and $_caMax.', isError: true);
      return;
    }
    if (exam < _examMin || exam > _examMax) {
      _snack('Exam for ${student.name} must be within $_examMin and $_examMax.', isError: true);
      return;
    }
    setState(() => _saving.add(student.id));
    final provider = _provider;
    final scaledCa = _caMax > 0 ? (ca / _caMax) * _caPercent : 0.0;
    final scaledExam = _examMax > 0 ? (exam / _examMax) * _examPercent : 0.0;
    final total = scaledCa + scaledExam;
    final grade = _grade(total);
    final entry = {
      'subjectId': subject.id,
      'subjectName': subject.name,
      'code': subject.code,
      'weight': subject.weight,
      'creditHours': subject.creditHours,
      'academicYear': widget.allocation.academicYear,
      'termOrSemester': widget.allocation.termOrSemester,
      'isComplete': 'yes',
      'CA': ca.toString(),
      'Exams': exam.toString(),
      'caMin': _caMin,
      'caMax': _caMax,
      'examMin': _examMin,
      'examMax': _examMax,
      'caPercent': _caPercent,
      'examPercent': _examPercent,
      'scaledCA': scaledCa.toStringAsFixed(2),
      'scaledExams': scaledExam.toStringAsFixed(2),
      'totalScore': total.toStringAsFixed(2),
      'grade': grade['grade'],
      'remarks': grade['remarks'],
      'enteredBy': widget.staffName,
      'enteredAt': DateTime.now().toIso8601String(),
    };
    final scoringId = '${student.id}_${provider.academicyrid}_${provider.term}';
    await provider.db.collection('subjectScoring').doc(scoringId).set({
      'studentId': student.id,
      'level': widget.allocation.classOrLevel,
      'department': widget.allocation.departmentId,
      'academicYear': widget.allocation.academicYear,
      'termOrSemester': widget.allocation.termOrSemester,
      'subjects': {subject.id: entry},
    }, SetOptions(merge: true));
    if (!mounted) return;
    setState(() {
      _saved[student.id] = entry;
      _saving.remove(student.id);
    });
  }

  Future<void> _saveAll() async {
    for (final student in _roster) {
      final ca = _ca[student.id]?.text.trim() ?? '';
      final exam = _exam[student.id]?.text.trim() ?? '';
      if (ca.isNotEmpty && exam.isNotEmpty) await _saveOne(student);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All entered scores saved.')));
  }

  List<List<String>> _buildRows() {
    final rows = <List<String>>[
      ['StudentID', 'Name', 'CA', 'CA Max', 'Exams', 'Exam Max', 'Total', 'Grade', 'Registered'],
    ];
    for (final s in _roster) {
      final saved = _saved[s.id];
      rows.add([
        s.studentid,
        s.name,
        saved?['CA']?.toString() ?? '',
        saved?['caMax']?.toString() ?? '',
        saved?['Exams']?.toString() ?? '',
        saved?['examMax']?.toString() ?? '',
        saved?['totalScore']?.toString() ?? '',
        saved?['grade']?.toString() ?? '',
        _registeredStudentIds.contains(s.id) ? 'Yes' : 'No',
      ]);
    }
    return rows;
  }

  Uint8List _rowsToCsvBytes(List<List<String>> rows) {
    final csv = rows.map((r) => r.map((c) => c.contains(',') ? '"$c"' : c).join(',')).join('\n');
    return Uint8List.fromList(utf8.encode(csv));
  }

  Uint8List _rowsToXlsxBytes(List<List<String>> rows) {
    final book = xls.Excel.createExcel();
    final sheet = book['Scores'];
    book.setDefaultSheet('Scores');
    for (final row in rows) {
      sheet.appendRow(row.map((c) => xls.TextCellValue(c)).toList());
    }
    final bytes = book.save();
    return Uint8List.fromList(bytes ?? []);
  }

  Future<void> _download() async {
    final rows = _buildRows();
    final isCsv = _exportFormat == 'csv';
    final bytes = isCsv ? _rowsToCsvBytes(rows) : _rowsToXlsxBytes(rows);
    final extension = isCsv ? 'csv' : 'xlsx';
    final fileName = '${widget.allocation.courseCode}_scores.$extension';
    final mimeType = isCsv ? 'text/csv' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    try {
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [XTypeGroup(label: extension.toUpperCase(), extensions: [extension])],
      );
      if (location == null) return;
      final file = XFile.fromData(bytes, mimeType: mimeType, name: fileName);
      await file.saveTo(location.path);
      _snack('${extension.toUpperCase()} saved.');
    } catch (_) {
      if (isCsv) {
        await Clipboard.setData(ClipboardData(text: utf8.decode(bytes)));
        _snack('Could not save file — CSV copied to clipboard instead.', isError: true);
      } else {
        _snack('Could not save the file on this device.', isError: true);
      }
    }
  }

  List<List<String>> _parseCsvBytes(Uint8List bytes) {
    final lines = utf8.decode(bytes).split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    return lines.map((line) => line.split(',').map((c) => c.trim()).toList()).toList();
  }

  List<List<String>> _parseXlsxBytes(Uint8List bytes) {
    final book = xls.Excel.decodeBytes(bytes);
    final sheet = book.tables[book.tables.keys.first];
    if (sheet == null) return [];
    return sheet.rows
        .map((row) => row.map((cell) => cell?.value?.toString().trim() ?? '').toList())
        .where((row) => row.any((c) => c.isNotEmpty))
        .toList();
  }

  Future<void> _uploadFile() async {
    final file = await openFile(acceptedTypeGroups: const [
      XTypeGroup(label: 'Scores', extensions: ['csv', 'xlsx']),
    ]);
    if (file == null) return;
    final length = await file.length();
    if (length > _maxUploadBytes) {
      _snack('File exceeds the 10 MB upload limit.', isError: true);
      return;
    }
    final extension = file.name.split('.').last.toLowerCase();
    if (extension != 'csv' && extension != 'xlsx') {
      _snack('Only .csv or .xlsx files are accepted.', isError: true);
      return;
    }
    setState(() => _uploading = true);
    final bytes = await file.readAsBytes();
    final rows = extension == 'csv' ? _parseCsvBytes(bytes) : _parseXlsxBytes(bytes);
    final dataRows = rows.isNotEmpty ? rows.sublist(1) : rows;
    var matched = 0, skipped = 0;
    for (final cols in dataRows) {
      if (cols.length < 3) {
        skipped++;
        continue;
      }
      final studentId = cols[0].trim();
      final student = _roster.where((s) => s.studentid == studentId || s.id == studentId).firstOrNull;
      if (student == null) {
        skipped++;
        continue;
      }
      final ca = cols[2].trim();
      final exam = cols.length > 3 ? cols[3].trim() : '';
      if (ca.isEmpty || exam.isEmpty) {
        skipped++;
        continue;
      }
      _ca[student.id]?.text = ca;
      _exam[student.id]?.text = exam;
      await _saveOne(student);
      matched++;
    }
    if (!mounted) return;
    setState(() => _uploading = false);
    _snack('Uploaded: $matched recorded, $skipped skipped.');
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? scheme.error : scheme.primary));
  }

  Future<void> _addMaterial() async {
    if (_titleController.text.trim().isEmpty || _urlController.text.trim().isEmpty) return;
    final provider = _provider;
    final a = widget.allocation;
    final id = '${provider.schoolid}_${a.courseCode}_${DateTime.now().millisecondsSinceEpoch}';
    final model = CourseMaterialModel(
      id: id,
      schoolId: provider.schoolid,
      courseCode: a.courseCode,
      courseName: a.courseName,
      departmentId: a.departmentId,
      classOrLevel: a.classOrLevel,
      academicYear: a.academicYear,
      termOrSemester: a.termOrSemester,
      title: _titleController.text.trim(),
      url: _urlController.text.trim(),
      staffId: widget.staffId,
      staffName: widget.staffName,
    );
    await provider.db.collection('courseMaterials').doc(id).set(model.toMap());
    _titleController.clear();
    _urlController.clear();
    if (!mounted) return;
    setState(() => _materials = [model, ..._materials]);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final a = widget.allocation;

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
                Text('${a.courseCode}  ${a.courseName}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: scheme.onSurface)),
                const SizedBox(height: 4),
                Text('${a.classOrLevel} • ${a.termOrSemester} ${a.academicYear}', style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(
                  'CA $_caMin–$_caMax (scaled to $_caPercent%) • Exam $_examMin–$_examMax (scaled to $_examPercent%)',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'csv', label: Text('CSV')),
                ButtonSegment(value: 'xlsx', label: Text('Excel')),
              ],
              selected: {_exportFormat},
              onSelectionChanged: (v) => setState(() => _exportFormat = v.first),
            ),
            OutlinedButton.icon(onPressed: _download, icon: const Icon(Icons.download), label: const Text('Download roster')),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _uploadFile,
              icon: _uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload),
              label: const Text('Upload scores'),
            ),
            FilledButton.icon(onPressed: _saveAll, icon: const Icon(Icons.save), label: const Text('Save all')),
          ],
        ),
        const SizedBox(height: 16),
        if (_subject == null)
          Text('This course code has no registered subject record.', style: TextStyle(color: scheme.error))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _roster.length,
            itemBuilder: (context, i) {
              final s = _roster[i];
              final saved = _saved[s.id];
              final busy = _saving.contains(s.id);
              final isRegistered = _registeredStudentIds.contains(s.id);
              return Opacity(
                opacity: isRegistered ? 1 : 0.55,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('${s.name} (${s.studentid})', style: const TextStyle(fontWeight: FontWeight.w700))),
                            if (!isRegistered)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: const Text('Not registered'),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: scheme.errorContainer,
                                  labelStyle: TextStyle(color: scheme.onErrorContainer, fontSize: 11),
                                ),
                              ),
                            if (saved != null) Chip(label: Text(saved['grade']?.toString() ?? '-')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _ca[s.id],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'CA',
                                  border: const OutlineInputBorder(),
                                  errorText: _caError(_ca[s.id]?.text),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _exam[s.id],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'Exam',
                                  border: const OutlineInputBorder(),
                                  errorText: _examError(_exam[s.id]?.text),
                                ),
                              ),
                            ),
                            if (saved != null) Text('Total: ${saved['totalScore']}', style: TextStyle(color: scheme.onSurfaceVariant)),
                            FilledButton(
                              onPressed: (busy || _caError(_ca[s.id]?.text) != null || _examError(_exam[s.id]?.text) != null)
                                  ? null
                                  : () => _saveOne(s),
                              child: busy
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Save'),
                            ),
                          ],
                        ),
                        if (saved != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Entered: CA ${saved['CA']} of ${saved['caMin']}-${saved['caMax']} (scaled ${saved['scaledCA']}/${saved['caPercent']}) • '
                                      'Exam ${saved['Exams']} of ${saved['examMin']}-${saved['examMax']} (scaled ${saved['scaledExams']}/${saved['examPercent']})',
                                  style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                                ),
                                Text(
                                  'Entered by ${saved['enteredBy']} on ${saved['enteredAt']}',
                                  style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 24),
        Text('Course materials', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _materials.length,
          itemBuilder: (context, i) {
            final m = _materials[i];
            return ListTile(
              leading: const Icon(Icons.link),
              title: Text(m.title),
              subtitle: SelectableText(m.url),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => Clipboard.setData(ClipboardData(text: m.url)),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Material title', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'Link (URL)', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            FilledButton(onPressed: _addMaterial, child: const Text('Add')),
          ],
        ),
      ],
    );
  }
}