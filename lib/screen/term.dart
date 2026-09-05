import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/termmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class Term extends StatefulWidget {
  final TermModel? term;
  const Term({super.key, this.term});

  @override
  State<Term> createState() => _TermState();
}

class _TermState extends State<Term> {
  final termname = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final data = widget.term;
    if (data != null) {
      termname.text = data.name;
    }
  }

  @override
  void dispose() {
    termname.dispose();
    super.dispose();
  }

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEdit = widget.term != null;

    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider value, Widget? child) {
        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.onPrimary),
              onPressed: () => Navigator.pop(context),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: termname,
                          enabled: !_isSubmitting,
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
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : () async {
                                if (!_formKey.currentState!.validate()) return;

                                setState(() => _isSubmitting = true);

                                try {
                                  final term = termname.text.trim();
                                  final normalizedTerm = _normalize(term);

                                  final docId = isEdit
                                      ? widget.term!.id
                                      : "${value.schoolid}_$normalizedTerm";

                                  final clashQuery = await value.db
                                      .collection('terms')
                                      .where('schoolId', isEqualTo: value.schoolid)
                                      .where('name', isEqualTo: term)
                                      .get();

                                  final hasClash = isEdit
                                      ? clashQuery.docs.any((doc) => doc.id != docId)
                                      : clashQuery.docs.isNotEmpty;

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

                                  final data = updatedTerm.toMap();

                                  await value.db
                                      .collection('terms')
                                      .doc(docId)
                                      .set(data, SetOptions(merge: true));

                                  await value.db
                                      .collection('schools')
                                      .doc(value.schoolid)
                                      .update({
                                    "term": term,
                                    "updatedAt": DateTime.now(),
                                  });

                                  if (!context.mounted) return;

                                  if (isEdit) {
                                   Navigator.pop(context);
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
                              },
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
                            ElevatedButton.icon(
                              onPressed: _isSubmitting
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}