// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../components/academicyrmodel.dart';
// import '../controller/dbmodels/idformatmodel.dart';
// import '../controller/dbmodels/termmodel.dart';
// import '../controller/dbmodels/subjectmodel.dart';
// import '../controller/myprovider.dart';
// import '../controller/routes.dart';
// import 'academicyr.dart';
// import 'coursemounting.dart';
// import 'idformat.dart';
//
// class SetupWizardPage extends StatefulWidget {
//   const SetupWizardPage({super.key});
//
//   @override
//   State<SetupWizardPage> createState() => _SetupWizardPageState();
// }
//
// class _SetupWizardPageState extends State<SetupWizardPage> {
//   final _stepScrollController = ScrollController();
//   int _step = 0;
//   bool _locked = false;
//   bool _saving = false;
//   String _schoolType = 'Loading...';
//   String _period = 'First semester';
//   final _yearController = TextEditingController();
//   final _reopeningDates = <String>[];
//   final _caController = TextEditingController(text: '40');
//   final _examController = TextEditingController(text: '60');
//   final _caMinController = TextEditingController(text: '0');
//   final _caMaxController = TextEditingController(text: '40');
//   final _examMinController = TextEditingController(text: '0');
//   final _examMaxController = TextEditingController(text: '60');
//   final _idFormatController = TextEditingController();
//   final _facultyController = TextEditingController();
//   final _departmentController = TextEditingController();
//   final _levelController = TextEditingController();
//   final _courseCodeController = TextEditingController();
//   final _courseNameController = TextEditingController();
//   final _weightController = TextEditingController(text: '1');
//   final _creditHoursController = TextEditingController(text: '3');
//   final _creditMinController = TextEditingController(text: '0.0');
//   final _creditMaxController = TextEditingController(text: '30.0');
//   final _gradeMinController = TextEditingController(text: '80');
//   final _gradeMaxController = TextEditingController(text: '100');
//   final _gradeController = TextEditingController(text: 'A');
//   final _gradePointController = TextEditingController(text: '4');
//   final _remarksController = TextEditingController(text: 'Excellent');
//   final _teacherController = TextEditingController();
//   final _staffSearchController = TextEditingController();
//   final _facultyEntries = <String>[];
//   final _departmentEntries = <String>[];
//   final _levelEntries = <String>[];
//   final _termEntries = <String>[];
//   final _entryIds = <String, String>{};
//   final _departmentFaculties = <String, String>{};
//   final _groupDepartments = <String, String>{};
//   String? _selectedDepartment;
//   String? _selectedStaff;
//   String? _selectedCourse;
//   String _allocationSearch = '';
//   List<Map<String, dynamic>> _assignedAllocations = [];
//   bool _loadingAllocations = false;
//
//   final _steps = const [
//     ('School profile', 'Type and academic identity', Icons.school_outlined),
//     (
//       'Academic period',
//       'Year, semester or term',
//       Icons.calendar_month_outlined,
//     ),
//     (
//       'Structure',
//       'Faculties, departments and levels',
//       Icons.account_tree_outlined,
//     ),
//     (
//       'Courses / subjects',
//       'Register academic course records',
//       Icons.menu_book_outlined,
//     ),
//     (
//       'Course mounting',
//       'Mount core and elective records by class or level',
//       Icons.playlist_add_check_outlined,
//     ),
//     (
//       'Course allocation',
//       'Assign courses to staff and classes',
//       Icons.assignment_ind_outlined,
//     ),
//     ('Assessment', 'Scores, grading and credits', Icons.fact_check_outlined),
//     ('Review & lock', 'Confirm the setup', Icons.lock_outline),
//   ];
//
//   bool get _usesSemester => _schoolType != 'Pre-tertiary';
//   String get _periodLabel => _usesSemester ? 'Semester' : 'Term';
//   String get _groupLabel => _usesSemester ? 'Level' : 'Class';
//   String get _courseLabel => _usesSemester ? 'Course' : 'Subject';
//   String _stepTitle(int index) =>
//       index == 3 ? (_usesSemester ? 'Courses' : 'Subjects') : _steps[index].$1;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _loadSchoolType();
//       final provider = context.read<Myprovider>();
//       await Future.wait([
//         provider.fetchdepart(),
//         provider.fetchsubjects(),
//         provider.fetchstaff(),
//         provider.fetchacademicyear(),
//         provider.fetchIdFormats(),
//         provider.fetchterms(),
//       ]);
//       if (provider.terms.isNotEmpty) {
//         _termEntries
//           ..clear()
//           ..addAll(provider.terms.map((term) => term.name));
//         if (!_termEntries.contains(_period)) {
//           _period = _termEntries.first;
//         }
//       }
//       await _loadStructureEntries();
//       await _loadAllocations();
//     });
//   }
//
//   Future<void> _loadStructureEntries() async {
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     if (schoolId.isEmpty) return;
//     final results = await Future.wait([
//       provider.db
//           .collection('faculties')
//           .where('schoolId', isEqualTo: schoolId)
//           .get(),
//       provider.db
//           .collection('department')
//           .where('schoolId', isEqualTo: schoolId)
//           .get(),
//       provider.db
//           .collection('classes')
//           .where('schoolId', isEqualTo: schoolId)
//           .get(),
//     ]);
//     if (!mounted) return;
//     setState(() {
//       _facultyEntries
//         ..clear()
//         ..addAll(results[0].docs.map((doc) => (doc.data())['name'].toString()));
//       _departmentEntries
//         ..clear()
//         ..addAll(results[1].docs.map((doc) => (doc.data())['name'].toString()));
//       _levelEntries
//         ..clear()
//         ..addAll(
//           results[2].docs
//               .where((doc) => (doc.data())['schoolType'] == _schoolType)
//               .map((doc) => (doc.data())['name'].toString()),
//         );
//       for (final doc in results[1].docs) {
//         final data = doc.data();
//         _departmentFaculties[data['name'].toString()] =
//             data['faculty']?.toString() ?? '';
//       }
//       for (final doc in results[2].docs) {
//         final data = doc.data();
//         if (data['schoolType'] == _schoolType) {
//           _groupDepartments[data['name'].toString()] =
//               data['department']?.toString() ?? '';
//         }
//       }
//     });
//   }
//
//   Future<void> _loadAllocations() async {
//     final provider = context.read<Myprovider>();
//     if (provider.schoolid.isEmpty) return;
//     setState(() => _loadingAllocations = true);
//     final snapshot = await provider.db
//         .collection('courseAllocation')
//         .where('schoolId', isEqualTo: provider.schoolid)
//         .get();
//     if (!mounted) return;
//     setState(() {
//       _assignedAllocations = snapshot.docs
//           .map((doc) => {...doc.data(), 'id': doc.id})
//           .toList();
//       _loadingAllocations = false;
//     });
//   }
//
//   Future<void> _saveAllocation() async {
//     final provider = context.read<Myprovider>();
//     final courseCode = _selectedCourse;
//     final staffId = _selectedStaff;
//     final departmentId = _selectedDepartment;
//     if (courseCode == null || staffId == null || departmentId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Select a department, course and staff member first.'),
//         ),
//       );
//       return;
//     }
//     final period = _period.toLowerCase().replaceAll(' ', '_');
//     final id =
//         '${provider.schoolid}_${courseCode}_${staffId}_${_yearController.text.trim()}_$period';
//     await provider.db.collection('courseAllocation').doc(id).set({
//       'id': id,
//       'schoolId': provider.schoolid,
//       'courseCode': courseCode,
//       'staffId': staffId,
//       'departmentId': departmentId,
//       'classOrLevel': _levelController.text.trim(),
//       'academicYear': _yearController.text.trim(),
//       'termOrSemester': _period,
//       'createdAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//     await _loadAllocations();
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Course allocation saved.'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }
//
//   Future<void> _loadSchoolType() async {
//     final prefs = await SharedPreferences.getInstance();
//     final type = prefs.getString('schoolType');
//     if (!mounted) return;
//     final configuredType =
//         type == 'Tertiary' || type == 'SHS' || type == 'Pre-tertiary'
//         ? type!
//         : 'Not configured';
//     setState(() {
//       _schoolType = configuredType;
//       _period = configuredType == 'Pre-tertiary'
//           ? 'First term'
//           : 'First semester';
//     });
//   }
//
//   Future<void> _saveSchoolProfile() async {
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     final academicYear = _yearController.text.trim();
//     final idFormat = _idFormatController.text.trim();
//     if (schoolId.isEmpty || academicYear.isEmpty || idFormat.isEmpty) {
//       _showSaveMessage('Select an academic year and ID format first.', error: true);
//       return;
//     }
//     await provider.db.collection('schools').doc(schoolId).set({
//       'schoolType': _schoolType,
//       'periodType': _usesSemester ? 'Semester' : 'Term',
//       'studentIdFormat': idFormat,
//       'currentAcademicYear': academicYear,
//       'setupCompleted': false,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('schoolType', _schoolType);
//     _showSaveMessage('School profile saved.');
//   }
//
//   Future<void> _saveAcademicPeriod() async {
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     final academicYear = _yearController.text.trim();
//     if (schoolId.isEmpty || academicYear.isEmpty || _period.trim().isEmpty) {
//       _showSaveMessage('Select an academic year and period first.', error: true);
//       return;
//     }
//     await provider.db.collection('schools').doc(schoolId).set({
//       'currentAcademicYear': academicYear,
//       'currentTermOrSemester': _period,
//       'reopeningDates': _reopeningDates,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//     final prefs = await SharedPreferences.getInstance();
//     await Future.wait([
//       prefs.setString('year', academicYear),
//       prefs.setString('term', _period),
//     ]);
//     _showSaveMessage('Academic period saved.');
//   }
//
//   Future<void> _saveStructureSettings() async {
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     final creditMin = double.tryParse(_creditMinController.text.trim());
//     final creditMax = double.tryParse(_creditMaxController.text.trim());
//     if (schoolId.isEmpty ||
//         creditMin == null ||
//         creditMax == null ||
//         creditMin < 0 ||
//         creditMax < creditMin) {
//       _showSaveMessage('Enter valid credit-hour limits first.', error: true);
//       return;
//     }
//     await provider.db.collection('schools').doc(schoolId).set({
//       'creditHourMin': creditMin,
//       'creditHourMax': creditMax,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//     _showSaveMessage('Structure settings saved.');
//   }
//
//   Future<void> _saveAssessmentSettings() async {
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     final period = _period.toLowerCase().replaceAll(' ', '_');
//     final ca = double.tryParse(_caController.text.trim());
//     final exam = double.tryParse(_examController.text.trim());
//     final caMin = double.tryParse(_caMinController.text.trim());
//     final caMax = double.tryParse(_caMaxController.text.trim());
//     final examMin = double.tryParse(_examMinController.text.trim());
//     final examMax = double.tryParse(_examMaxController.text.trim());
//     if (schoolId.isEmpty ||
//         ca == null ||
//         exam == null ||
//         caMin == null ||
//         caMax == null ||
//         examMin == null ||
//         examMax == null ||
//         ca + exam != 100 ||
//         caMin < 0 ||
//         caMax < caMin ||
//         examMin < 0 ||
//         examMax < examMin) {
//       _showSaveMessage('CA and Exam must total 100% with valid ranges.', error: true);
//       return;
//     }
//     await provider.db.collection('scoreConfig').doc('${schoolId}_$period').set({
//       'schoolId': schoolId,
//       'academicYear': _yearController.text.trim(),
//       'termOrSemester': _period,
//       'caPercent': ca,
//       'examPercent': exam,
//       'caMin': caMin,
//       'caMax': caMax,
//       'examMin': examMin,
//       'examMax': examMax,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//     _showSaveMessage('Assessment settings saved.');
//   }
//
//   Future<void> _saveCurrentSection() async {
//     if (_saving) return;
//     setState(() => _saving = true);
//     try {
//       switch (_step) {
//         case 0:
//           await _saveSchoolProfile();
//         case 1:
//           await _saveAcademicPeriod();
//         case 2:
//           await _saveStructureSettings();
//         case 6:
//           await _saveAssessmentSettings();
//       }
//     } catch (error) {
//       _showSaveMessage('Section could not be saved: $error', error: true);
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   Future<void> _lockSetup() async {
//     if (_saving) return;
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Lock setup?'),
//         content: const Text(
//           'Lock the current setup? You can still view the records, but editing will be disabled.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Lock setup'),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true || !mounted) return;
//     final provider = context.read<Myprovider>();
//     await provider.db.collection('schools').doc(provider.schoolid.trim()).set({
//       'setupCompleted': true,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//     setState(() => _locked = true);
//     _showSaveMessage('Setup locked successfully.');
//   }
//
//   void _showSaveMessage(String message, {bool error = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: error ? Colors.red : Colors.green,
//       ),
//     );
//   }
//
//   Future<void> _registerAcademicYear() async {
//     final result = await showDialog<AcademicModel>(
//       context: context,
//       builder: (_) => Dialog(
//         child: SizedBox(width: 480, child: AcademicYr(embedded: true)),
//       ),
//     );
//     if (result != null && mounted) setState(() => _yearController.text = result.name);
//   }
//
//   Future<void> _editAcademicYear(AcademicModel year) async {
//     final result = await showDialog<AcademicModel>(
//       context: context,
//       builder: (_) => Dialog(
//         child: SizedBox(width: 480, child: AcademicYr(year: year, embedded: true)),
//       ),
//     );
//     if (result != null && mounted) setState(() => _yearController.text = result.name);
//   }
//
//
//
//   Future<void> _editIdFormat(IdformatModel format) async {
//     final result = await showDialog<IdformatModel>(
//       context: context,
//       builder: (_) => Dialog(
//         child: SizedBox(width: 480, child: IdformatScreen(idformatModel: format, embedded: true)),
//       ),
//     );
//     if (result != null && mounted) setState(() => _idFormatController.text = result.name);
//   }
//
//   Future<void> _registerIdFormat() async {
//     final controller = TextEditingController();
//     final name = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Register ID format'),
//         content: TextField(
//           controller: controller,
//           autofocus: true,
//           decoration: const InputDecoration(
//             labelText: 'ID format',
//             hintText: 'e.g. STU-{YEAR}-{0000}',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.pop(context, controller.text.trim()),
//             child: const Text('Register'),
//           ),
//         ],
//       ),
//     );
//     controller.dispose();
//     if (name == null || name.isEmpty || !mounted) return;
//
//     final provider = context.read<Myprovider>();
//     final formattedName = name.toUpperCase();
//     final docId =
//         '${provider.schoolid}_${formattedName.replaceAll(RegExp(r'\s+'), '')}';
//     final idFormat = IdformatModel(
//       id: docId,
//       name: formattedName,
//       schoolId: provider.schoolid,
//       staff: provider.name,
//     );
//     await provider.db
//         .collection('idformats')
//         .doc(docId)
//         .set(idFormat.toMap(), SetOptions(merge: true));
//     await provider.fetchIdFormats();
//     if (mounted) {
//       _idFormatController.text = formattedName;
//       setState(() {});
//     }
//   }
//
//   Future<void> _editTerm({String? currentValue}) async {
//     final controller = TextEditingController(text: currentValue ?? '');
//     final label = _usesSemester ? 'Semester' : 'Term';
//     final name = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(currentValue == null ? 'Add $label' : 'Edit $label'),
//         content: TextField(
//           controller: controller,
//           autofocus: true,
//           decoration: InputDecoration(
//             labelText: label,
//             hintText: _usesSemester ? 'e.g. First semester' : 'e.g. First term',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           FilledButton(
//             onPressed: () {
//               final value = controller.text.trim();
//               if (value.isNotEmpty) Navigator.pop(context, value);
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//     controller.dispose();
//     if (name == null || name.isEmpty || !mounted) return;
//     if (currentValue == null && _termEntries.contains(name)) return;
//
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     if (schoolId.isEmpty) return;
//     final normalized = name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
//     final id = '${schoolId}_${_usesSemester ? 'semester' : 'term'}_$normalized';
//     if (currentValue != null && currentValue != name) {
//       await _deleteTerm(currentValue, refresh: false);
//     }
//     await provider.db.collection('terms').doc(id).set({
//       ...TermModel(id: id, name: name, schoolId: schoolId).toMap(),
//       'schoolType': _schoolType,
//       'entryType': _usesSemester ? 'Semester' : 'Term',
//     }, SetOptions(merge: true));
//     await provider.fetchterms();
//     if (!mounted) return;
//     setState(() {
//       if (currentValue != null) _termEntries.remove(currentValue);
//       if (!_termEntries.contains(name)) _termEntries.add(name);
//       _period = name;
//     });
//   }
//
//   Future<void> _deleteTerm(String name, {bool refresh = true}) async {
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     final normalized = name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
//     final id = '${schoolId}_${_usesSemester ? 'semester' : 'term'}_$normalized';
//     await provider.db.collection('terms').doc(id).delete();
//     if (!mounted || !refresh) return;
//     await provider.fetchterms();
//     setState(() {
//       _termEntries.remove(name);
//       if (_period == name) {
//         _period = _termEntries.isNotEmpty
//             ? _termEntries.first
//             : (_usesSemester ? 'First semester' : 'First term');
//       }
//     });
//   }
//
//   Future<void> _confirmDeleteTerm(String name) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete ${_usesSemester ? 'semester' : 'term'}?'),
//         content: Text('Remove "$name" from the registered options?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//     if (confirmed == true) await _deleteTerm(name);
//   }
//
//   Widget _termPanel(ColorScheme scheme) {
//     final label = _usesSemester ? 'Semesters' : 'Terms';
//     final singular = _usesSemester ? 'Semester' : 'Term';
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: scheme.surface,
//         border: Border.all(color: scheme.outlineVariant),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   label,
//                   style: const TextStyle(fontWeight: FontWeight.w700),
//                 ),
//               ),
//               OutlinedButton.icon(
//                 onPressed: _locked ? null : () => _editTerm(),
//                 icon: const Icon(Icons.add, size: 17),
//                 label: const Text('Add'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           DropdownButtonFormField<String>(
//             initialValue: _termEntries.contains(_period) ? _period : null,
//             decoration: InputDecoration(
//               labelText: 'Select $singular',
//               border: const OutlineInputBorder(),
//             ),
//             hint: Text('Select a registered $singular'),
//             items: _termEntries
//                 .map((term) => DropdownMenuItem(value: term, child: Text(term)))
//                 .toList(),
//             onChanged: _locked
//                 ? null
//                 : (value) => setState(() => _period = value ?? ''),
//           ),
//           const SizedBox(height: 10),
//           if (_termEntries.isEmpty)
//             Text(
//               'No $singular registered yet.',
//               style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
//             )
//           else
//             ..._termEntries.asMap().entries.map(
//               (entry) => Container(
//                 constraints: const BoxConstraints(minHeight: 58),
//                 padding: const EdgeInsets.symmetric(vertical: 7),
//                 decoration: BoxDecoration(
//                   border: Border(top: BorderSide(color: scheme.outlineVariant)),
//                 ),
//                 child: Row(
//                   children: [
//                     SizedBox(width: 28, child: Text('${entry.key + 1}')),
//                     Expanded(
//                       child: InputDecorator(
//                         decoration: const InputDecoration(
//                           isDense: true,
//                           border: OutlineInputBorder(),
//                         ),
//                         child: Text(entry.value),
//                       ),
//                     ),
//                     IconButton(
//                       tooltip: 'Edit ${entry.value}',
//                       icon: const Icon(Icons.edit_outlined),
//                       onPressed: _locked
//                           ? null
//                           : () => _editTerm(currentValue: entry.value),
//                     ),
//                     IconButton(
//                       tooltip: 'Delete ${entry.value}',
//                       icon: const Icon(Icons.delete_outline, color: Colors.red),
//                       onPressed: _locked
//                           ? null
//                           : () => _confirmDeleteTerm(entry.value),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _deleteRegistered(
//     String collection,
//     String id,
//     String label,
//   ) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Remove registration?'),
//         content: Text('Remove "$label" from the registered options?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true || !mounted) return;
//     final provider = context.read<Myprovider>();
//     await provider.deleteData(collection, id);
//     if (collection == 'academicyears') {
//       await provider.fetchacademicyear();
//       if (_yearController.text == label) _yearController.clear();
//     } else {
//       await provider.fetchIdFormats();
//       if (_idFormatController.text == label) _idFormatController.clear();
//     }
//     if (mounted) setState(() {});
//   }
//
//   Future<void> _addReopeningDate() async {
//     final date = await showDatePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       initialDate: DateTime.now(),
//     );
//     if (date == null || !mounted) return;
//     final value =
//         '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//     if (!_reopeningDates.contains(value)) {
//       setState(() => _reopeningDates.add(value));
//     }
//   }
//
//   Widget _reopeningDatePanel(ColorScheme scheme) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: scheme.surface,
//         border: Border.all(color: scheme.outlineVariant),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Expanded(
//                 child: Text(
//                   'Reopening dates',
//                   style: TextStyle(fontWeight: FontWeight.w700),
//                 ),
//               ),
//               OutlinedButton.icon(
//                 onPressed: _locked ? null : _addReopeningDate,
//                 icon: const Icon(Icons.add, size: 17),
//                 label: const Text('Add'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (_reopeningDates.isEmpty)
//             Text(
//               'No reopening date registered yet.',
//               style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
//             )
//           else
//             ..._reopeningDates.asMap().entries.map(
//               (entry) => Container(
//                 constraints: const BoxConstraints(minHeight: 58),
//                 padding: const EdgeInsets.symmetric(vertical: 7),
//                 decoration: BoxDecoration(
//                   border: Border(top: BorderSide(color: scheme.outlineVariant)),
//                 ),
//                 child: Row(
//                   children: [
//                     SizedBox(width: 28, child: Text('${entry.key + 1}')),
//                     Expanded(
//                       child: InputDecorator(
//                         decoration: const InputDecoration(
//                           isDense: true,
//                           border: OutlineInputBorder(),
//                         ),
//                         child: Text(entry.value),
//                       ),
//                     ),
//                     IconButton(
//                       tooltip: 'Delete ${entry.value}',
//                       icon: const Icon(Icons.delete_outline, color: Colors.red),
//                       onPressed: _locked
//                           ? null
//                           : () => setState(
//                               () => _reopeningDates.remove(entry.value),
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // Widget _registeredSettingChoice({
//   //   required String label,
//   //   required String? value,
//   //   required List<String> options,
//   //   required ValueChanged<String?> onChanged,
//   //   required VoidCallback onRegister,
//   //   required ValueChanged<String> onDelete,
//   // }) {
//   //   final scheme = Theme.of(context).colorScheme;
//   //   return Container(
//   //     padding: const EdgeInsets.all(14),
//   //     decoration: BoxDecoration(
//   //       color: scheme.surface,
//   //       border: Border.all(color: scheme.outlineVariant),
//   //       borderRadius: BorderRadius.circular(12),
//   //     ),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Row(
//   //           children: [
//   //             Expanded(
//   //               child: Text(
//   //                 label,
//   //                 style: const TextStyle(fontWeight: FontWeight.w700),
//   //               ),
//   //             ),
//   //             OutlinedButton.icon(
//   //               onPressed: _locked ? null : onRegister,
//   //               icon: const Icon(Icons.add, size: 17),
//   //               label: const Text('Add'),
//   //             ),
//   //           ],
//   //         ),
//   //         const SizedBox(height: 12),
//   //         DropdownButtonFormField<String>(
//   //           initialValue: options.contains(value) ? value : null,
//   //           decoration: InputDecoration(
//   //             labelText: 'Select $label',
//   //             border: const OutlineInputBorder(),
//   //           ),
//   //           hint: Text('Select a registered $label'),
//   //           items: options
//   //               .map((item) => DropdownMenuItem(value: item, child: Text(item)))
//   //               .toList(),
//   //           onChanged: _locked ? null : onChanged,
//   //         ),
//   //         const SizedBox(height: 10),
//   //         if (options.isEmpty)
//   //           Text(
//   //             'No $label registered yet.',
//   //             style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
//   //           )
//   //         else
//   //           ...options.asMap().entries.map(
//   //             (entry) => Container(
//   //               constraints: const BoxConstraints(minHeight: 58),
//   //               padding: const EdgeInsets.symmetric(vertical: 7),
//   //               decoration: BoxDecoration(
//   //                 border: Border(top: BorderSide(color: scheme.outlineVariant)),
//   //               ),
//   //               child: Row(
//   //                 children: [
//   //                   SizedBox(width: 28, child: Text('${entry.key + 1}')),
//   //                   Expanded(
//   //                     child: InputDecorator(
//   //                       decoration: const InputDecoration(
//   //                         isDense: true,
//   //                         border: OutlineInputBorder(),
//   //                       ),
//   //                       child: Text(entry.value),
//   //                     ),
//   //                   ),
//   //                   IconButton(
//   //                     tooltip: 'Delete ${entry.value}',
//   //                     icon: const Icon(Icons.delete_outline, color: Colors.red),
//   //                     onPressed: _locked ? null : () => onDelete(entry.value),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   Widget _registeredSettingChoice({
//     required String label,
//     required String? value,
//     required List<String> options,
//     required ValueChanged<String?> onChanged,
//     required VoidCallback onRegister,
//     required ValueChanged<String> onEdit,   // NEW
//     required ValueChanged<String> onDelete,
//   }) {
//     final scheme = Theme.of(context).colorScheme;
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: scheme.surface,
//         border: Border.all(color: scheme.outlineVariant),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
//               OutlinedButton.icon(
//                 onPressed: _locked ? null : onRegister,
//                 icon: const Icon(Icons.add, size: 17),
//                 label: const Text('Add'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           DropdownButtonFormField<String>(
//             initialValue: options.contains(value) ? value : null,
//             decoration: InputDecoration(labelText: 'Select $label', border: const OutlineInputBorder()),
//             hint: Text('Select a registered $label'),
//             items: options.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
//             onChanged: _locked ? null : onChanged,
//           ),
//           const SizedBox(height: 10),
//           if (options.isEmpty)
//             Text('No $label registered yet.', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12))
//           else
//             ...options.asMap().entries.map(
//                   (entry) => Container(
//                 constraints: const BoxConstraints(minHeight: 58),
//                 padding: const EdgeInsets.symmetric(vertical: 7),
//                 decoration: BoxDecoration(
//                   border: Border(top: BorderSide(color: scheme.outlineVariant)),
//                 ),
//                 child: Row(
//                   children: [
//                     SizedBox(width: 28, child: Text('${entry.key + 1}')),
//                     Expanded(
//                       child: InputDecorator(
//                         decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
//                         child: Text(entry.value),
//                       ),
//                     ),
//                     IconButton(
//                       tooltip: 'Edit ${entry.value}',
//                       icon: const Icon(Icons.edit_outlined),
//                       onPressed: _locked ? null : () => onEdit(entry.value),
//                     ),
//                     IconButton(
//                       tooltip: 'Delete ${entry.value}',
//                       icon: const Icon(Icons.delete_outline, color: Colors.red),
//                       onPressed: _locked ? null : () => onDelete(entry.value),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//   Future<void> _editStructureEntry(
//       String kind,
//       List<String> entries, {
//         String? currentValue,
//       }) async {
//     final controller = TextEditingController();
//     controller.text = currentValue ?? '';
//     final isDepartment = kind == 'Department';
//     final isGroup = kind != 'Faculty' && kind != 'Department';
//     String? faculty = currentValue == null
//         ? null
//         : _departmentFaculties[currentValue];
//     String? department = currentValue == null
//         ? null
//         : _groupDepartments[currentValue];
//     final value = await showDialog<String>(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           title: Text(currentValue == null ? 'Add $kind' : 'Edit $kind'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: controller,
//                 autofocus: true,
//                 decoration: InputDecoration(labelText: '$kind name'),
//               ),
//               if (isDepartment) ...[
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   initialValue: _facultyEntries.contains(faculty)
//                       ? faculty
//                       : null,
//                   decoration: const InputDecoration(labelText: 'Faculty'),
//                   items: _facultyEntries
//                       .map(
//                         (item) =>
//                         DropdownMenuItem(value: item, child: Text(item)),
//                   )
//                       .toList(),
//                   onChanged: (next) => setDialogState(() => faculty = next),
//                 ),
//               ],
//               if (isGroup) ...[
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   initialValue: _departmentEntries.contains(department)
//                       ? department
//                       : null,
//                   decoration: const InputDecoration(
//                     labelText: 'Department / programme',
//                   ),
//                   items: _departmentEntries
//                       .map(
//                         (item) =>
//                         DropdownMenuItem(value: item, child: Text(item)),
//                   )
//                       .toList(),
//                   onChanged: (next) => setDialogState(() => department = next),
//                 ),
//               ],
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             FilledButton(
//               onPressed: () {
//                 if (controller.text.trim().isEmpty ||
//                     (isDepartment && faculty == null) ||
//                     (isGroup && department == null)) {
//                   return;
//                 }
//                 Navigator.pop(context, controller.text.trim());
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//     controller.dispose();
//     if (!mounted || value == null || value.isEmpty) {
//       return;
//     }
//     final provider = context.read<Myprovider>();
//     final schoolId = provider.schoolid.trim();
//     if (schoolId.isEmpty) return;
//     if (currentValue == null && entries.contains(value)) return;
//     if (currentValue != null && currentValue != value) {
//       await _deleteStructureEntry(kind, currentValue, refresh: false);
//     }
//     final id =
//         '${schoolId}_${kind.toLowerCase()}_${value.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';
//     final collection = kind == 'Faculty'
//         ? 'faculties'
//         : kind == 'Department'
//         ? 'department'
//         : 'classes';
//     await provider.db.collection(collection).doc(id).set({
//       'id': id,
//       'name': value,
//       'schoolId': schoolId,
//       'schoolType': _schoolType,
//       'entryType': kind,
//       if (isDepartment) 'faculty': faculty,
//       if (isGroup) 'department': department,
//       'createdAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//     if (mounted) {
//       setState(() {
//         if (currentValue != null) entries.remove(currentValue);
//         if (!entries.contains(value)) entries.add(value);
//         _entryIds['$kind:$value'] = id;
//         if (isDepartment && faculty != null) {
//           _departmentFaculties[value] = faculty!;
//         }
//         if (isGroup && department != null) {
//           _groupDepartments[value] = department!;
//         }
//       });
//     }
//   }
//
//   Future<void> _deleteStructureEntry(
//     String kind,
//     String value, {
//     bool refresh = true,
//   }) async {
//     final provider = context.read<Myprovider>();
//     final collection = kind == 'Faculty'
//         ? 'faculties'
//         : kind == 'Department'
//         ? 'department'
//         : 'classes';
//     final id =
//         _entryIds['$kind:$value'] ??
//         '${provider.schoolid}_${kind.toLowerCase()}_${value.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';
//     await provider.db.collection(collection).doc(id).delete();
//     if (!mounted || !refresh) return;
//     setState(() {
//       final entries = kind == 'Faculty'
//           ? _facultyEntries
//           : kind == 'Department'
//           ? _departmentEntries
//           : _levelEntries;
//       entries.remove(value);
//       _departmentFaculties.remove(value);
//       _groupDepartments.remove(value);
//     });
//   }
//
//   @override
//   void dispose() {
//     _stepScrollController.dispose();
//     _yearController.dispose();
//     _caController.dispose();
//     _examController.dispose();
//     _caMinController.dispose();
//     _caMaxController.dispose();
//     _examMinController.dispose();
//     _examMaxController.dispose();
//     for (final controller in [
//       _idFormatController,
//       _facultyController,
//       _departmentController,
//       _levelController,
//       _courseCodeController,
//       _courseNameController,
//       _weightController,
//       _creditHoursController,
//       _creditMinController,
//       _creditMaxController,
//       _gradeMinController,
//       _gradeMaxController,
//       _gradeController,
//       _gradePointController,
//       _remarksController,
//       _teacherController,
//       _staffSearchController,
//     ]) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'School setup wizard',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         // leading: IconButton(
//         //   tooltip: 'Back to dashboard',
//         //   icon: const Icon(Icons.arrow_back),
//         //   onPressed: () => Navigator.pop(context),
//         // ),
//         actions: [
//           if (_locked)
//             const Padding(
//               padding: EdgeInsets.only(right: 20),
//               child: Chip(
//                 avatar: Icon(Icons.lock, size: 16),
//                 label: Text('Locked'),
//               ),
//             ),
//         ],
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final compact = constraints.maxWidth < 850;
//           return Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 1180),
//               child: Padding(
//                 padding: EdgeInsets.all(compact ? 16 : 28),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Let’s get your school ready',
//                       style: Theme.of(context).textTheme.headlineSmall
//                           ?.copyWith(fontWeight: FontWeight.w800),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Complete the essentials once, then manage each area from the sidebar.',
//                       style: TextStyle(color: scheme.onSurfaceVariant),
//                     ),
//                     const SizedBox(height: 22),
//                     Expanded(
//                       child: compact
//                           ? _compactLayout(scheme)
//                           : Row(
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 _stepRail(scheme),
//                                 const SizedBox(width: 20),
//                                 Expanded(child: _content(scheme)),
//                               ],
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _compactLayout(ColorScheme scheme) {
//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             border: Border.all(color: scheme.outlineVariant),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               for (var index = 0; index < _steps.length; index++)
//                 ChoiceChip(
//                   label: Text('${index + 1}. ${_stepTitle(index)}'),
//                   selected: _step == index,
//                   onSelected: (_) => setState(() => _step = index),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),
//         Expanded(child: _content(scheme)),
//       ],
//     );
//   }
//
//   Widget _stepRail(ColorScheme scheme) {
//     return SizedBox(
//       width: 280,
//       child: Card(
//         margin: EdgeInsets.zero,
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'SETUP PROGRESS',
//                 style: TextStyle(
//                   fontSize: 11,
//                   letterSpacing: 1.2,
//                   fontWeight: FontWeight.w800,
//                   color: scheme.primary,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Expanded(
//                 child: Scrollbar(
//                   controller: _stepScrollController,
//                   thumbVisibility: true,
//                   child: ListView.builder(
//                     controller: _stepScrollController,
//                     padding: const EdgeInsets.only(right: 6),
//                     itemCount: _steps.length,
//                     itemBuilder: (context, index) {
//                       final selected = index == _step;
//                       final done = index < _step || _locked;
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 8),
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(10),
//                           onTap: _locked
//                               ? null
//                               : () => setState(() => _step = index),
//                           child: Container(
//                             padding: const EdgeInsets.all(11),
//                             decoration: BoxDecoration(
//                               color: selected
//                                   ? scheme.primaryContainer
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(
//                                 color: selected
//                                     ? scheme.primary.withValues(alpha: .35)
//                                     : scheme.outlineVariant,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 14,
//                                   backgroundColor: done
//                                       ? scheme.primary
//                                       : scheme.surfaceContainerHighest,
//                                   foregroundColor: done
//                                       ? scheme.onPrimary
//                                       : scheme.onSurfaceVariant,
//                                   child: done
//                                       ? const Icon(Icons.check, size: 16)
//                                       : Text(
//                                           '${index + 1}',
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         _stepTitle(index),
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 13,
//                                         ),
//                                       ),
//                                       Text(
//                                         _steps[index].$2,
//                                         style: TextStyle(
//                                           fontSize: 11,
//                                           color: scheme.onSurfaceVariant,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Icon(
//                                   _steps[index].$3,
//                                   size: 18,
//                                   color: scheme.onSurfaceVariant,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               LinearProgressIndicator(
//                 value: (_step + 1) / _steps.length,
//                 minHeight: 7,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 '${_step + 1} of ${_steps.length} sections',
//                 style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _content(ColorScheme scheme) {
//     final step = _steps[_step];
//     return Card(
//       margin: EdgeInsets.zero,
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(step.$3, color: scheme.primary),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     _stepTitle(_step),
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(step.$2, style: TextStyle(color: scheme.onSurfaceVariant)),
//             const SizedBox(height: 20),
//             Expanded(child: SingleChildScrollView(child: _stepBody(scheme))),
//             const Divider(height: 28),
//             Wrap(
//               alignment: WrapAlignment.spaceBetween,
//               crossAxisAlignment: WrapCrossAlignment.center,
//               runSpacing: 10,
//               spacing: 10,
//               children: [
//                 TextButton.icon(
//                   onPressed: _step == 0 ? null : () => setState(() => _step--),
//                   icon: const Icon(Icons.arrow_back),
//                   label: const Text('Back'),
//                 ),
//                 if (_step == 0 || _step == 1 || _step == 2 || _step == 6)
//                   OutlinedButton.icon(
//                     onPressed: _locked || _saving ? null : _saveCurrentSection,
//                     icon: const Icon(Icons.save_outlined),
//                     label: Text(_saving ? 'Saving...' : 'Save section'),
//                   ),
//                 _step == _steps.length - 1
//                     ? FilledButton.icon(
//                         onPressed: _locked || _saving ? null : _lockSetup,
//                         icon: Icon(_locked ? Icons.lock : Icons.lock_outline),
//                         label: Text(_locked ? 'Setup locked' : 'Lock setup'),
//                       )
//                     : FilledButton.icon(
//                         onPressed: () => setState(() => _step++),
//                         icon: const Icon(Icons.arrow_forward),
//                         label: const Text('Continue'),
//                       ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _openCourseRegistrationModal({
//     SubjectModel? initialRecord,
//   }) async {
//     final provider = context.read<Myprovider>();
//     final codeController = TextEditingController();
//     final nameController = TextEditingController();
//     final weightController = TextEditingController(text: '1');
//     final creditHoursController = TextEditingController(text: '3');
//     String? faculty = initialRecord == null
//         ? null
//         : _departmentFaculties[initialRecord.department];
//     String? department = initialRecord?.department;
//     String? group = initialRecord?.level;
//     String courseType = initialRecord?.type ?? 'Core';
//     String courseScope = initialRecord?.scope ?? 'Single department';
//     String search = '';
//     SubjectModel? editing = initialRecord;
//     if (initialRecord != null) {
//       codeController.text = initialRecord.code ?? '';
//       nameController.text = initialRecord.name;
//       weightController.text = initialRecord.weight.toString();
//       creditHoursController.text = initialRecord.creditHours.toString();
//     }
//
//     Future<void> saveRecord(StateSetter setDialogState) async {
//       final code = codeController.text.trim().toUpperCase();
//       final name = nameController.text.trim().toUpperCase();
//       final weight = double.tryParse(weightController.text.trim());
//       final creditHours = double.tryParse(creditHoursController.text.trim());
//       if (code.isEmpty ||
//           name.isEmpty ||
//           faculty == null ||
//           department == null ||
//           group == null ||
//           weight == null ||
//           creditHours == null) {
//         return;
//       }
//       final id = '${provider.schoolid}_$code';
//       if (editing != null && editing!.id != id) {
//         await provider.db.collection('subjects').doc(editing!.id).delete();
//       }
//       final data = SubjectModel(
//         id: id,
//         code: code,
//         name: name,
//         schoolId: provider.schoolid,
//         department: department,
//         level: group,
//         weight: weight,
//         creditHours: creditHours,
//         creditHourMin: double.tryParse(_creditMinController.text) ?? 0,
//         creditHourMax: double.tryParse(_creditMaxController.text) ?? 30,
//         type: courseType,
//         scope: courseScope,
//       ).toMap();
//       data['faculty'] = faculty;
//       data['schoolType'] = _schoolType;
//       data['entryType'] = _courseLabel;
//       await provider.db
//           .collection('subjects')
//           .doc(id)
//           .set(data, SetOptions(merge: true));
//       await provider.fetchsubjects();
//       if (!mounted) return;
//       final saved = provider.subjectList.firstWhere(
//             (item) => item.id == id,
//         orElse: () => SubjectModel(id: id, code: code, name: name),
//       );
//       setState(() {
//         _courseCodeController.text = code;
//         _courseNameController.text = name;
//         _facultyController.text = faculty!;
//         _departmentController.text = department!;
//         _levelController.text = group!;
//         _selectedCourse = code;
//       });
//       editing = saved;
//       setDialogState(() {});
//     }
//
//     Future<void> deleteRecord(
//         SubjectModel record,
//         StateSetter setDialogState,
//         ) async {
//       final confirmed = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Delete ${_courseLabel.toLowerCase()}?'),
//           content: Text('Remove "${record.name}" from the registered records?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Delete', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         ),
//       );
//       if (confirmed != true) return;
//       await provider.db.collection('subjects').doc(record.id).delete();
//       await provider.fetchsubjects();
//       if (editing?.id == record.id) editing = null;
//       setDialogState(() {});
//     }
//
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           final records = provider.subjectList.where((record) {
//             final query = search.toLowerCase();
//             return record.name.toLowerCase().contains(query) ||
//                 (record.code ?? '').toLowerCase().contains(query);
//           }).toList();
//
//           // Filtered + de-duplicated option lists, scoped to the parent selection.
//           final departmentOptions = _departmentEntries
//               .where((d) => faculty == null || _departmentFaculties[d] == faculty)
//               .toSet()
//               .toList();
//           final groupOptions = _levelEntries
//               .where((l) => department == null || _groupDepartments[l] == department)
//               .toSet()
//               .toList();
//           final facultyOptions = _facultyEntries.toSet().toList();
//
//           return AlertDialog(
//             title: Row(
//               children: [
//                 Icon(_usesSemester ? Icons.menu_book : Icons.book_outlined),
//                 const SizedBox(width: 8),
//                 Text('Register $_courseLabel'),
//               ],
//             ),
//             content: SizedBox(
//               width: 760,
//               height: 620,
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextFormField(
//                       controller: codeController,
//                       decoration: InputDecoration(
//                         labelText: '$_courseLabel code',
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: nameController,
//                       decoration: InputDecoration(
//                         labelText: '$_courseLabel name',
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue:
//                       facultyOptions.contains(faculty) ? faculty : null,
//                       decoration: const InputDecoration(labelText: 'Faculty'),
//                       items: facultyOptions
//                           .map(
//                             (item) => DropdownMenuItem(
//                           value: item,
//                           child: Text(item),
//                         ),
//                       )
//                           .toList(),
//                       onChanged: (value) => setDialogState(() {
//                         faculty = value;
//                         // Drop department/group if they no longer belong to this faculty.
//                         if (department != null &&
//                             _departmentFaculties[department] != faculty) {
//                           department = null;
//                           group = null;
//                         }
//                       }),
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue: departmentOptions.contains(department)
//                           ? department
//                           : null,
//                       decoration: const InputDecoration(
//                         labelText: 'Department / programme',
//                       ),
//                       items: departmentOptions
//                           .map(
//                             (item) => DropdownMenuItem(
//                           value: item,
//                           child: Text(item),
//                         ),
//                       )
//                           .toList(),
//                       onChanged: (value) => setDialogState(() {
//                         department = value;
//                         faculty = _departmentFaculties[value] ?? faculty;
//                         // Drop group if it no longer belongs to this department.
//                         if (group != null &&
//                             _groupDepartments[group] != department) {
//                           group = null;
//                         }
//                       }),
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue:
//                       groupOptions.contains(group) ? group : null,
//                       decoration: InputDecoration(labelText: _groupLabel),
//                       items: groupOptions
//                           .map(
//                             (item) => DropdownMenuItem(
//                           value: item,
//                           child: Text(item),
//                         ),
//                       )
//                           .toList(),
//                       onChanged: (value) => setDialogState(() {
//                         group = value;
//                         department = _groupDepartments[value] ?? department;
//                         faculty = _departmentFaculties[department] ?? faculty;
//                       }),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             controller: weightController,
//                             keyboardType: const TextInputType.numberWithOptions(
//                               decimal: true,
//                             ),
//                             decoration: const InputDecoration(
//                               labelText: 'Weight',
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextFormField(
//                             controller: creditHoursController,
//                             keyboardType: const TextInputType.numberWithOptions(
//                               decimal: true,
//                             ),
//                             decoration: const InputDecoration(
//                               labelText: 'Credit hours',
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue: courseType,
//                       decoration: const InputDecoration(labelText: 'Type'),
//                       items: const ['Core', 'Elective']
//                           .map(
//                             (item) => DropdownMenuItem(
//                           value: item,
//                           child: Text(item),
//                         ),
//                       )
//                           .toList(),
//                       onChanged: (value) =>
//                           setDialogState(() => courseType = value ?? 'Core'),
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue: courseScope,
//                       decoration: const InputDecoration(labelText: 'Scope'),
//                       items: const ['Single department', 'All departments']
//                           .map(
//                             (item) => DropdownMenuItem(
//                           value: item,
//                           child: Text(item),
//                         ),
//                       )
//                           .toList(),
//                       onChanged: (value) => setDialogState(
//                             () => courseScope = value ?? 'Single department',
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             'Registered ${_courseLabel.toLowerCase()}s',
//                             style: const TextStyle(fontWeight: FontWeight.w800),
//                           ),
//                         ),
//                         if (editing != null)
//                           TextButton(
//                             onPressed: () => setDialogState(() {
//                               editing = null;
//                               codeController.clear();
//                               nameController.clear();
//                             }),
//                             child: const Text('Clear form'),
//                           ),
//                       ],
//                     ),
//                     TextField(
//                       onChanged: (value) =>
//                           setDialogState(() => search = value),
//                       decoration: const InputDecoration(
//                         labelText: 'Search registered records',
//                         prefixIcon: Icon(Icons.search),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     if (records.isEmpty)
//                       const Padding(
//                         padding: EdgeInsets.all(12),
//                         child: Text('No registered records found.'),
//                       )
//                     else
//                       ...records.map(
//                             (record) => ListTile(
//                           dense: true,
//                           title: Text('${record.code ?? ''}  ${record.name}'),
//                           subtitle: Text(
//                             '${record.department ?? ''} • ${record.level ?? ''}',
//                           ),
//                           onTap: () {
//                             editing = record;
//                             codeController.text = record.code ?? '';
//                             nameController.text = record.name;
//                             department = record.department;
//                             group = record.level;
//                             faculty = _departmentFaculties[department];
//                             weightController.text = record.weight.toString();
//                             creditHoursController.text = record.creditHours
//                                 .toString();
//                             courseType = record.type;
//                             courseScope = record.scope;
//                             setDialogState(() {});
//                           },
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 tooltip: 'Edit ${record.name}',
//                                 icon: const Icon(Icons.edit_outlined),
//                                 onPressed: () {
//                                   editing = record;
//                                   codeController.text = record.code ?? '';
//                                   nameController.text = record.name;
//                                   department = record.department;
//                                   group = record.level;
//                                   faculty = _departmentFaculties[department];
//                                   weightController.text = record.weight
//                                       .toString();
//                                   creditHoursController.text = record
//                                       .creditHours
//                                       .toString();
//                                   courseType = record.type;
//                                   courseScope = record.scope;
//                                   setDialogState(() {});
//                                 },
//                               ),
//                               IconButton(
//                                 tooltip: 'Delete ${record.name}',
//                                 icon: const Icon(
//                                   Icons.delete_outline,
//                                   color: Colors.red,
//                                 ),
//                                 onPressed: () =>
//                                     deleteRecord(record, setDialogState),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(dialogContext),
//                 child: const Text('Close'),
//               ),
//               FilledButton.icon(
//                 onPressed: () => saveRecord(setDialogState),
//                 icon: Icon(editing == null ? Icons.add : Icons.save),
//                 label: Text(editing == null ? 'Register' : 'Update'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//     codeController.dispose();
//     nameController.dispose();
//     weightController.dispose();
//     creditHoursController.dispose();
//   }
//   Future<void> _openRegisteredCoursesModal() async {
//     final provider = context.read<Myprovider>();
//     String search = '';
//
//     Future<void> deleteRecord(
//       SubjectModel record,
//       StateSetter setDialogState,
//     ) async {
//       final confirmed = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Delete ${_courseLabel.toLowerCase()}?'),
//           content: Text('Remove "${record.name}" from the registered records?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Delete', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         ),
//       );
//       if (confirmed != true) return;
//       await provider.db.collection('subjects').doc(record.id).delete();
//       await provider.fetchsubjects();
//       if (_selectedCourse == record.code && mounted) {
//         setState(() => _selectedCourse = null);
//       }
//       setDialogState(() {});
//     }
//
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           final query = search.trim().toLowerCase();
//           final records = provider.subjectList.where((record) {
//             return query.isEmpty ||
//                 record.name.toLowerCase().contains(query) ||
//                 (record.code ?? '').toLowerCase().contains(query) ||
//                 (record.department ?? '').toLowerCase().contains(query) ||
//                 (record.level ?? '').toLowerCase().contains(query);
//           }).toList();
//           return AlertDialog(
//             title: Text('Registered ${_courseLabel}s'),
//             content: SizedBox(
//               width: 900,
//               height: 560,
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   final desktop = constraints.maxWidth >= 650;
//                   return Column(
//                     children: [
//                       TextField(
//                         onChanged: (value) =>
//                             setDialogState(() => search = value),
//                         decoration: const InputDecoration(
//                           labelText: 'Search registered records',
//                           prefixIcon: Icon(Icons.search),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Expanded(
//                         child: records.isEmpty
//                             ? const Center(
//                                 child: Text('No registered records found.'),
//                               )
//                             : desktop
//                             ? SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: SingleChildScrollView(
//                                   child: DataTable(
//                                     columns: const [
//                                       DataColumn(label: Text('#')),
//                                       DataColumn(label: Text('Code')),
//                                       DataColumn(label: Text('Name')),
//                                       DataColumn(label: Text('Faculty')),
//                                       DataColumn(label: Text('Department')),
//                                       DataColumn(label: Text('Class / Level')),
//                                       DataColumn(label: Text('Credits')),
//                                       DataColumn(label: Text('Action')),
//                                     ],
//                                     rows: records.asMap().entries.map((entry) {
//                                       final record = entry.value;
//                                       final faculty =
//                                           _departmentFaculties[record
//                                               .department] ??
//                                           '';
//                                       return DataRow(
//                                         cells: [
//                                           DataCell(Text('${entry.key + 1}')),
//                                           DataCell(Text(record.code ?? '')),
//                                           DataCell(Text(record.name)),
//                                           DataCell(Text(faculty)),
//                                           DataCell(
//                                             Text(record.department ?? ''),
//                                           ),
//                                           DataCell(Text(record.level ?? '')),
//                                           DataCell(
//                                             Text(record.creditHours.toString()),
//                                           ),
//                                           DataCell(
//                                             Row(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 IconButton(
//                                                   tooltip:
//                                                       'Edit ${record.name}',
//                                                   icon: const Icon(
//                                                     Icons.edit_outlined,
//                                                   ),
//                                                   onPressed: () async {
//                                                     Navigator.pop(
//                                                       dialogContext,
//                                                     );
//                                                     await _openCourseRegistrationModal(
//                                                       initialRecord: record,
//                                                     );
//                                                   },
//                                                 ),
//                                                 IconButton(
//                                                   tooltip:
//                                                       'Delete ${record.name}',
//                                                   icon: const Icon(
//                                                     Icons.delete_outline,
//                                                     color: Colors.red,
//                                                   ),
//                                                   onPressed: () => deleteRecord(
//                                                     record,
//                                                     setDialogState,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     }).toList(),
//                                   ),
//                                 ),
//                               )
//                             : ListView.separated(
//                                 itemCount: records.length,
//                                 separatorBuilder: (_, __) =>
//                                     const Divider(height: 1),
//                                 itemBuilder: (context, index) {
//                                   final record = records[index];
//                                   final faculty =
//                                       _departmentFaculties[record.department] ??
//                                       '';
//                                   return ListTile(
//                                     leading: CircleAvatar(
//                                       child: Text('${index + 1}'),
//                                     ),
//                                     title: Text(
//                                       '${record.code ?? ''}  ${record.name}',
//                                     ),
//                                     subtitle: Text(
//                                       'Faculty: $faculty\nDepartment: ${record.department ?? ''}\nClass / Level: ${record.level ?? ''}\nCredits: ${record.creditHours} | Weight: ${record.weight}',
//                                     ),
//                                     isThreeLine: true,
//                                     trailing: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         IconButton(
//                                           tooltip: 'Edit ${record.name}',
//                                           icon: const Icon(Icons.edit_outlined),
//                                           onPressed: () async {
//                                             Navigator.pop(dialogContext);
//                                             await _openCourseRegistrationModal(
//                                               initialRecord: record,
//                                             );
//                                           },
//                                         ),
//                                         IconButton(
//                                           tooltip: 'Delete ${record.name}',
//                                           icon: const Icon(
//                                             Icons.delete_outline,
//                                             color: Colors.red,
//                                           ),
//                                           onPressed: () => deleteRecord(
//                                             record,
//                                             setDialogState,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(dialogContext),
//                 child: const Text('Close'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _openGradingScaleModal({String? initialId}) async {
//     final provider = context.read<Myprovider>();
//     final departmentOptions = provider.departments;
//     String scope = initialId?.endsWith('_default') == true
//         ? 'Default'
//         : 'Department';
//     String? departmentId;
//     List<Map<String, dynamic>> bands = [
//       {
//         'min': '0',
//         'max': '49.9',
//         'grade': 'F',
//         'weight': '0',
//         'remarks': 'Needs improvement',
//       },
//       {
//         'min': '50',
//         'max': '59.9',
//         'grade': 'C',
//         'weight': '1',
//         'remarks': 'Satisfactory',
//       },
//       {
//         'min': '60',
//         'max': '69.9',
//         'grade': 'B',
//         'weight': '2',
//         'remarks': 'Good',
//       },
//       {
//         'min': '70',
//         'max': '100',
//         'grade': 'A',
//         'weight': '3',
//         'remarks': 'Excellent',
//       },
//     ];
//     if (initialId != null) {
//       final snapshot = await provider.db
//           .collection('gradingsystems')
//           .doc(initialId)
//           .get();
//       final data = snapshot.data();
//       if (data != null) {
//         scope = data['scope'] == 'department' ? 'Department' : 'Default';
//         departmentId = data['departmentId']?.toString();
//         final stored = data['bands'] ?? data['gradingsystem']?.first?['grades'];
//         if (stored is List && stored.isNotEmpty) {
//           bands = stored
//               .map<Map<String, dynamic>>(
//                 (item) => {
//                   'min': '${item['minScore'] ?? item['min'] ?? 0}',
//                   'max': '${item['maxScore'] ?? item['max'] ?? 0}',
//                   'grade': '${item['grade'] ?? ''}',
//                   'weight': '${item['weight'] ?? 0}',
//                   'remarks': '${item['remarks'] ?? item['remark'] ?? ''}',
//                 },
//               )
//               .toList();
//         }
//       }
//     }
//     if (!mounted) return;
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setModalState) {
//           final validation = _validateGradeBands(bands);
//           return AlertDialog(
//             title: Text(
//               initialId == null ? 'Add grading scale' : 'Edit grading scale',
//             ),
//             content: SizedBox(
//               width: 900,
//               height: 620,
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           initialValue: scope,
//                           decoration: const InputDecoration(
//                             labelText: 'Scale scope',
//                           ),
//                           items: const [
//                             DropdownMenuItem(
//                               value: 'Default',
//                               child: Text('School default'),
//                             ),
//                             DropdownMenuItem(
//                               value: 'Department',
//                               child: Text('Department scale'),
//                             ),
//                           ],
//                           onChanged: (value) =>
//                               setModalState(() => scope = value ?? 'Default'),
//                         ),
//                       ),
//                       if (scope == 'Department') ...[
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: DropdownButtonFormField<String>(
//                             initialValue: departmentId,
//                             decoration: const InputDecoration(
//                               labelText: 'Department',
//                             ),
//                             items: departmentOptions
//                                 .map(
//                                   (item) => DropdownMenuItem(
//                                     value: item.id,
//                                     child: Text(item.name),
//                                   ),
//                                 )
//                                 .toList(),
//                             onChanged: (value) =>
//                                 setModalState(() => departmentId = value),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: bands.length,
//                       itemBuilder: (context, index) {
//                         final band = bands[index];
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 8),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: TextFormField(
//                                   initialValue: band['min'],
//                                   decoration: const InputDecoration(
//                                     labelText: 'Min',
//                                   ),
//                                   onChanged: (value) => band['min'] = value,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: TextFormField(
//                                   initialValue: band['max'],
//                                   decoration: const InputDecoration(
//                                     labelText: 'Max',
//                                   ),
//                                   onChanged: (value) => band['max'] = value,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: TextFormField(
//                                   initialValue: band['grade'],
//                                   decoration: const InputDecoration(
//                                     labelText: 'Grade',
//                                   ),
//                                   onChanged: (value) => band['grade'] = value,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: TextFormField(
//                                   initialValue: band['weight'],
//                                   decoration: const InputDecoration(
//                                     labelText: 'Weight',
//                                   ),
//                                   onChanged: (value) => band['weight'] = value,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 flex: 2,
//                                 child: TextFormField(
//                                   initialValue: band['remarks'],
//                                   decoration: const InputDecoration(
//                                     labelText: 'Remarks',
//                                   ),
//                                   onChanged: (value) => band['remarks'] = value,
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.delete_outline,
//                                   color: Colors.red,
//                                 ),
//                                 onPressed: bands.length <= 1
//                                     ? null
//                                     : () => setModalState(
//                                         () => bands.removeAt(index),
//                                       ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Text(
//                     validation ?? 'Scale ranges are valid.',
//                     style: TextStyle(
//                       color: validation == null ? Colors.green : Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(dialogContext),
//                 child: const Text('Cancel'),
//               ),
//               OutlinedButton.icon(
//                 onPressed: () => setModalState(
//                   () => bands.add({
//                     'min': '',
//                     'max': '',
//                     'grade': '',
//                     'weight': '',
//                     'remarks': '',
//                   }),
//                 ),
//                 icon: const Icon(Icons.add),
//                 label: const Text('Add grade'),
//               ),
//               FilledButton.icon(
//                 onPressed:
//                     validation != null ||
//                         (scope == 'Department' && departmentId == null)
//                     ? null
//                     : () async {
//                         final schoolId = provider.schoolid;
//                         final id = scope == 'Default'
//                             ? '${schoolId}_default'
//                             : '${schoolId}_${departmentId!.toLowerCase()}';
//                         await provider.db
//                             .collection('gradingsystems')
//                             .doc(id)
//                             .set({
//                               'id': id,
//                               'schoolid': schoolId,
//                               'scope': scope == 'Default'
//                                   ? 'default'
//                                   : 'department',
//                               'departmentId': scope == 'Default'
//                                   ? null
//                                   : departmentId,
//                               'name': scope == 'Default'
//                                   ? 'School default'
//                                   : departmentOptions
//                                         .firstWhere(
//                                           (item) => item.id == departmentId,
//                                         )
//                                         .name,
//                               'bands': bands
//                                   .map(
//                                     (band) => {
//                                       'minScore': double.parse(
//                                         band['min'].toString(),
//                                       ),
//                                       'maxScore': double.parse(
//                                         band['max'].toString(),
//                                       ),
//                                       'grade': band['grade'],
//                                       'weight': double.parse(
//                                         band['weight'].toString(),
//                                       ),
//                                       'remarks': band['remarks'],
//                                     },
//                                   )
//                                   .toList(),
//                               'updatedAt': FieldValue.serverTimestamp(),
//                             }, SetOptions(merge: true));
//                         if (dialogContext.mounted) Navigator.pop(dialogContext);
//                       },
//                 icon: const Icon(Icons.save),
//                 label: const Text('Save scale'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   String? _validateGradeBands(List<Map<String, dynamic>> bands) {
//     final ranges = <List<double>>[];
//     for (final band in bands) {
//       final min = double.tryParse(band['min'].toString());
//       final max = double.tryParse(band['max'].toString());
//       if (min == null || max == null || max <= min) {
//         return 'Every range must have valid min and max values.';
//       }
//       ranges.add([min, max]);
//     }
//     ranges.sort((a, b) => a[0].compareTo(b[0]));
//     for (var index = 1; index < ranges.length; index++) {
//       if (ranges[index][0] < ranges[index - 1][1] + 0.1) {
//         return 'Grade ranges overlap. Leave at least 0.1 between boundaries.';
//       }
//     }
//     return null;
//   }
//
//   Future<void> _viewGradingScales() async {
//     final provider = context.read<Myprovider>();
//     final snapshot = await provider.db
//         .collection('gradingsystems')
//         .where('schoolid', isEqualTo: provider.schoolid)
//         .get();
//     if (!mounted) return;
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('View grading scales'),
//         content: SizedBox(
//           width: 760,
//           height: 500,
//           child: ListView.builder(
//             itemCount: snapshot.docs.length,
//             itemBuilder: (context, index) {
//               final doc = snapshot.docs[index];
//               final data = doc.data();
//               final bands = (data['bands'] as List?)?.length ?? 0;
//               return ListTile(
//                 title: Text(data['name']?.toString() ?? doc.id),
//                 subtitle: Text('${data['scope'] ?? 'default'} • $bands grades'),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.edit_outlined),
//                   onPressed: () {
//                     Navigator.pop(dialogContext);
//                     _openGradingScaleModal(initialId: doc.id);
//                   },
//                 ),
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _gradingScaleManager(ColorScheme scheme) => Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       border: Border.all(color: scheme.outlineVariant),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Row(
//       children: [
//         const Icon(Icons.rule_folder_outlined),
//         const SizedBox(width: 12),
//         const Expanded(
//           child: Text(
//             'Grading scale',
//             style: TextStyle(fontWeight: FontWeight.w800),
//           ),
//         ),
//         OutlinedButton.icon(
//           onPressed: _openGradingScaleModal,
//           icon: const Icon(Icons.add),
//           label: const Text('Add scale'),
//         ),
//         const SizedBox(width: 8),
//         FilledButton.icon(
//           onPressed: _viewGradingScales,
//           icon: const Icon(Icons.visibility_outlined),
//           label: const Text('View scales'),
//         ),
//       ],
//     ),
//   );
//
//   Widget _stepBody(ColorScheme scheme) {
//     switch (_step) {
//       case 0:
//         final provider = context.watch<Myprovider>();
//         return _fields([
//           InputDecorator(
//             decoration: const InputDecoration(
//               labelText: 'School type',
//               prefixIcon: Icon(Icons.lock_outline),
//             ),
//             child: Text(_schoolType),
//           ),
//           _registeredSettingChoice(
//             label: 'Academic year',
//             value: _yearController.text,
//             options: provider.academicyears.map((year) => year.name).toList(),
//             onChanged: (value) => setState(() => _yearController.text = value ?? ''),
//             onRegister: _registerAcademicYear,
//             onEdit: (name) {
//               final year = provider.academicyears.firstWhere((item) => item.name == name);
//               _editAcademicYear(year);
//             },
//             onDelete: (name) {
//               final year = provider.academicyears.firstWhere((item) => item.name == name);
//               _deleteRegistered('academicyears', year.id, name);
//             },
//           ),
//           _registeredSettingChoice(
//             label: 'ID format',
//             value: _idFormatController.text,
//             options: provider.idFormats.map((format) => format.name).toList(),
//             onChanged: (value) => setState(() => _idFormatController.text = value ?? ''),
//             onRegister: _registerIdFormat,
//             onEdit: (name) {
//               final format = provider.idFormats.firstWhere((item) => item.name == name);
//               _editIdFormat(format);
//             },
//             onDelete: (name) {
//               final format = provider.idFormats.firstWhere((item) => item.name == name);
//               _deleteRegistered('idformats', format.id, name);
//             },
//           ),
//           _registeredSettingChoice(
//             label: 'ID format',
//             value: _idFormatController.text,
//             options: provider.idFormats.map((format) => format.name).toList(),
//             onChanged: (value) =>
//                 setState(() => _idFormatController.text = value ?? ''),
//             onRegister: _registerIdFormat,
//             onDelete: (name) {
//               final format = provider.idFormats.firstWhere(
//                 (item) => item.name == name,
//               );
//               _deleteRegistered('idformats', format.id, name);
//             }, onEdit: (String value) {  },
//           ),
//         ]);
//       case 1:
//         return _fields([
//           _termPanel(scheme),
//           _reopeningDatePanel(scheme),
//           TextFormField(
//             enabled: !_locked,
//             decoration: const InputDecoration(
//               labelText: 'Next school fees amount',
//             ),
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//           ),
//         ]);
//       case 2:
//         return _fields([
//           _structurePanel('Faculty', 'Faculty', _facultyEntries, scheme),
//           _structurePanel(
//             'Department / programme',
//             'Department',
//             _departmentEntries,
//             scheme,
//           ),
//           _structurePanel(_groupLabel, _groupLabel, _levelEntries, scheme),
//           TextFormField(
//             controller: _creditMinController,
//             enabled: !_locked,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: const InputDecoration(
//               labelText: 'School credit-hour minimum',
//             ),
//           ),
//           TextFormField(
//             controller: _creditMaxController,
//             enabled: !_locked,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: const InputDecoration(
//               labelText: 'School credit-hour maximum',
//             ),
//           ),
//         ]);
//       case 3:
//         final provider = context.watch<Myprovider>();
//         final selected = provider.subjectList.where(
//           (item) => item.code == _selectedCourse,
//         );
//         return Container(
//           padding: const EdgeInsets.all(18),
//           decoration: BoxDecoration(
//             border: Border.all(color: scheme.outlineVariant),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(_usesSemester ? Icons.menu_book : Icons.book_outlined),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       'Register $_courseLabel',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w800,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Wrap(
//                 spacing: 10,
//                 runSpacing: 10,
//                 children: [
//                   OutlinedButton.icon(
//                     onPressed: _locked ? null : _openCourseRegistrationModal,
//                     icon: const Icon(Icons.add),
//                     label: Text('Register $_courseLabel'),
//                   ),
//                   FilledButton.icon(
//                     onPressed: _openRegisteredCoursesModal,
//                     icon: const Icon(Icons.visibility_outlined),
//                     label: Text('View registered $_courseLabel'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 '${provider.subjectList.length} registered ${_courseLabel.toLowerCase()} records',
//                 style: TextStyle(color: scheme.onSurfaceVariant),
//               ),
//               if (selected.isNotEmpty) ...[
//                 const SizedBox(height: 12),
//                 InputDecorator(
//                   decoration: InputDecoration(
//                     labelText: 'Selected $_courseLabel',
//                     border: const OutlineInputBorder(),
//                   ),
//                   child: Text('${selected.first.code}  ${selected.first.name}'),
//                 ),
//               ],
//             ],
//           ),
//         );
//       case 4:
//         return _courseMountingStep(scheme);
//       case 5:
//         return _allocationBody(scheme);
//       case 6:
//         return _fields([_scoreFields(scheme), _gradingScaleManager(scheme)]);
//       default:
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: scheme.primaryContainer,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     _locked ? Icons.lock : Icons.verified_outlined,
//                     color: scheme.primary,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       _locked
//                           ? 'This setup is locked for the current period.'
//                           : 'Review the essentials, then lock the setup to protect your academic configuration.',
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             _summaryRow('School type', _schoolType, scheme),
//             _summaryRow('Academic year', _yearController.text, scheme),
//             _summaryRow(
//               _periodLabel,
//               _usesSemester ? 'First semester' : 'First term',
//               scheme,
//             ),
//             _summaryRow(
//               'Assessment split',
//               '${_caController.text}% CA + ${_examController.text}% Exam',
//               scheme,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'You can still view records from the sidebar after locking. Unlocking requires an administrator.',
//               style: TextStyle(color: scheme.onSurfaceVariant),
//             ),
//           ],
//         );
//     }
//   }
//
//   Widget _fields(List<Widget> children) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: children
//         .map(
//           (child) =>
//               Padding(padding: const EdgeInsets.only(bottom: 18), child: child),
//         )
//         .toList(),
//   );
//
//   Widget _allocationBody(ColorScheme scheme) {
//     final provider = context.watch<Myprovider>();
//     dynamic selectedDepartment;
//     for (final item in provider.departments) {
//       if (item.id == _selectedDepartment) selectedDepartment = item;
//     }
//     final staffQuery = _staffSearchController.text.trim().toLowerCase();
//     final staff = provider.stafflist.where((item) {
//       final departmentMatches =
//           _selectedDepartment == null ||
//           item.departmentId.isEmpty ||
//           item.departmentId == _selectedDepartment ||
//           item.departmentId.toLowerCase() ==
//               (selectedDepartment?.name ?? '').toString().toLowerCase();
//       final searchMatches =
//           staffQuery.isEmpty ||
//           item.name.toLowerCase().contains(staffQuery) ||
//           item.email.toLowerCase().contains(staffQuery);
//       return departmentMatches && searchMatches;
//     }).toList();
//     final query = _allocationSearch.toLowerCase();
//     final assignedCodes = _assignedAllocations
//         .where(
//           (item) =>
//               item['academicYear'] == _yearController.text.trim() &&
//               item['termOrSemester'] == _period,
//         )
//         .map((item) => item['courseCode'].toString())
//         .toSet();
//     final courses = provider.subjectList.where((course) {
//       final textMatches =
//           query.isEmpty ||
//           course.name.toLowerCase().contains(query) ||
//           (course.code ?? '').toLowerCase().contains(query);
//       final departmentMatches =
//           _selectedDepartment == null ||
//           course.department == null ||
//           course.department == selectedDepartment?.name ||
//           course.scope == 'All departments';
//       return textMatches && departmentMatches;
//     }).toList();
//     final unassigned = courses
//         .where((course) => !assignedCodes.contains(course.code))
//         .toList();
//     final assigned = _assignedAllocations
//         .where(
//           (item) =>
//               item['academicYear'] == _yearController.text.trim() &&
//               item['termOrSemester'] == _period,
//         )
//         .toList();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _formSectionTitle(
//                 'Course allocation',
//                 'Manage registered $_courseLabel assignments by department and teacher.',
//               ),
//             ),
//             FilledButton.icon(
//               onPressed: () => context.go(Routes.courseallocation),
//               icon: const Icon(Icons.open_in_new),
//               label: Text('Open $_courseLabel allocation'),
//             ),
//           ],
//         ),
//         if (_facultyEntries.isEmpty)
//           TextFormField(
//             controller: _facultyController,
//             enabled: !_locked,
//             decoration: const InputDecoration(
//               labelText: 'Faculty / level group',
//             ),
//           )
//         else
//           DropdownButtonFormField<String>(
//             initialValue: _facultyEntries.contains(_facultyController.text)
//                 ? _facultyController.text
//                 : null,
//             decoration: const InputDecoration(
//               labelText: 'Faculty / level group',
//             ),
//             items: _facultyEntries
//                 .map((item) => DropdownMenuItem(value: item, child: Text(item)))
//                 .toList(),
//             onChanged: _locked
//                 ? null
//                 : (value) =>
//                       setState(() => _facultyController.text = value ?? ''),
//           ),
//         DropdownButtonFormField<String>(
//           initialValue: _selectedDepartment,
//           decoration: const InputDecoration(
//             labelText: 'Department / programme',
//           ),
//           items: provider.departments
//               .map(
//                 (item) =>
//                     DropdownMenuItem(value: item.id, child: Text(item.name)),
//               )
//               .toList(),
//           onChanged: _locked
//               ? null
//               : (value) => setState(() {
//                   _selectedDepartment = value;
//                   _departmentController.text = provider.departments
//                       .firstWhere((item) => item.id == value)
//                       .name;
//                   _selectedCourse = null;
//                 }),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _staffSearchController,
//           enabled: !_locked,
//           onChanged: (_) => setState(() {}),
//           decoration: const InputDecoration(
//             labelText: 'Search staff',
//             prefixIcon: Icon(Icons.search),
//           ),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           initialValue: _selectedStaff,
//           decoration: const InputDecoration(labelText: 'Staff / tutor'),
//           items: staff
//               .map(
//                 (item) => DropdownMenuItem(
//                   value: item.id,
//                   child: Text('${item.name} (${item.accessLevel})'),
//                 ),
//               )
//               .toList(),
//           onChanged: _locked
//               ? null
//               : (value) => setState(() {
//                   _selectedStaff = value;
//                   _teacherController.text = value ?? '';
//                 }),
//         ),
//         const SizedBox(height: 18),
//         if (_loadingAllocations)
//           const Padding(
//             padding: EdgeInsets.only(bottom: 12),
//             child: LinearProgressIndicator(),
//           ),
//         TextField(
//           enabled: !_locked,
//           onChanged: (value) => setState(() => _allocationSearch = value),
//           decoration: InputDecoration(
//             labelText: 'Search $_courseLabel',
//             prefixIcon: const Icon(Icons.search),
//           ),
//         ),
//         const SizedBox(height: 8),
//         _allocationList('$_courseLabel not assigned', unassigned, scheme),
//         const SizedBox(height: 16),
//         _assignedList(assigned, scheme),
//       ],
//     );
//   }
//
//   Widget _courseMountingStep(ColorScheme scheme) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         border: Border.all(color: scheme.outlineVariant),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.playlist_add_check_outlined, size: 30),
//           const SizedBox(height: 10),
//           Text(
//             'Course mounting',
//             style: Theme.of(
//               context,
//             ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Mount core and elective ${_courseLabel.toLowerCase()}s by department and ${_groupLabel.toLowerCase()}. Credit limits are validated from the school profile.',
//             style: TextStyle(color: scheme.onSurfaceVariant),
//           ),
//           const SizedBox(height: 18),
//           FilledButton.icon(
//             onPressed: () {
//               showDialog<void>(
//                 context: context,
//                 builder: (context) => Dialog(
//                   child: SizedBox(
//                     width: 1100,
//                     height: 720,
//                     child: const CourseMountingPage(embedded: true),
//                   ),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.open_in_new),
//             label: const Text('Open course mounting'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _allocationList(
//     String title,
//     List<dynamic> courses,
//     ColorScheme scheme,
//   ) => Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       border: Border.all(color: scheme.outlineVariant),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '$title (${courses.length})',
//           style: const TextStyle(fontWeight: FontWeight.w800),
//         ),
//         if (courses.isEmpty)
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Text(
//               'No records found.',
//               style: TextStyle(color: scheme.onSurfaceVariant),
//             ),
//           )
//         else
//           ...courses.map(
//             (course) => ListTile(
//               dense: true,
//               title: Text('${course.code ?? ''}  ${course.name}'),
//               subtitle: Text(
//                 '${course.department ?? 'All departments'} • ${course.creditHours} credit hours',
//               ),
//               trailing: FilledButton(
//                 onPressed: _locked
//                     ? null
//                     : () => setState(() => _selectedCourse = course.code),
//                 child: Text(
//                   _selectedCourse == course.code ? 'Selected' : 'Select',
//                 ),
//               ),
//             ),
//           ),
//         if (_selectedCourse != null)
//           Align(
//             alignment: Alignment.centerRight,
//             child: FilledButton.icon(
//               onPressed: _locked ? null : _saveAllocation,
//               icon: const Icon(Icons.save),
//               label: const Text('Save allocation'),
//             ),
//           ),
//       ],
//     ),
//   );
//
//   Widget _assignedList(
//     List<Map<String, dynamic>> records,
//     ColorScheme scheme,
//   ) => Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: scheme.primaryContainer,
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Assigned $_courseLabel records (${records.length})',
//           style: const TextStyle(fontWeight: FontWeight.w800),
//         ),
//         if (records.isEmpty)
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Text(
//               'No assigned courses for this period.',
//               style: TextStyle(color: scheme.onPrimaryContainer),
//             ),
//           )
//         else
//           ...records.map(
//             (item) => ListTile(
//               dense: true,
//               title: Text(item['courseCode'].toString()),
//               subtitle: Text(
//                 'Staff: ${item['staffId']} • ${item['departmentId']}',
//               ),
//             ),
//           ),
//       ],
//     ),
//   );
//
//   Widget _formSectionTitle(String title, String subtitle) => Padding(
//     padding: const EdgeInsets.only(bottom: 4),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
//         ),
//         Text(
//           subtitle,
//           style: TextStyle(
//             color: Theme.of(context).colorScheme.onSurfaceVariant,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _structurePanel(
//     String title,
//     String kind,
//     List<String> entries,
//     ColorScheme scheme,
//   ) => Container(
//     margin: const EdgeInsets.only(bottom: 2),
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       border: Border.all(color: scheme.outlineVariant),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(fontWeight: FontWeight.w700),
//               ),
//             ),
//             OutlinedButton.icon(
//               onPressed: _locked
//                   ? null
//                   : () => _editStructureEntry(kind, entries),
//               icon: const Icon(Icons.add, size: 17),
//               label: const Text('Add'),
//             ),
//           ],
//         ),
//         if (entries.isEmpty)
//           Text(
//             'No $kind registered yet.',
//             style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
//           )
//         else
//           ...entries.map(
//             (entry) => ListTile(
//               dense: true,
//               contentPadding: EdgeInsets.zero,
//               leading: Icon(
//                 Icons.check_circle_outline,
//                 color: scheme.primary,
//                 size: 18,
//               ),
//               title: Text(entry),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     tooltip: 'Edit $entry',
//                     icon: const Icon(Icons.edit_outlined),
//                     onPressed: _locked
//                         ? null
//                         : () => _editStructureEntry(
//                             kind,
//                             entries,
//                             currentValue: entry,
//                           ),
//                   ),
//                   IconButton(
//                     tooltip: 'Delete $entry',
//                     icon: const Icon(Icons.delete_outline, color: Colors.red),
//                     onPressed: _locked
//                         ? null
//                         : () => _deleteStructureEntry(kind, entry),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     ),
//   );
//
//   Widget _scoreFields(ColorScheme scheme) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       border: Border.all(color: scheme.outlineVariant),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Score configuration',
//           style: TextStyle(fontWeight: FontWeight.w800),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           'The two components must total 100%. Set the allowed minimum and maximum in the manager.',
//           style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
//         ),
//         const SizedBox(height: 14),
//         _fieldGrid([
//           TextFormField(
//             controller: _caController,
//             enabled: !_locked,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(
//               labelText: 'Continuous assessment %',
//             ),
//           ),
//           TextFormField(
//             controller: _caMinController,
//             enabled: !_locked,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: const InputDecoration(labelText: 'CA minimum'),
//           ),
//           TextFormField(
//             controller: _caMaxController,
//             enabled: !_locked,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: const InputDecoration(labelText: 'CA maximum'),
//           ),
//           TextFormField(
//             controller: _examController,
//             enabled: !_locked,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(labelText: 'Exam %'),
//           ),
//           TextFormField(
//             controller: _examMinController,
//             enabled: !_locked,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: const InputDecoration(labelText: 'Exam minimum'),
//           ),
//           TextFormField(
//             controller: _examMaxController,
//             enabled: !_locked,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: const InputDecoration(labelText: 'Exam maximum'),
//           ),
//         ]),
//       ],
//     ),
//   );
//
//   Widget _fieldGrid(List<Widget> fields) => LayoutBuilder(
//     builder: (context, constraints) {
//       if (constraints.maxWidth < 520) {
//         return Column(
//           children: fields
//               .map(
//                 (field) => Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: field,
//                 ),
//               )
//               .toList(),
//         );
//       }
//       final width = (constraints.maxWidth - 12) / 2;
//       return Wrap(
//         spacing: 12,
//         runSpacing: 12,
//         children: fields
//             .map((field) => SizedBox(width: width, child: field))
//             .toList(),
//       );
//     },
//   );
//
//   Widget _summaryRow(String label, String value, ColorScheme scheme) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: Row(
//       children: [
//         SizedBox(
//           width: 150,
//           child: Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(fontWeight: FontWeight.w700),
//           ),
//         ),
//       ],
//     ),
//   );
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/screen/term.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/academicyrmodel.dart';
import '../controller/dbmodels/idformatmodel.dart';
import '../controller/dbmodels/termmodel.dart';
import '../controller/dbmodels/subjectmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import 'coursemounting.dart';
import 'academicyr.dart';
import 'idformat.dart';

class SetupWizardPage extends StatefulWidget {
  const SetupWizardPage({super.key});

  @override
  State<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends State<SetupWizardPage> {
  final _stepScrollController = ScrollController();
  int _step = 0;
  bool _locked = false;
  bool _saving = false;
  String _schoolType = 'Loading...';
  String _period = 'First semester';
  final _yearController = TextEditingController();
  final _reopeningDates = <String>[];
  final _caController = TextEditingController(text: '40');
  final _examController = TextEditingController(text: '60');
  final _caMinController = TextEditingController(text: '0');
  final _caMaxController = TextEditingController(text: '40');
  final _examMinController = TextEditingController(text: '0');
  final _examMaxController = TextEditingController(text: '60');
  final _idFormatController = TextEditingController();
  final _facultyController = TextEditingController();
  final _departmentController = TextEditingController();
  final _levelController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _weightController = TextEditingController(text: '1');
  final _creditHoursController = TextEditingController(text: '3');
  final _creditMinController = TextEditingController(text: '0.0');
  final _creditMaxController = TextEditingController(text: '30.0');
  final _gradeMinController = TextEditingController(text: '80');
  final _gradeMaxController = TextEditingController(text: '100');
  final _gradeController = TextEditingController(text: 'A');
  final _gradePointController = TextEditingController(text: '4');
  final _remarksController = TextEditingController(text: 'Excellent');
  final _teacherController = TextEditingController();
  final _staffSearchController = TextEditingController();
  final _facultyEntries = <String>[];
  final _departmentEntries = <String>[];
  final _levelEntries = <String>[];
  final _termEntries = <String>[];
  final _entryIds = <String, String>{};
  final _departmentFaculties = <String, String>{};
  final _groupDepartments = <String, String>{};
  String? _selectedDepartment;
  String? _selectedStaff;
  String? _selectedCourse;
  String _allocationSearch = '';
  List<Map<String, dynamic>> _assignedAllocations = [];
  bool _loadingAllocations = false;

  final _steps = const [
    ('School profile', 'Type and academic identity', Icons.school_outlined),
    (
    'Academic period',
    'Year, semester or term',
    Icons.calendar_month_outlined,
    ),
    (
    'Structure',
    'Faculties, departments and levels',
    Icons.account_tree_outlined,
    ),
    (
    'Courses / subjects',
    'Register academic course records',
    Icons.menu_book_outlined,
    ),
    (
    'Course mounting',
    'Mount core and elective records by class or level',
    Icons.playlist_add_check_outlined,
    ),
    (
    'Course allocation',
    'Assign courses to staff and classes',
    Icons.assignment_ind_outlined,
    ),
    ('Assessment', 'Scores, grading and credits', Icons.fact_check_outlined),
    ('Review & lock', 'Confirm the setup', Icons.lock_outline),
  ];

  bool get _usesSemester => _schoolType != 'Pre-tertiary';
  String get _periodLabel => _usesSemester ? 'Semester' : 'Term';
  String get _groupLabel => _usesSemester ? 'Level' : 'Class';
  String get _courseLabel => _usesSemester ? 'Course' : 'Subject';
  String _stepTitle(int index) =>
      index == 3 ? (_usesSemester ? 'Courses' : 'Subjects') : _steps[index].$1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSchoolType();
      final provider = context.read<Myprovider>();
      await Future.wait([
        provider.fetchdepart(),
        provider.fetchsubjects(),
        provider.fetchstaff(),
        provider.fetchacademicyear(),
        provider.fetchIdFormats(),
        provider.fetchterms(),
      ]);
      if (provider.terms.isNotEmpty) {
        _termEntries
          ..clear()
          ..addAll(provider.terms.map((term) => term.name));
        if (!_termEntries.contains(_period)) {
          _period = _termEntries.first;
        }
      }
      await _loadStructureEntries();
      await _loadAllocations();
    });
  }

  Future<void> _loadStructureEntries() async {
    final provider = context.read<Myprovider>();
    final schoolId = provider.schoolid.trim();
    if (schoolId.isEmpty) return;
    final results = await Future.wait([
      provider.db
          .collection('faculties')
          .where('schoolId', isEqualTo: schoolId)
          .get(),
      provider.db
          .collection('department')
          .where('schoolId', isEqualTo: schoolId)
          .get(),
      provider.db
          .collection('classes')
          .where('schoolId', isEqualTo: schoolId)
          .get(),
    ]);
    if (!mounted) return;
    setState(() {
      _facultyEntries
        ..clear()
        ..addAll(results[0].docs.map((doc) => (doc.data())['name'].toString()));
      _departmentEntries
        ..clear()
        ..addAll(results[1].docs.map((doc) => (doc.data())['name'].toString()));
      _levelEntries
        ..clear()
        ..addAll(
          results[2].docs
              .where((doc) => (doc.data())['schoolType'] == _schoolType)
              .map((doc) => (doc.data())['name'].toString()),
        );
      for (final doc in results[1].docs) {
        final data = doc.data();
        _departmentFaculties[data['name'].toString()] =
            data['faculty']?.toString() ?? '';
      }
      for (final doc in results[2].docs) {
        final data = doc.data();
        if (data['schoolType'] == _schoolType) {
          _groupDepartments[data['name'].toString()] =
              data['department']?.toString() ?? '';
        }
      }
    });
  }

  Future<void> _loadAllocations() async {
    final provider = context.read<Myprovider>();
    if (provider.schoolid.isEmpty) return;
    setState(() => _loadingAllocations = true);
    final snapshot = await provider.db
        .collection('courseAllocation')
        .where('schoolId', isEqualTo: provider.schoolid)
        .get();
    if (!mounted) return;
    setState(() {
      _assignedAllocations = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
      _loadingAllocations = false;
    });
  }

  Future<void> _saveAllocation() async {
    final provider = context.read<Myprovider>();
    final courseCode = _selectedCourse;
    final staffId = _selectedStaff;
    final departmentId = _selectedDepartment;
    if (courseCode == null || staffId == null || departmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a department, course and staff member first.'),
        ),
      );
      return;
    }
    final period = _period.toLowerCase().replaceAll(' ', '_');
    final id =
        '${provider.schoolid}_${courseCode}_${staffId}_${_yearController.text.trim()}_$period';
    await provider.db.collection('courseAllocation').doc(id).set({
      'id': id,
      'schoolId': provider.schoolid,
      'courseCode': courseCode,
      'staffId': staffId,
      'departmentId': departmentId,
      'classOrLevel': _levelController.text.trim(),
      'academicYear': _yearController.text.trim(),
      'termOrSemester': _period,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _loadAllocations();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course allocation saved.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _loadSchoolType() async {
    final prefs = await SharedPreferences.getInstance();
    final type = prefs.getString('schoolType');
    if (!mounted) return;
    final configuredType =
    type == 'Tertiary' || type == 'SHS' || type == 'Pre-tertiary'
        ? type!
        : 'Not configured';
    setState(() {
      _schoolType = configuredType;
      _period = configuredType == 'Pre-tertiary'
          ? 'First term'
          : 'First semester';
    });
  }

  Future<void> _saveSchoolProfile() async {
    final provider = context.read<Myprovider>();
    final schoolId = provider.schoolid.trim();
    final academicYear = _yearController.text.trim();
    final idFormat = _idFormatController.text.trim();
    if (schoolId.isEmpty || academicYear.isEmpty || idFormat.isEmpty) {
      _showSaveMessage('Select an academic year and ID format first.', error: true);
      return;
    }
    await provider.db.collection('schools').doc(schoolId).set({
      'schoolType': _schoolType,
      'periodType': _usesSemester ? 'Semester' : 'Term',
      'studentIdFormat': idFormat,
      'currentAcademicYear': academicYear,
      'setupCompleted': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('schoolType', _schoolType);
    _showSaveMessage('School profile saved.');
  }

  Future<void> _saveAcademicPeriod() async {
    final provider = context.read<Myprovider>();
    final schoolId = provider.schoolid.trim();
    final academicYear = _yearController.text.trim();
    if (schoolId.isEmpty || academicYear.isEmpty || _period.trim().isEmpty) {
      _showSaveMessage('Select an academic year and period first.', error: true);
      return;
    }
    await provider.db.collection('schools').doc(schoolId).set({
      'currentAcademicYear': academicYear,
      'currentTermOrSemester': _period,
      'reopeningDates': _reopeningDates,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('year', academicYear),
      prefs.setString('term', _period),
    ]);
    _showSaveMessage('Academic period saved.');
  }

  Future<void> _saveStructureSettings() async {
    final provider = context.read<Myprovider>();
    final schoolId = provider.schoolid.trim();
    final creditMin = double.tryParse(_creditMinController.text.trim());
    final creditMax = double.tryParse(_creditMaxController.text.trim());
    if (schoolId.isEmpty ||
        creditMin == null ||
        creditMax == null ||
        creditMin < 0 ||
        creditMax < creditMin) {
      _showSaveMessage('Enter valid credit-hour limits first.', error: true);
      return;
    }
    await provider.db.collection('schools').doc(schoolId).set({
      'creditHourMin': creditMin,
      'creditHourMax': creditMax,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _showSaveMessage('Structure settings saved.');
  }

  Future<void> _saveAssessmentSettings() async {
    final provider = context.read<Myprovider>();
    final schoolId = provider.schoolid.trim();
    final period = _period.toLowerCase().replaceAll(' ', '_');
    final ca = double.tryParse(_caController.text.trim());
    final exam = double.tryParse(_examController.text.trim());
    final caMin = double.tryParse(_caMinController.text.trim());
    final caMax = double.tryParse(_caMaxController.text.trim());
    final examMin = double.tryParse(_examMinController.text.trim());
    final examMax = double.tryParse(_examMaxController.text.trim());
    if (schoolId.isEmpty ||
        ca == null ||
        exam == null ||
        caMin == null ||
        caMax == null ||
        examMin == null ||
        examMax == null ||
        ca + exam != 100 ||
        caMin < 0 ||
        caMax < caMin ||
        examMin < 0 ||
        examMax < examMin) {
      _showSaveMessage('CA and Exam must total 100% with valid ranges.', error: true);
      return;
    }
    await provider.db.collection('scoreConfig').doc('${schoolId}_$period').set({
      'schoolId': schoolId,
      'academicYear': _yearController.text.trim(),
      'termOrSemester': _period,
      'caPercent': ca,
      'examPercent': exam,
      'caMin': caMin,
      'caMax': caMax,
      'examMin': examMin,
      'examMax': examMax,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _showSaveMessage('Assessment settings saved.');
  }

  Future<void> _saveCurrentSection() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      switch (_step) {
        case 0:
          await _saveSchoolProfile();
        case 1:
          await _saveAcademicPeriod();
        case 2:
          await _saveStructureSettings();
        case 6:
          await _saveAssessmentSettings();
      }
    } catch (error) {
      _showSaveMessage('Section could not be saved: $error', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _lockSetup() async {
    if (_saving) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lock setup?'),
        content: const Text(
          'Lock the current setup? You can still view the records, but editing will be disabled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lock setup'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final provider = context.read<Myprovider>();
    await provider.db.collection('schools').doc(provider.schoolid.trim()).set({
      'setupCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    setState(() => _locked = true);
    _showSaveMessage('Setup locked successfully.');
  }

  void _showSaveMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  // ── Academic year: opens the real AcademicYr screen embedded in a dialog ──
  Future<void> _registerAcademicYear() async {
    final result = await showDialog<AcademicModel>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(width: 480, child: AcademicYr(embedded: true)),
      ),
    );
    if (result != null && mounted) setState(() => _yearController.text = result.name);
  }

  Future<void> _editAcademicYear(AcademicModel year) async {
    final result = await showDialog<AcademicModel>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(width: 480, child: AcademicYr(year: year, embedded: true)),
      ),
    );
    if (result != null && mounted) setState(() => _yearController.text = result.name);
  }

  // ── ID format: opens the real IdformatScreen embedded in a dialog ──
  Future<void> _registerIdFormat() async {
    final result = await showDialog<IdformatModel>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(width: 480, child: IdformatScreen(embedded: true)),
      ),
    );
    if (result != null && mounted) setState(() => _idFormatController.text = result.name);
  }

  Future<void> _editIdFormat(IdformatModel format) async {
    final result = await showDialog<IdformatModel>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(width: 480, child: IdformatScreen(idformatModel: format, embedded: true)),
      ),
    );
    if (result != null && mounted) setState(() => _idFormatController.text = result.name);
  }

  Future<void> _registerTerm() async {
    final result = await showDialog<TermModel>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(width: 480, child: Term(embedded: true)),
      ),
    );
    if (result != null && mounted) setState(() => _period = result.name);
  }

  Future<void> _editTerm(TermModel term) async {
    final result = await showDialog<TermModel>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 480,
          child: Term(
            term: term,
            embedded: true,
            onDeleted: () {
              if (_period == term.name) {
                final provider = context.read<Myprovider>();
                setState(() {
                  _period = provider.terms.isNotEmpty
                      ? provider.terms.first.name
                      : (_usesSemester ? 'First semester' : 'First term');
                });
              }
            },
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        if (_period == term.name) _period = result.name;
      });
    }
  }

  Future<void> _confirmDeleteTerm(TermModel term) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${_usesSemester ? 'semester' : 'term'}?'),
        content: Text('Remove "${term.name}" from the registered options?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<Myprovider>();
    await provider.db.collection('terms').doc(term.id).delete();
    provider.removeTerm(term.id);

    if (!mounted) return;
    setState(() {
      if (_period == term.name) {
        _period = provider.terms.isNotEmpty
            ? provider.terms.first.name
            : (_usesSemester ? 'First semester' : 'First term');
      }
    });
  }
  Widget _termPanel(ColorScheme scheme, Myprovider provider) {
    final label = _usesSemester ? 'Semesters' : 'Terms';
    final singular = _usesSemester ? 'Semester' : 'Term';
    final terms = provider.terms; // List<TermModel>

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _locked ? null : _registerTerm,
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: terms.any((t) => t.name == _period) ? _period : null,
            decoration: InputDecoration(
              labelText: 'Select $singular',
              border: const OutlineInputBorder(),
            ),
            hint: Text('Select a registered $singular'),
            items: terms
                .map((t) => DropdownMenuItem(value: t.name, child: Text(t.name)))
                .toList(),
            onChanged: _locked
                ? null
                : (value) => setState(() => _period = value ?? ''),
          ),
          const SizedBox(height: 10),
          if (terms.isEmpty)
            Text(
              'No $singular registered yet.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            )
          else
            ...terms.asMap().entries.map(
                  (entry) => Container(
                constraints: const BoxConstraints(minHeight: 58),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: scheme.outlineVariant)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('${entry.key + 1}')),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        child: Text(entry.value.name),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit ${entry.value.name}',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _locked ? null : () => _editTerm(entry.value),
                    ),
                    IconButton(
                      tooltip: 'Delete ${entry.value.name}',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _locked ? null : () => _confirmDeleteTerm(entry.value),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteRegistered(
      String collection,
      String id,
      String label,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove registration?'),
        content: Text('Remove "$label" from the registered options?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final provider = context.read<Myprovider>();
    await provider.deleteData(collection, id);
    if (collection == 'academicyears') {
      await provider.fetchacademicyear();
      if (_yearController.text == label) _yearController.clear();
    } else {
      await provider.fetchIdFormats();
      if (_idFormatController.text == label) _idFormatController.clear();
    }
    if (mounted) setState(() {});
  }

  Future<void> _addReopeningDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final value =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    if (!_reopeningDates.contains(value)) {
      setState(() => _reopeningDates.add(value));
    }
  }

  Widget _reopeningDatePanel(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Reopening dates',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _locked ? null : _addReopeningDate,
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_reopeningDates.isEmpty)
            Text(
              'No reopening date registered yet.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            )
          else
            ..._reopeningDates.asMap().entries.map(
                  (entry) => Container(
                constraints: const BoxConstraints(minHeight: 58),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: scheme.outlineVariant)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('${entry.key + 1}')),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        child: Text(entry.value),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete ${entry.value}',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _locked
                          ? null
                          : () => setState(
                            () => _reopeningDates.remove(entry.value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Single, correct version of the registered-setting picker ──
  Widget _registeredSettingChoice({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required VoidCallback onRegister,
    required ValueChanged<String> onEdit,
    required ValueChanged<String> onDelete,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
              OutlinedButton.icon(
                onPressed: _locked ? null : onRegister,
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: options.contains(value) ? value : null,
            decoration: InputDecoration(labelText: 'Select $label', border: const OutlineInputBorder()),
            hint: Text('Select a registered $label'),
            items: options.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: _locked ? null : onChanged,
          ),
          const SizedBox(height: 10),
          if (options.isEmpty)
            Text('No $label registered yet.', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12))
          else
            ...options.asMap().entries.map(
                  (entry) => Container(
                constraints: const BoxConstraints(minHeight: 58),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: scheme.outlineVariant)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('${entry.key + 1}')),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                        child: Text(entry.value),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit ${entry.value}',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _locked ? null : () => onEdit(entry.value),
                    ),
                    IconButton(
                      tooltip: 'Delete ${entry.value}',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _locked ? null : () => onDelete(entry.value),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editStructureEntry(
      String kind,
      List<String> entries, {
        String? currentValue,
      }) async {
    final controller = TextEditingController();
    controller.text = currentValue ?? '';
    final isDepartment = kind == 'Department';
    final isGroup = kind != 'Faculty' && kind != 'Department';
    String? faculty = currentValue == null
        ? null
        : _departmentFaculties[currentValue];
    String? department = currentValue == null
        ? null
        : _groupDepartments[currentValue];
    final value = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(currentValue == null ? 'Add $kind' : 'Edit $kind'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(labelText: '$kind name'),
              ),
              if (isDepartment) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _facultyEntries.contains(faculty)
                      ? faculty
                      : null,
                  decoration: const InputDecoration(labelText: 'Faculty'),
                  items: _facultyEntries
                      .map(
                        (item) =>
                        DropdownMenuItem(value: item, child: Text(item)),
                  )
                      .toList(),
                  onChanged: (next) => setDialogState(() => faculty = next),
                ),
              ],
              if (isGroup) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _departmentEntries.contains(department)
                      ? department
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Department / programme',
                  ),
                  items: _departmentEntries
                      .map(
                        (item) =>
                        DropdownMenuItem(value: item, child: Text(item)),
                  )
                      .toList(),
                  onChanged: (next) => setDialogState(() => department = next),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty ||
                    (isDepartment && faculty == null) ||
                    (isGroup && department == null)) {
                  return;
                }
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!mounted || value == null || value.isEmpty) {
      return;
    }
    final provider = context.read<Myprovider>();
    final schoolId = provider.schoolid.trim();
    if (schoolId.isEmpty) return;
    if (currentValue == null && entries.contains(value)) return;
    if (currentValue != null && currentValue != value) {
      await _deleteStructureEntry(kind, currentValue, refresh: false);
    }
    final id =
        '${schoolId}_${kind.toLowerCase()}_${value.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';
    final collection = kind == 'Faculty'
        ? 'faculties'
        : kind == 'Department'
        ? 'department'
        : 'classes';
    await provider.db.collection(collection).doc(id).set({
      'id': id,
      'name': value,
      'schoolId': schoolId,
      'schoolType': _schoolType,
      'entryType': kind,
      if (isDepartment) 'faculty': faculty,
      if (isGroup) 'department': department,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (mounted) {
      setState(() {
        if (currentValue != null) entries.remove(currentValue);
        if (!entries.contains(value)) entries.add(value);
        _entryIds['$kind:$value'] = id;
        if (isDepartment && faculty != null) {
          _departmentFaculties[value] = faculty!;
        }
        if (isGroup && department != null) {
          _groupDepartments[value] = department!;
        }
      });
    }
  }

  Future<void> _deleteStructureEntry(
      String kind,
      String value, {
        bool refresh = true,
      }) async {
    final provider = context.read<Myprovider>();
    final collection = kind == 'Faculty'
        ? 'faculties'
        : kind == 'Department'
        ? 'department'
        : 'classes';
    final id =
        _entryIds['$kind:$value'] ??
            '${provider.schoolid}_${kind.toLowerCase()}_${value.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';
    await provider.db.collection(collection).doc(id).delete();
    if (!mounted || !refresh) return;
    setState(() {
      final entries = kind == 'Faculty'
          ? _facultyEntries
          : kind == 'Department'
          ? _departmentEntries
          : _levelEntries;
      entries.remove(value);
      _departmentFaculties.remove(value);
      _groupDepartments.remove(value);
    });
  }

  @override
  void dispose() {
    _stepScrollController.dispose();
    _yearController.dispose();
    _caController.dispose();
    _examController.dispose();
    _caMinController.dispose();
    _caMaxController.dispose();
    _examMinController.dispose();
    _examMaxController.dispose();
    for (final controller in [
      _idFormatController,
      _facultyController,
      _departmentController,
      _levelController,
      _courseCodeController,
      _courseNameController,
      _weightController,
      _creditHoursController,
      _creditMinController,
      _creditMaxController,
      _gradeMinController,
      _gradeMaxController,
      _gradeController,
      _gradePointController,
      _remarksController,
      _teacherController,
      _staffSearchController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'School setup wizard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_locked)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Chip(
                avatar: Icon(Icons.lock, size: 16),
                label: Text('Locked'),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 850;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.all(compact ? 16 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Let’s get your school ready',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete the essentials once, then manage each area from the sidebar.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 22),
                    Expanded(
                      child: compact
                          ? _compactLayout(scheme)
                          : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _stepRail(scheme),
                          const SizedBox(width: 20),
                          Expanded(child: _content(scheme)),
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
    );
  }

  Widget _compactLayout(ColorScheme scheme) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < _steps.length; index++)
                ChoiceChip(
                  label: Text('${index + 1}. ${_stepTitle(index)}'),
                  selected: _step == index,
                  onSelected: (_) => setState(() => _step = index),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _content(scheme)),
      ],
    );
  }

  Widget _stepRail(ColorScheme scheme) {
    return SizedBox(
      width: 280,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SETUP PROGRESS',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Scrollbar(
                  controller: _stepScrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _stepScrollController,
                    padding: const EdgeInsets.only(right: 6),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final selected = index == _step;
                      final done = index < _step || _locked;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _locked
                              ? null
                              : () => setState(() => _step = index),
                          child: Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: selected
                                  ? scheme.primaryContainer
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? scheme.primary.withValues(alpha: .35)
                                    : scheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: done
                                      ? scheme.primary
                                      : scheme.surfaceContainerHighest,
                                  foregroundColor: done
                                      ? scheme.onPrimary
                                      : scheme.onSurfaceVariant,
                                  child: done
                                      ? const Icon(Icons.check, size: 16)
                                      : Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _stepTitle(index),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        _steps[index].$2,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  _steps[index].$3,
                                  size: 18,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_step + 1) / _steps.length,
                minHeight: 7,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              Text(
                '${_step + 1} of ${_steps.length} sections',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(ColorScheme scheme) {
    final step = _steps[_step];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(step.$3, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _stepTitle(_step),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(step.$2, style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: _stepBody(scheme))),
            const Divider(height: 28),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10,
              spacing: 10,
              children: [
                TextButton.icon(
                  onPressed: _step == 0 ? null : () => setState(() => _step--),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
                if (_step == 0 || _step == 1 || _step == 2 || _step == 6)
                  OutlinedButton.icon(
                    onPressed: _locked || _saving ? null : _saveCurrentSection,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Saving...' : 'Save section'),
                  ),
                _step == _steps.length - 1
                    ? FilledButton.icon(
                  onPressed: _locked || _saving ? null : _lockSetup,
                  icon: Icon(_locked ? Icons.lock : Icons.lock_outline),
                  label: Text(_locked ? 'Setup locked' : 'Lock setup'),
                )
                    : FilledButton.icon(
                  onPressed: () => setState(() => _step++),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCourseRegistrationModal({
    SubjectModel? initialRecord,
  }) async {
    final provider = context.read<Myprovider>();
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final weightController = TextEditingController(text: '1');
    final creditHoursController = TextEditingController(text: '3');
    String? faculty = initialRecord == null
        ? null
        : _departmentFaculties[initialRecord.department];
    String? department = initialRecord?.department;
    String? group = initialRecord?.level;
    String courseType = initialRecord?.type ?? 'Core';
    String courseScope = initialRecord?.scope ?? 'Single department';
    String search = '';
    SubjectModel? editing = initialRecord;
    if (initialRecord != null) {
      codeController.text = initialRecord.code ?? '';
      nameController.text = initialRecord.name;
      weightController.text = initialRecord.weight.toString();
      creditHoursController.text = initialRecord.creditHours.toString();
    }

    Future<void> saveRecord(StateSetter setDialogState) async {
      final code = codeController.text.trim().toUpperCase();
      final name = nameController.text.trim().toUpperCase();
      final weight = double.tryParse(weightController.text.trim());
      final creditHours = double.tryParse(creditHoursController.text.trim());
      if (code.isEmpty ||
          name.isEmpty ||
          faculty == null ||
          department == null ||
          group == null ||
          weight == null ||
          creditHours == null) {
        return;
      }
      final id = '${provider.schoolid}_$code';
      if (editing != null && editing!.id != id) {
        await provider.db.collection('subjects').doc(editing!.id).delete();
      }
      final data = SubjectModel(
        id: id,
        code: code,
        name: name,
        schoolId: provider.schoolid,
        department: department,
        level: group,
        weight: weight,
        creditHours: creditHours,
        creditHourMin: double.tryParse(_creditMinController.text) ?? 0,
        creditHourMax: double.tryParse(_creditMaxController.text) ?? 30,
        type: courseType,
        scope: courseScope,
      ).toMap();
      data['faculty'] = faculty;
      data['schoolType'] = _schoolType;
      data['entryType'] = _courseLabel;
      await provider.db
          .collection('subjects')
          .doc(id)
          .set(data, SetOptions(merge: true));
      await provider.fetchsubjects();
      if (!mounted) return;
      final saved = provider.subjectList.firstWhere(
            (item) => item.id == id,
        orElse: () => SubjectModel(id: id, code: code, name: name),
      );
      setState(() {
        _courseCodeController.text = code;
        _courseNameController.text = name;
        _facultyController.text = faculty!;
        _departmentController.text = department!;
        _levelController.text = group!;
        _selectedCourse = code;
      });
      editing = saved;
      setDialogState(() {});
    }

    Future<void> deleteRecord(
        SubjectModel record,
        StateSetter setDialogState,
        ) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete ${_courseLabel.toLowerCase()}?'),
          content: Text('Remove "${record.name}" from the registered records?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await provider.db.collection('subjects').doc(record.id).delete();
      await provider.fetchsubjects();
      if (editing?.id == record.id) editing = null;
      setDialogState(() {});
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final records = provider.subjectList.where((record) {
            final query = search.toLowerCase();
            return record.name.toLowerCase().contains(query) ||
                (record.code ?? '').toLowerCase().contains(query);
          }).toList();

          final departmentOptions = _departmentEntries
              .where((d) => faculty == null || _departmentFaculties[d] == faculty)
              .toSet()
              .toList();
          final groupOptions = _levelEntries
              .where((l) => department == null || _groupDepartments[l] == department)
              .toSet()
              .toList();
          final facultyOptions = _facultyEntries.toSet().toList();

          return AlertDialog(
            title: Row(
              children: [
                Icon(_usesSemester ? Icons.menu_book : Icons.book_outlined),
                const SizedBox(width: 8),
                Text('Register $_courseLabel'),
              ],
            ),
            content: SizedBox(
              width: 760,
              height: 620,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: codeController,
                      decoration: InputDecoration(
                        labelText: '$_courseLabel code',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: '$_courseLabel name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue:
                      facultyOptions.contains(faculty) ? faculty : null,
                      decoration: const InputDecoration(labelText: 'Faculty'),
                      items: facultyOptions
                          .map(
                            (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                          .toList(),
                      onChanged: (value) => setDialogState(() {
                        faculty = value;
                        if (department != null &&
                            _departmentFaculties[department] != faculty) {
                          department = null;
                          group = null;
                        }
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: departmentOptions.contains(department)
                          ? department
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Department / programme',
                      ),
                      items: departmentOptions
                          .map(
                            (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                          .toList(),
                      onChanged: (value) => setDialogState(() {
                        department = value;
                        faculty = _departmentFaculties[value] ?? faculty;
                        if (group != null &&
                            _groupDepartments[group] != department) {
                          group = null;
                        }
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue:
                      groupOptions.contains(group) ? group : null,
                      decoration: InputDecoration(labelText: _groupLabel),
                      items: groupOptions
                          .map(
                            (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                          .toList(),
                      onChanged: (value) => setDialogState(() {
                        group = value;
                        department = _groupDepartments[value] ?? department;
                        faculty = _departmentFaculties[department] ?? faculty;
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Weight',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: creditHoursController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Credit hours',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: courseType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const ['Core', 'Elective']
                          .map(
                            (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => courseType = value ?? 'Core'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: courseScope,
                      decoration: const InputDecoration(labelText: 'Scope'),
                      items: const ['Single department', 'All departments']
                          .map(
                            (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                          .toList(),
                      onChanged: (value) => setDialogState(
                            () => courseScope = value ?? 'Single department',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Registered ${_courseLabel.toLowerCase()}s',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (editing != null)
                          TextButton(
                            onPressed: () => setDialogState(() {
                              editing = null;
                              codeController.clear();
                              nameController.clear();
                            }),
                            child: const Text('Clear form'),
                          ),
                      ],
                    ),
                    TextField(
                      onChanged: (value) =>
                          setDialogState(() => search = value),
                      decoration: const InputDecoration(
                        labelText: 'Search registered records',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (records.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('No registered records found.'),
                      )
                    else
                      ...records.map(
                            (record) => ListTile(
                          dense: true,
                          title: Text('${record.code ?? ''}  ${record.name}'),
                          subtitle: Text(
                            '${record.department ?? ''} • ${record.level ?? ''}',
                          ),
                          onTap: () {
                            editing = record;
                            codeController.text = record.code ?? '';
                            nameController.text = record.name;
                            department = record.department;
                            group = record.level;
                            faculty = _departmentFaculties[department];
                            weightController.text = record.weight.toString();
                            creditHoursController.text = record.creditHours
                                .toString();
                            courseType = record.type;
                            courseScope = record.scope;
                            setDialogState(() {});
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit ${record.name}',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () {
                                  editing = record;
                                  codeController.text = record.code ?? '';
                                  nameController.text = record.name;
                                  department = record.department;
                                  group = record.level;
                                  faculty = _departmentFaculties[department];
                                  weightController.text = record.weight
                                      .toString();
                                  creditHoursController.text = record
                                      .creditHours
                                      .toString();
                                  courseType = record.type;
                                  courseScope = record.scope;
                                  setDialogState(() {});
                                },
                              ),
                              IconButton(
                                tooltip: 'Delete ${record.name}',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    deleteRecord(record, setDialogState),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              FilledButton.icon(
                onPressed: () => saveRecord(setDialogState),
                icon: Icon(editing == null ? Icons.add : Icons.save),
                label: Text(editing == null ? 'Register' : 'Update'),
              ),
            ],
          );
        },
      ),
    );
    codeController.dispose();
    nameController.dispose();
    weightController.dispose();
    creditHoursController.dispose();
  }
  Future<void> _openRegisteredCoursesModal() async {
    final provider = context.read<Myprovider>();
    String search = '';

    Future<void> deleteRecord(
        SubjectModel record,
        StateSetter setDialogState,
        ) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete ${_courseLabel.toLowerCase()}?'),
          content: Text('Remove "${record.name}" from the registered records?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await provider.db.collection('subjects').doc(record.id).delete();
      await provider.fetchsubjects();
      if (_selectedCourse == record.code && mounted) {
        setState(() => _selectedCourse = null);
      }
      setDialogState(() {});
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final query = search.trim().toLowerCase();
          final records = provider.subjectList.where((record) {
            return query.isEmpty ||
                record.name.toLowerCase().contains(query) ||
                (record.code ?? '').toLowerCase().contains(query) ||
                (record.department ?? '').toLowerCase().contains(query) ||
                (record.level ?? '').toLowerCase().contains(query);
          }).toList();
          return AlertDialog(
            title: Text('Registered ${_courseLabel}s'),
            content: SizedBox(
              width: 900,
              height: 560,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 650;
                  return Column(
                    children: [
                      TextField(
                        onChanged: (value) =>
                            setDialogState(() => search = value),
                        decoration: const InputDecoration(
                          labelText: 'Search registered records',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: records.isEmpty
                            ? const Center(
                          child: Text('No registered records found.'),
                        )
                            : desktop
                            ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Code')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Faculty')),
                                DataColumn(label: Text('Department')),
                                DataColumn(label: Text('Class / Level')),
                                DataColumn(label: Text('Credits')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows: records.asMap().entries.map((entry) {
                                final record = entry.value;
                                final faculty =
                                    _departmentFaculties[record
                                        .department] ??
                                        '';
                                return DataRow(
                                  cells: [
                                    DataCell(Text('${entry.key + 1}')),
                                    DataCell(Text(record.code ?? '')),
                                    DataCell(Text(record.name)),
                                    DataCell(Text(faculty)),
                                    DataCell(
                                      Text(record.department ?? ''),
                                    ),
                                    DataCell(Text(record.level ?? '')),
                                    DataCell(
                                      Text(record.creditHours.toString()),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip:
                                            'Edit ${record.name}',
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(
                                                dialogContext,
                                              );
                                              await _openCourseRegistrationModal(
                                                initialRecord: record,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            tooltip:
                                            'Delete ${record.name}',
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            onPressed: () => deleteRecord(
                                              record,
                                              setDialogState,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        )
                            : ListView.separated(
                          itemCount: records.length,
                          separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final record = records[index];
                            final faculty =
                                _departmentFaculties[record.department] ??
                                    '';
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                '${record.code ?? ''}  ${record.name}',
                              ),
                              subtitle: Text(
                                'Faculty: $faculty\nDepartment: ${record.department ?? ''}\nClass / Level: ${record.level ?? ''}\nCredits: ${record.creditHours} | Weight: ${record.weight}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit ${record.name}',
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () async {
                                      Navigator.pop(dialogContext);
                                      await _openCourseRegistrationModal(
                                        initialRecord: record,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Delete ${record.name}',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => deleteRecord(
                                      record,
                                      setDialogState,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
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

  Future<void> _openGradingScaleModal({String? initialId}) async {
    final provider = context.read<Myprovider>();
    final departmentOptions = provider.departments;
    String scope = initialId?.endsWith('_default') == true
        ? 'Default'
        : 'Department';
    String? departmentId;
    List<Map<String, dynamic>> bands = [
      {
        'min': '0',
        'max': '49.9',
        'grade': 'F',
        'weight': '0',
        'remarks': 'Needs improvement',
      },
      {
        'min': '50',
        'max': '59.9',
        'grade': 'C',
        'weight': '1',
        'remarks': 'Satisfactory',
      },
      {
        'min': '60',
        'max': '69.9',
        'grade': 'B',
        'weight': '2',
        'remarks': 'Good',
      },
      {
        'min': '70',
        'max': '100',
        'grade': 'A',
        'weight': '3',
        'remarks': 'Excellent',
      },
    ];
    if (initialId != null) {
      final snapshot = await provider.db
          .collection('gradingsystems')
          .doc(initialId)
          .get();
      final data = snapshot.data();
      if (data != null) {
        scope = data['scope'] == 'department' ? 'Department' : 'Default';
        departmentId = data['departmentId']?.toString();
        final stored = data['bands'] ?? data['gradingsystem']?.first?['grades'];
        if (stored is List && stored.isNotEmpty) {
          bands = stored
              .map<Map<String, dynamic>>(
                (item) => {
              'min': '${item['minScore'] ?? item['min'] ?? 0}',
              'max': '${item['maxScore'] ?? item['max'] ?? 0}',
              'grade': '${item['grade'] ?? ''}',
              'weight': '${item['weight'] ?? 0}',
              'remarks': '${item['remarks'] ?? item['remark'] ?? ''}',
            },
          )
              .toList();
        }
      }
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final validation = _validateGradeBands(bands);
          return AlertDialog(
            title: Text(
              initialId == null ? 'Add grading scale' : 'Edit grading scale',
            ),
            content: SizedBox(
              width: 900,
              height: 620,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: scope,
                          decoration: const InputDecoration(
                            labelText: 'Scale scope',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Default',
                              child: Text('School default'),
                            ),
                            DropdownMenuItem(
                              value: 'Department',
                              child: Text('Department scale'),
                            ),
                          ],
                          onChanged: (value) =>
                              setModalState(() => scope = value ?? 'Default'),
                        ),
                      ),
                      if (scope == 'Department') ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: departmentId,
                            decoration: const InputDecoration(
                              labelText: 'Department',
                            ),
                            items: departmentOptions
                                .map(
                                  (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                                .toList(),
                            onChanged: (value) =>
                                setModalState(() => departmentId = value),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: bands.length,
                      itemBuilder: (context, index) {
                        final band = bands[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: band['min'],
                                  decoration: const InputDecoration(
                                    labelText: 'Min',
                                  ),
                                  onChanged: (value) => band['min'] = value,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: band['max'],
                                  decoration: const InputDecoration(
                                    labelText: 'Max',
                                  ),
                                  onChanged: (value) => band['max'] = value,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: band['grade'],
                                  decoration: const InputDecoration(
                                    labelText: 'Grade',
                                  ),
                                  onChanged: (value) => band['grade'] = value,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: band['weight'],
                                  decoration: const InputDecoration(
                                    labelText: 'Weight',
                                  ),
                                  onChanged: (value) => band['weight'] = value,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: band['remarks'],
                                  decoration: const InputDecoration(
                                    labelText: 'Remarks',
                                  ),
                                  onChanged: (value) => band['remarks'] = value,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: bands.length <= 1
                                    ? null
                                    : () => setModalState(
                                      () => bands.removeAt(index),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    validation ?? 'Scale ranges are valid.',
                    style: TextStyle(
                      color: validation == null ? Colors.green : Colors.red,
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
              OutlinedButton.icon(
                onPressed: () => setModalState(
                      () => bands.add({
                    'min': '',
                    'max': '',
                    'grade': '',
                    'weight': '',
                    'remarks': '',
                  }),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add grade'),
              ),
              FilledButton.icon(
                onPressed:
                validation != null ||
                    (scope == 'Department' && departmentId == null)
                    ? null
                    : () async {
                  final schoolId = provider.schoolid;
                  final id = scope == 'Default'
                      ? '${schoolId}_default'
                      : '${schoolId}_${departmentId!.toLowerCase()}';
                  await provider.db
                      .collection('gradingsystems')
                      .doc(id)
                      .set({
                    'id': id,
                    'schoolid': schoolId,
                    'scope': scope == 'Default'
                        ? 'default'
                        : 'department',
                    'departmentId': scope == 'Default'
                        ? null
                        : departmentId,
                    'name': scope == 'Default'
                        ? 'School default'
                        : departmentOptions
                        .firstWhere(
                          (item) => item.id == departmentId,
                    )
                        .name,
                    'bands': bands
                        .map(
                          (band) => {
                        'minScore': double.parse(
                          band['min'].toString(),
                        ),
                        'maxScore': double.parse(
                          band['max'].toString(),
                        ),
                        'grade': band['grade'],
                        'weight': double.parse(
                          band['weight'].toString(),
                        ),
                        'remarks': band['remarks'],
                      },
                    )
                        .toList(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save scale'),
              ),
            ],
          );
        },
      ),
    );
  }

  String? _validateGradeBands(List<Map<String, dynamic>> bands) {
    final ranges = <List<double>>[];
    for (final band in bands) {
      final min = double.tryParse(band['min'].toString());
      final max = double.tryParse(band['max'].toString());
      if (min == null || max == null || max <= min) {
        return 'Every range must have valid min and max values.';
      }
      ranges.add([min, max]);
    }
    ranges.sort((a, b) => a[0].compareTo(b[0]));
    for (var index = 1; index < ranges.length; index++) {
      if (ranges[index][0] < ranges[index - 1][1] + 0.1) {
        return 'Grade ranges overlap. Leave at least 0.1 between boundaries.';
      }
    }
    return null;
  }

  Future<void> _viewGradingScales() async {
    final provider = context.read<Myprovider>();
    final snapshot = await provider.db
        .collection('gradingsystems')
        .where('schoolid', isEqualTo: provider.schoolid)
        .get();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('View grading scales'),
        content: SizedBox(
          width: 760,
          height: 500,
          child: ListView.builder(
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.docs[index];
              final data = doc.data();
              final bands = (data['bands'] as List?)?.length ?? 0;
              return ListTile(
                title: Text(data['name']?.toString() ?? doc.id),
                subtitle: Text('${data['scope'] ?? 'default'} • $bands grades'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _openGradingScaleModal(initialId: doc.id);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _gradingScaleManager(ColorScheme scheme) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: scheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.rule_folder_outlined),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Grading scale',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _openGradingScaleModal,
          icon: const Icon(Icons.add),
          label: const Text('Add scale'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _viewGradingScales,
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('View scales'),
        ),
      ],
    ),
  );

  // ── _stepBody case 0: only ONE academic-year and ONE id-format block ──
  Widget _stepBody(ColorScheme scheme) {
    switch (_step) {
      case 0:
        final provider = context.watch<Myprovider>();
        return _fields([
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'School type',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            child: Text(_schoolType),
          ),
          _registeredSettingChoice(
            label: 'Academic year',
            value: _yearController.text,
            options: provider.academicyears.map((year) => year.name).toList(),
            onChanged: (value) => setState(() => _yearController.text = value ?? ''),
            onRegister: _registerAcademicYear,
            onEdit: (name) {
              final year = provider.academicyears.firstWhere((item) => item.name == name);
              _editAcademicYear(year);
            },
            onDelete: (name) {
              final year = provider.academicyears.firstWhere((item) => item.name == name);
              _deleteRegistered('academicyears', year.id, name);
            },
          ),
          _registeredSettingChoice(
            label: 'ID format',
            value: _idFormatController.text,
            options: provider.idFormats.map((format) => format.name).toList(),
            onChanged: (value) => setState(() => _idFormatController.text = value ?? ''),
            onRegister: _registerIdFormat,
            onEdit: (name) {
              final format = provider.idFormats.firstWhere((item) => item.name == name);
              _editIdFormat(format);
            },
            onDelete: (name) {
              final format = provider.idFormats.firstWhere((item) => item.name == name);
              _deleteRegistered('idformats', format.id, name);
            },
          ),
        ]);
      case 1:
      case 1:
        final provider = context.watch<Myprovider>();
        return _fields([
          _termPanel(scheme, provider),
          _reopeningDatePanel(scheme),
          TextFormField(
            enabled: !_locked,
            decoration: const InputDecoration(
              labelText: 'Next school fees amount',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ]);
      case 2:
        return _fields([
          _structurePanel('Faculty', 'Faculty', _facultyEntries, scheme),
          _structurePanel(
            'Department / programme',
            'Department',
            _departmentEntries,
            scheme,
          ),
          _structurePanel(_groupLabel, _groupLabel, _levelEntries, scheme),
          TextFormField(
            controller: _creditMinController,
            enabled: !_locked,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'School credit-hour minimum',
            ),
          ),
          TextFormField(
            controller: _creditMaxController,
            enabled: !_locked,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'School credit-hour maximum',
            ),
          ),
        ]);
      case 3:
        final provider = context.watch<Myprovider>();
        final selected = provider.subjectList.where(
              (item) => item.code == _selectedCourse,
        );
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_usesSemester ? Icons.menu_book : Icons.book_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Register $_courseLabel',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: _locked ? null : _openCourseRegistrationModal,
                    icon: const Icon(Icons.add),
                    label: Text('Register $_courseLabel'),
                  ),
                  FilledButton.icon(
                    onPressed: _openRegisteredCoursesModal,
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text('View registered $_courseLabel'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.subjectList.length} registered ${_courseLabel.toLowerCase()} records',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              if (selected.isNotEmpty) ...[
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Selected $_courseLabel',
                    border: const OutlineInputBorder(),
                  ),
                  child: Text('${selected.first.code}  ${selected.first.name}'),
                ),
              ],
            ],
          ),
        );
      case 4:
        return _courseMountingStep(scheme);
      case 5:
        return _allocationBody(scheme);
      case 6:
        return _fields([_scoreFields(scheme), _gradingScaleManager(scheme)]);
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _locked ? Icons.lock : Icons.verified_outlined,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _locked
                          ? 'This setup is locked for the current period.'
                          : 'Review the essentials, then lock the setup to protect your academic configuration.',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _summaryRow('School type', _schoolType, scheme),
            _summaryRow('Academic year', _yearController.text, scheme),
            _summaryRow(
              _periodLabel,
              _usesSemester ? 'First semester' : 'First term',
              scheme,
            ),
            _summaryRow(
              'Assessment split',
              '${_caController.text}% CA + ${_examController.text}% Exam',
              scheme,
            ),
            const SizedBox(height: 16),
            Text(
              'You can still view records from the sidebar after locking. Unlocking requires an administrator.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        );
    }
  }

  Widget _fields(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children
        .map(
          (child) =>
          Padding(padding: const EdgeInsets.only(bottom: 18), child: child),
    )
        .toList(),
  );

  Widget _allocationBody(ColorScheme scheme) {
    final provider = context.watch<Myprovider>();
    dynamic selectedDepartment;
    for (final item in provider.departments) {
      if (item.id == _selectedDepartment) selectedDepartment = item;
    }
    final staffQuery = _staffSearchController.text.trim().toLowerCase();
    final staff = provider.stafflist.where((item) {
      final departmentMatches =
          _selectedDepartment == null ||
              item.departmentId.isEmpty ||
              item.departmentId == _selectedDepartment ||
              item.departmentId.toLowerCase() ==
                  (selectedDepartment?.name ?? '').toString().toLowerCase();
      final searchMatches =
          staffQuery.isEmpty ||
              item.name.toLowerCase().contains(staffQuery) ||
              item.email.toLowerCase().contains(staffQuery);
      return departmentMatches && searchMatches;
    }).toList();
    final query = _allocationSearch.toLowerCase();
    final assignedCodes = _assignedAllocations
        .where(
          (item) =>
      item['academicYear'] == _yearController.text.trim() &&
          item['termOrSemester'] == _period,
    )
        .map((item) => item['courseCode'].toString())
        .toSet();
    final courses = provider.subjectList.where((course) {
      final textMatches =
          query.isEmpty ||
              course.name.toLowerCase().contains(query) ||
              (course.code ?? '').toLowerCase().contains(query);
      final departmentMatches =
          _selectedDepartment == null ||
              course.department == null ||
              course.department == selectedDepartment?.name ||
              course.scope == 'All departments';
      return textMatches && departmentMatches;
    }).toList();
    final unassigned = courses
        .where((course) => !assignedCodes.contains(course.code))
        .toList();
    final assigned = _assignedAllocations
        .where(
          (item) =>
      item['academicYear'] == _yearController.text.trim() &&
          item['termOrSemester'] == _period,
    )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _formSectionTitle(
                'Course allocation',
                'Manage registered $_courseLabel assignments by department and teacher.',
              ),
            ),
            FilledButton.icon(
              onPressed: () => context.go(Routes.courseallocation),
              icon: const Icon(Icons.open_in_new),
              label: Text('Open $_courseLabel allocation'),
            ),
          ],
        ),
        if (_facultyEntries.isEmpty)
          TextFormField(
            controller: _facultyController,
            enabled: !_locked,
            decoration: const InputDecoration(
              labelText: 'Faculty / level group',
            ),
          )
        else
          DropdownButtonFormField<String>(
            initialValue: _facultyEntries.contains(_facultyController.text)
                ? _facultyController.text
                : null,
            decoration: const InputDecoration(
              labelText: 'Faculty / level group',
            ),
            items: _facultyEntries
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: _locked
                ? null
                : (value) =>
                setState(() => _facultyController.text = value ?? ''),
          ),
        DropdownButtonFormField<String>(
          initialValue: _selectedDepartment,
          decoration: const InputDecoration(
            labelText: 'Department / programme',
          ),
          items: provider.departments
              .map(
                (item) =>
                DropdownMenuItem(value: item.id, child: Text(item.name)),
          )
              .toList(),
          onChanged: _locked
              ? null
              : (value) => setState(() {
            _selectedDepartment = value;
            _departmentController.text = provider.departments
                .firstWhere((item) => item.id == value)
                .name;
            _selectedCourse = null;
          }),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _staffSearchController,
          enabled: !_locked,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Search staff',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedStaff,
          decoration: const InputDecoration(labelText: 'Staff / tutor'),
          items: staff
              .map(
                (item) => DropdownMenuItem(
              value: item.id,
              child: Text('${item.name} (${item.accessLevel})'),
            ),
          )
              .toList(),
          onChanged: _locked
              ? null
              : (value) => setState(() {
            _selectedStaff = value;
            _teacherController.text = value ?? '';
          }),
        ),
        const SizedBox(height: 18),
        if (_loadingAllocations)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(),
          ),
        TextField(
          enabled: !_locked,
          onChanged: (value) => setState(() => _allocationSearch = value),
          decoration: InputDecoration(
            labelText: 'Search $_courseLabel',
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 8),
        _allocationList('$_courseLabel not assigned', unassigned, scheme),
        const SizedBox(height: 16),
        _assignedList(assigned, scheme),
      ],
    );
  }

  Widget _courseMountingStep(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.playlist_add_check_outlined, size: 30),
          const SizedBox(height: 10),
          Text(
            'Course mounting',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Mount core and elective ${_courseLabel.toLowerCase()}s by department and ${_groupLabel.toLowerCase()}. Credit limits are validated from the school profile.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => Dialog(
                  child: SizedBox(
                    width: 1100,
                    height: 720,
                    child: const CourseMountingPage(embedded: true),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open course mounting'),
          ),
        ],
      ),
    );
  }

  Widget _allocationList(
      String title,
      List<dynamic> courses,
      ColorScheme scheme,
      ) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: scheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${courses.length})',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        if (courses.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'No records found.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          )
        else
          ...courses.map(
                (course) => ListTile(
              dense: true,
              title: Text('${course.code ?? ''}  ${course.name}'),
              subtitle: Text(
                '${course.department ?? 'All departments'} • ${course.creditHours} credit hours',
              ),
              trailing: FilledButton(
                onPressed: _locked
                    ? null
                    : () => setState(() => _selectedCourse = course.code),
                child: Text(
                  _selectedCourse == course.code ? 'Selected' : 'Select',
                ),
              ),
            ),
          ),
        if (_selectedCourse != null)
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _locked ? null : _saveAllocation,
              icon: const Icon(Icons.save),
              label: const Text('Save allocation'),
            ),
          ),
      ],
    ),
  );

  Widget _assignedList(
      List<Map<String, dynamic>> records,
      ColorScheme scheme,
      ) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned $_courseLabel records (${records.length})',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        if (records.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'No assigned courses for this period.',
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
          )
        else
          ...records.map(
                (item) => ListTile(
              dense: true,
              title: Text(item['courseCode'].toString()),
              subtitle: Text(
                'Staff: ${item['staffId']} • ${item['departmentId']}',
              ),
            ),
          ),
      ],
    ),
  );

  Widget _formSectionTitle(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  Widget _structurePanel(
      String title,
      String kind,
      List<String> entries,
      ColorScheme scheme,
      ) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      border: Border.all(color: scheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _locked
                  ? null
                  : () => _editStructureEntry(kind, entries),
              icon: const Icon(Icons.add, size: 17),
              label: const Text('Add'),
            ),
          ],
        ),
        if (entries.isEmpty)
          Text(
            'No $kind registered yet.',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          )
        else
          ...entries.map(
                (entry) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.check_circle_outline,
                color: scheme.primary,
                size: 18,
              ),
              title: Text(entry),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit $entry',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: _locked
                        ? null
                        : () => _editStructureEntry(
                      kind,
                      entries,
                      currentValue: entry,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete $entry',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: _locked
                        ? null
                        : () => _deleteStructureEntry(kind, entry),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget _scoreFields(ColorScheme scheme) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      border: Border.all(color: scheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Score configuration',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'The two components must total 100%. Set the allowed minimum and maximum in the manager.',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        _fieldGrid([
          TextFormField(
            controller: _caController,
            enabled: !_locked,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Continuous assessment %',
            ),
          ),
          TextFormField(
            controller: _caMinController,
            enabled: !_locked,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'CA minimum'),
          ),
          TextFormField(
            controller: _caMaxController,
            enabled: !_locked,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'CA maximum'),
          ),
          TextFormField(
            controller: _examController,
            enabled: !_locked,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Exam %'),
          ),
          TextFormField(
            controller: _examMinController,
            enabled: !_locked,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Exam minimum'),
          ),
          TextFormField(
            controller: _examMaxController,
            enabled: !_locked,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Exam maximum'),
          ),
        ]),
      ],
    ),
  );

  Widget _fieldGrid(List<Widget> fields) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 520) {
        return Column(
          children: fields
              .map(
                (field) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: field,
            ),
          )
              .toList(),
        );
      }
      final width = (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: fields
            .map((field) => SizedBox(width: width, child: field))
            .toList(),
      );
    },
  );

  Widget _summaryRow(String label, String value, ColorScheme scheme) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}