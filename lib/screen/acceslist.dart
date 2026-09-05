import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/componentmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class AccessList extends StatefulWidget {
  const AccessList({super.key});

  @override
  State<AccessList> createState() => _AccessListState();
}

class _AccessListState extends State<AccessList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<Myprovider>(context, listen: false).fetchomponents());
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 900) return 3;
    if (width > 700) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Myprovider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Access Components",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2D2F45),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, Routes.accesscomponent),
        ),
      ),
      body: provider.isloadcomponents
          ? const Center(child: CircularProgressIndicator())
          : provider.accessComponents.isEmpty
          ? const Center(
        child: Text(
          "No access components found",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(screenWidth),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.2,
        ),
        itemCount: provider.accessComponents.length,
        itemBuilder: (context, index) {
          final ComponentModel data =
          provider.accessComponents[index];
          return Card(
            color: const Color(0xFFffffff),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                    Color(0xFF00496d),
                    child: Text(
                      data.name.isNotEmpty
                          ? data.name[0].toUpperCase()
                          : "?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mark: ${data.totalMark}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.amber, size: 20),
                        tooltip: "Edit",
                        onPressed: () {
                          Navigator.pushNamed(context, 
                            Routes.accesscomponent,
                            arguments: data,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.redAccent, size: 20),
                        tooltip: "Delete",
                        onPressed: () async {
                          final confirm =
                          await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor:
                              const Color(0xFF2D2F45),
                              title: const Text(
                                "Confirm Delete",
                                style: TextStyle(
                                    color: Colors.white),
                              ),
                              content: Text(
                                "Are you sure you want to delete '${data.name}'?",
                                style: const TextStyle(
                                    color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Colors.white70),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.redAccent,
                                  ),
                                  child: const Text("Delete",
                                      style: TextStyle(
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await provider.deleteData(
                              'assesscomponent',
                              data.id,
                            );

                            if (context.mounted) {
                              setState(() {});
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Deleted successfully"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
