import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';
import '../controller/routes.dart';

class ViewAcademicyr extends StatefulWidget {
  const ViewAcademicyr({super.key});

  @override
  State<ViewAcademicyr> createState() => _ViewAcademicyrState();
}

class _ViewAcademicyrState extends State<ViewAcademicyr> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Myprovider>(context, listen: false).fetchacademicyear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider provider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'All Academic Years',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF2D2F45),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go(Routes.dashboard),
            ),
          ),
          //backgroundColor: const Color(0xFF1F1F2C),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700),
              child: Container(
                margin: EdgeInsets.all(20),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: provider.loadacademicyear
                      ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : provider.academicyears.isEmpty
                      ? const Center(
                    child: Text(
                      "No academic years found",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : ListView.separated(
                    itemCount: provider.academicyears.length,
                    separatorBuilder: (_, __) =>
                    const Divider(color: Colors.grey),
                    itemBuilder: (context, index) {
                      final year = provider.academicyears[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF2D2F45),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          year.name.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.amber),
                              onPressed: () {
                                context.go(Routes.academicyr, extra: year);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete ${year.name}',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: Text(
                                      "Are you sure you want to delete '${year.name}'?",
                                    ),
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
                                          style:
                                          TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await provider.deleteData(
                                    "academicyears",
                                    year.id,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Academic Year deleted successfully",
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
          ),
        );
      },
    );
  }
}
