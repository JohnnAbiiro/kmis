
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      final loaded = provider.selectedEntry;
     print("Loaded entry: $loaded");
      if (loaded == null) {
       // print("No saved entry found");
        setState(() => isLoading = false);
        return;
      }


      entry = loaded;
      subject = loaded['subject'];
      level = loaded['class'];
      subjectkey = loaded['subjectkey'];
      teacherid = provider.staffid;
      setState(() => isLoading = false);
      //print("Fetching scoring marks for $subject - $level");

      await provider.fetchStaffScoringMarks(
        className: level,
        subjectKey: subjectkey,
      );
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
              "${value.name} ~ ${value.auth.currentUser?.email ?? "No user"} ~ ${value.year} ~ ~ ${value.staffid} ~${value.term}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.go(Routes.staffhome);
              },
            ),
            actions: actionButtons(value, context),
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
                          final scores =
                              mark['scores'] as Map<String, dynamic>? ?? {};

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
                                  Text(
                                    'Class: ${mark['class'] ?? ''}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Wrap(
                                    runSpacing: 10,
                                    spacing: 10.0,
                                    children: [
                                      Text(
                                        'Subject: ${mark['subject'] ?? ''}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        'Year: ${value.year}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                context.go(
                                  Routes.entermark,
                                  extra: {
                                    "studentId": mark['studentId'],
                                    "studentName": mark['studentName'],
                                    "class": mark['class'],
                                    "subject": mark['subject'],
                                    "photoUrl": mark['photoUrl'],
                                    "scores": scores,
                                    "subjectkey": subjectkey,
                                  },
                                );
                              },
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
}
