import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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

    int touchedIndex = -1;

    List<PieChartSectionData> showingSections() {
      final data = [
        {'value': 85.0, 'color': const Color(0xFF7A6FF0)}, // Present
        {'value': 10.0, 'color': const Color(0xFFFFA726)}, // Late
        {'value': 5.0, 'color': const Color(0xFFE53935)}, // Absent
      ];

      return List.generate(data.length, (i) {
        final isTouched = i == touchedIndex;
        final double radius = isTouched ? 50 : 40;
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
        color: Colors.white,
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
            Text('Staff & Teacher Information', style: TextStyle(fontSize: 18, color: Color(0xFF00496d))),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.black12
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(6))
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_sharp, size: 40, color: Color(0xFF7A6FF0),),
                          Text("Total Staff", style: TextStyle(fontSize: 13)),
                          Text("1,200", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30))
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 120,
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
                                "Teachers Attendance",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF2F3A4C)),
                              ),
                              Icon(Icons.more_vert, color: Colors.grey),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
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
