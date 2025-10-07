import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/statsprovider.dart';
import '../controller/routes.dart';

class CSAT extends StatelessWidget {
  final double cwidth;
  const CSAT({super.key, required this.cwidth});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (BuildContext context, value, Widget? child) {
        return FutureBuilder<QuerySnapshot>(
          future: (value.accesslevel == "Admin")
              ? FirebaseFirestore.instance
              .collection('regionLevelCounts')
              .where('region', isEqualTo: '')
              .get()
              : FirebaseFirestore.instance
              .collection('regionLevelCounts')
              .get(),
          builder: (context, snapshot) {
            final regions = snapshot.hasData ? snapshot.data!.docs : [];

            return SingleChildScrollView(
              child: Container(
                width: cwidth,
                height: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFFffffff),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(color: Colors.grey[800]!),
                    ),
                    children: [
                      TableRow(
                        children: [
                          TableHeader('Region'),
                          TableHeader('# Students'),
                          TableHeader('Action'),
                        ],
                      ),
                      if (!snapshot.hasData)
                        ...List.generate(5, (index) {
                          return TableRow(
                            children: [
                              StockCell(title: "...", subtitle: ""),
                              PriceCell("..."),
                              ChangeCell("...", true),
                            ],
                          );
                        })
                      else
                        ...regions.map((doc) {
                          final regionName = doc['region'] ?? 'Unknown';
                          final total = doc['total'] ?? 0;
                          return TableRow(
                            children: [
                              StockCell(title: regionName, subtitle: ''),
                              PriceCell(total.toString()),
                              InkWell(
                                child: ChangeCell("View", true),
                                onTap: () async {
                                  try {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    );

                                    try {
                                      // value.setSelectedRegion(doc['region']);
                                      //  value.studentdata();
                                    } catch (e) {
                                      print(e);
                                    }

                                    Navigator.pop(context);
                                    // Navigator.pushNamed(
                                    //     context, Routes.contestantlist);
                                  } catch (e) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: $e")),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget TableHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: const TextStyle(
        color: Color(0xFF00496d),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget StockCell({required String title, required String subtitle}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
      );

  Widget PriceCell(String price) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Text(
      price,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );

  Widget ChangeCell(String label, bool isPositive) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    ),
  );
}