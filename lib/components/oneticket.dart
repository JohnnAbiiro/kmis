import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/statsprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class OneTicket extends StatelessWidget {
  final double cwidth;
  final String totalvotes;
  const OneTicket({super.key, required this.cwidth, required this.totalvotes});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (BuildContext context,  value, Widget? child) {
        return  Container(
          width: cwidth,
          height: 400,
          decoration: BoxDecoration(
            color: Color(0xFFffffff),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Dropdown for year
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('2023', style: TextStyle(color: Colors.black54)),
                      Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount
                const Text(
                  'GHC 253,825',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),
                const Text(
                  'Budget: 56,800',
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 16),

                // Mini line chart
                SizedBox(
                  height: 80,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 2),
                            FlSpot(1, 3),
                            FlSpot(2, 2.5),
                            FlSpot(3, 4),
                            FlSpot(4, 3.5),
                            FlSpot(5, 4.2),
                            FlSpot(6, 2.2),
                            FlSpot(7, 4.2),
                            FlSpot(8, 1.4),
                            FlSpot(9, 3.0),
                            FlSpot(10, 4.5),
                          ],
                          isCurved: true,
                          color: Colors.deepPurple,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.withOpacity(0.2),
                                Colors.transparent
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          barWidth: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Increase  Fees',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
