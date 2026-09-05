/*

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import 'dropdown.dart';

class clearScores extends StatefulWidget {
  const clearScores({super.key});

  @override
  State<clearScores> createState() => _clearScoresState();
}

class _clearScoresState extends State<clearScores> {
  final _formKey = GlobalKey<FormState>();
  String? myRegion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      final value= context.read<Myprovider>();
      await value.cfetchJudges();
      await value.fetchRegion();
      //value.getfetchRegions();
      value.getfetchLevels();

    });

  }


  String? level;
  String? selectedLevel;
  String? selectedEpisodeName;
  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFF2C2C3C);

    return  Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2D2F45),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context,  Routes.dashboard),
          ),
          title:  Text(
            'Drop Judge Scores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body:   Consumer<Myprovider>(
            builder: (BuildContext context, value, child) {
              return  SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: myRegion,
                        items: value.regs
                            .map(
                              (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                        dropdownColor: inputFill,
                        onChanged: (value) {
                          setState(() {
                            myRegion = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Select Region",
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[700]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[700]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                            ),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          filled: true,
                          fillColor: inputFill,
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please select a category'
                            : null,
                      ),
                      SizedBox(height: 20,),
                      DropdownButtonFormField<String>(
                        value: level,
                        items:value.levelss
                            .map(
                              (cat) => DropdownMenuItem(
                            value: cat.levelname,
                            child: Text(
                              cat.levelname,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                        dropdownColor: inputFill,
                        onChanged: (value) {
                          setState(() {
                            level = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Level Category",
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[700]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[700]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                            ),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          filled: true,
                          fillColor: inputFill,
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please select a level'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      CustomDropdown(
                        label: "Episode",
                        items: value.episodes.map((e) => e.episodename).toList(),
                        value: selectedEpisodeName,
                        onChanged: (val) {
                          setState(() {
                            selectedEpisodeName = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: () async{
                          if (level == null || level!.isEmpty|| selectedEpisodeName == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select a level and episode before continuing."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          _showStaffDialog(context,myRegion!,level!,selectedEpisodeName!,value);
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
    );

  }
}
Future<void> _showStaffDialog(BuildContext context, String region, String level, String episode,Myprovider value) async {

  final staffDocs=value.contestantJudges.where(
          (judge)=>judge['region']==region &&
          judge['level']==level &&
          judge['episode']==episode
  ).toList();
  if (staffDocs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No staff found for the selected filters.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Matching Staff', style: TextStyle(color: Colors.black)),
      content: staffDocs.isEmpty
          ? const Text('No staff found for the selected filters.')
          : SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: staffDocs.length,
          itemBuilder: (context, index) {
            final staffName = staffDocs[index]['name'] as String;
            final staffphone = staffDocs[index]['phone'] as String;
            return ListTile(
              title: Text(staffName),
              trailing: value.isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Deletion',style: TextStyle(color: Colors.black)),
                        content: Text('Are you sure you want to clear scores for $staffName?',style: TextStyle(color: Colors.black)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete',style: TextStyle(color: Colors.black),),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await value.resetScoringMarks(
                        staffPhone: staffphone,
                        region: region,
                        level: level,
                        episode: episode,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Scores cleared for $staffName"),
                          backgroundColor: Colors.green,
                        ),
                      );}
                  }
              ),
            );          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

resetScoringMarks({    required String staffPhone, required String region,required String level, required String episode, }) async {

  try {
    isLoading=true;
    notifyListeners();
    final scoredField = 'scored$staffPhone';
    if(accesslevel=='Admin'){
      print('Admin access, resetting all scores');
      final query = await db
          .collection('scoringMark')
          .where(scoredField, isEqualTo: 'yes')
          .where('region', isEqualTo: region)
          .where('level', isEqualTo: level)
          .where('episodeId', isEqualTo: episode).get();

      WriteBatch batch = db.batch();

      for (final doc in query.docs) {
        final data = doc.data();
        if (data.containsKey(staffPhone)) {
          final judgeData = data[staffPhone] as Map<String, dynamic>? ?? {};
          final scores = judgeData['scores'] as Map<String, dynamic>? ?? {};
          final resetScores = {for (var key in scores.keys) key: '0'};
          print('Resetting scores for $staffPhone: $resetScores');
          final updateData = {
            staffPhone: {
              'criteriatotal': '0',
              'scores': resetScores,
              'totalScore': '0',
            },
            scoredField: 'no',
          };

          batch.update(doc.reference, updateData);
        }
      }
      await batch.commit();
    }
  } catch (e) {
    debugPrint('Error resetting scoringMark: $e');
    rethrow;
  }finally {
    isLoading = false;
    notifyListeners();
  }

}

*/