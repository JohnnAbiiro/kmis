import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AcademicPerformanceCard extends StatelessWidget {
  final double cwidth;
  const AcademicPerformanceCard({super.key, required this.cwidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: cwidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            "Academic Performance",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black12
              ),
              borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recent Exam Results",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // Chart + Legend row
                Row(
                  children: [
                    // Bar Chart
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 120,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [
                                BarChartRodData(
                                  toY: 4,
                                  color: Colors.orange,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                )
                              ]),
                              BarChartGroupData(x: 1, barRods: [
                                BarChartRodData(
                                  toY: 5,
                                  color: Colors.deepOrange,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                )
                              ]),
                              BarChartGroupData(x: 2, barRods: [
                                BarChartRodData(
                                  toY: 6,
                                  color: Colors.amber,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                )
                              ]),
                              BarChartGroupData(x: 3, barRods: [
                                BarChartRodData(
                                  toY: 5,
                                  color: Colors.orangeAccent,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                )
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Legend
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendItem(Colors.deepOrange, "Class A"),
                          const SizedBox(height: 6),
                          _legendItem(Colors.amber, "Class B"),
                          const SizedBox(height: 6),
                          _legendItem(Colors.teal, "Class C"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}
