import 'package:ksoftsms/components/academicperformance.dart';
import 'package:ksoftsms/components/attendancetracking.dart';
import 'package:ksoftsms/components/scoresheet.dart';
import 'package:ksoftsms/controller/loginprovider.dart';
import 'package:ksoftsms/controller/statsprovider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ksoftsms/components/prioritycard.dart';
import 'package:ksoftsms/components/sidebar.dart';
import 'package:ksoftsms/components/summarychart.dart';
import 'package:ksoftsms/components/ticketbydaychart.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/widgets/animatedadmission.dart';
import 'package:provider/provider.dart';
import '../controller/routes.dart';
import 'columnchart.dart';
import 'csat.dart';
import 'duplicatecontainer.dart';
import 'guagecontainer.dart';
import 'hourminutes.dart';
import 'oneticket.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  double totalRevenue = 0;
  double todayRevenue = 0;
  int totalTickets = 0;
  double totalvotes = 0;
  String topCollector = '';
  String schoolname = '';
  List<Map<String, dynamic>> topCollectors = [];
  @override
  void initState()  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().getdata();
      print(context.read<Myprovider>().currentschool);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
     final provider= context.read<Myprovider>();
      provider.getdata();
      setState(() {
        schoolname=provider.currentschool;
      });
     print(provider.phone);
    });

  }
  String todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth <= 500;
    bool isTablet = screenWidth < 900;
    bool isBigTablet = screenWidth < 1200;
    return Consumer<StatsProvider>(
      builder: (BuildContext context, StatsProvider value, Widget? child) {
        return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: const Color(0xFF00273a),
              title: Text(schoolname.toUpperCase(), style: TextStyle(color: Colors.white)),
              actions: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CircleAvatar(
                    backgroundColor: Color(0xFF00496d),
                      child: Icon(Icons.person, color: Colors.white54)
                  ),
                ),
              ],
            ),
            drawer: CustomDrawer(),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        HourMinutes(
                          cwidth: isMobile
                              ? screenWidth * 0.95
                              : isTablet
                              ? screenWidth * 0.63
                              : isBigTablet
                              ? screenWidth * 0.473
                              : screenWidth * 0.23,
                          topcollector: topCollector.toLowerCase(),
                        ),
                        DuplicateContainer(
                          heading: 'Total Judges Assigned',
                          number: value.totaljugdes.toString(),
                          value: 'Judges',
                          containerWidth: isMobile
                              ? screenWidth * 0.95
                              : isTablet
                              ? screenWidth * 0.63
                              : isBigTablet
                              ? screenWidth * 0.473
                              : screenWidth * 0.24,
                        ),
                        GaugeContainer(
                          cwidth: isMobile
                              ? screenWidth * 0.95
                              : isTablet
                              ? screenWidth * 0.63
                              : isBigTablet
                              ? screenWidth * 0.473
                              : screenWidth * 0.23,
                          reader: double.parse(value.totalscored.toString()),
                          totalval: double.parse(value.totaltempaltes.toString()),
                        ),
                        // DuplicateContainer(
                        //   heading: 'Staff & Teacher Information',
                        //   number: value.totalcontestants.toString(),
                        //   value: '${value.accesslevel}',
                        //   containerWidth: isMobile
                        //       ? screenWidth * 0.95
                        //       : isTablet
                        //       ? screenWidth * 0.63
                        //       : isBigTablet
                        //       ? screenWidth * 0.473
                        //       : screenWidth * 0.24,
                        // ),
                        AttendanceTracking(
                          cwidth: isMobile
                              ? screenWidth * 0.95
                              : isTablet
                              ? screenWidth * 0.63
                              : isBigTablet
                              ? screenWidth * 0.473
                              : screenWidth * 0.23,
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Wrap(
                      runSpacing: 16,
                      spacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        TicketsByDayChart(
                          cwidth: isMobile
                              ? screenWidth * 0.95
                              : isTablet
                              ? screenWidth * 0.63
                              : isBigTablet
                              ? screenWidth * 0.955
                              : screenWidth * 0.487,
                        ),
                        // PriorityDonutChart(
                        //   cwidth: isMobile
                        //       ? screenWidth * 0.95
                        //       : isTablet
                        //       ? screenWidth * 0.63
                        //       : isBigTablet
                        //       ? screenWidth * 0.473
                        //       : (screenWidth - 20) * 0.233,
                        // ),
                        AcademicPerformanceCard(
                          cwidth: isMobile
                              ? screenWidth * 0.95
                              : isTablet
                              ? screenWidth * 0.63
                              : isBigTablet
                              ? screenWidth * 0.473
                              : screenWidth * 0.23,
                        ),
                        AnimatedAdmissionsReportCard(
                          cwidth: isMobile
                              ? screenWidth * 0.95
                              : isTablet
                              ? screenWidth * 0.63
                              : isBigTablet
                              ? screenWidth * 0.473
                              : screenWidth * 0.23,
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Wrap(
                      runSpacing: 15,
                      spacing: 15,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        ColumnChart(
                          cwidth: isMobile
                              ? screenWidth * 0.95
                              : isTablet
                              ? screenWidth * 0.63
                              : isBigTablet
                              ? screenWidth * 0.955
                              : screenWidth * 0.487,
                        ),
                        OneTicket(
                          cwidth: isMobile
                              ? screenWidth * 0.95
                              : isTablet
                              ? screenWidth * 0.63
                              : isBigTablet
                              ? screenWidth * 0.473
                              : (screenWidth - 20) * 0.233,
                              totalvotes: "${value.totalvotes}",
                        ),
                        CSAT(
                          cwidth: isMobile
                              ? screenWidth * 0.95
                              : isTablet
                              ? screenWidth * 0.63
                              : isBigTablet
                              ? screenWidth * 0.473
                              : (screenWidth - 20) * 0.233,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
        );
      },
    );
  }
}
