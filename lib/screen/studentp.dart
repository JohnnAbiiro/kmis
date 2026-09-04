import 'package:flutter/material.dart';

// void main() {
//   runApp(const StudentPortalApp());
// }

// ============================================================
// APP
// ============================================================

class StudentPortalApp extends StatelessWidget {
  const StudentPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Portal',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF315CF6),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
        ),
      ),
      home: const StudentDashboardPage(),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  State<StudentDashboardPage> createState() =>
      _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  int selectedNavigation = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;
            final isTablet = constraints.maxWidth >= 700;

            return Row(
              children: [
                if (isDesktop) const _DesktopSidebar(),

                Expanded(
                  child: Column(
                    children: [
                      _TopHeader(
                        isDesktop: isDesktop,
                        onNotificationTap: () {
                          _showMessage(
                            context,
                            'You have 3 new notifications.',
                          );
                        },
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop
                                ? 32
                                : isTablet
                                ? 24
                                : 16,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const _WelcomeSection(),

                              const SizedBox(height: 24),

                              _SummaryCards(
                                isTablet: isTablet,
                              ),

                              const SizedBox(height: 24),

                              _MainDashboardGrid(
                                isDesktop: isDesktop,
                                isTablet: isTablet,
                              ),

                              const SizedBox(height: 24),

                              _QuickServices(),

                              const SizedBox(height: 24),

                              _Announcements(),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),

      bottomNavigationBar: MediaQuery.of(context).size.width < 1100
          ? _MobileNavigation(
        selectedIndex: selectedNavigation,
        onSelected: (index) {
          setState(() {
            selectedNavigation = index;
          });
        },
      )
          : null,
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ============================================================
// DESKTOP SIDEBAR
// ============================================================

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF101828),
      child: Column(
        children: [
          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF315CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'StudentHub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          const _SidebarItem(
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            selected: true,
          ),

          const _SidebarItem(
            icon: Icons.school_outlined,
            title: 'Academics',
          ),

          const _SidebarItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Finance',
          ),

          const _SidebarItem(
            icon: Icons.calendar_month_outlined,
            title: 'Timetable',
          ),

          const _SidebarItem(
            icon: Icons.assignment_outlined,
            title: 'Results',
          ),

          const _SidebarItem(
            icon: Icons.fact_check_outlined,
            title: 'Attendance',
          ),

          const _SidebarItem(
            icon: Icons.description_outlined,
            title: 'Documents',
          ),

          const _SidebarItem(
            icon: Icons.support_agent_outlined,
            title: 'Support',
          ),

          const Spacer(),

          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white70,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Need help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Contact student support.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: Colors.white24,
                      ),
                    ),
                    child: const Text('Contact'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;

  const _SidebarItem({
    required this.icon,
    required this.title,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF315CF6)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: selected
              ? Colors.white
              : Colors.white60,
          size: 21,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.white70,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
        onTap: () {},
      ),
    );
  }
}

// ============================================================
// TOP HEADER
// ============================================================

class _TopHeader extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onNotificationTap;

  const _TopHeader({
    required this.isDesktop,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8ECF3),
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF315CF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
              ),
            ),

          if (!isDesktop)
            const SizedBox(width: 12),

          if (!isDesktop)
            const Text(
              'StudentHub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

          if (isDesktop)
            const Text(
              'Student Dashboard',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),

          const Spacer(),

          IconButton(
            onPressed: onNotificationTap,
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 26,
                ),
                Positioned(
                  right: 1,
                  top: 1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4D67),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'AM',
                style: TextStyle(
                  color: Color(0xFF315CF6),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          if (isDesktop) ...[
            const SizedBox(width: 10),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ayinemi Matthew',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Student',
                  style: TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF667085),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// WELCOME
// ============================================================

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good afternoon, Ayinemi 👋',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101828),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Here is your academic and financial overview.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),

        if (MediaQuery.of(context).size.width > 600)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE4E7EC),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF667085),
                ),
                SizedBox(width: 8),
                Text(
                  '2026/2027 • First Semester',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================
// SUMMARY CARDS
// ============================================================

class _SummaryCards extends StatelessWidget {
  final bool isTablet;

  const _SummaryCards({
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTablet) {
      return const Column(
        children: [
          _FinanceSummary(),
          SizedBox(height: 16),
          _AcademicSummary(),
        ],
      );
    }

    return const Row(
      children: [
        Expanded(child: _FinanceSummary()),
        SizedBox(width: 18),
        Expanded(child: _AcademicSummary()),
      ],
    );
  }
}

// ============================================================
// FINANCE CARD
// ============================================================

class _FinanceSummary extends StatelessWidget {
  const _FinanceSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF315CF6),
            Color(0xFF2447C9),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ACCOUNT BALANCE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Outstanding',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'GH₵ 2,450.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: .78,
              minHeight: 7,
              backgroundColor: Color(0x33FFFFFF),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 9),

          const Row(
            children: [
              Text(
                '78% paid',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Spacer(),
              Text(
                'GH₵ 8,550 paid',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _FinanceMiniValue(
                  label: 'Total Fees',
                  value: 'GH₵ 11,000',
                ),
              ),
              Expanded(
                child: _FinanceMiniValue(
                  label: 'Scholarship',
                  value: 'GH₵ 500',
                ),
              ),
              Expanded(
                child: _FinanceMiniValue(
                  label: 'Due Date',
                  value: '15 Sep',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF315CF6),
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'View Financial Account',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceMiniValue extends StatelessWidget {
  final String label;
  final String value;

  const _FinanceMiniValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ACADEMIC SUMMARY
// ============================================================

class _AcademicSummary extends StatelessWidget {
  const _AcademicSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE7EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconContainer(
                icon: Icons.school_outlined,
                background: const Color(0xFFEFF2FF),
                iconColor: const Color(0xFF315CF6),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Academic Performance',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const _StatusBadge(
                text: 'Good Standing',
                color: Color(0xFF12B76A),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              SizedBox(
                width: 105,
                height: 105,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 105,
                      height: 105,
                      child: CircularProgressIndicator(
                        value: .74,
                        strokeWidth: 9,
                        backgroundColor: const Color(0xFFE8ECF5),
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(
                          Color(0xFF315CF6),
                        ),
                      ),
                    ),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '3.72',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'CGPA',
                          style: TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 25),

              const Expanded(
                child: Column(
                  children: [
                    _AcademicValue(
                      title: 'Semester GPA',
                      value: '3.84',
                    ),
                    SizedBox(height: 14),
                    _AcademicValue(
                      title: 'Credits Registered',
                      value: '21',
                    ),
                    SizedBox(height: 14),
                    _AcademicValue(
                      title: 'Credits Completed',
                      value: '84',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('View Results'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Transcript'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AcademicValue extends StatelessWidget {
  final String title;
  final String value;

  const _AcademicValue({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MAIN GRID
// ============================================================

class _MainDashboardGrid extends StatelessWidget {
  final bool isDesktop;
  final bool isTablet;

  const _MainDashboardGrid({
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) {
      return const Column(
        children: [
          _TodaySchedule(),
          SizedBox(height: 18),
          _AttendanceCard(),
          SizedBox(height: 18),
          _CourseProgress(),
          SizedBox(height: 18),
          _RecentTransactions(),
        ],
      );
    }

    return const Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _TodaySchedule(),
            ),
            SizedBox(width: 18),
            Expanded(
              child: _AttendanceCard(),
            ),
          ],
        ),

        SizedBox(height: 18),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CourseProgress(),
            ),
            SizedBox(width: 18),
            Expanded(
              child: _RecentTransactions(),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// SCHEDULE
// ============================================================

class _TodaySchedule extends StatelessWidget {
  const _TodaySchedule();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: "Today's Schedule",
      subtitle: 'Thursday, 3 September',
      action: 'View timetable',
      child: Column(
        children: [
          _ScheduleItem(
            time: '08:00',
            course: 'Database Systems',
            lecturer: 'Dr. Mensah',
            room: 'Room B204',
            status: 'Completed',
            statusColor: const Color(0xFF12B76A),
            icon: Icons.check_circle_rounded,
          ),
          _ScheduleItem(
            time: '10:00',
            course: 'Software Engineering',
            lecturer: 'Prof. Owusu',
            room: 'Computer Lab 2',
            status: 'Next',
            statusColor: const Color(0xFF315CF6),
            icon: Icons.arrow_forward_rounded,
          ),
          _ScheduleItem(
            time: '14:00',
            course: 'Operating Systems',
            lecturer: 'Dr. Boateng',
            room: 'Room A102',
            status: 'Upcoming',
            statusColor: const Color(0xFF98A2B3),
            icon: Icons.schedule_rounded,
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time;
  final String course;
  final String lecturer;
  final String room;
  final String status;
  final Color statusColor;
  final IconData icon;

  const _ScheduleItem({
    required this.time,
    required this.course,
    required this.lecturer,
    required this.room,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),

          Container(
            width: 3,
            height: 43,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$lecturer • $room',
                  style: const TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            icon,
            size: 19,
            color: statusColor,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ATTENDANCE
// ============================================================

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Attendance',
      subtitle: 'Current semester',
      action: 'Details',
      child: Column(
        children: [
          const SizedBox(height: 5),

          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: .92,
                        strokeWidth: 10,
                        backgroundColor:
                        const Color(0xFFE8ECF3),
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(
                          Color(0xFF12B76A),
                        ),
                      ),
                    ),
                    const Text(
                      '92%',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 22),

              const Expanded(
                child: Column(
                  children: [
                    _AttendanceRow(
                      label: 'Present',
                      value: '42',
                      color: Color(0xFF12B76A),
                    ),
                    SizedBox(height: 12),
                    _AttendanceRow(
                      label: 'Absent',
                      value: '3',
                      color: Color(0xFFF04438),
                    ),
                    SizedBox(height: 12),
                    _AttendanceRow(
                      label: 'Late',
                      value: '2',
                      color: Color(0xFFF79009),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 17,
                  color: Color(0xFF12B76A),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your attendance is above the required 75%.',
                    style: TextStyle(
                      color: Color(0xFF087443),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AttendanceRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// COURSE PROGRESS
// ============================================================

class _CourseProgress extends StatelessWidget {
  const _CourseProgress();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Course Progress',
      subtitle: 'Current semester',
      action: 'All courses',
      child: Column(
        children: const [
          _CourseProgressRow(
            code: 'CS301',
            title: 'Database Systems',
            progress: .78,
          ),
          _CourseProgressRow(
            code: 'CS305',
            title: 'Software Engineering',
            progress: .85,
          ),
          _CourseProgressRow(
            code: 'CS307',
            title: 'Operating Systems',
            progress: .64,
          ),
          _CourseProgressRow(
            code: 'CS309',
            title: 'Computer Networks',
            progress: .72,
          ),
        ],
      ),
    );
  }
}

class _CourseProgressRow extends StatelessWidget {
  final String code;
  final String title;
  final double progress;

  const _CourseProgressRow({
    required this.code,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    color: Color(0xFF315CF6),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE9EDF4),
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                Color(0xFF315CF6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RECENT TRANSACTIONS
// ============================================================

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Recent Transactions',
      subtitle: 'Financial account',
      action: 'View all',
      child: Column(
        children: const [
          _TransactionRow(
            icon: Icons.school_outlined,
            title: 'Tuition Fee',
            date: '01 Sep 2026',
            amount: '- GH₵ 2,000',
            isCredit: false,
          ),
          _TransactionRow(
            icon: Icons.home_outlined,
            title: 'Hostel Fee',
            date: '27 Aug 2026',
            amount: '- GH₵ 1,500',
            isCredit: false,
          ),
          _TransactionRow(
            icon: Icons.card_giftcard_outlined,
            title: 'Scholarship',
            date: '20 Aug 2026',
            amount: '+ GH₵ 500',
            isCredit: true,
          ),
          _TransactionRow(
            icon: Icons.menu_book_outlined,
            title: 'Library Fee',
            date: '15 Aug 2026',
            amount: '- GH₵ 100',
            isCredit: false,
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final bool isCredit;

  const _TransactionRow({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: isCredit
                  ? const Color(0xFFECFDF3)
                  : const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: isCredit
                  ? const Color(0xFF12B76A)
                  : const Color(0xFF667085),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          Text(
            amount,
            style: TextStyle(
              color: isCredit
                  ? const Color(0xFF12B76A)
                  : const Color(0xFF344054),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUICK SERVICES
// ============================================================

class _QuickServices extends StatelessWidget {
  const _QuickServices();

  @override
  Widget build(BuildContext context) {
    final services = [
      (
      Icons.app_registration_rounded,
      'Course Registration',
      ),
      (
      Icons.receipt_long_outlined,
      'Payment Receipts',
      ),
      (
      Icons.description_outlined,
      'Academic Transcript',
      ),
      (
      Icons.badge_outlined,
      'Student ID',
      ),
      (
      Icons.home_work_outlined,
      'Accommodation',
      ),
      (
      Icons.local_library_outlined,
      'Library',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Services',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            int columns;

            if (constraints.maxWidth >= 1000) {
              columns = 6;
            } else if (constraints.maxWidth >= 600) {
              columns = 3;
            } else {
              columns = 2;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (context, index) {
                final service = services[index];

                return _ServiceCard(
                  icon: service.$1,
                  title: service.$2,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ServiceCard({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE7EAF0),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF315CF6),
                  size: 18,
                ),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ANNOUNCEMENTS
// ============================================================

class _Announcements extends StatelessWidget {
  const _Announcements();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Important Updates',
      subtitle: 'Stay informed',
      action: 'View all',
      child: Column(
        children: const [
          _AnnouncementRow(
            icon: Icons.priority_high_rounded,
            title: 'Fee payment deadline',
            description:
            'Outstanding fees should be settled by 15 September.',
            color: Color(0xFFF04438),
          ),
          _AnnouncementRow(
            icon: Icons.calendar_month_outlined,
            title: 'Examination timetable published',
            description:
            'Your first semester examination timetable is now available.',
            color: Color(0xFF315CF6),
          ),
          _AnnouncementRow(
            icon: Icons.check_circle_outline,
            title: 'Course registration is open',
            description:
            'Complete your semester registration before the deadline.',
            color: Color(0xFF12B76A),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _AnnouncementRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF98A2B3),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REUSABLE DASHBOARD CARD
// ============================================================

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;
  final Widget child;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE7EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF98A2B3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  action,
                  style: const TextStyle(
                    color: Color(0xFF315CF6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          child,
        ],
      ),
    );
  }
}

// ============================================================
// MOBILE NAVIGATION
// ============================================================

class _MobileNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _MobileNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      height: 68,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE8EDFF),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school_rounded),
          label: 'Academics',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon:
          Icon(Icons.account_balance_wallet_rounded),
          label: 'Finance',
        ),
        NavigationDestination(
          icon: Icon(Icons.apps_outlined),
          selectedIcon: Icon(Icons.apps_rounded),
          label: 'Services',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

// ============================================================
// SMALL UI COMPONENTS
// ============================================================

class _IconContainer extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;

  const _IconContainer({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 21,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}