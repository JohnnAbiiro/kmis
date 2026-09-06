//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
//
// import '../controller/dbmodels/courseallocationmodel.dart';
// import '../controller/dbmodels/coursemountmodel.dart';
// import '../controller/myprovider.dart';
// import '../controller/routes.dart';
// import 'viewcourseallocation.dart';
//
// class CourseAllocationPage extends StatefulWidget {
//   const CourseAllocationPage({super.key});
//
//   @override
//   State<CourseAllocationPage> createState() => _CourseAllocationPageState();
// }
//
// class _CourseAllocationPageState extends State<CourseAllocationPage> {
//   bool _loading = true;
//   String? _facultyId;
//   String? _departmentId;
//   String? _classOrLevel;
//   String? _staffId;
//   String _staffSearch = '';
//   final Set<String> _checkedAvailable = {};
//   final Set<String> _checkedSelected = {};
//   final Set<String> _selectedCodes = {};
//   List<CourseMountModel> _mounts = [];
//   List<CourseAllocationModel> _allocations = [];
//
//   Myprovider get _provider => context.read<Myprovider>();
//
//   String get _courseTitle => _provider.schoolType == 'Pre-tertiary' ? 'Subject' : 'Course';
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _load());
//   }
//
//   Future<void> _load() async {
//     final provider = _provider;
//     await Future.wait([
//       provider.fetchdepart(),
//       provider.fetchstaff(),
//       provider.fetchsubjects(),
//       provider.fetchclass(),
//     ]);
//     final mountsSnap = await provider.db
//         .collection('courseMounting')
//         .where('schoolId', isEqualTo: provider.schoolid)
//         .where('academicYear', isEqualTo: provider.year)
//         .where('termOrSemester', isEqualTo: provider.term)
//         .get();
//     final allocSnap = await provider.db
//         .collection('courseAllocation')
//         .where('schoolId', isEqualTo: provider.schoolid)
//         .where('academicYear', isEqualTo: provider.year)
//         .where('termOrSemester', isEqualTo: provider.term)
//         .get();
//     if (!mounted) return;
//     setState(() {
//       _mounts = mountsSnap.docs.map((d) => CourseMountModel.fromMap({...d.data(), 'id': d.id})).toList();
//       _allocations = allocSnap.docs.map((d) => CourseAllocationModel.fromMap({...d.data(), 'id': d.id})).toList();
//       _loading = false;
//     });
//   }
//
//   String? get _selectedFacultyName =>
//       _provider.faculties.where((f) => f.id == _facultyId).map((f) => f.name as String).firstOrNull;
//
//   String? get _selectedDepartmentName =>
//       _provider.departments.where((d) => d.id == _departmentId).map((d) => d.name as String).firstOrNull;
//
//   List<dynamic> get _availableDepartments =>
//       _provider.departments.where((d) => _facultyId == null || d.faculty == _selectedFacultyName).toList();
//
//   CourseMountModel? get _mountForSelection {
//     if (_departmentId == null || _classOrLevel == null) return null;
//     return _mounts.where((m) => m.departmentId == _departmentId && m.classOrLevel == _classOrLevel).firstOrNull;
//   }
//
//   List<dynamic> get _availableLevels {
//     final ids = _mounts.where((m) => _departmentId == null || m.departmentId == _departmentId).map((m) => m.classOrLevel).toSet();
//     return _provider.classdata.where((c) => ids.contains(c.name)).toList();
//   }
//
//   List<dynamic> get _staffOptions {
//     final query = _staffSearch.toLowerCase();
//     return _provider.stafflist.where((s) {
//       final departmentMatches = _departmentId == null || s.departmentId == _departmentId;
//       final searchMatches = query.isEmpty || s.name.toLowerCase().contains(query) || s.email.toLowerCase().contains(query);
//       return departmentMatches && searchMatches;
//     }).toList();
//   }
//
//   List<dynamic> get _mountedCourses {
//     final mount = _mountForSelection;
//     if (mount == null) return [];
//     return _provider.subjectList.where((c) => mount.allCourseCodes.contains(c.code)).toList();
//   }
//
//   Set<String> get _allocatedElsewhereCodes {
//     if (_departmentId == null || _classOrLevel == null) return {};
//     return _allocations
//         .where((a) => a.departmentId == _departmentId && a.classOrLevel == _classOrLevel && a.staffId != _staffId)
//         .map((a) => a.courseCode)
//         .toSet();
//   }
//
//   List<dynamic> get _availableCourses => _mountedCourses
//       .where((c) => !_selectedCodes.contains(c.code) && !_allocatedElsewhereCodes.contains(c.code))
//       .toList();
//
//   List<dynamic> get _selectedCourses => _mountedCourses.where((c) => _selectedCodes.contains(c.code)).toList();
//
//   void _onSelectionChanged() {
//     setState(() {
//       _selectedCodes.clear();
//       if (_staffId != null && _departmentId != null && _classOrLevel != null) {
//         _selectedCodes.addAll(
//           _allocations
//               .where((a) => a.staffId == _staffId && a.departmentId == _departmentId && a.classOrLevel == _classOrLevel)
//               .map((a) => a.courseCode),
//         );
//       }
//       _checkedAvailable.clear();
//       _checkedSelected.clear();
//     });
//   }
//
//   void _addChecked() {
//     setState(() {
//       _selectedCodes.addAll(_checkedAvailable);
//       _checkedAvailable.clear();
//     });
//   }
//
//   void _removeChecked() {
//     setState(() {
//       _selectedCodes.removeAll(_checkedSelected);
//       _checkedSelected.clear();
//     });
//   }
//
//   Future<void> _save() async {
//     final provider = _provider;
//     final staffId = _staffId;
//     final departmentId = _departmentId;
//     final classOrLevel = _classOrLevel;
//     if (staffId == null || departmentId == null || classOrLevel == null) return;
//     final staff = provider.stafflist.firstWhere((s) => s.id == staffId);
//     final existing = _allocations.where(
//           (a) => a.staffId == staffId && a.departmentId == departmentId && a.classOrLevel == classOrLevel,
//     );
//     for (final item in existing) {
//       if (!_selectedCodes.contains(item.courseCode)) {
//         await provider.db.collection('courseAllocation').doc(item.id).delete();
//       }
//     }
//     for (final code in _selectedCodes) {
//       final course = _provider.subjectList.firstWhere((c) => c.code == code);
//       final id = '${provider.schoolid}_${staffId}_${departmentId}_${classOrLevel}_$code';
//       final model = CourseAllocationModel(
//         id: id,
//         schoolId: provider.schoolid,
//         staffId: staffId,
//         staffName: staff.name,
//         facultyId: _facultyId ?? '',
//         departmentId: departmentId,
//         classOrLevel: classOrLevel,
//         academicYear: provider.year,
//         termOrSemester: provider.term,
//         courseCode: code,
//         courseName: course.name,
//       );
//       await provider.db.collection('courseAllocation').doc(id).set(model.toMap(), SetOptions(merge: true));
//     }
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Allocation saved.'), backgroundColor: Colors.green),
//       );
//     }
//     await _load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$_courseTitle allocation'),
//         leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(Routes.setupWizard)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.table_view_outlined),
//             tooltip: 'View allocation',
//             onPressed: () => Navigator.of(context).push(
//               MaterialPageRoute(builder: (_) => const ViewCourseAllocationPage()),
//             ),
//           ),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final wide = constraints.maxWidth > 700;
//                 final fields = [
//                   _dropdown('Faculty', _facultyId, _provider.faculties.map((f) => f.id as String).toList(),
//                       _provider.faculties.map((f) => f.name as String).toList(), (v) {
//                         setState(() {
//                           _facultyId = v;
//                           _departmentId = null;
//                           _classOrLevel = null;
//                           _staffId = null;
//                         });
//                         _onSelectionChanged();
//                       }),
//                   _dropdown('Department', _departmentId, _availableDepartments.map((d) => d.id as String).toList(),
//                       _availableDepartments.map((d) => d.name as String).toList(), (v) {
//                         setState(() {
//                           _departmentId = v;
//                           _classOrLevel = null;
//                           _staffId = null;
//                         });
//                         _onSelectionChanged();
//                       }),
//                   _dropdown('Class / Level', _classOrLevel, _availableLevels.map((c) => c.name as String).toList(),
//                       _availableLevels.map((c) => c.name as String).toList(), (v) {
//                         setState(() => _classOrLevel = v);
//                         _onSelectionChanged();
//                       }),
//                 ];
//                 return wide
//                     ? Row(children: fields.map((f) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: f))).toList())
//                     : Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList());
//               },
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               onChanged: (v) => setState(() => _staffSearch = v),
//               decoration: const InputDecoration(labelText: 'Search staff', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 10),
//             DropdownButtonFormField<String>(
//               initialValue: _staffOptions.any((s) => s.id == _staffId) ? _staffId : null,
//               decoration: const InputDecoration(labelText: 'Staff / tutor', border: OutlineInputBorder()),
//               items: _staffOptions.map((s) => DropdownMenuItem(value: s.id as String, child: Text('${s.name} (${s.accessLevel})'))).toList(),
//               onChanged: (v) {
//                 setState(() => _staffId = v);
//                 _onSelectionChanged();
//               },
//             ),
//             const SizedBox(height: 12),
//             if (_mountForSelection == null && _departmentId != null && _classOrLevel != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Text('No mounted $_courseTitle records for this class.', style: const TextStyle(color: Colors.red)),
//               ),
//             if (_staffId != null && _mountForSelection != null)
//               Expanded(child: _pickerBody(scheme))
//             else
//               Expanded(child: Center(child: Text('Select department, class and staff to allocate.', style: TextStyle(color: scheme.onSurfaceVariant)))),
//             if (_staffId != null && _mountForSelection != null) ...[
//               const SizedBox(height: 12),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save assignments')),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _dropdown(String label, String? value, List<String> ids, List<String> names, ValueChanged<String?> onChanged) {
//     return DropdownButtonFormField<String>(
//       initialValue: ids.contains(value) ? value : null,
//       decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
//       items: List.generate(ids.length, (i) => DropdownMenuItem(value: ids[i], child: Text(names[i]))),
//       onChanged: onChanged,
//     );
//   }
//
//   Widget _pickerBody(ColorScheme scheme) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final wide = constraints.maxWidth > 640;
//         final available = _list('Available $_courseTitle records', _availableCourses, _checkedAvailable, scheme);
//         final buttons = Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           child: wide
//               ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//             OutlinedButton(onPressed: _checkedAvailable.isEmpty ? null : _addChecked, child: const Text('Add >>')),
//             const SizedBox(height: 10),
//             OutlinedButton(onPressed: _checkedSelected.isEmpty ? null : _removeChecked, child: const Text('<< Remove')),
//           ])
//               : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             OutlinedButton(onPressed: _checkedAvailable.isEmpty ? null : _addChecked, child: const Text('Add >>')),
//             const SizedBox(width: 10),
//             OutlinedButton(onPressed: _checkedSelected.isEmpty ? null : _removeChecked, child: const Text('<< Remove')),
//           ]),
//         );
//         final selected = _list('Allocated $_courseTitle records', _selectedCourses, _checkedSelected, scheme);
//         return wide
//             ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: available), buttons, Expanded(child: selected)])
//             : Column(children: [Expanded(child: available), buttons, Expanded(child: selected)]);
//       },
//     );
//   }
//
//   Widget _list(String title, List<dynamic> courses, Set<String> checked, ColorScheme scheme) {
//     return Container(
//       decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(10)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(padding: const EdgeInsets.all(10), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
//           const Divider(height: 1),
//           Expanded(
//             child: courses.isEmpty
//                 ? Center(child: Text('No records', style: TextStyle(color: scheme.onSurfaceVariant)))
//                 : ListView.builder(
//               itemCount: courses.length,
//               itemBuilder: (context, i) {
//                 final course = courses[i];
//                 return CheckboxListTile(
//                   dense: true,
//                   value: checked.contains(course.code),
//                   title: Text('${course.code}  ${course.name}'),
//                   onChanged: (v) => setState(() {
//                     if (v == true) {
//                       checked.add(course.code);
//                     } else {
//                       checked.remove(course.code);
//                     }
//                   }),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


import '../controller/dbmodels/CourseAllocationModel.dart';
import '../controller/dbmodels/coursemountmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import 'viewcourseallocation.dart';

class CourseAllocationPage extends StatefulWidget {
  const CourseAllocationPage({super.key});

  @override
  State<CourseAllocationPage> createState() => _CourseAllocationPageState();
}

class _CourseAllocationPageState extends State<CourseAllocationPage> {
  bool _loading = true;
  bool _saving = false;
  String? _facultyId;
  String? _departmentId;
  String? _classOrLevel;
  String? _staffId;
  String _staffSearch = '';
  final Set<String> _checkedAvailable = {};
  final Set<String> _checkedSelected = {};
  final Set<String> _selectedCodes = {};
  List<CourseMountModel> _mounts = [];
  List<CourseAllocationModel> _allocations = [];

  Myprovider get _provider => context.read<Myprovider>();

  String get _courseTitle => _provider.schoolType == 'Pre-tertiary' ? 'Subject' : 'Course';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = _provider;
    await Future.wait([
      provider.fetchdepart(),
      provider.fetchstaff(),
      provider.fetchsubjects(),
      provider.fetchclass(),
    ]);
    final mountsSnap = await provider.db
        .collection('courseMounting')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('academicYear', isEqualTo: provider.year)
        .where('termOrSemester', isEqualTo: provider.term)
        .get();
    final allocSnap = await provider.db
        .collection('courseAllocation')
        .where('schoolId', isEqualTo: provider.schoolid)
        .where('academicYear', isEqualTo: provider.year)
        .where('termOrSemester', isEqualTo: provider.term)
        .get();
    if (!mounted) return;
    setState(() {
      _mounts = mountsSnap.docs.map((d) => CourseMountModel.fromMap({...d.data(), 'id': d.id})).toList();
      _allocations = allocSnap.docs.map((d) => CourseAllocationModel.fromMap({...d.data(), 'id': d.id})).toList();
      _loading = false;
    });
  }

  String? get _selectedFacultyName =>
      _provider.faculties.where((f) => f.id == _facultyId).map((f) => f.name as String).firstOrNull;

  String? get _selectedDepartmentName =>
      _provider.departments.where((d) => d.id == _departmentId).map((d) => d.name as String).firstOrNull;

  List<dynamic> get _availableDepartments =>
      _provider.departments.where((d) => _facultyId == null || d.faculty == _selectedFacultyName).toList();

  CourseMountModel? get _mountForSelection {
    if (_departmentId == null || _classOrLevel == null) return null;
    return _mounts.where((m) => m.departmentId == _departmentId && m.classOrLevel == _classOrLevel).firstOrNull;
  }

  List<dynamic> get _availableLevels {
    final ids = _mounts.where((m) => _departmentId == null || m.departmentId == _departmentId).map((m) => m.classOrLevel).toSet();
    return _provider.classdata.where((c) => ids.contains(c.name)).toList();
  }

  List<dynamic> get _staffOptions {
    final query = _staffSearch.toLowerCase();
    return _provider.stafflist.where((s) {
      final departmentMatches = _departmentId == null || s.departmentId == _departmentId;
      final searchMatches = query.isEmpty || s.name.toLowerCase().contains(query) || s.email.toLowerCase().contains(query);
      final notAlreadyAssigned = !_isStaffAssigned(s.id as String);
      return departmentMatches && searchMatches && notAlreadyAssigned;
    }).toList();
  }


  bool _isStaffAssigned(String staffId) {
    if (_departmentId == null || _classOrLevel == null) return false;
    return _allocations.any(
          (a) => a.staffId == staffId && a.departmentId == _departmentId && a.classOrLevel == _classOrLevel,
    );
  }

  List<dynamic> get _mountedCourses {
    final mount = _mountForSelection;
    if (mount == null) return [];
    return _provider.subjectList.where((c) => mount.allCourseCodes.contains(c.code)).toList();
  }

  Set<String> get _allocatedElsewhereCodes {
    if (_departmentId == null || _classOrLevel == null) return {};
    return _allocations
        .where((a) => a.departmentId == _departmentId && a.classOrLevel == _classOrLevel && a.staffId != _staffId)
        .map((a) => a.courseCode)
        .toSet();
  }

  List<dynamic> get _availableCourses => _mountedCourses
      .where((c) => !_selectedCodes.contains(c.code) && !_allocatedElsewhereCodes.contains(c.code))
      .toList();

  List<dynamic> get _selectedCourses => _mountedCourses.where((c) => _selectedCodes.contains(c.code)).toList();

  void _onSelectionChanged() {
    setState(() {
      _selectedCodes.clear();
      if (_staffId != null && _departmentId != null && _classOrLevel != null) {
        _selectedCodes.addAll(
          _allocations
              .where((a) => a.staffId == _staffId && a.departmentId == _departmentId && a.classOrLevel == _classOrLevel)
              .map((a) => a.courseCode),
        );
      }
      _checkedAvailable.clear();
      _checkedSelected.clear();
    });
  }

  void _addChecked() {
    setState(() {
      _selectedCodes.addAll(_checkedAvailable);
      _checkedAvailable.clear();
    });
  }

  void _removeChecked() {
    setState(() {
      _selectedCodes.removeAll(_checkedSelected);
      _checkedSelected.clear();
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final provider = _provider;
    final staffId = _staffId;
    final departmentId = _departmentId;
    final classOrLevel = _classOrLevel;
    if (staffId == null || departmentId == null || classOrLevel == null) return;

    setState(() => _saving = true);
    try {
      final staff = provider.stafflist.firstWhere((s) => s.id == staffId);
      final existing = _allocations.where(
            (a) => a.staffId == staffId && a.departmentId == departmentId && a.classOrLevel == classOrLevel,
      );
      for (final item in existing) {
        if (!_selectedCodes.contains(item.courseCode)) {
          await provider.db.collection('courseAllocation').doc(item.id).delete();
        }
      }
      for (final code in _selectedCodes) {
        final course = _provider.subjectList.firstWhere((c) => c.code == code);
        final id = '${provider.schoolid}_${staffId}_${departmentId}_${classOrLevel}_$code';
        final model = CourseAllocationModel(
          id: id,
          schoolId: provider.schoolid,
          staffId: staffId,
          staffName: staff.name,
          facultyId: _facultyId ?? '',
          departmentId: departmentId,
          classOrLevel: classOrLevel,
          academicYear: provider.year,
          termOrSemester: provider.term,
          courseCode: code,
          courseName: course.name,
          staffemail: staff.email,
        );
        await provider.db.collection('courseAllocation').doc(id).set(model.toMap(), SetOptions(merge: true));
      }

      // Reload allocations so the "already assigned" indicator and the
      // available/selected course lists reflect what was just saved,
      // without needing to re-navigate to the page.
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedCodes.isEmpty
                ? 'Allocation cleared for ${staff.name}.'
                : 'Allocation saved for ${staff.name}.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save allocation: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('$_courseTitle allocation'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(Routes.setupWizard)),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_view_outlined),
            tooltip: 'View allocation',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ViewCourseAllocationPage()),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 700;
                final fields = [
                  _dropdown('Faculty', _facultyId, _provider.faculties.map((f) => f.id as String).toList(),
                      _provider.faculties.map((f) => f.name as String).toList(), _saving ? null : (v) {
                        setState(() {
                          _facultyId = v;
                          _departmentId = null;
                          _classOrLevel = null;
                          _staffId = null;
                        });
                        _onSelectionChanged();
                      }),
                  _dropdown('Department', _departmentId, _availableDepartments.map((d) => d.id as String).toList(),
                      _availableDepartments.map((d) => d.name as String).toList(), _saving ? null : (v) {
                        setState(() {
                          _departmentId = v;
                          _classOrLevel = null;
                          _staffId = null;
                        });
                        _onSelectionChanged();
                      }),
                  _dropdown('Class / Level', _classOrLevel, _availableLevels.map((c) => c.name as String).toList(),
                      _availableLevels.map((c) => c.name as String).toList(), _saving ? null : (v) {
                        setState(() => _classOrLevel = v);
                        _onSelectionChanged();
                      }),
                ];
                return wide
                    ? Row(children: fields.map((f) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: f))).toList())
                    : Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList());
              },
            ),
            const SizedBox(height: 10),
            TextField(
              enabled: !_saving,
              onChanged: (v) => setState(() => _staffSearch = v),
              decoration: const InputDecoration(labelText: 'Search staff', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _staffOptions.any((s) => s.id == _staffId) ? _staffId : null,
              decoration: const InputDecoration(labelText: 'Staff / tutor', border: OutlineInputBorder()),
              items: _staffOptions.map((s) {
                final assigned = _isStaffAssigned(s.id as String);
                return DropdownMenuItem(
                  value: s.id as String,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Text('${s.name} (${s.accessLevel})', overflow: TextOverflow.ellipsis)),
                      if (assigned) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                      ],
                    ],
                  ),
                );
              }).toList(),
              selectedItemBuilder: (context) => _staffOptions
                  .map((s) => Text('${s.name} (${s.accessLevel})', overflow: TextOverflow.ellipsis))
                  .toList(),
              onChanged: _saving
                  ? null
                  : (v) {
                setState(() => _staffId = v);
                _onSelectionChanged();
              },
            ),
            if (_staffOptions.any((s) => _isStaffAssigned(s.id as String)))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'already has a $_courseTitle allocation for this class/level',
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (_mountForSelection == null && _departmentId != null && _classOrLevel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('No mounted $_courseTitle records for this class.', style: const TextStyle(color: Colors.red)),
              ),
            if (_staffId != null && _mountForSelection != null)
              Expanded(child: _pickerBody(scheme))
            else
              Expanded(child: Center(child: Text('Select department, class and staff to allocate.', style: TextStyle(color: scheme.onSurfaceVariant)))),
            if (_staffId != null && _mountForSelection != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save assignments'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> ids, List<String> names, ValueChanged<String?>? onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: ids.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: List.generate(ids.length, (i) => DropdownMenuItem(value: ids[i], child: Text(names[i]))),
      onChanged: onChanged,
    );
  }

  Widget _pickerBody(ColorScheme scheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 640;
        final available = _list('Available $_courseTitle records', _availableCourses, _checkedAvailable, scheme);
        final buttons = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: wide
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(onPressed: (_saving || _checkedAvailable.isEmpty) ? null : _addChecked, child: const Text('Add >>')),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: (_saving || _checkedSelected.isEmpty) ? null : _removeChecked, child: const Text('<< Remove')),
          ])
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(onPressed: (_saving || _checkedAvailable.isEmpty) ? null : _addChecked, child: const Text('Add >>')),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: (_saving || _checkedSelected.isEmpty) ? null : _removeChecked, child: const Text('<< Remove')),
          ]),
        );
        final selected = _list('Allocated $_courseTitle records', _selectedCourses, _checkedSelected, scheme);
        return wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: available), buttons, Expanded(child: selected)])
            : Column(children: [Expanded(child: available), buttons, Expanded(child: selected)]);
      },
    );
  }

  Widget _list(String title, List<dynamic> courses, Set<String> checked, ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(10), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
          const Divider(height: 1),
          Expanded(
            child: courses.isEmpty
                ? Center(child: Text('No records', style: TextStyle(color: scheme.onSurfaceVariant)))
                : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, i) {
                final course = courses[i];
                return CheckboxListTile(
                  dense: true,
                  value: checked.contains(course.code),
                  title: Text('${course.code}  ${course.name}'),
                  onChanged: _saving
                      ? null
                      : (v) => setState(() {
                    if (v == true) {
                      checked.add(course.code);
                    } else {
                      checked.remove(course.code);
                    }
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}