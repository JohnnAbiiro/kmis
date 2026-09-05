import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../components/academicyrmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import 'academicyr.dart';

class ViewAcademicyr extends StatefulWidget {
  const ViewAcademicyr({super.key});

  @override
  State<ViewAcademicyr> createState() => _ViewAcademicyrState();
}

class _ViewAcademicyrState extends State<ViewAcademicyr> {
  final Set<String> _deletingIds = {};
  late List<AcademicModel> _years;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<Myprovider>(context, listen: false);
      await provider.fetchacademicyear();
      if (mounted) {
        setState(() {
          _years = List<AcademicModel>.from(provider.academicyears);
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
        final isLoading = !_initialized && provider.loadacademicyear;

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            title: Text('All Academic Years', style: TextStyle(color: colors.onPrimary)),
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.onPrimary),
              onPressed: () => context.go(Routes.dashboard),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(color: colors.primary),
              )
                  : (!_initialized || _years.isEmpty)
                  ? Center(
                child: Text(
                  "No academic years found",
                  style: TextStyle(fontSize: 17, color: colors.onSurfaceVariant),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _years.length,
                itemBuilder: (context, index) {
                  final year = _years[index];
                  final isDeleting = _deletingIds.contains(year.id);

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
                        year.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
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
                            tooltip: "Edit ${year.name}",
                            onPressed: () async {

                              final result =await Navigator.push(context,MaterialPageRoute(
                                  builder: (_)=>AcademicYr(year: year,))
                              );
                              if (result != null && mounted) {
                                setState(() {
                                  final idx = _years.indexWhere((y) => y.id == result.id);
                                  if (idx != -1) {
                                    _years[idx] = result;
                                  }
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: colors.error),
                            tooltip: 'Delete ${year.name}',
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
                                    "Are you sure you want to delete '${year.name}'?",
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

                              setState(() => _deletingIds.add(year.id));
                              try {
                                await provider.deleteAcademicyr( year.id);
                                if (mounted) {
                                  setState(() {
                                    _years.removeWhere((y) => y.id == year.id);
                                  });
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        "Academic Year deleted successfully",
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
                                      content: Text("Failed to delete academic year: $e"),
                                      backgroundColor: colors.error,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _deletingIds.remove(year.id));
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