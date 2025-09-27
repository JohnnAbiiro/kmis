import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TicketsByDayChart extends StatelessWidget {
  final double cwidth;
  const TicketsByDayChart({super.key, required this.cwidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cwidth,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'School Performance',
              style: TextStyle(color: Color(0xFF00273a), fontSize: 16),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 150,
              width: 650,
              child: LineChart(
                LineChartData(
                  backgroundColor: Color(0xFFffffff),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, _) {
                          final days = [
                            'Week 01',
                            'Week 02',
                            'Week 03',
                            'Week 04',
                            'Week 05',
                            'Week 06',
                          ];
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(
                              color: Color(0xFF00496d),
                              fontSize: 10,
                            ),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text(
                          '${value.toInt()}',
                          style: TextStyle(color: Color(0xFF00496d), fontSize: 10),
                        ),
                        interval: 2,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Color(0xFFfb7d5b),
                      dotData: FlDotData(show: true),
                      barWidth: 3,
                      spots: [
                        FlSpot(0, 1),
                        FlSpot(1, 3),
                        FlSpot(2, 2.5),
                        FlSpot(3, 3.5),
                        FlSpot(4, 4),
                        FlSpot(5, 3),
                      ],
                    ),
                    LineChartBarData(
                      isCurved: true,
                      color: Color(0xFF7A6FF0),
                      dotData: FlDotData(show: true),
                      barWidth: 3,
                      spots: [
                        FlSpot(0, 1),
                        FlSpot(1, 4),
                        FlSpot(2, 2),
                        FlSpot(3, 4),
                        FlSpot(4, 3),
                        FlSpot(5, 5),
                      ],
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF7A6FF0).withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                LegendDot(color: Color(0xFF7A6FF0), label: 'This week',),
                SizedBox(width: 20),
                LegendDot(color: Color(0xFFfb7d5b), label: 'Last week'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(color: Color(0xFF00273a), fontSize: 12)),
      ],
    );
  }
}
