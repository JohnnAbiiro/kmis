import 'package:ksoftsms/components/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ColumnChart extends StatefulWidget {
  final double cwidth;
  const ColumnChart({super.key, required this.cwidth});

  @override
  State<ColumnChart> createState() => _ColumnChartState();
}

class _ColumnChartState extends State<ColumnChart> {
  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> barData = [
      {'month': 'Jan', 'paid': 80, 'unpaid': 50},
      {'month': 'Feb', 'paid': 70, 'unpaid': 40},
      {'month': 'Mar', 'paid': 90, 'unpaid': 60},
      {'month': 'Apr', 'paid': 100, 'unpaid': 70},
      {'month': 'May', 'paid': 60, 'unpaid': 30},
      {'month': 'Jun', 'paid': 40, 'unpaid': 60},
      {'month': 'Jul', 'paid': 70, 'unpaid': 50},
      {'month': 'Aug', 'paid': 50, 'unpaid': 60},
      {'month': 'Sep', 'paid': 80, 'unpaid': 30},
      {'month': 'Oct', 'paid': 30, 'unpaid': 70},
      {'month': 'Nov', 'paid': 90, 'unpaid': 10},
      {'month': 'Dec', 'paid': 10, 'unpaid': 90},
    ];

    return Container(
      height: 400,
      width: widget.cwidth,
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                  'Fees Report',
                  style: TextStyle(fontSize: 18, color: Color(0xFF00496d))
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(radius: 5, backgroundColor: Color(0xFF00b377)),
                  SizedBox(width: 6),
                  Text('Paid'),
                  SizedBox(width: 16),
                  CircleAvatar(radius: 5, backgroundColor: Colors.deepPurple),
                  SizedBox(width: 6),
                  Text('Unpaid'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 120,
                barGroups: [
                  for (int i = 0; i < barData.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        // Paid bar
                        BarChartRodData(
                          toY: barData[i]['paid'].toDouble(),
                          color: Color(0xFF00b377),
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        // Unpaid bar
                        BarChartRodData(
                          toY: barData[i]['unpaid'].toDouble(),
                          color: Colors.deepPurple,
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                ],
                gridData: FlGridData(show: false, horizontalInterval: 20),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= barData.length) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          //axisSide: meta.axisSide,
                          meta: meta,
                          space: 6,
                          child: Text(
                            barData[value.toInt()]['month'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 300),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}
