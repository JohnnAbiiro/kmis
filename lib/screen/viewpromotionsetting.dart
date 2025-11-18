import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';
import '../controller/routes.dart';

class ViewPromotionSettings extends StatefulWidget {
  const ViewPromotionSettings({super.key});

  @override
  State<ViewPromotionSettings> createState() => _ViewPromotionSettingsState();
}

class _ViewPromotionSettingsState extends State<ViewPromotionSettings> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<Myprovider>(context, listen: false)
          .fetchPromotionSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (BuildContext context, provider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Promotion Settings',
                style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF2D2F45),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go(Routes.dashboard),
            ),
          ),

          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.all(20),
                child: provider.loadingPromotion
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : provider.promotionList.isEmpty
                    ? const Center(
                  child: Text(
                    "No promotion settings found",
                    style:
                    TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                )
                    : ListView.separated(
                  itemCount: provider.promotionList.length,
                  separatorBuilder: (_, __) =>
                  const Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    final rule = provider.promotionList[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF00496d),
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        "${rule['current']} → ${rule['next']}",
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 16),
                      ),
                      // subtitle: Text(
                      //   "School Id: ${rule['schoolId'] ?? ''}",
                      //   style: const TextStyle(
                      //       color: Colors.black54, fontSize: 13),
                      // ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ///
                          /// EDIT BUTTON
                          ///
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: "Edit",
                            onPressed: () {
                              provider.setEditPromotionData(rule);
                              context.go(Routes.promotionsetting);
                            },
                          ),

                          ///
                          /// DELETE BUTTON
                          ///
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete setting',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: Text(
                                      "Remove promotion rule '${rule['current']} → ${rule['next']}'?"),
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
                                await provider.deleteData(
                                    "promotion_settings", rule['id']);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Promotion rule deleted",
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
