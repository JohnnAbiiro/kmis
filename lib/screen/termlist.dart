import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import '../controller/routes.dart';

class Viewterms extends StatefulWidget {
  const Viewterms({super.key});

  @override
  State<Viewterms> createState() => _ViewtermsState();
}

class _ViewtermsState extends State<Viewterms> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => Provider.of<Myprovider>(context, listen: false).fetchterms(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider provider, Widget? child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),

          appBar: AppBar(
            title: const Text('All Terms', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF2D2F45),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go(Routes.dashboard),
            ),
          ),

          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: provider.loadterms
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2D2F45)),
              )
                  : provider.terms.isEmpty
                  ? const Center(
                child: Text(
                  "No terms found",
                  style: TextStyle(fontSize: 17, color: Colors.black54),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                itemCount: provider.terms.length,
                itemBuilder: (context, index) {
                  final term = provider.terms[index];

                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),

                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF2D2F45),
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),

                      title: Text(
                        term.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      subtitle: Text(
                        "Term ID: ${term.id}",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.amber),
                            tooltip: "Edit ${term.name}",
                            onPressed: () {
                              context.go(Routes.term, extra: term);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            tooltip: 'Delete ${term.name}',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: Text(
                                      "Are you sure you want to delete '${term.name}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(
                                            color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await provider.deleteData(
                                    "terms", term.id);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Term deleted successfully",
                                        textAlign: TextAlign.center),
                                    backgroundColor: Colors.red,
                                  ),
                                );
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
