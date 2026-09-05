import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/idformatmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class IdformatScreen extends StatefulWidget {
  final IdformatModel? idformatModel;
  const IdformatScreen({super.key, this.idformatModel});

  @override
  State<IdformatScreen> createState() => _IdformatScreenState();
}

class _IdformatScreenState extends State<IdformatScreen> {
  final idformatController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final data = widget.idformatModel;
    if (data != null) {
      idformatController.text = data.name;
    }
  }

  @override
  void dispose() {
    idformatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEdit = widget.idformatModel != null;

    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider provider, Widget? child) {
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                  final idformatName =
                                  idformatController.text.trim().toUpperCase();

                                  final formattedId = idformatName.replaceAll(RegExp(r'\s+'), '');
                                  final docId = isEdit
                                      ? widget.idformatModel!.id
                                      : "${provider.schoolid}_$formattedId";

                                  final clashQuery = await provider.db
                                      .collection('idformats')
                                      .where('schoolId', isEqualTo: provider.schoolid)
                                      .where('name', isEqualTo: idformatName)
                                      .get();

                                  final hasClash = clashQuery.docs.any((doc) {
                                    if (isEdit && doc.id == docId) return false;
                                    return true;
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

                                  if (!context.mounted) return;

                                  if (isEdit) {
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
                            ElevatedButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.pushNamed(context, Routes.viewidformats),
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