
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:provider/provider.dart';
import '../components/staffsizebar.dart';
import '../controller/routes.dart';
import 'actionbuttons.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<Myprovider>(context, listen: false);
    String staffKey=provider.normalizeAndSanitize("${provider.staffid}_${provider.academicyrid}_${provider.term}");
    provider.fetchTeacherSetup(staffKey);
  });}

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final count = mediaWidth > 600 ? 3 : 2;

    return Consumer<Myprovider>(
      builder: (context, provider, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'Welcome ${provider.name} ~ ${provider.term ?? "No user"}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            elevation: 0,
            actions: actionButtons(provider, context),
          ),
          drawer: CustomDrawer(),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D2F45), Color(0xFF1B1C2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: provider.assignedList.isEmpty
                ? _buildMessage("No subjects/classes assigned yet.")
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                  childAspectRatio: mediaWidth > 900
                      ? 1.8
                      : mediaWidth > 600
                      ? 1.3
                      : 1.0,
                ),
                itemCount: provider.assignedList.length,
                itemBuilder: (context, index) {
                  final entry = provider.assignedList[index];
                  final color =
                  Colors.primaries[index % Colors.primaries.length];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    splashColor: color.withOpacity(0.3),
                    onTap: () async {
                      await provider.clearSelectedEntry();
                      await provider.setSelectedEntry(entry);
                      final assessmentkey="${provider.schoolid}_${entry['department']}";
                      final normalizedKey=provider.normalizeAndSanitize(assessmentkey);
                      await provider.loadSelectedGradingSystem(level:normalizedKey);
                      context.go(Routes.staffscoring);
                    },
                    child: _buildClickableCard(
                      context,
                      icon: Icons.book_rounded,
                      title: "${entry['subject']} (${entry['class']}) ${entry['department']}",
                      color: color,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  Widget _buildClickableCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
      }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
