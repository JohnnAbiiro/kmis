import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';

class DuplicateContainer extends StatefulWidget {
  final String heading;
  final String number;
  final String value;
  final double containerWidth;

  const DuplicateContainer({
    super.key,
    required this.heading,
    required this.number,
    required this.value,
    required this.containerWidth,
  });

  @override
  State<DuplicateContainer> createState() => _DuplicateContainerState();
}

class _DuplicateContainerState extends State<DuplicateContainer> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    int touchedIndex = -1;

    List<PieChartSectionData> showingSections() {
      final data = [
        {'value': 70.0, 'color': const Color(0xFF7A6FF0)},
        {'value': 30.0, 'color': const Color(0xFFFFA726)},
        //{'value': 5.0, 'color': const Color(0xFFE53935)},
      ];

      return List.generate(data.length, (i) {
        final isTouched = i == touchedIndex;
        final double radius = isTouched ? 40 : 30;
        return PieChartSectionData(
          color: data[i]['color'] as Color,
          value: data[i]['value'] as double,
          title: '',
          radius: radius,
        );
      });
    }
    return Container(
      width: widget.containerWidth,
      height: 250,
      decoration: BoxDecoration(
        color: colors.surface,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Staff & Teacher Information', style: TextStyle(fontSize: 18, color: colors.primary)),
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
                          stream: FirebaseFirestore.instance.collection('staff').snapshots(),
                          builder: (context, snapshot){

                            //final docs = snapshot.data!.docs;
                            //int teaching = docs.where((doc) => (doc['accessLevel']?.toString().toLowerCase() == 'teacher')).length;
                            if (!snapshot.hasData) {
                              return Shimmer.fromColors(
                                baseColor: const Color(0xFF7A6FF0).withOpacity(0.2),
                                highlightColor: const Color(0xFFada1ff).withOpacity(0.4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 12,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

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
                                Icon(Icons.school_sharp, size: 40, color: colors.primary),
                                Text("Total Staff", style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
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
                        color: Color(0xFFada1ff).withOpacity(0.3),
                        borderRadius: BorderRadius.all(Radius.circular(6))
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Staff Information",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2F3A4C)),
                              ),
                              Icon(Icons.more_vert, color: Colors.grey),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 30,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 0,
                              pieTouchData: PieTouchData(
                              ),
                              sections: showingSections(),
                            ),
                            swapAnimationDuration: const Duration(milliseconds: 800),
                            swapAnimationCurve: Curves.easeOut,
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(color: Color(0xFF7A6FF0), shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Teaching ",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(color: Color(0xFFFFA726), shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Non-Teaching",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

