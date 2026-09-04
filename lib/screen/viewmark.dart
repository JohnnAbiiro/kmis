import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/routes.dart';
import '../controller/myprovider.dart';

class ViewScorePage extends StatefulWidget {
  const ViewScorePage({super.key});

  @override
  State<ViewScorePage> createState() => _ViewScorePageState();
}

class _ViewScorePageState extends State<ViewScorePage> {
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
     // provider.clearContestantDetails();
      await provider.loadSelectedEntry();
      final loaded = provider.selectedEntry;
      if (loaded == null) {
        setState(() => isLoading = false);
        return;
      }
      provider.fetchScoredMarks();
      entry = loaded;
      subject = loaded['subject'];
      level = loaded['class'];
      subjectkey = loaded['subjectkey'];
      teacherid = provider.staffid;
      setState(() => isLoading = false);
      //print("Fetching scoring marks for $subject - $level");
      //
      // await provider.fetchStaffScoringMarks(
      //   className: level,
      //   subjectKey: subjectkey,
      // );
     // provider.fetchScoredMarks(teacherid, level, subjectkey,);
    //  provider.fetchAccessComponents();
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
    double maxWidth = 900;
    final provider = Provider.of<Myprovider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go(Routes.scores);
          },
        ),
        backgroundColor: const Color(0xFF2D2F45),
        title: Text(
          "Recorded Student Marks ",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<Myprovider>(
        builder: (context, provider, _) {
          final marks = provider.scoredList.where((m) {
            if (_searchText.isEmpty) return true;

            final values =
            [
              (m['studentName'] ?? '').toString().toLowerCase(),
              (m['studentId'] ?? '').toString().toLowerCase(),
              (m['totalscore'] ?? '').toString().toLowerCase(),
              (m['id'] ?? '').toString().toLowerCase(),
            ];

            return values.any((v) => v.contains(_searchText));
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  /// 🔍 SEARCH BOX
                  SizedBox(
                    width: maxWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: "Search Student",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                      ),
                    ),
                  ),

                  ///  MARKS LIST
                  Expanded(
                    child: Container(
                      width: maxWidth,
                      color: const Color(0xFF2D2F45),
                      child: marks.isEmpty
                          ? const Center(
                        child: Text(
                          "No marks found",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                          : ListView.builder(
                        itemCount: marks.length,
                        itemBuilder: (context, idx) {
                          final mark = marks[idx];
                          final index = idx + 1;
                          final imageUrl = mark['photoUrl'] ?? '';
                          final allScores = Map<String, dynamic>.from(mark['scores'] ?? {});
                          final subjectKey = subjectkey;

                          final subjectScores = Map<String, dynamic>.from(
                            allScores[subjectKey] ?? {},
                          );

                          final ca = subjectScores['CA']?.toString() ?? '0';
                          final exams = subjectScores['Exams']?.toString() ?? '0';
                          final total = subjectScores['totalScore']?.toString() ?? '0';

                          return Card(
                            color: Colors.white10,
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage('assets/images/logo.png')
                                as ImageProvider,
                              ),
                              title: Text(
                                mark['studentName'] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Student ID: ${mark['studentId'] ?? ''}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'Total Score: $total',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'CA: $ca',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'Exams: $exams',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                index.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () async {
                                await provider.clearstudentsdetail();
                                await provider.studentsdetails(
                                  mark['studentId'] ?? '',
                                  mark['studentName'] ?? '',
                                  mark['class'] ?? '',
                                  mark['department'] ?? '',
                                  mark['hassubjectkey'] ?? false,
                                  mark['subject'] ?? '',
                                  mark['photoUrl'] ?? '',
                                 total,
                                  subjectkey ?? '',
                                  level,

                                );
                                context.go(Routes.entermark);
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
          );
        },
      ),
    );
  }
}


/*

fetchScoredMarks() async {
  try {
    isLoading = true;
    notifyListeners();

    await getdata();
    final query = db
        .collection('scoringMark')
        .where('episodeId', isEqualTo: episodeName)
        .where('region', isEqualTo: regionName)
        .where('level', isEqualTo: levelName)
        .where('scored$phone', isEqualTo: "yes");

    final snapshot = await query.get();

    scoredList = snapshot.docs.map((doc) {
      final data = doc.data();
      final phoneSection = data[phone];
      final rawScores =
      phoneSection is Map<String, dynamic>
          ? phoneSection['scores']
          : null;
      final totalScoreRaw =
      phoneSection is Map<String, dynamic>
          ? phoneSection['totalScore']
          : null;
      final scores = (data[phone]?['scores'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      // Convert scores map to a list of entries
      final sortedScoresList = scores.entries.toList();
      sortedScoresList.sort((a, b) => a.key.compareTo(b.key));
      final sortedScoresMap = Map.fromEntries(sortedScoresList);


      return {
        'id':         doc.id,
        'studentName': data['studentName'] ?? '',
        'studentId':   data['studentId']   ?? '',
        'level':       data['level']       ?? '',
        'photoUrl':    data['photoUrl']    ?? '',
        'totalscore':  totalScoreRaw?.toString() ?? '0',
        'scores':      sortedScoresMap,
      };
    }).toList();
  } catch (e) {
    print("Error fetching scored marks: $e");
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
clearContestantDetails() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('scoringid');
  await prefs.remove('studentId');
  await prefs.remove('studentName');
  await prefs.remove('studentphoto');
  await prefs.remove('pagekey');
  await prefs.remove('scores');

  contestantID = '';
  contestantName = '';
  imageUrl = '';
  pagekey = '';
  contestantScores = <String, dynamic>{};
  notifyListeners();
}
*/