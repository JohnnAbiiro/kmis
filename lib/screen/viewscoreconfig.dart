import 'package:flutter/material.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:provider/provider.dart';
import '../controller/routes.dart';

class ScoreConfigViewPage extends StatefulWidget {
  const ScoreConfigViewPage({super.key});

  @override
  State<ScoreConfigViewPage> createState() => _ScoreConfigViewPageState();
}

class _ScoreConfigViewPageState extends State<ScoreConfigViewPage> {
  @override
  void initState() {
    super.initState();
    // fetch config when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchScoreConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Score Configuration"),
            backgroundColor: const Color(0xFF2D2F45),
          ),
          body: provider.loadingsconfig
              ? const Center(child: CircularProgressIndicator())
              : provider.scoreconfig.isEmpty
              ? const Center(child: Text("No configuration available"))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.scoreconfig.length,
            itemBuilder: (context, index) {
              final config = provider.scoreconfig[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    "Continuous Assessment: ${config.continuous}%",
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    "Exam: ${config.exam}%",
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blueAccent),
                        tooltip: 'Edit configuration',
                        onPressed: () {
                          Navigator.pushNamed(context, 
                            Routes.scoreconfig,
                            arguments: config,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        tooltip: 'Delete configuration',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor:
                              const Color(0xFF2D2F45),
                              title: const Text(
                                'Confirm Deletion',
                                style:
                                TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this score configuration?',
                                style: TextStyle(
                                    color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors.grey),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(false),
                                ),
                                TextButton(
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.red),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(true),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && config.id != null) {
                            await provider.deleteData(
                              'scoringconfi',
                              config.id!,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Configuration deleted successfully"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
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
        );
      },
    );
  }
}
