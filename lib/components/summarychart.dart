import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SummaryDonutChart extends StatelessWidget {
  final double cwidth;
  const SummaryDonutChart({super.key, required this.cwidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      // constraints: BoxConstraints(
      //   maxWidth:
      //       MediaQuery.of(context).size.width < 600 ? double.infinity : 375,
      // ),
      width: cwidth,
      height: 250,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFe8fbf0),
              Colors.white,

            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admissions', style: TextStyle(fontSize: 15)),
              Center(
                child: CircularPercentIndicator(
                  radius: 70.0,
                  lineWidth: 10.0,
                  percent: 0.7,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: Color(0xFFfb7d5b).withOpacity(0.3),
                  progressColor: Color(0xFF00496d),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "70%",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00273a),
                        ),
                      ),
                      Text(
                        "of 100%",
                        style: TextStyle(color: Color(0xFF00496d), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: Color(0xFFb0bcc2)),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SummaryItem(label: "Cal", value: "305"),
                      SummaryItem(label: "Steps", value: "10983"),
                      SummaryItem(label: "Distance", value: "7km"),
                      SummaryItem(label: "Sleep", value: "7hr"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const SummaryItem({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 10)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
