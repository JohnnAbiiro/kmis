import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnimatedAdmissionsReportCard extends StatefulWidget {
  final double cwidth;
  const AnimatedAdmissionsReportCard({super.key, required this.cwidth});

  @override
  State<AnimatedAdmissionsReportCard> createState() =>
      _AnimatedAdmissionsReportCardState();
}

class _AnimatedAdmissionsReportCardState
    extends State<AnimatedAdmissionsReportCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final double percentage = 70; // e.g. 70% of total admissions

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.cwidth,
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // === Left Side (Texts) ===
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Admissions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Termly Report",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              const Text(
                "1,350",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.keyboard_arrow_up_sharp, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "10.8%",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // === Right Side (Animated Pie Chart) ===
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            startDegreeOffset: 270,
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: _animation.value,
                                radius: 10,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: Colors.green.shade200,
                                value: 100 - _animation.value,
                                radius: 10,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "184",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 5, backgroundColor: Colors.green),
                  SizedBox(width: 6),
                  Text('Male'),
                  SizedBox(width: 16),
                  CircleAvatar(radius: 5, backgroundColor: Colors.green.shade200),
                  SizedBox(width: 6),
                  Text('Female'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
