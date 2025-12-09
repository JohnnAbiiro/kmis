import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';

class Masspromotion extends StatefulWidget {
  const Masspromotion({super.key});

  @override
  State<Masspromotion> createState() => _MasspromotionState();
}

class _MasspromotionState extends State<Masspromotion> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final p = context.read<Myprovider>();
      await p.fetchPromotionSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Myprovider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mass Promotion Manager"),
        backgroundColor: const Color(0xFF2D2F45),
        foregroundColor: Colors.white,
      ),

      body: loading || provider.loadclassdata
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Mass Promotion ",
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                itemCount: provider.promotionList.length,
                separatorBuilder: (_, __) =>
                const Divider(color: Colors.grey),
                itemBuilder: (context, index) {
                  final rule = provider.promotionList[index];

                  final previous =
                      rule['previous']?.toString() ?? '';
                  final current = rule['current']?.toString() ?? '';
                  final next = rule['next']?.toString() ?? '';

                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${index + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // =========================
                          // PREVIOUS CLASS
                          // =========================
                          Text(
                            "Previous: $previous",
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            rule['previous_description'] ??
                                "Previous Class",
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Current: $current",
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            rule['current_description'] ??
                                "Current Class",
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13),
                          ),

                          const SizedBox(height: 10),

                          // =========================
                          // NEXT CLASS
                          // =========================
                          Text(
                            "Next: $next",
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                FontWeight.w600),
                          ),
                          Text(
                            rule['next_description'] ??
                                "Next Class",
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // MASS PROMOTION BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final provider = context.read<Myprovider>();
                  final db = provider.db;

                  setState(() => loading = true);
                  final settingsSnap = await db .collection("promotion_settings")
                      .where("schoolId", isEqualTo: provider.schoolid).limit(1).get();

                  if (settingsSnap.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No promotion rules found")),
                    );
                    setState(() => loading = false);
                    return;
                  }

                  final rules = settingsSnap.docs.first.data()["rules"] as List<dynamic>;
                  final studentsSnap = await db.collection("students")
                      .where("schoolId", isEqualTo: provider.schoolid)
                      .where("status", isEqualTo: "active").get();

               if (studentsSnap.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No students found")),
                    );
                    setState(() => loading = false);
                    return;
                  }
               WriteBatch batch = db.batch();
                for (var s in studentsSnap.docs) {
                final student = s.data();
               final String level = student["level"]?.toString()?.trim() ?? "";
               final String academic = student["academicyear"]?.toString() ?? "";
               final int cycle = int.tryParse(student["promotioncycle"]?.toString() ?? "0") ?? 0;

              if (academic == provider.year) continue;
              final rule = rules.firstWhere(
                    (r) => r["current"].toString().trim() == level,
                orElse: () => null,
              );

                    if (rule == null) continue;

                    final current = rule["current"].toString().trim();
                    final next = rule["next"].toString().trim();
                    final previous = rule["previous"].toString().trim();

                    if (next.toLowerCase() == "alma") {
                      batch.update(s.reference, {
                        "previousclass": previous,
                        "currentclass": "alma",
                        "level": "alma",
                        "nextclass": "almata",
                        "status": "completed",
                        "promotionstatus": "completed",
                        "academicyear": provider.year,
                        "promotioncycle": (cycle + 1).toString(),
                        "promotiondate": DateTime.now().toString(),
                      });
                    }

                    else {
                      batch.update(s.reference, {
                        "previousclass": current ?? current,
                        "currentclass": next,
                        "level": next,
                        "nextclass": "",
                        "promotionstatus": "promoted",
                        "academicyear": provider.year,
                        "promotioncycle": (cycle + 1).toString(),
                        "promotiondate": DateTime.now().toString(),
                      });
                    }
                  }

                  // ----------------------------
                  // 6. Save all at once
                  // ----------------------------
                  await batch.commit();

                  setState(() => loading = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mass promotion completed")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF00496d),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                ),
                child: const Text(
                  "Promote All (Mass)",
                  style:
                  TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final provider = context.read<Myprovider>();
                  final db = provider.db;

                  setState(() => loading = true);
                   final settingsSnap = await db
                      .collection("promotion_settings")
                      .where("schoolId", isEqualTo: provider.schoolid).limit(1).get();

                  if (settingsSnap.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No promotion rules found")),
                    );
                    setState(() => loading = false);
                    return;
                  }

                  final rules = settingsSnap.docs.first.data()["rules"] as List<dynamic>;
                  final studentsSnap = await db
                      .collection("students")
                      .where("schoolId", isEqualTo: provider.schoolid)
                      .where("status", isEqualTo: "active")
                      .where("academicyear", isEqualTo: provider.year).get();
                     if (studentsSnap.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No students to reverse")),
                    );
                    setState(() => loading = false);
                    return;
                  }
                  WriteBatch batch = db.batch();

                  for (var s in studentsSnap.docs) {
                    final student = s.data();
                    final String level = student["level"]?.toString()?.trim() ?? "";
                    final int cycle = int.tryParse(student["promotioncycle"]?.toString() ?? "0") ?? 0;
                   final rule = rules.firstWhere(
                          (r) => r["next"].toString().trim().toLowerCase() == level.toLowerCase(),
                      orElse: () => null,
                    );

                    if (rule == null) continue;

                    final current = rule["current"].toString().trim();
                    final next = rule["next"].toString().trim();
                    final previous = rule["previous"].toString().trim();

                    if (level.toLowerCase() == "alma") {
                      batch.update(s.reference, {
                        "previousclass": rule["current"],
                        "currentclass": rule["current"],
                        "level": rule["current"],
                        "nextclass": next,
                        "status": "active",
                        "promotionstatus": "",
                        "academicyear": provider.year,
                        "promotioncycle": cycle > 0 ? (cycle - 1).toString() : "0",
                      });
                    }
                    else {
                      batch.update(s.reference, {
                        "previousclass": previous,
                        "currentclass": current,
                        "level": current,
                        "nextclass": next,
                        "promotionstatus": "",
                        "academicyear": provider.year,
                        "promotioncycle": cycle > 0 ? (cycle - 1).toString() : "0",
                      });
                    }
                  }

                  await batch.commit();
                  setState(() => loading = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Promotion reversal completed")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF00496d),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                ),
                child: const Text("Undo Promotion", style: TextStyle(color: Colors.white), ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
