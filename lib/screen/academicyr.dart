import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../components/academicyrmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class AcademicYr extends StatefulWidget {
  final AcademicModel? year;
  final bool embedded;
  const AcademicYr({super.key, this.year, this.embedded = false});

  @override
  State<AcademicYr> createState() => _AcademicYrState();
}

class _AcademicYrState extends State<AcademicYr> {
  final yearName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _duplicateWarning;

  bool get isEdit => widget.year != null;

  @override
  void initState() {
    super.initState();
    final data = widget.year;
    if (data != null) yearName.text = data.name;
    yearName.addListener(_checkDuplicateAsTyped);
  }

  @override
  void dispose() {
    yearName.removeListener(_checkDuplicateAsTyped);
    yearName.dispose();
    super.dispose();
  }

  String _normalize(String value) =>
      value.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toLowerCase();

  void _checkDuplicateAsTyped() {
    final raw = yearName.text;
    if (raw.trim().isEmpty) {
      if (_duplicateWarning != null) setState(() => _duplicateWarning = null);
      return;
    }
    final typedNormalized = _normalize(raw);
    final provider = Provider.of<Myprovider>(context, listen: false);
    final clash = provider.academicyears.any((y) {
      if (isEdit && y.id == widget.year!.id) return false;
      return _normalize(y.name) == typedNormalized;
    });
    final warning =
    clash ? 'This academic year already exists for this school.' : null;
    if (warning != _duplicateWarning) setState(() => _duplicateWarning = warning);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Consumer<Myprovider>(
      builder: (context, value, child) {
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
                      isEdit ? 'Edit Academic Year' : 'Register Academic Year',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: yearName,
                enabled: !_isSubmitting,
                style: TextStyle(fontSize: 14, color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: "Academic Year",
                  hintText: "Enter Academic Year (e.g. 2024/2025)",
                  labelStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                  hintStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                  border: OutlineInputBorder(borderSide: BorderSide(color: colors.outline)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colors.outline)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide(color: colors.error)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  filled: true,
                  fillColor: colors.surface,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Academic Year cannot be empty';
                  if (_duplicateWarning != null) return _duplicateWarning;
                  return null;
                },
              ),
              if (_duplicateWarning != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_duplicateWarning!, style: TextStyle(color: colors.error, fontSize: 12)),
                  ),
                ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: (_isSubmitting || _duplicateWarning != null)
                        ? null
                        : () => _handleSubmit(context, value, colors),
                    icon: _isSubmitting
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                    )
                        : Icon(isEdit ? Icons.update : Icons.save),
                    label: Text(isEdit ? 'Update Year' : 'Register Year'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      disabledBackgroundColor: colors.primary.withOpacity(0.5),
                      disabledForegroundColor: colors.onPrimary.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                    ),
                  ),
                  if (widget.embedded)
                    OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pushNamed(context, Routes.viewacademicyr),
                      icon: Icon(Icons.list, color: colors.onSecondary),
                      label: Text('View Academic yr', style: TextStyle(color: colors.onSecondary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.secondary,
                        foregroundColor: colors.onSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
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
          backgroundColor: colors.surface,
          appBar: AppBar(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.onPrimary),
              onPressed: () => context.go(Routes.dashboard),
            ),
            title: Text(
              isEdit ? 'Edit Academic Year' : 'Register Academic Year',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onPrimary),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant),
                ),
                margin: const EdgeInsets.all(30.0),
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(padding: const EdgeInsets.all(30.0), child: formBody),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit(BuildContext context, Myprovider value, ColorScheme colors) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final year = yearName.text.trim();
      final yea = year.replaceAll('/', '');
      final normalizedYear = _normalize(year);
      final docId = isEdit ? widget.year!.id : "${value.schoolid}_$normalizedYear";

      final hasClash = value.academicyears.any((y) {
        if (y.id == docId) return false;
        return _normalize(y.name) == normalizedYear;
      });

      if (hasClash) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('This academic year already exists for this school.'),
              backgroundColor: colors.error,
            ),
          );
        }
        return;
      }

      final updatedYear = AcademicModel(
        id: docId,
        idd: yea,
        name: year,
        staff: value.name,
        schoolid: value.schoolid,
        timestamp: DateTime.now(),
      );

      final data = updatedYear.toMap();
      data['name'] = normalizedYear;

      await value.db.collection('academicyears').doc(docId).set(data, SetOptions(merge: true));
      await value.db.collection('schools').doc(value.schoolid).update({
        "academicyr": year,
        "academicyrid": yea,
        "updatedAt": DateTime.now(),
      });

      value.upsertAcademicYear(updatedYear);
      if (!context.mounted) return;

      if (isEdit || widget.embedded) {
        // Both edit and embedded-add close the dialog and hand the result back.
        Navigator.pop(context, updatedYear);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Academic Year registered successfully', textAlign: TextAlign.center),
          backgroundColor: Colors.green.shade600,
        ),
      );
      yearName.clear();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save academic year: $e"), backgroundColor: colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}