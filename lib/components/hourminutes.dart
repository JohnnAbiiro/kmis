import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';

class HourMinutes extends StatelessWidget {
  final double cwidth;
  final String topcollector;

  const HourMinutes(
      {super.key, required this.cwidth, required this.topcollector});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final male = 60;
    final female = 40;
    return Consumer<Myprovider>(
      builder: (context, value, child) {
        return Container(
          width: cwidth,
          height: 250,
          decoration: BoxDecoration(
            color: colors.surface,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Student Information', style: TextStyle(fontSize: 18, color: colors.primary)),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border.all(
                            color: Colors.black12
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(6))
                        ),
                        child: Center(
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('students').snapshots(),
                              builder: (context, snapshot){
                                if (!snapshot.hasData) {
                                  return Shimmer.fromColors(
                                    baseColor: const Color(0xFF00b377).withOpacity(0.2),
                                    highlightColor: const Color(0xFF00d7c4).withOpacity(0.4),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Title shimmer
                                        Container(
                                          height: 12,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Shimmer pie circle
                                        Container(
                                          height: 50,
                                          width: 50,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Male & Female legend shimmer
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 12,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Container(
                                              height: 12,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                final count = snapshot.data!.docs.length;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_alt, color: colors.primary, size: 40),
                                    Text("Total Students", style: TextStyle(fontSize: 12, color: colors.onSurface),),
                                    Text(count.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 30, color: colors.onSurface))
                                  ],
                                );
                              }
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.all(Radius.circular(6))
                        ),
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance.collection('students').snapshots(),
                            builder: (context, snapshot){
                              if (!snapshot.hasData) {
                                return Shimmer.fromColors(
                                  baseColor: colors.primary.withOpacity(0.2),
                                  highlightColor: colors.primaryContainer.withOpacity(0.4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Title shimmer
                                      Container(
                                        height: 12,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: colors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Shimmer pie circle
                                      Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: colors.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Male & Female legend shimmer
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 12,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: colors.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Container(
                                            height: 12,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final docs = snapshot.data!.docs;
                              int male = docs.where((doc) => (doc['sex']?.toString().toLowerCase() == 'male')).length;
                              int female = docs.where((doc) => (doc['sex']?.toString().toLowerCase() == 'female')).length;

                              if (male == 0 && female == 0) {
                                return const Center(child: Text('No data'));
                              }

                              int maleCount = 0;
                              int femaleCount = 0;

                              for (var doc in snapshot.data!.docs) {
                                String sex = doc['sex'].toString().toLowerCase();

                                if (sex == 'male') {
                                  maleCount++;
                                } else if (sex == 'female') {
                                  femaleCount++;
                                }
                              }

                              int total = maleCount + femaleCount;

                              double malePercentage = total > 0 ? (maleCount / total) * 100 : 0;
                              double femalePercentage = total > 0 ? (femaleCount / total) * 100 : 0;

                              //print(maleCount);
                              //print(malePercentage.toStringAsFixed(1) + "%");
                              //print(femalePercentage.toStringAsFixed(1) + "%");

                              return Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Male vs Female",
                                      style: TextStyle(fontSize: 13, color: colors.onSurface),
                                    ),
                                    //const SizedBox(height: 10),
                                    SizedBox(
                                      height: 60,
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 1,
                                          centerSpaceRadius: 0,
                                          sections: [
                                            PieChartSectionData(
                                              value: male.toDouble(),
                                              color: colors.primary,
                                              title: "${malePercentage.toStringAsFixed(1)}%",
                                              radius: 30,
                                              titleStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.onPrimary),
                                            ),
                                            PieChartSectionData(
                                              value: female.toDouble(),
                                              color: colors.primaryContainer,
                                              title: "${femalePercentage.toStringAsFixed(1)}%",
                                              radius: 28,
                                              titleStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.onPrimaryContainer),
                                            ),
                                          ],
                                        ),
                                        swapAnimationDuration: const Duration(milliseconds: 1200),
                                        swapAnimationCurve: Curves.easeOutCubic,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Male",
                                              style: TextStyle(fontSize: 12, color: colors.onSurface),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Female",
                                              style: TextStyle(fontSize: 12, color: colors.onSurface),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }
                        )
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}