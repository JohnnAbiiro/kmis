import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import '../controller/routes.dart';
import 'class.dart';

class Viewclass extends StatefulWidget {
  const Viewclass({super.key});

  @override
  State<Viewclass> createState() => _ViewclassState();
}

class _ViewclassState extends State<Viewclass> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => Provider.of<Myprovider>(context, listen: false).fetchclass(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider provider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('All Classes', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF2D2F45),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go(Routes.dashboard),
            ),
          ),

          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700),
              child: Container(
                color: Colors.white,
                margin: EdgeInsets.all(20),
                child: provider.loadclassdata
                    ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2D2F45)),
                )
                    : provider.classdata.isEmpty
                    ? const Center(
                  child: Text(
                    "No classes found",
                    style: TextStyle(color: Colors.black54),
                  ),
                )
                    : ListView.separated(
                  itemCount: provider.classdata.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    final classes = provider.classdata[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF00496d),
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        classes.name.toUpperCase(),
                        style: const TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.amber),
                            onPressed: () {
                              Navigator.push(context,MaterialPageRoute(builder: (context) => ClassScreen(classes: classes)));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete ${classes.name}',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: Text(
                                      "Are you sure you want to delete '${classes.name}'?"),
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
                                await provider.deleteClass(classes.id);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Class deleted successfully",
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
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}