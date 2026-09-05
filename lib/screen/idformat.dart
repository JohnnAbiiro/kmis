import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/idformatmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class IdformatScreen extends StatefulWidget {
  final IdformatModel? idformatModel;
  final bool embedded;
  const IdformatScreen({super.key, this.idformatModel, this.embedded = false});

  @override
  State<IdformatScreen> createState() => _IdformatScreenState();
}

class _IdformatScreenState extends State<IdformatScreen> {
  final idformatController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  String? _duplicateWarning;

  bool get isEdit => widget.idformatModel != null;

  @override
  void initState() {
    super.initState();
    final data = widget.idformatModel;
    if (data != null) {
      idformatController.text = data.name;
    }
    idformatController.addListener(_checkDuplicateAsTyped);
  }

  @override
  void dispose() {
    idformatController.removeListener(_checkDuplicateAsTyped);
    idformatController.dispose();
    super.dispose();
  }

  String _normalizedName(String raw) {
    return raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  String _normalizedIdFor(String rawName, String schoolId) {
    return "${schoolId}_${_normalizedName(rawName)}";
  }

  void _checkDuplicateAsTyped() {
    final raw = idformatController.text;
    if (raw.trim().isEmpty) {
      if (_duplicateWarning != null) setState(() => _duplicateWarning = null);
      return;
    }

    final typedName = _normalizedName(raw);

    final clash = _currentProvider().idFormats.any((f) {
      if (isEdit && f.id == widget.idformatModel!.id) return false; // ignore self
      return _normalizedName(f.name) == typedName;
    });

    final warning = clash ? 'This ID format already exists for this school.' : null;
    if (warning != _duplicateWarning) {
      setState(() => _duplicateWarning = warning);
    }
  }

  Myprovider _currentProvider() => Provider.of<Myprovider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider provider, Widget? child) {
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
                      isEdit ? 'Edit ID Format' : 'Register ID Format',
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
                controller: idformatController,
                enabled: !_isSubmitting,
                style: TextStyle(fontSize: 16, color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: "ID Format Name",
                  hintText: "Enter ID Format",
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ID format cannot be empty';
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
                    onPressed: (_isSubmitting || _duplicateWarning != null)
                        ? null
                        : () => _handleSubmit(context, provider, colors),
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
                    label: Text(isEdit ? 'Update ID Format' : 'Register ID Format'),
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
                  if (widget.embedded)
                    OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => context.go(Routes.viewidformats),
                      icon: Icon(Icons.list, color: colors.onSecondary),
                      label: Text('View ID Formats', style: TextStyle(color: colors.onSecondary)),
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
              isEdit ? 'Edit ID Format' : 'Register ID Format',
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

  Future<void> _handleSubmit(
      BuildContext context,
      Myprovider provider,
      ColorScheme colors,
      ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final idformatName = idformatController.text.trim().toUpperCase();
      final nameMappedId = _normalizedIdFor(idformatName, provider.schoolid);
      final docId = isEdit ? widget.idformatModel!.id : nameMappedId;
      final typedNormalizedName = _normalizedName(idformatName);
      final hasClash = provider.idFormats.any((f) {
        if (f.id == docId) return false; // this entry itself, not a clash
        return _normalizedName(f.name) == typedNormalizedName;
      });

      if (hasClash) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'This ID format already exists for this school.',
              ),
              backgroundColor: colors.error,
            ),
          );
        }
        return;
      }

      final updatedIdformat = IdformatModel(
        id: docId,
        name: idformatName,
        schoolId: provider.schoolid,
        timestamp: DateTime.now(),
        staff: provider.name,
      );

      await provider.db
          .collection('idformats')
          .doc(docId)
          .set(updatedIdformat.toMap(), SetOptions(merge: true));

      // Update the cached list in place — no refetch needed.
      provider.upsertIdFormat(updatedIdformat);

      if (!context.mounted) return;

      if (isEdit || widget.embedded) {
        Navigator.pop(context, updatedIdformat);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'ID Format registered successfully',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );

      idformatController.clear();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save ID format: $e"),
            backgroundColor: colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}