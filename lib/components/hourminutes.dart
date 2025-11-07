import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HourMinutes extends StatelessWidget {
  final double cwidth;
  final String topcollector;

  const HourMinutes(
      {super.key, required this.cwidth, required this.topcollector});

  @override
  Widget build(BuildContext context) {

    final male = 60;
    final female = 40;
    return Consumer<Myprovider>(
      builder: (context, value, child) {
        return Container(
          width: cwidth,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
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
                Text('Student Information', style: TextStyle(fontSize: 18, color: Color(0xFF00496d))),
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
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('students').snapshots(),
                              builder: (context, snapshot){
                                if (!snapshot.hasData) return const CircularProgressIndicator();
                                final count = snapshot.data!.docs.length;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_alt, color: Color(0xFF00b377), size: 40),
                                    Text("Total Students", style: TextStyle(fontSize: 12),),
                                    Text(count.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 30))
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
                        height: 120,
                        width: 150,
                        decoration: BoxDecoration(
                            color: Color(0xFFe1fef3),
                            borderRadius: BorderRadius.all(Radius.circular(6))
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Male vs Female",
                                style: TextStyle(fontSize: 13),
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
                                        color: Color(0xFF00b377),
                                        title: male.toString(),
                                        radius: 30,
                                        titleStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      PieChartSectionData(
                                        value: female.toDouble(),
                                        color: Color(0xFF00d7c4),
                                        title: female.toString(),
                                        radius: 20,
                                        titleStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
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
                                        decoration: BoxDecoration(color: Color(0xFF00b377), shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Male",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(color: Color(0xFF00d7c4), shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Female",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                // Text(topcollector.toUpperCase(), style: TextStyle(fontSize: 15,
                //     color: Colors.green,
                //     fontWeight: FontWeight.bold),),
                // SizedBox(height: 50),
                // Center(
                //   child: Text('${0}/${0}', style: TextStyle(
                //       fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFfb7d5b))),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}