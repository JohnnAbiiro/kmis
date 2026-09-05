import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/facultymodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class FacultyPage extends StatefulWidget {
  final FacultyModel? faculty;
  final bool embedded;
  /// Called after a successful delete, before the dialog is popped —
  /// lets the caller (e.g. a setup wizard) clear its own cached state.
  final VoidCallback? onDeleted;
  const FacultyPage({
    super.key,
    this.faculty,
    this.embedded = false,
    this.onDeleted,
  });

  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  final facultyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _isDeleting = false;

  String? _duplicateWarning;

  bool get isEdit => widget.faculty != null;
  bool get _busy => _saving || _isDeleting;

  @override
  void initState() {
    super.initState();
    final data = widget.faculty;
    if (data != null) {
      facultyController.text = data.name;
    }
    facultyController.addListener(_checkDuplicateAsTyped);
  }

  @override
  void dispose() {
    facultyController.removeListener(_checkDuplicateAsTyped);
    facultyController.dispose();
    super.dispose();
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

  void _checkDuplicateAsTyped() {
    final raw = facultyController.text;
    if (raw.trim().isEmpty) {
      if (_duplicateWarning != null) setState(() => _duplicateWarning = null);
      return;
    }

    final typedNormalized = _normalize(raw);
    final provider = Provider.of<Myprovider>(context, listen: false);

    final clash = provider.faculties.any((f) {
      if (isEdit && f.id == widget.faculty!.id) return false; // ignore self
      return _normalize(f.name) == typedNormalized;
    });

    final warning = clash ? 'A faculty with this name already exists.' : null;
    if (warning != _duplicateWarning) {
      setState(() => _duplicateWarning = warning);
    }
  }

  Future<void> _save(Myprovider value) async {
    if (!_formKey.currentState!.validate() || _busy) return;

    setState(() => _saving = true);
    try {
      final facultyName = facultyController.text.trim();
      final docId = isEdit
          ? widget.faculty!.id
          : value.db.collection('faculties').doc().id;

      final normalizedName = _normalize(facultyName);
      final hasClash = value.faculties.any((f) {
        if (f.id == docId) return false; // this entry itself, not a clash
        return _normalize(f.name) == normalizedName;
      });

      if (hasClash) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('A faculty named "$facultyName" already exists'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final data = FacultyModel(
        id: docId,
        name: facultyName,
        schoolId: value.schoolid,
        timestamp: DateTime.now(),
        staff: value.name,
      ).toMap();

      await value.db
          .collection('faculties')
          .doc(docId)
          .set(data, SetOptions(merge: true));

      final savedFaculty = FacultyModel.fromMap(data, docId);
      value.upsertFaculty(savedFaculty);

      if (!mounted) return;

      if (isEdit || widget.embedded) {
        Navigator.pop(context, savedFaculty);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Faculty registered successfully'),
          backgroundColor: Colors.green,
        ),
      );

      facultyController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save faculty: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete(Myprovider value) async {
    final faculty = widget.faculty;
    if (faculty == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete faculty?'),
        content: Text(
          'Remove "${faculty.name}" from the registered faculties? This cannot be undone.',
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
      await value.deleteFaculties(faculty.id);
      widget.onDeleted?.call();
      if (!mounted) return;
      Navigator.pop(context); // signal "deleted" — no FacultyModel returned
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not delete faculty: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      isEdit ? 'Edit Faculty' : 'Register Faculty',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _busy ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: facultyController,
                enabled: !_busy,
                decoration: InputDecoration(
                  labelText: "Faculty Name",
                  hintText: "Enter Faculty Name",
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00496d)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[700]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  filled: false,
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Faculty name cannot be empty';
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
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: (_busy || _duplicateWarning != null)
                        ? null
                        : () => _save(value),
                    icon: _saving
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Icon(isEdit ? Icons.update : Icons.save),
                    label: Text(
                      _saving
                          ? 'Saving...'
                          : isEdit
                          ? 'Update Faculty'
                          : 'Register Faculty',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00496d),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                  if (isEdit)
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _confirmDelete(value),
                      icon: _isDeleting
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                          : const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
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
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00496d)),
                        foregroundColor: Colors.black54,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      icon: const Icon(Icons.list),
                      label: const Text("View Faculty"),
                      onPressed: _busy ? null : () => context.go(Routes.viewfaculty),
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

        // Full page: original route-based layout.
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2D2F45),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go(Routes.dashboard),
            ),
            title: Text(
              isEdit ? 'Edit Faculty' : 'Register Faculty',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: const Color(0xFFffffff),
                margin: const EdgeInsets.all(30.0),
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
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