// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../controller/dbmodels/classmodel.dart';
// import '../controller/myprovider.dart';
// import '../controller/routes.dart';
// import '../widgets/dropdown.dart';
// import '../widgets/dropdown1.dart';
//
// class ClassScreen extends StatefulWidget {
//   final ClassModel? classes;
//   final bool embedded;
//   final VoidCallback? onDeleted;
//   const ClassScreen({super.key, this.classes, this.embedded = false, this.onDeleted});
//
//   @override
//   State<ClassScreen> createState() => _ClassScreenState();
// }
//
// class _ClassScreenState extends State<ClassScreen> {
//   final classController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   String? selecteddepart;
//   bool _isSubmitting = false;
//   bool _isDeleting = false;
//
//
//   String? _duplicateWarning;
//   bool _checkingDuplicate = false;
//   Timer? _debounce;
//
//   bool get isEdit => widget.classes != null;
//   bool get _busy => _isSubmitting || _isDeleting;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<Myprovider>();
//       provider.fetchdepart();
//     });
//
//     final data = widget.classes;
//     if (data != null) {
//       classController.text = data.name;
//       selecteddepart = data.department;
//     }
//
//     classController.addListener(_scheduleDuplicateCheck);
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     classController.removeListener(_scheduleDuplicateCheck);
//     classController.dispose();
//     super.dispose();
//   }
//
//   String _normalize(String value) =>
//       value.trim().replaceAll(RegExp(r'\s+'), '').toLowerCase();
//
//   String? _facultyForSelectedDepartment(Myprovider provider) {
//     if (selecteddepart == null) return null;
//     for (final d in provider.departments) {
//       if (d.name == selecteddepart) return d.faculty;
//     }
//     return null;
//   }
//
//   String _computeId(String schoolId, String faculty, String department, String className) {
//     final normFaculty = _normalize(faculty);
//     final normDept = _normalize(department);
//     final normName = _normalize(className);
//     return "${schoolId}_${normFaculty}_${normDept}_$normName";
//   }
//
//   void _scheduleDuplicateCheck() {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 400), _checkDuplicate);
//   }
//  Future<void> _checkDuplicate() async {
//     final name = classController.text.trim();
//     if (name.isEmpty || selecteddepart == null) {
//       if (_duplicateWarning != null || _checkingDuplicate) {
//         if (mounted) {
//           setState(() {
//             _duplicateWarning = null;
//             _checkingDuplicate = false;
//           });
//         }
//       }
//       return;
//     }
//
//     final provider = context.read<Myprovider>();
//     final faculty = _facultyForSelectedDepartment(provider);
//     if (faculty == null || faculty.trim().isEmpty) {
//       if (mounted) {
//         setState(() {
//           _duplicateWarning = 'Selected department has no faculty set.';
//           _checkingDuplicate = false;
//         });
//       }
//       return;
//     }
//     final targetId = _computeId(provider.schoolid, faculty, selecteddepart!, name);
//
//     if (mounted) setState(() => _checkingDuplicate = true);
//
//     try {
//       final snap = await provider.db.collection('classes').doc(targetId).get();
//       final isSelf = isEdit && widget.classes!.id == targetId;
//       final clash = snap.exists && !isSelf;
//
//       if (!mounted) return;
//       setState(() {
//         _duplicateWarning =
//         clash ? 'A class with this name already exists in this department.' : null;
//         _checkingDuplicate = false;
//       });
//     } catch (_) {
//       if (mounted) setState(() => _checkingDuplicate = false);
//     }
//   }
//
//   Future<void> _handleSubmit(
//       BuildContext context,
//       Myprovider value,
//       ColorScheme colors,
//       ) async {
//     if (!_formKey.currentState!.validate() || _busy) return;
//     if (selecteddepart == null) return; // dropdown has its own validatorMsg
//
//     setState(() => _isSubmitting = true);
//     try {
//       final className = classController.text.trim();
//       final faculty = _facultyForSelectedDepartment(value);
//       if (faculty == null || faculty.trim().isEmpty) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Selected department has no faculty set.'),
//               backgroundColor: colors.error,
//             ),
//           );
//         }
//         return;
//       }
//       final targetId = _computeId(value.schoolid, faculty, selecteddepart!, className);
//
//
//       final docId = isEdit ? widget.classes!.id : targetId;
//
//
//       final existing = await value.db.collection('classes').doc(targetId).get();
//       final hasClash = existing.exists && existing.id != docId;
//
//       if (hasClash) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('A class with this name already exists in this department.'),
//               backgroundColor: colors.error,
//             ),
//           );
//         }
//         return;
//       }
//
//       final model = ClassModel(
//         id: docId,
//         name: className,
//         schoolId: value.schoolid,
//         department: selecteddepart,
//         faculty: faculty,
//         timestamp: DateTime.now(),
//         staff: value.name,
//       );
//
//       await value.db.collection('classes').doc(docId).set(model.toMap(), SetOptions(merge: true));
//
//       // Update the cached list in place — no refetch needed.
//       value.upsertClass(model);
//
//       if (!context.mounted) return;
//
//       if (isEdit || widget.embedded) {
//         Navigator.pop(context, model);
//         return;
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Class registered successfully', textAlign: TextAlign.center),
//           backgroundColor: Colors.green.shade600,
//         ),
//       );
//
//       classController.clear();
//       setState(() => selecteddepart = null);
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to save class: $e"),
//             backgroundColor: colors.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }
//
//   Future<void> _confirmDelete(BuildContext context, Myprovider value) async {
//     final cls = widget.classes;
//     if (cls == null) return;
//
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Delete class?'),
//         content: Text(
//           'Remove "${cls.name}" from the registered classes? This cannot be undone.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed != true || !mounted) return;
//
//     setState(() => _isDeleting = true);
//
//     try {
//       await value.db.collection('classes').doc(cls.id).delete();
//
//       value.removeClass(cls.id);
//
//       widget.onDeleted?.call();
//
//       if (!context.mounted) return;
//
//       Navigator.pop(context);
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to delete class: $e"),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isDeleting = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//
//     return Consumer<Myprovider>(
//       builder: (BuildContext context, Myprovider value, Widget? child) {
//         final formBody = Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (widget.embedded)
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       isEdit ? 'Edit Class' : 'Register Class',
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: _busy ? null : () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               const SizedBox(height: 20),
//               buildDropdown(
//                 value: selecteddepart,
//                 items: value.departments.map((e) => e.name).toList(),
//                 label: "Department",
//                 fillColor: colors.surface,
//                 onChanged: _busy
//                     ? null
//                     : (v) {
//                   setState(() => selecteddepart = v);
//                   _scheduleDuplicateCheck();
//                 },
//                 validatorMsg: 'Select department',
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: classController,
//                 enabled: !_busy,
//                 style: TextStyle(fontSize: 14, color: colors.onSurface),
//                 decoration: InputDecoration(
//                   labelText: "Class Name",
//                   hintText: "Enter Class Name",
//                   labelStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
//                   hintStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: colors.outline),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: colors.outline),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: colors.primary, width: 2),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: colors.error),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     vertical: 10,
//                     horizontal: 12,
//                   ),
//                   filled: true,
//                   fillColor: colors.surface,
//                   suffixIcon: _checkingDuplicate
//                       ? const Padding(
//                     padding: EdgeInsets.all(12),
//                     child: SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   )
//                       : null,
//                 ),
//                 validator: (v) {
//                   if (v == null || v.trim().isEmpty) {
//                     return 'Class name cannot be empty';
//                   }
//                   if (_duplicateWarning != null) {
//                     return _duplicateWarning;
//                   }
//                   return null;
//                 },
//               ),
//               if (_duplicateWarning != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 6),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       _duplicateWarning!,
//                       style: TextStyle(color: colors.error, fontSize: 12),
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 20),
//               Wrap(
//                 spacing: 10,
//                 runSpacing: 10,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: (_busy || _checkingDuplicate || _duplicateWarning != null)
//                         ? null
//                         : () => _handleSubmit(context, value, colors),
//                     icon: _isSubmitting
//                         ? SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: colors.onPrimary,
//                       ),
//                     )
//                         : Icon(isEdit ? Icons.update : Icons.save),
//                     label: Text(isEdit ? 'Update Class' : 'Register Class'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: colors.primary,
//                       foregroundColor: colors.onPrimary,
//                       disabledBackgroundColor: colors.primary.withOpacity(0.5),
//                       disabledForegroundColor: colors.onPrimary.withOpacity(0.7),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 40,
//                         vertical: 15,
//                       ),
//                       textStyle: const TextStyle(fontSize: 18),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       elevation: 5,
//                     ),
//                   ),
//                   if (isEdit)
//                     OutlinedButton.icon(
//                       onPressed: _busy ? null : () => _confirmDelete(context, value),
//                       icon: _isDeleting
//                           ? SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: colors.error,
//                         ),
//                       )
//                           : Icon(Icons.delete_outline, color: colors.error),
//                       label: Text('Delete', style: TextStyle(color: colors.error)),
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(color: colors.error),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 40,
//                           vertical: 15,
//                         ),
//                         textStyle: const TextStyle(fontSize: 18),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   if (widget.embedded)
//                     OutlinedButton(
//                       onPressed: _busy ? null : () => Navigator.pop(context),
//                       child: const Text('Cancel'),
//                     )
//                   else
//                     ElevatedButton.icon(
//                       onPressed: _busy
//                           ? null
//                           : () => context.go(Routes.viewclass),
//                       icon: Icon(Icons.list, color: colors.onSecondary),
//                       label: Text('View Classes', style: TextStyle(color: colors.onSecondary)),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: colors.secondary,
//                         foregroundColor: colors.onSecondary,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 40,
//                           vertical: 15,
//                         ),
//                         textStyle: const TextStyle(fontSize: 18),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 5,
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//
//         // Embedded: just the form, wrapped in a Dialog by the caller.
//         if (widget.embedded) {
//           return Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: SingleChildScrollView(child: formBody),
//           );
//         }
//
//         // Full page: same container/appbar styling as Term's full-page layout.
//         return Scaffold(
//           backgroundColor: colors.surface,
//           appBar: AppBar(
//             backgroundColor: colors.primary,
//             foregroundColor: colors.onPrimary,
//             leading: IconButton(
//               icon: Icon(Icons.arrow_back, color: colors.onPrimary),
//               onPressed: () {
//                 if (context.canPop()) {
//                   context.pop();
//                 } else {
//                   context.go(Routes.dashboard);
//                 }
//               },
//             ),
//             title: Text(
//               isEdit ? 'Edit Class' : 'Register Class',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: colors.onPrimary,
//               ),
//             ),
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(
//               vertical: 40,
//               horizontal: 16,
//             ),
//             child: Align(
//               alignment: Alignment.topCenter,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: colors.surfaceContainerLow,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: colors.outlineVariant),
//                 ),
//                 margin: const EdgeInsets.all(30.0),
//                 constraints: const BoxConstraints(maxWidth: 800),
//                 child: Padding(
//                   padding: const EdgeInsets.all(30.0),
//                   child: formBody,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/classmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../widgets/dropdown.dart';
import '../widgets/dropdown1.dart';

class ClassScreen extends StatefulWidget {
  final ClassModel? classes;
  final bool embedded;
  final VoidCallback? onDeleted;
  const ClassScreen({super.key, this.classes, this.embedded = false, this.onDeleted});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final classController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selecteddepart;
  bool _isSubmitting = false;
  bool _isDeleting = false;


  String? _duplicateWarning;
  bool _checkingDuplicate = false;
  Timer? _debounce;

  bool get isEdit => widget.classes != null;
  bool get _busy => _isSubmitting || _isDeleting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<Myprovider>();
      provider.fetchdepart();
    });

    final data = widget.classes;
    if (data != null) {
      classController.text = data.name;
      selecteddepart = data.department;
    }

    classController.addListener(_scheduleDuplicateCheck);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    classController.removeListener(_scheduleDuplicateCheck);
    classController.dispose();
    super.dispose();
  }

  String _normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), '').toLowerCase();

  String? _facultyForSelectedDepartment(Myprovider provider) {
    if (selecteddepart == null) return null;
    for (final d in provider.departments) {
      if (d.name == selecteddepart) return d.faculty;
    }
    return null;
  }

  String? _departmentIdForSelectedDepartment(Myprovider provider) {
    if (selecteddepart == null) return null;
    for (final d in provider.departments) {
      if (d.name == selecteddepart) return d.id;
    }
    return null;
  }

  String? _facultyIdForFaculty(Myprovider provider, String faculty) {
    for (final f in provider.faculties) {
      if (f.name == faculty) return f.id;
    }
    return null;
  }

  String _computeId(String schoolId, String faculty, String department, String className) {
    final normFaculty = _normalize(faculty);
    final normDept = _normalize(department);
    final normName = _normalize(className);
    return "${schoolId}_${normFaculty}_${normDept}_$normName";
  }

  void _scheduleDuplicateCheck() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _checkDuplicate);
  }
  Future<void> _checkDuplicate() async {
    final name = classController.text.trim();
    if (name.isEmpty || selecteddepart == null) {
      if (_duplicateWarning != null || _checkingDuplicate) {
        if (mounted) {
          setState(() {
            _duplicateWarning = null;
            _checkingDuplicate = false;
          });
        }
      }
      return;
    }

    final provider = context.read<Myprovider>();
    final faculty = _facultyForSelectedDepartment(provider);
    if (faculty == null || faculty.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _duplicateWarning = 'Selected department has no faculty set.';
          _checkingDuplicate = false;
        });
      }
      return;
    }
    final targetId = _computeId(provider.schoolid, faculty, selecteddepart!, name);

    if (mounted) setState(() => _checkingDuplicate = true);

    try {
      final snap = await provider.db.collection('classes').doc(targetId).get();
      final isSelf = isEdit && widget.classes!.id == targetId;
      final clash = snap.exists && !isSelf;

      if (!mounted) return;
      setState(() {
        _duplicateWarning =
        clash ? 'A class with this name already exists in this department.' : null;
        _checkingDuplicate = false;
      });
    } catch (_) {
      if (mounted) setState(() => _checkingDuplicate = false);
    }
  }

  Future<void> _handleSubmit(
      BuildContext context,
      Myprovider value,
      ColorScheme colors,
      ) async {
    if (!_formKey.currentState!.validate() || _busy) return;
    if (selecteddepart == null) return; // dropdown has its own validatorMsg

    setState(() => _isSubmitting = true);
    try {
      final className = classController.text.trim();
      final faculty = _facultyForSelectedDepartment(value);
      if (faculty == null || faculty.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Selected department has no faculty set.'),
              backgroundColor: colors.error,
            ),
          );
        }
        return;
      }
      final targetId = _computeId(value.schoolid, faculty, selecteddepart!, className);


      final docId = isEdit ? widget.classes!.id : targetId;


      final existing = await value.db.collection('classes').doc(targetId).get();
      final hasClash = existing.exists && existing.id != docId;

      if (hasClash) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('A class with this name already exists in this department.'),
              backgroundColor: colors.error,
            ),
          );
        }
        return;
      }

      final model = ClassModel(
        id: docId,
        name: className,
        schoolId: value.schoolid,
        department: selecteddepart,
        departmentid: _departmentIdForSelectedDepartment(value),
        faculty: faculty,
        facultyid: _facultyIdForFaculty(value, faculty),
        timestamp: DateTime.now(),
        staff: value.name,
      );

      await value.db.collection('classes').doc(docId).set(model.toMap(), SetOptions(merge: true));

      // Update the cached list in place — no refetch needed.
      value.upsertClass(model);

      if (!context.mounted) return;

      if (isEdit || widget.embedded) {
        Navigator.pop(context, model);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Class registered successfully', textAlign: TextAlign.center),
          backgroundColor: Colors.green.shade600,
        ),
      );

      classController.clear();
      setState(() => selecteddepart = null);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save class: $e"),
            backgroundColor: colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Myprovider value) async {
    final cls = widget.classes;
    if (cls == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete class?'),
        content: Text(
          'Remove "${cls.name}" from the registered classes? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await value.db.collection('classes').doc(cls.id).delete();

      value.removeClass(cls.id);

      widget.onDeleted?.call();

      if (!context.mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete class: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider value, Widget? child) {
        final formBody = Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.embedded)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Class' : 'Register Class',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _busy ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              buildDropdown(
                value: selecteddepart,
                items: value.departments.map((e) => e.name).toList(),
                label: "Department",
                fillColor: colors.surface,
                onChanged: _busy
                    ? null
                    : (v) {
                  setState(() => selecteddepart = v);
                  _scheduleDuplicateCheck();
                },
                validatorMsg: 'Select department',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: classController,
                enabled: !_busy,
                style: TextStyle(fontSize: 14, color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: "Class Name",
                  hintText: "Enter Class Name",
                  labelStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                  hintStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: colors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors.error),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  filled: true,
                  fillColor: colors.surface,
                  suffixIcon: _checkingDuplicate
                      ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : null,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Class name cannot be empty';
                  }
                  if (_duplicateWarning != null) {
                    return _duplicateWarning;
                  }
                  return null;
                },
              ),
              if (_duplicateWarning != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _duplicateWarning!,
                      style: TextStyle(color: colors.error, fontSize: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: (_busy || _checkingDuplicate || _duplicateWarning != null)
                        ? null
                        : () => _handleSubmit(context, value, colors),
                    icon: _isSubmitting
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onPrimary,
                      ),
                    )
                        : Icon(isEdit ? Icons.update : Icons.save),
                    label: Text(isEdit ? 'Update Class' : 'Register Class'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      disabledBackgroundColor: colors.primary.withOpacity(0.5),
                      disabledForegroundColor: colors.onPrimary.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                  if (isEdit)
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _confirmDelete(context, value),
                      icon: _isDeleting
                          ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.error,
                        ),
                      )
                          : Icon(Icons.delete_outline, color: colors.error),
                      label: Text('Delete', style: TextStyle(color: colors.error)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.error),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  if (widget.embedded)
                    OutlinedButton(
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => context.go(Routes.viewclass),
                      icon: Icon(Icons.list, color: colors.onSecondary),
                      label: Text('View Classes', style: TextStyle(color: colors.onSecondary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.secondary,
                        foregroundColor: colors.onSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );

        // Embedded: just the form, wrapped in a Dialog by the caller.
        if (widget.embedded) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(child: formBody),
          );
        }

        // Full page: same container/appbar styling as Term's full-page layout.
        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.onPrimary),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.dashboard);
                }
              },
            ),
            title: Text(
              isEdit ? 'Edit Class' : 'Register Class',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onPrimary,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 16,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant),
                ),
                margin: const EdgeInsets.all(30.0),
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: formBody,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}