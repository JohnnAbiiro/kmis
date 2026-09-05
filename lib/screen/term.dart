import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/termmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class Term extends StatefulWidget {
  final TermModel? term;
  final bool embedded;
  /// Called after a successful delete, before the dialog is popped —
  /// lets the caller (e.g. a setup wizard) clear its own cached state.
  final VoidCallback? onDeleted;
  const Term({super.key, this.term, this.embedded = false, this.onDeleted});

  @override
  State<Term> createState() => _TermState();
}

class _TermState extends State<Term> {
  final termname = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isDeleting = false;

  String? _duplicateWarning;

  bool get isEdit => widget.term != null;
  bool get _busy => _isSubmitting || _isDeleting;

  @override
  void initState() {
    super.initState();
    final data = widget.term;
    if (data != null) {
      termname.text = data.name;
    }
    termname.addListener(_checkDuplicateAsTyped);
  }

  @override
  void dispose() {
    termname.removeListener(_checkDuplicateAsTyped);
    termname.dispose();
    super.dispose();
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

  void _checkDuplicateAsTyped() {
    final raw = termname.text;
    if (raw.trim().isEmpty) {
      if (_duplicateWarning != null) setState(() => _duplicateWarning = null);
      return;
    }

    final typedNormalized = _normalize(raw);
    final provider = Provider.of<Myprovider>(context, listen: false);

    final clash = provider.terms.any((t) {
      if (isEdit && t.id == widget.term!.id) return false; // ignore self
      return _normalize(t.name) == typedNormalized;
    });

    final warning = clash ? 'This term already exists for this school.' : null;
    if (warning != _duplicateWarning) {
      setState(() => _duplicateWarning = warning);
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
                      isEdit ? 'Edit Term' : 'Register Term',
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
                controller: termname,
                enabled: !_busy,
                style: TextStyle(fontSize: 14, color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: "Term Name",
                  hintText: "Enter Term Name",
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
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Term name cannot be empty';
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
                    onPressed: (_busy || _duplicateWarning != null)
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
                    label: Text(isEdit ? 'Update Term' : 'Register Term'),
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
                          : () => context.go(Routes.viewterm),
                      icon: Icon(Icons.list, color: colors.onSecondary),
                      label: Text('View Terms', style: TextStyle(color: colors.onSecondary)),
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
              isEdit ? 'Edit Term' : 'Register Term',
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
                constraints: const BoxConstraints(maxWidth: 600),
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

  Future<void> _handleSubmit(
      BuildContext context,
      Myprovider value,
      ColorScheme colors,
      ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final term = termname.text.trim();
      final normalizedTerm = _normalize(term);
      final docId = isEdit ? widget.term!.id : "${value.schoolid}_$normalizedTerm";

      final hasClash = value.terms.any((t) {
        if (t.id == docId) return false; // this entry itself, not a clash
        return _normalize(t.name) == normalizedTerm;
      });

      if (hasClash) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'This term already exists for this school.',
              ),
              backgroundColor: colors.error,
            ),
          );
        }
        return;
      }

      final updatedTerm = TermModel(
        id: docId,
        name: term,
        schoolId: value.schoolid,
        timestamp: DateTime.now(),
      );

      await value.db
          .collection('terms')
          .doc(docId)
          .set(updatedTerm.toMap(), SetOptions(merge: true));

      await value.db.collection('schools').doc(value.schoolid).update({
        "term": term,
        "updatedAt": DateTime.now(),
      });

      value.upsertTerm(updatedTerm);

      if (!context.mounted) return;

      if (isEdit || widget.embedded) {
        Navigator.pop(context, updatedTerm);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Term registered successfully',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );

      termname.clear();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save term: $e"),
            backgroundColor: colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Myprovider value) async {
    final term = widget.term;
    if (term == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete term?'),
        content: Text('Remove "${term.name}" from the registered terms? This cannot be undone.'),
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
      await value.db.collection('terms').doc(term.id).delete();

      // Keep the cached list in sync without a refetch.
      value.removeTerm(term.id);

      widget.onDeleted?.call();

      if (!context.mounted) return;

      // Signal "deleted" to the caller by popping with no term,
      // after onDeleted has already let it update its own state.
      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete term: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}