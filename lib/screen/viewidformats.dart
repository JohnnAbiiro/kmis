import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import '../controller/routes.dart';

class ViewIdFormats extends StatefulWidget {
  const ViewIdFormats({super.key});

  @override
  State<ViewIdFormats> createState() => _ViewIdFormatsState();
}

class _ViewIdFormatsState extends State<ViewIdFormats> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<Myprovider>(context, listen: false).fetchIdFormats()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider provider, Widget? child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            title: const Text('ID Formats', style: TextStyle(color: Colors.white)),
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
              child: provider.loadIdFormats
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2D2F45)),
              )
                  : provider.idFormats.isEmpty
                  ? const Center(
                child: Text(
                  "No ID formats found",
                  style: TextStyle(fontSize: 17, color: Colors.black54),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: provider.idFormats.length,
                itemBuilder: (context, index) {
                  final idFormat = provider.idFormats[index];

                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF2D2F45),
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      title: Text(
                        idFormat.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ID Format: ${idFormat.id}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          Text(
                            "Last Number: ${idFormat.name}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          Text(
                            "School ID: ${idFormat.schoolId}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          Text(
                            "Staff: ${idFormat.staff}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.amber),
                            tooltip: "Edit ${idFormat.name}",
                            onPressed: () {
                              context.go(Routes.idformat, extra: idFormat);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete ${idFormat.name}',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: Text(
                                    "Are you sure you want to delete '${idFormat.name}'?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await provider.deleteData("idformats", idFormat.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "ID Format deleted successfully",
                                      textAlign: TextAlign.center,
                                    ),
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
