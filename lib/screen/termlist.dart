import 'package:flutter/material.dart';
import 'package:ksoftsms/screen/term.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import '../controller/dbmodels/termmodel.dart';
import '../controller/routes.dart';

class Viewterms extends StatefulWidget {
  const Viewterms({super.key});

  @override
  State<Viewterms> createState() => _ViewtermsState();
}

class _ViewtermsState extends State<Viewterms> {
  final Set<String> _deletingIds = {};
  late List<TermModel> _terms;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<Myprovider>(context, listen: false);
      await provider.fetchterms();
      if (mounted) {
        setState(() {
          _terms = List<TermModel>.from(provider.terms);
          _initialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider provider, Widget? child) {
        final isLoading = !_initialized && provider.loadterms;

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            title: Text('All Terms', style: TextStyle(color: colors.onPrimary)),
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: 0,
            // leading: IconButton(
            //   icon: Icon(Icons.arrow_back, color: colors.onPrimary),
            //   onPressed: () =>Navigator.pop(context),
            // ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(color: colors.primary),
              )
                  : (!_initialized || _terms.isEmpty)
                  ? Center(
                child: Text(
                  "No terms found",
                  style: TextStyle(fontSize: 17, color: colors.onSurfaceVariant),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _terms.length,
                itemBuilder: (context, index) {
                  final term = _terms[index];
                  final isDeleting = _deletingIds.contains(term.id);

                  return Card(
                    elevation: 2,
                    color: colors.surfaceContainer,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colors.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: colors.primary,
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(color: colors.onPrimary, fontSize: 16),
                        ),
                      ),
                      title: Text(
                        term.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        "Term ID: ${term.id}",
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                      ),
                      trailing: isDeleting
                          ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.primary,
                        ),
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: colors.tertiary),
                            tooltip: "Edit ${term.name}",
                            onPressed: () async {

                              final result = await Navigator.push(context,MaterialPageRoute(builder: (context) => Term(term: term)));
                              if (result != null && mounted) {
                                setState(() {
                                  final idx = _terms.indexWhere((t) => t.id == result.id);
                                  if (idx != -1) {
                                    _terms[idx] = result;
                                  }
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: colors.error),
                            tooltip: 'Delete ${term.name}',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: colors.surfaceContainerHigh,
                                  title: Text(
                                    "Confirm Delete",
                                    style: TextStyle(color: colors.onSurface),
                                  ),
                                  content: Text(
                                    "Are you sure you want to delete '${term.name}'?",
                                    style: TextStyle(color: colors.onSurfaceVariant),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: colors.onSurfaceVariant),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: colors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;
                              if (!context.mounted) return;

                              setState(() => _deletingIds.add(term.id));
                              try {
                                await provider.deleteTerms(term.id);
                                if (mounted) {
                                  setState(() {
                                    _terms.removeWhere((t) => t.id == term.id);
                                  });
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        "Term deleted successfully",
                                        textAlign: TextAlign.center,
                                      ),
                                      backgroundColor: Colors.green.shade600,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Failed to delete term: $e"),
                                      backgroundColor: colors.error,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _deletingIds.remove(term.id));
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}