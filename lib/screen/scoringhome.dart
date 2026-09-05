
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import 'actionbuttons.dart';

class StaffScoringPage extends StatefulWidget {

  const StaffScoringPage({super.key});

  @override
  State<StaffScoringPage> createState() => _StaffScoringPageState();
}

class _StaffScoringPageState extends State<StaffScoringPage> {

  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String level = "";
  String subject = "";
  String subjectkey = "";
  String teacherid = "";
  Map<String, dynamic>? entry;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<Myprovider>(context, listen: false);
      await provider.loadSelectedEntry();
      await provider.loadStudentDetails();
      final loaded = provider.selectedEntry;
      if (loaded == null) {
        setState(() => isLoading = false);
        return;
      }
      entry = loaded;
      subject = loaded['subject'];
      level = loaded['class'];
      subjectkey = loaded['subjectkey'];
      teacherid = provider.staffid;
      setState(() => isLoading = false);
      await provider.fetchStaffScoringMarks(className: level, subjectKey: subjectkey,);
    });

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double maxWidth = 900;
    return Consumer<Myprovider>(
      builder: (BuildContext context, value, Widget? child) {
        final filteredMarks = value.marksList.where((m) {
          if (_searchText.isEmpty) return true;
          final values = [
            (m['id'] ?? '').toString().toLowerCase(),
            (m['studentName'] ?? '').toString().toLowerCase(),
            (m['studentId'] ?? '').toString().toLowerCase(),
            (m['class'] ?? '').toString().toLowerCase(),
          ];
          return values.any((v) => v.contains(_searchText));
        }).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2D2F45),
            foregroundColor: Colors.white,
            title: Text(
              "${value.className} ~ ${subject} ~ ${value.year} ~${value.term}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, Routes.staffhome);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.grade, color: Colors.white),
                tooltip: "View Marks",
                onPressed: () {
                 Navigator.pushNamed(context, Routes.viewmarks);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  //Search bar
                  SizedBox(
                    width: maxWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: "Search Students",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fillColor: Colors.white60,
                          filled: true,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      width: maxWidth,
                      color: const Color(0xFF2D2F45),
                      child: ListView.builder(
                        itemCount: filteredMarks.length,
                        itemBuilder: (context, idx) {
                          final mark = filteredMarks[idx];
                          final index = value.marksList.indexOf(mark) + 1;

                          return Card(
                            color: Colors.white10,
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueGrey,
                                child: Text(
                                  index.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                mark['studentName'] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID: ${mark['studentId'] ?? ''}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),

                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _assessmentButton(
                                    context: context,
                                    provider: value,
                                    mark: mark,
                                    label: "CA",
                                    subject: subject,
                                    subjectkey: subjectkey,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 6),
                                  _assessmentButton(
                                    context: context,
                                    provider: value,
                                    mark: mark,
                                    label: "Exams",
                                    color: Colors.green,
                                    subject:subject,
                                    subjectkey: subjectkey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _assessmentButton({
    required BuildContext context,
    required Myprovider provider,
    required Map<String, dynamic> mark,
    required String label,
    required Color color,
    required String subject,
    required String subjectkey,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: () async {

        await provider.clearstudentsdetail();
        await provider.studentsdetails(
          mark['studentId'] ?? '',
          mark['studentName'] ?? '',
          mark['class'] ?? '',
          mark['department'] ?? '',
          mark['hassubjectkey'] ?? '',
          subject,
          mark['photoUrl'] ?? '',
          mark['totalScore']?.toString() ?? '',
          subjectkey,
          label,
        );
        Navigator.pushNamed(context, Routes.enterAssessmentMarks,);
      },
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

}
