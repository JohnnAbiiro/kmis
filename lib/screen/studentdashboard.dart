import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ============================================================================
// MODELS
// ============================================================================

class StudentProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String studentId;
  final String department;
  final String faculty;
  final String level;
  final String session;
  final String profileImage;
  final DateTime dateOfBirth;
  final String gender;
  final String nationality;
  final String religion;
  final String bloodGroup;
  final String genotype;
  final String homeAddress;
  final String emergencyContact;
  final String emergencyPhone;

  StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.studentId,
    required this.department,
    required this.faculty,
    required this.level,
    required this.session,
    this.profileImage = '',
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.religion,
    required this.bloodGroup,
    required this.genotype,
    required this.homeAddress,
    required this.emergencyContact,
    required this.emergencyPhone,
  });
}

class AcademicRecord {
  final String semester;
  final String session;
  final List<Course> courses;
  final double gpa;
  final double cgpa;
  final int totalCredits;
  final int earnedCredits;
  final String academicStanding;

  AcademicRecord({
    required this.semester,
    required this.session,
    required this.courses,
    required this.gpa,
    required this.cgpa,
    required this.totalCredits,
    required this.earnedCredits,
    required this.academicStanding,
  });
}

class Course {
  final String code;
  final String title;
  final int credits;
  final String grade;
  final double score;
  final String status; // 'completed', 'in-progress', 'registered'
  final String instructor;
  final String schedule;
  final String venue;

  Course({
    required this.code,
    required this.title,
    required this.credits,
    required this.grade,
    required this.score,
    required this.status,
    required this.instructor,
    required this.schedule,
    required this.venue,
  });
}

class FinancialRecord {
  final String transactionId;
  final DateTime date;
  final String description;
  final String category;
  final double amount;
  final String status; // 'paid', 'pending', 'overdue'
  final String paymentMethod;
  final String reference;

  FinancialRecord({
    required this.transactionId,
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.reference,
  });
}

class FeeBreakdown {
  final String category;
  final double amount;
  final double paid;
  final double balance;
  final String dueDate;

  FeeBreakdown({
    required this.category,
    required this.amount,
    required this.paid,
    required this.balance,
    required this.dueDate,
  });
}

class AttendanceRecord {
  final String courseCode;
  final String courseTitle;
  final int totalClasses;
  final int attended;
  final int excused;
  final double percentage;
  final List<AttendanceSession> sessions;

  AttendanceRecord({
    required this.courseCode,
    required this.courseTitle,
    required this.totalClasses,
    required this.attended,
    required this.excused,
    required this.percentage,
    required this.sessions,
  });
}

class AttendanceSession {
  final DateTime date;
  final String status; // 'present', 'absent', 'excused'
  final String time;

  AttendanceSession({
    required this.date,
    required this.status,
    required this.time,
  });
}

class LibraryRecord {
  final String bookId;
  final String title;
  final String author;
  final DateTime borrowedDate;
  final DateTime dueDate;
  final DateTime? returnedDate;
  final String status; // 'borrowed', 'returned', 'overdue'
  final double fine;

  LibraryRecord({
    required this.bookId,
    required this.title,
    required this.author,
    required this.borrowedDate,
    required this.dueDate,
    this.returnedDate,
    required this.status,
    required this.fine,
  });
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String venue;
  final String type; // 'academic', 'sports', 'cultural', 'administrative'
  final String priority; // 'high', 'medium', 'low'
  final bool isMandatory;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.venue,
    required this.type,
    required this.priority,
    required this.isMandatory,
  });
}

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final String type; // 'info', 'warning', 'success', 'error'
  final String action;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
    required this.type,
    required this.action,
  });
}

// ============================================================================
// MOCK DATA
// ============================================================================

class MockData {
  static StudentProfile getStudentProfile() {
    return StudentProfile(
      id: 'STU2024001',
      name: 'Oluwafemi Adebayo',
      email: 'oluwafemi.adebayo@university.edu',
      phone: '+234 803 456 7890',
      studentId: '2024/001',
      department: 'Computer Science',
      faculty: 'Engineering & Technology',
      level: '400 Level',
      session: '2024/2025',
      profileImage: '',
      dateOfBirth: DateTime(2000, 5, 15),
      gender: 'Male',
      nationality: 'Nigerian',
      religion: 'Christianity',
      bloodGroup: 'O+',
      genotype: 'AA',
      homeAddress: '15, University Road, Ibadan, Nigeria',
      emergencyContact: 'Mrs. Yetunde Adebayo',
      emergencyPhone: '+234 803 123 4567',
    );
  }

  static AcademicRecord getAcademicRecord() {
    return AcademicRecord(
      semester: 'Second Semester',
      session: '2024/2025',
      gpa: 4.25,
      cgpa: 4.12,
      totalCredits: 18,
      earnedCredits: 15,
      academicStanding: 'Good Standing',
      courses: [
        Course(
          code: 'CSC 401',
          title: 'Advanced Database Systems',
          credits: 3,
          grade: 'A',
          score: 87.5,
          status: 'completed',
          instructor: 'Prof. O. Johnson',
          schedule: 'Mon 10:00 AM - 12:00 PM',
          venue: 'Room 301, Engineering Building',
        ),
        Course(
          code: 'CSC 403',
          title: 'Machine Learning',
          credits: 3,
          grade: 'A',
          score: 82.0,
          status: 'completed',
          instructor: 'Dr. A. Ibrahim',
          schedule: 'Tue 2:00 PM - 4:00 PM',
          venue: 'Room 203, ICT Center',
        ),
        Course(
          code: 'CSC 405',
          title: 'Software Engineering',
          credits: 3,
          grade: 'B+',
          score: 76.5,
          status: 'completed',
          instructor: 'Dr. B. Ogunleye',
          schedule: 'Wed 9:00 AM - 11:00 AM',
          venue: 'Room 105, Science Complex',
        ),
        Course(
          code: 'CSC 407',
          title: 'Computer Networks',
          credits: 3,
          grade: 'A-',
          score: 80.0,
          status: 'completed',
          instructor: 'Prof. S. Adeyemi',
          schedule: 'Thu 1:00 PM - 3:00 PM',
          venue: 'Room 202, ICT Center',
        ),
        Course(
          code: 'CSC 409',
          title: 'Research Methodology',
          credits: 2,
          grade: 'B',
          score: 72.0,
          status: 'completed',
          instructor: 'Dr. M. Oladipo',
          schedule: 'Fri 11:00 AM - 1:00 PM',
          venue: 'Room 302, Engineering Building',
        ),
        Course(
          code: 'CSC 411',
          title: 'Cloud Computing',
          credits: 3,
          grade: 'In Progress',
          score: 0,
          status: 'in-progress',
          instructor: 'Dr. K. Ibrahim',
          schedule: 'Mon 2:00 PM - 4:00 PM',
          venue: 'Room 204, ICT Center',
        ),
        Course(
          code: 'CSC 413',
          title: 'Mobile App Development',
          credits: 1,
          grade: 'Registered',
          score: 0,
          status: 'registered',
          instructor: 'Mr. T. Adeleke',
          schedule: 'Wed 2:00 PM - 5:00 PM',
          venue: 'Lab 2, ICT Center',
        ),
      ],
    );
  }

  static List<FinancialRecord> getFinancialRecords() {
    return [
      FinancialRecord(
        transactionId: 'TX2024001',
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Tuition Fee Payment - 2024/2025 Session',
        category: 'Tuition',
        amount: 250000,
        status: 'paid',
        paymentMethod: 'Bank Transfer',
        reference: 'REF/2024/001234',
      ),
      FinancialRecord(
        transactionId: 'TX2024002',
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Accommodation Fee - Hostel Block A',
        category: 'Accommodation',
        amount: 120000,
        status: 'paid',
        paymentMethod: 'Card Payment',
        reference: 'REF/2024/001235',
      ),
      FinancialRecord(
        transactionId: 'TX2024003',
        date: DateTime.now().subtract(const Duration(days: 10)),
        description: 'Library Service Fee',
        category: 'Library',
        amount: 15000,
        status: 'paid',
        paymentMethod: 'Cash',
        reference: 'REF/2024/001236',
      ),
      FinancialRecord(
        transactionId: 'TX2024004',
        date: DateTime.now().subtract(const Duration(days: 15)),
        description: 'Laboratory Fee - Computer Science',
        category: 'Laboratory',
        amount: 45000,
        status: 'pending',
        paymentMethod: '',
        reference: '',
      ),
      FinancialRecord(
        transactionId: 'TX2024005',
        date: DateTime.now().subtract(const Duration(days: 20)),
        description: 'Sports & Recreation Fee',
        category: 'Sports',
        amount: 30000,
        status: 'overdue',
        paymentMethod: '',
        reference: '',
      ),
      FinancialRecord(
        transactionId: 'TX2024006',
        date: DateTime.now().subtract(const Duration(days: 25)),
        description: 'Student Union Fee',
        category: 'Union',
        amount: 10000,
        status: 'paid',
        paymentMethod: 'Bank Transfer',
        reference: 'REF/2024/001237',
      ),
    ];
  }

  static List<FeeBreakdown> getFeeBreakdown() {
    return [
      FeeBreakdown(
        category: 'Tuition Fee',
        amount: 250000,
        paid: 250000,
        balance: 0,
        dueDate: '2024-09-30',
      ),
      FeeBreakdown(
        category: 'Accommodation',
        amount: 120000,
        paid: 120000,
        balance: 0,
        dueDate: '2024-09-15',
      ),
      FeeBreakdown(
        category: 'Library Fee',
        amount: 15000,
        paid: 15000,
        balance: 0,
        dueDate: '2024-10-15',
      ),
      FeeBreakdown(
        category: 'Laboratory Fee',
        amount: 45000,
        paid: 0,
        balance: 45000,
        dueDate: '2024-11-30',
      ),
      FeeBreakdown(
        category: 'Sports Fee',
        amount: 30000,
        paid: 0,
        balance: 30000,
        dueDate: '2024-12-15',
      ),
      FeeBreakdown(
        category: 'Student Union Fee',
        amount: 10000,
        paid: 10000,
        balance: 0,
        dueDate: '2024-09-30',
      ),
    ];
  }

  static List<AttendanceRecord> getAttendanceRecords() {
    return [
      AttendanceRecord(
        courseCode: 'CSC 401',
        courseTitle: 'Advanced Database Systems',
        totalClasses: 24,
        attended: 22,
        excused: 1,
        percentage: 91.67,
        sessions: [
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 1)), status: 'present', time: '10:00 AM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 3)), status: 'present', time: '10:00 AM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 5)), status: 'present', time: '10:00 AM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 8)), status: 'absent', time: '10:00 AM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 10)), status: 'present', time: '10:00 AM'),
        ],
      ),
      AttendanceRecord(
        courseCode: 'CSC 403',
        courseTitle: 'Machine Learning',
        totalClasses: 20,
        attended: 18,
        excused: 1,
        percentage: 90.0,
        sessions: [
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 2)), status: 'present', time: '2:00 PM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 4)), status: 'present', time: '2:00 PM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 6)), status: 'excused', time: '2:00 PM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 9)), status: 'present', time: '2:00 PM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 11)), status: 'present', time: '2:00 PM'),
        ],
      ),
      AttendanceRecord(
        courseCode: 'CSC 405',
        courseTitle: 'Software Engineering',
        totalClasses: 18,
        attended: 15,
        excused: 0,
        percentage: 83.33,
        sessions: [
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 1)), status: 'present', time: '9:00 AM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 4)), status: 'present', time: '9:00 AM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 7)), status: 'present', time: '9:00 AM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 10)), status: 'absent', time: '9:00 AM'),
          AttendanceSession(date: DateTime.now().subtract(const Duration(days: 13)), status: 'absent', time: '9:00 AM'),
        ],
      ),
    ];
  }

  static List<LibraryRecord> getLibraryRecords() {
    return [
      LibraryRecord(
        bookId: 'BK2024001',
        title: 'Advanced Database Systems',
        author: 'R. Elmasri',
        borrowedDate: DateTime.now().subtract(const Duration(days: 10)),
        dueDate: DateTime.now().add(const Duration(days: 4)),
        returnedDate: null,
        status: 'borrowed',
        fine: 0,
      ),
      LibraryRecord(
        bookId: 'BK2024002',
        title: 'Machine Learning for Beginners',
        author: 'A. Ng',
        borrowedDate: DateTime.now().subtract(const Duration(days: 25)),
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        returnedDate: null,
        status: 'overdue',
        fine: 1500,
      ),
      LibraryRecord(
        bookId: 'BK2024003',
        title: 'Software Engineering Fundamentals',
        author: 'I. Sommerville',
        borrowedDate: DateTime.now().subtract(const Duration(days: 30)),
        dueDate: DateTime.now().subtract(const Duration(days: 15)),
        returnedDate: DateTime.now().subtract(const Duration(days: 12)),
        status: 'returned',
        fine: 0,
      ),
      LibraryRecord(
        bookId: 'BK2024004',
        title: 'Computer Networks',
        author: 'A. Tanenbaum',
        borrowedDate: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 9)),
        returnedDate: null,
        status: 'borrowed',
        fine: 0,
      ),
    ];
  }

  static List<Event> getEvents() {
    return [
      Event(
        id: 'EVT001',
        title: 'Final Year Project Presentation',
        description: 'All final year students must present their project proposals to the department committee.',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        venue: 'Conference Hall, ICT Center',
        type: 'academic',
        priority: 'high',
        isMandatory: true,
      ),
      Event(
        id: 'EVT002',
        title: 'Tech Career Fair 2024',
        description: 'Meet with industry partners, explore internship opportunities, and network with professionals.',
        dateTime: DateTime.now().add(const Duration(days: 7)),
        venue: 'Sports Pavilion',
        type: 'academic',
        priority: 'medium',
        isMandatory: false,
      ),
      Event(
        id: 'EVT003',
        title: 'Inter-Faculty Sports Competition',
        description: 'Annual inter-faculty sports competition. Sign up for your preferred sporting event.',
        dateTime: DateTime.now().add(const Duration(days: 14)),
        venue: 'University Sports Complex',
        type: 'sports',
        priority: 'low',
        isMandatory: false,
      ),
      Event(
        id: 'EVT004',
        title: 'Faculty Board Meeting',
        description: 'Important faculty meeting to discuss curriculum updates and student welfare.',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        venue: 'Faculty Board Room',
        type: 'administrative',
        priority: 'high',
        isMandatory: true,
      ),
    ];
  }

  static List<Notification> getNotifications() {
    return [
      Notification(
        id: 'NOT001',
        title: 'Project Presentation Reminder',
        message: 'Your project presentation is scheduled for December 15th. Ensure you submit your report by December 10th.',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        type: 'warning',
        action: 'View Details',
      ),
      Notification(
        id: 'NOT002',
        title: 'Payment Reminder',
        message: 'Your laboratory fee payment of ₦45,000 is due by November 30th. Please make payment to avoid penalties.',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
        type: 'error',
        action: 'Pay Now',
      ),
      Notification(
        id: 'NOT003',
        title: 'Library Book Due Soon',
        message: 'Your borrowed book "Advanced Database Systems" is due in 4 days. Please return or renew.',
        date: DateTime.now().subtract(const Duration(hours: 12)),
        isRead: false,
        type: 'info',
        action: 'Renew',
      ),
      Notification(
        id: 'NOT004',
        title: 'CGPA Update',
        message: 'Your CGPA has been updated to 4.12. Excellent performance! Keep it up.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'success',
        action: 'View Results',
      ),
    ];
  }
}

// ============================================================================
// THEME
// ============================================================================

class AppTheme {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF7C3AED);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  static const Color background = Color(0xFFF0F4FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textSecondary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted),
      ),
    );
  }
}
// ============================================================================
// MAIN APP
// ============================================================================

class StudentPortal extends StatelessWidget {
  const StudentPortal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Portal',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const StudentDashboard(),
    );
  }
}

// ============================================================================
// DASHBOARD
// ============================================================================

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTab = 0;

  final StudentProfile _profile = MockData.getStudentProfile();
  final AcademicRecord _academic = MockData.getAcademicRecord();
  final List<FinancialRecord> _finance = MockData.getFinancialRecords();
  final List<FeeBreakdown> _fees = MockData.getFeeBreakdown();
  final List<AttendanceRecord> _attendance = MockData.getAttendanceRecords();
  final List<LibraryRecord> _library = MockData.getLibraryRecords();
  final List<Event> _events = MockData.getEvents();
  final List<Notification> _notifications = MockData.getNotifications();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildQuickStats(),
                const SizedBox(height: 20),
                _buildTabNavigation(),
                const SizedBox(height: 16),
                _buildTabContent(),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // APP BAR
  // ==========================================================================

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.background,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Student Portal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () => _showNotifications(),
              icon: const Icon(Icons.notifications_outlined),
            ),
            if (_notifications.where((n) => !n.isRead).isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  // ==========================================================================
  // PROFILE HEADER
  // ==========================================================================

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profile.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_profile.studentId} • ${_profile.department}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.verified_rounded,
                        '${_profile.level}',
                        AppTheme.success,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.calendar_today_rounded,
                        _profile.session,
                        AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.grade_rounded,
                        'CGPA: ${_academic.cgpa.toStringAsFixed(2)}',
                        AppTheme.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // QUICK STATS
  // ==========================================================================

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'CGPA',
            _academic.cgpa.toStringAsFixed(2),
            'Current Standing',
            AppTheme.primary,
            Icons.grade_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Semester GPA',
            _academic.gpa.toStringAsFixed(2),
            '${_academic.semester}',
            AppTheme.secondary,
            Icons.auto_stories_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Credits',
            '${_academic.totalCredits}',
            '${_academic.earnedCredits} Earned',
            AppTheme.success,
            Icons.book_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Balance',
            '₦${_formatCurrency(_getTotalBalance())}',
            '${_getPaidAmount()} Paid',
            AppTheme.warning,
            Icons.account_balance_wallet_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB NAVIGATION
  // ==========================================================================

  Widget _buildTabNavigation() {
    final tabs = [
      'Overview',
      'Academics',
      'Finance',
      'Attendance',
      'Library',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.divider,
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==========================================================================
  // TAB CONTENT
  // ==========================================================================

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildAcademicsTab();
      case 2:
        return _buildFinanceTab();
      case 3:
        return _buildAttendanceTab();
      case 4:
        return _buildLibraryTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================================================
  // OVERVIEW TAB
  // ==========================================================================

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upcoming Events
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _events.take(3).length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final event = _events[index];
            return _buildEventCard(event);
          },
        ),
        const SizedBox(height: 20),

        // Recent Notifications
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _notifications.take(3).length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return _buildNotificationCard(notification);
          },
        ),
        const SizedBox(height: 20),

        // Quick Actions
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    Color color;
    switch (event.priority) {
      case 'high':
        color = AppTheme.danger;
        break;
      case 'medium':
        color = AppTheme.warning;
        break;
      default:
        color = AppTheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              event.type == 'academic' ? Icons.school_rounded :
              event.type == 'sports' ? Icons.sports_baseball_rounded :
              event.type == 'cultural' ? Icons.art_track_rounded :
              Icons.business_center_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('MMM d, HH:mm').format(event.dateTime)} • ${event.venue}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (event.isMandatory)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Mandatory',
                style: TextStyle(
                  color: AppTheme.danger,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Notification notification) {
    Color color;
    switch (notification.type) {
      case 'success':
        color = AppTheme.success;
        break;
      case 'warning':
        color = AppTheme.warning;
        break;
      case 'error':
        color = AppTheme.danger;
        break;
      default:
        color = AppTheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.transparent : color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: notification.isRead ? Colors.transparent : color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.message,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            DateFormat('h:mm a').format(notification.date),
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildQuickAction(
          Icons.payment_rounded,
          'Pay Fees',
          AppTheme.primary,
              () {},
        ),
        const SizedBox(width: 12),
        _buildQuickAction(
          Icons.receipt_long_rounded,
          'View Results',
          AppTheme.success,
              () {},
        ),
        const SizedBox(width: 12),
        _buildQuickAction(
          Icons.local_library_rounded,
          'Library',
          AppTheme.secondary,
              () {},
        ),
        const SizedBox(width: 12),
        _buildQuickAction(
          Icons.calendar_month_rounded,
          'Timetable',
          AppTheme.warning,
              () {},
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ACADEMICS TAB
  // ==========================================================================

  Widget _buildAcademicsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildAcademicSummary('GPA', _academic.gpa.toStringAsFixed(2), AppTheme.primary),
            const SizedBox(width: 12),
            _buildAcademicSummary('CGPA', _academic.cgpa.toStringAsFixed(2), AppTheme.secondary),
            const SizedBox(width: 12),
            _buildAcademicSummary('Credits', '${_academic.earnedCredits}/${_academic.totalCredits}', AppTheme.success),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Academic Standing',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.success.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _academic.academicStanding,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                    const Text(
                      'You are in good academic standing. Keep up the excellent work!',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Courses',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._academic.courses.map((course) => _buildCourseCard(course)),
      ],
    );
  }

  Widget _buildAcademicSummary(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    Color statusColor;
    String statusText;
    switch (course.status) {
      case 'completed':
        statusColor = AppTheme.success;
        statusText = 'Completed';
        break;
      case 'in-progress':
        statusColor = AppTheme.warning;
        statusText = 'In Progress';
        break;
      case 'registered':
        statusColor = AppTheme.primary;
        statusText = 'Registered';
        break;
      default:
        statusColor = AppTheme.textMuted;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.code,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildCourseInfo('Credits', '${course.credits}'),
              const SizedBox(width: 16),
              _buildCourseInfo('Grade', course.grade),
              const SizedBox(width: 16),
              _buildCourseInfo('Score', course.score > 0 ? '${course.score.toStringAsFixed(1)}%' : 'N/A'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                course.instructor,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.schedule_rounded, size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                course.schedule,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // FINANCE TAB
  // ==========================================================================

  Widget _buildFinanceTab() {
    final totalBalance = _getTotalBalance();
    final totalPaid = _getPaidAmount();
    final totalDue = _getTotalDue();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildFinanceSummary('Total Balance', '₦${_formatCurrency(totalBalance)}', AppTheme.danger),
            const SizedBox(width: 12),
            _buildFinanceSummary('Total Paid', '₦${_formatCurrency(totalPaid)}', AppTheme.success),
            const SizedBox(width: 12),
            _buildFinanceSummary('Total Due', '₦${_formatCurrency(totalDue)}', AppTheme.warning),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Fee Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._fees.map((fee) => _buildFeeCard(fee)),
        const SizedBox(height: 16),
        const Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._finance.map((transaction) => _buildTransactionCard(transaction)),
      ],
    );
  }

  Widget _buildFinanceSummary(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeCard(FeeBreakdown fee) {
    final isPaid = fee.balance == 0;
    final isPartial = fee.balance > 0 && fee.paid > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Due: ${fee.dueDate}',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${_formatCurrency(fee.amount)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPaid ? AppTheme.success.withOpacity(0.1) :
                      isPartial ? AppTheme.warning.withOpacity(0.1) :
                      AppTheme.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPaid ? 'Paid' :
                      isPartial ? 'Partial' :
                      'Unpaid',
                      style: TextStyle(
                        color: isPaid ? AppTheme.success :
                        isPartial ? AppTheme.warning :
                        AppTheme.danger,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paid',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '₦${_formatCurrency(fee.paid)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '₦${_formatCurrency(fee.balance)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: fee.balance == 0 ? AppTheme.success : AppTheme.danger,
                      ),
                    ),
                  ],
                ),
              ),
              if (fee.balance > 0)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(FinancialRecord transaction) {
    Color statusColor;
    String statusText;
    switch (transaction.status) {
      case 'paid':
        statusColor = AppTheme.success;
        statusText = 'Paid';
        break;
      case 'pending':
        statusColor = AppTheme.warning;
        statusText = 'Pending';
        break;
      case 'overdue':
        statusColor = AppTheme.danger;
        statusText = 'Overdue';
        break;
      default:
        statusColor = AppTheme.textMuted;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              transaction.status == 'paid' ? Icons.payment_rounded :
              transaction.status == 'pending' ? Icons.hourglass_empty_rounded :
              Icons.warning_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${DateFormat('MMM d, yyyy').format(transaction.date)} • ${transaction.category}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.status == 'paid' ? '+₦${_formatCurrency(transaction.amount)}' :
                '₦${_formatCurrency(transaction.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: transaction.status == 'paid' ? AppTheme.success : AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ATTENDANCE TAB
  // ==========================================================================

  Widget _buildAttendanceTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            children: [
              _buildAttendanceSummary('Overall', '${_getOverallAttendancePercentage().toStringAsFixed(1)}%', AppTheme.primary),
              const SizedBox(width: 12),
              _buildAttendanceSummary('Present', _getTotalPresent().toString(), AppTheme.success),
              const SizedBox(width: 12),
              _buildAttendanceSummary('Absent', _getTotalAbsent().toString(), AppTheme.danger),
              const SizedBox(width: 12),
              _buildAttendanceSummary('Excused', _getTotalExcused().toString(), AppTheme.warning),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Course Attendance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._attendance.map((record) => _buildAttendanceCard(record)),
      ],
    );
  }

  Widget _buildAttendanceSummary(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record) {
    final color = record.percentage >= 80 ? AppTheme.success :
    record.percentage >= 60 ? AppTheme.warning :
    AppTheme.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.courseCode,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      record.courseTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${record.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildAttendanceStat('Attended', record.attended.toString(), AppTheme.success),
              const SizedBox(width: 16),
              _buildAttendanceStat('Absent', '${record.totalClasses - record.attended - record.excused}', AppTheme.danger),
              const SizedBox(width: 16),
              _buildAttendanceStat('Excused', record.excused.toString(), AppTheme.warning),
              const SizedBox(width: 16),
              _buildAttendanceStat('Total', record.totalClasses.toString(), AppTheme.textMuted),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Flexible(
                  flex: record.attended,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(2),
                      ),
                    ),
                  ),
                ),
                if (record.excused > 0)
                  Flexible(
                    flex: record.excused,
                    child: Container(
                      color: AppTheme.warning,
                    ),
                  ),
                Flexible(
                  flex: record.totalClasses - record.attended - record.excused,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.danger,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(2),
                      ),
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

  Widget _buildAttendanceStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // LIBRARY TAB
  // ==========================================================================

  Widget _buildLibraryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLibrarySummary('Borrowed', _library.where((b) => b.status == 'borrowed').length.toString(), AppTheme.primary),
            const SizedBox(width: 12),
            _buildLibrarySummary('Overdue', _library.where((b) => b.status == 'overdue').length.toString(), AppTheme.danger),
            const SizedBox(width: 12),
            _buildLibrarySummary('Returned', _library.where((b) => b.status == 'returned').length.toString(), AppTheme.success),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Borrowed Books',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._library.map((book) => _buildLibraryCard(book)),
      ],
    );
  }

  Widget _buildLibrarySummary(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryCard(LibraryRecord book) {
    Color statusColor;
    String statusText;
    switch (book.status) {
      case 'borrowed':
        statusColor = AppTheme.primary;
        statusText = 'Borrowed';
        break;
      case 'overdue':
        statusColor = AppTheme.danger;
        statusText = 'Overdue';
        break;
      case 'returned':
        statusColor = AppTheme.success;
        statusText = 'Returned';
        break;
      default:
        statusColor = AppTheme.textMuted;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              book.status == 'returned' ? Icons.check_circle_rounded :
              book.status == 'overdue' ? Icons.warning_rounded :
              Icons.book_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${book.author} • ${book.bookId}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Borrowed: ${DateFormat('MMM d, yyyy').format(book.borrowedDate)} • Due: ${DateFormat('MMM d, yyyy').format(book.dueDate)}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (book.fine > 0)
                Text(
                  'Fine: ₦${_formatCurrency(book.fine)}',
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (book.status != 'returned')
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Renew',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // NOTIFICATIONS DIALOG
  // ==========================================================================

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Mark All Read',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationCard(notification);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  double _getTotalBalance() {
    return _fees.fold(0.0, (sum, fee) => sum + fee.balance);
  }

  double _getPaidAmount() {
    return _fees.fold(0.0, (sum, fee) => sum + fee.paid);
  }

  double _getTotalDue() {
    return _fees.fold(0.0, (sum, fee) => sum + fee.amount);
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
    );
  }

  double _getOverallAttendancePercentage() {
    if (_attendance.isEmpty) return 0.0;
    final totalAttended = _attendance.fold(0, (sum, r) => sum + r.attended);
    final totalClasses = _attendance.fold(0, (sum, r) => sum + r.totalClasses);
    return totalClasses > 0 ? (totalAttended / totalClasses) * 100 : 0;
  }

  int _getTotalPresent() {
    return _attendance.fold(0, (sum, r) => sum + r.attended);
  }

  int _getTotalAbsent() {
    return _attendance.fold(0, (sum, r) => sum + (r.totalClasses - r.attended - r.excused));
  }

  int _getTotalExcused() {
    return _attendance.fold(0, (sum, r) => sum + r.excused);
  }
}

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================

// void main() {
//   runApp(const StudentPortal());
// }