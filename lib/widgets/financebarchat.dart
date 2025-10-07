import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PaymentChart extends StatelessWidget {
  const PaymentChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments Overview')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 800000,
            barGroups: [
              makeGroupData('Year 7', 160000, 63200, 96900),
              makeGroupData('Year 8', 315000, 96900, 218000),
              makeGroupData('Year 9', 160000, 50800, 110000),
              makeGroupData('Year 10', 141000, 45200, 95500),
              makeGroupData('Year 11', 160000, 59200, 101000),
            ],
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 36),
              ),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(String label, double expected, double paid, double remaining) {
    return BarChartGroupData(
      barsSpace: 4,
      x: 0,
      barRods: [
        BarChartRodData(
          toY: expected + paid + remaining,
          rodStackItems: [
            BarChartRodStackItem(0, expected, Colors.blue, BorderSide.none),
            BarChartRodStackItem(expected, expected + paid, Colors.green, BorderSide.none),
            BarChartRodStackItem(expected + paid, expected + paid + remaining, Colors.orange, BorderSide.none),
          ],
          width: 25,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }
}

void main() {
  runApp(const MaterialApp(home: PaymentChart()));
}
