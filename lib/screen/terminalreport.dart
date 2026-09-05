/*
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../components/terminalreportsheetprinter.dart';
import '../controller/routes.dart';

class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key});

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  String? selectedSchool;
  String? selectedLevel;
  String? selectedTerm;

  final List<String> schools = ["Sacred Heart Academy"];
  final List<String> levels = ["JHS2", "JHS3"];
  final List<String> terms = ["First Term", "Second Term", "Third Term"];

  // Static student dataset
  final Map<String, List<Map<String, dynamic>>> studentsData = {
    "Sacred Heart Academy-JHS2": [
      {
        "name": "ASAA COURAGE AWINTIMAM",
        "id": "SHS-0456",
        "class": "JHS2",
        "subjects": [
          {
            "code": "ENG",
            "subject": "English Language",
            "classScore": "30",
            "examScore": "40",
            "totalScore": "70",
            "remarks": "Good",
          },
          {
            "code": "MTH",
            "subject": "Mathematics",
            "classScore": "25",
            "examScore": "50",
            "totalScore": "75",
            "remarks": "Good",
          },
          {
            "code": "SCI",
            "subject": "Integrated Science",
            "classScore": "28",
            "examScore": "42",
            "totalScore": "70",
            "remarks": "Good",
          },
          {
            "code": "SOC",
            "subject": "Social Studies",
            "classScore": "26",
            "examScore": "45",
            "totalScore": "71",
            "remarks": "Good",
          },
          {
            "code": "BDT",
            "subject": "Basic Design & Technology",
            "classScore": "27",
            "examScore": "46",
            "totalScore": "73",
            "remarks": "Very Good",
          },
          {
            "code": "CRE",
            "subject": "Creative Arts",
            "classScore": "29",
            "examScore": "48",
            "totalScore": "77",
            "remarks": "Very Good",
          },
          {
            "code": "RME",
            "subject": "Religious & Moral Education",
            "classScore": "30",
            "examScore": "50",
            "totalScore": "80",
            "remarks": "Excellent",
          },
          {
            "code": "ICT",
            "subject": "Computing",
            "classScore": "32",
            "examScore": "44",
            "totalScore": "76",
            "remarks": "Very Good",
          },
          {
            "code": "FRN",
            "subject": "French",
            "classScore": "24",
            "examScore": "40",
            "totalScore": "64",
            "remarks": "Fair",
          },
        ],
      },
      {
        "name": "AMMA KORANTENG",
        "id": "SHS-0457",
        "class": "JHS2",
        "subjects": [
          {
            "code": "ENG",
            "subject": "English Language",
            "classScore": "28",
            "examScore": "42",
            "totalScore": "70",
            "remarks": "Good",
          },
          {
            "code": "MTH",
            "subject": "Mathematics",
            "classScore": "30",
            "examScore": "45",
            "totalScore": "75",
            "remarks": "Good",
          },
          {
            "code": "SCI",
            "subject": "Integrated Science",
            "classScore": "30",
            "examScore": "40",
            "totalScore": "70",
            "remarks": "Good",
          },
          {
            "code": "SST",
            "subject": "Social Studies",
            "classScore": "32",
            "examScore": "47",
            "totalScore": "79",
            "remarks": "Very Good",
          },
          {
            "code": "BDT",
            "subject": "Basic Design & Technology",
            "classScore": "27",
            "examScore": "46",
            "totalScore": "73",
            "remarks": "Very Good",
          },
          {
            "code": "CRE",
            "subject": "Creative Arts",
            "classScore": "29",
            "examScore": "48",
            "totalScore": "77",
            "remarks": "Very Good",
          },
          {
            "code": "RME",
            "subject": "Religious & Moral Education",
            "classScore": "31",
            "examScore": "49",
            "totalScore": "80",
            "remarks": "Excellent",
          },
          {
            "code": "ICT",
            "subject": "Computing",
            "classScore": "25",
            "examScore": "44",
            "totalScore": "69",
            "remarks": "Good",
          },
        ],
      },
    ],
    "Sacred Heart Academy-JHS3": [
      {
        "name": "KOFI MENSAH",
        "id": "SHS-0789",
        "class": "JHS3",
        "subjects": [
          {
            "code": "SCI",
            "subject": "Integrated Science",
            "classScore": "30",
            "examScore": "40",
            "totalScore": "70",
            "remarks": "Good",
          },
          {
            "code": "SST",
            "subject": "Social Studies",
            "classScore": "32",
            "examScore": "47",
            "totalScore": "79",
            "remarks": "Very Good",
          },
          {
            "code": "ENG",
            "subject": "English Language",
            "classScore": "28",
            "examScore": "42",
            "totalScore": "70",
            "remarks": "Good",
          },
          {
            "code": "MTH",
            "subject": "Mathematics",
            "classScore": "30",
            "examScore": "45",
            "totalScore": "75",
            "remarks": "Good",
          },
          {
            "code": "BDT",
            "subject": "Basic Design & Technology",
            "classScore": "27",
            "examScore": "46",
            "totalScore": "73",
            "remarks": "Very Good",
          },
          {
            "code": "CRE",
            "subject": "Creative Arts",
            "classScore": "29",
            "examScore": "48",
            "totalScore": "77",
            "remarks": "Very Good",
          },
          {
            "code": "RME",
            "subject": "Religious & Moral Education",
            "classScore": "31",
            "examScore": "49",
            "totalScore": "80",
            "remarks": "Excellent",
          },
          {
            "code": "ICT",
            "subject": "Computing",
            "classScore": "25",
            "examScore": "44",
            "totalScore": "69",
            "remarks": "Good",
          },
        ],

      },
    ],
  };

  /// Strip unsupported characters (non-ASCII)
  String cleanText(String input) {
    return input.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
  }

  ///Calculate overall class positions
  Map<String, String> calculateClassPositions(List<Map<String, dynamic>> students) {
    final totals = students.map((student) {
      final subjectScores = student["subjects"]
          .map((s) => int.tryParse(s["totalScore"].toString()) ?? 0)
          .toList();

      final total = subjectScores.isNotEmpty
          ? subjectScores.reduce((a, b) => a + b)
          : 0;

      return {
        "id": student["id"] as String,
        "total": total,
      };
    }).toList();

    // Sort by total descending
    totals.sort((a, b) => (b["total"] as int).compareTo(a["total"] as int));

    // Assign positions
    final positions = <String, String>{};
    for (int i = 0; i < totals.length; i++) {
      positions[totals[i]["id"] as String] = (i + 1).toString();
    }

    return positions;
  }

  /// Calculate subject positions across class
  Map<String, Map<String, String>> calculateSubjectPositions(List<Map<String, dynamic>> students) {
    final subjectScores = <String, List<Map<String, dynamic>>>{};

    // Collect scores per subject code
    for (var student in students) {
      for (var s in student["subjects"]) {
        final code = s["code"];
        final total = int.tryParse(s["totalScore"].toString()) ?? 0;

        subjectScores.putIfAbsent(code, () => []);
        subjectScores[code]!.add({
          "id": student["id"],
          "score": total,
        });
      }
    }

    // Rank within each subject
    final result = <String, Map<String, String>>{};
    subjectScores.forEach((code, entries) {
      entries.sort((a, b) => (b["score"] as int).compareTo(a["score"] as int));

      for (int i = 0; i < entries.length; i++) {
        result.putIfAbsent(entries[i]["id"], () => {});
        result[entries[i]["id"]]![code] = (i + 1).toString();
      }
    });

    return result;
  }

  Future<void> generateReports() async {
    if (selectedSchool == null || selectedLevel == null || selectedTerm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select school, level and term")),
      );
      return;
    }

    final key = "$selectedSchool-$selectedLevel";
    final students = studentsData[key] ?? [];

    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No students found for this selection")),
      );
      return;
    }

    // Compute class and subject positions
    final classPositions = calculateClassPositions(students);
    final subjectPositions = calculateSubjectPositions(students);

    final pdf = pw.Document();

    for (var student in students) {
      final updatedSubjects = List<Map<String, dynamic>>.from(student["subjects"]).map((s) {
        final pos = subjectPositions[student["id"]]?[s["code"]] ?? '';
        return {
          ...s,
          "position": pos, //add subject position
        };
      }).toList();

      final report = ReportCardPrinter(
        schoolName: cleanText(selectedSchool!),
        reportTitle: "TERMINAL REPORT CARD",
        examSession: cleanText("END OF $selectedTerm EXAMINATION, 2023/2024"),
        logoAssetPathl: "assets/images/logo.png",
        logoAssetPathr: "assets/images/logo.png",
        studentName: cleanText(student["name"]),
        studentId: cleanText(student["id"]),
        studentClass: cleanText(student["class"]),
        noInClass: students.length.toString(),
        reOpeningDate: "10th September 2024",
        promotedTo: "Next Class",
        nextTermFees: "GHS705.00",
        subjects: updatedSubjects,
        areaOfStrength: "Mathematics and English",
        areaOfInterest: "Reading & Science Projects",
        weakness: "Needs improvement in handwriting",
        attendance: "95%",
        teacherRemarks: cleanText("A hardworking student."),
        headTeacherRemarks: cleanText("Promoted to the next class."),
        position: classPositions[student["id"]] ?? '',
      );

      final studentPage = await report.generatePage(PdfPageFormat.a4, "Report Card");
      pdf.addPage(studentPage);
    }

    final allBytes = await pdf.save();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => allBytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1D2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2F45),
        title: const Text(
          "Terminal Reports",
          style: TextStyle(color: Colors.white60),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white60),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSchool,
              decoration: const InputDecoration(
                labelText: "Select School",
                filled: true,
                fillColor: Colors.white70,
              ),
              items: schools
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => selectedSchool = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedLevel,
              decoration: const InputDecoration(
                labelText: "Select Level",
                filled: true,
                fillColor: Colors.white70,
              ),
              items: levels
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (val) => setState(() => selectedLevel = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedTerm,
              decoration: const InputDecoration(
                labelText: "Select Term",
                filled: true,
                fillColor: Colors.white70,
              ),
              items: terms
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => selectedTerm = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generate Reports"),
              onPressed: generateReports,
            ),
          ],
        ),
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../widgets/dropdown.dart';

class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key});
  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  final _formKey = GlobalKey<FormState>();
  String? selectedClass,
      selectedDepartment,
      selectedTerm,
      selectedAcademicYear,
      selectedAcademicyr;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<Myprovider>();
      provider.fetchclass();
      provider.fetchterms();
      provider.fetchacademicyear();
      provider.getdata();

    });
  }


  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF1B1D2A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF2D2F45),
              title: const Text("Terminal Reports",
                  style: TextStyle(color: Colors.white60)),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white60),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildDropdown(
                        value: selectedAcademicYear,
                        items: provider.academicyears.map((e) => e.name).toList(),
                        label: "Academic Year",
                        fillColor: Colors.white70,
                        onChanged: (val) {
                          setState(() {
                            final yr = provider.academicyears
                                .firstWhere((e) => e.name == val);
                            selectedAcademicyr = yr.idd;
                            selectedAcademicYear = yr.name;
                          });
                        },
                        validatorMsg: "Please select an academic year",
                      ),
                      const SizedBox(height: 16),
                      buildDropdown(
                        value: selectedTerm,
                        items: provider.terms.map((e) => e.name).toList(),
                        label: "Term",
                        fillColor: Colors.white70,
                        onChanged: (val) => setState(() => selectedTerm = val),
                        validatorMsg: "Please select a term",
                      ),
                      const SizedBox(height: 16),
                      buildDropdown(
                        value: selectedClass,
                        items: provider.classdata.map((e) => e.name).toList(),
                        label: "Class",
                        fillColor: Colors.white70,
                        onChanged: (val) {
                          setState(() {
                            selectedClass = val;
                            final classObj = provider.classdata
                                .firstWhere((c) => c.name == val);
                            selectedDepartment = classObj.department ?? "";
                          });
                        },
                        validatorMsg: "Please select a class",
                      ),
                      const SizedBox(height: 16),
                      if (selectedDepartment != null &&
                          selectedDepartment!.isNotEmpty)
                        TextFormField(
                          initialValue: selectedDepartment,
                          readOnly: true,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: "Department",
                            filled: true,
                            fillColor: Colors.white70,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // ElevatedButton.icon(
                      //   icon: const Icon(Icons.picture_as_pdf),
                      //   label: const Text("Generate Reports"),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.blueAccent,
                      //     foregroundColor: Colors.white,
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 32, vertical: 14),
                      //     textStyle: const TextStyle(fontSize: 16),
                      //   ),
                      //   onPressed: () async {
                      //     if (!_formKey.currentState!.validate()) return;
                      //
                      //     try {
                      //       await provider.generateReports(
                      //         level: selectedClass!,
                      //         term: selectedTerm!,
                      //         academyear:selectedAcademicYear!,
                      //       );
                      //     } catch (e) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                      //       );
                      //     }
                      //   },
                      // ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: _isGenerating
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text("Generate Reports"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _isGenerating
                            ? null // disable while generating
                            : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _isGenerating = true);

                          try {
                           await provider.generateReports(
                              level: selectedClass!,
                              term: selectedTerm!,
                              academyear: selectedAcademicYear!,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Reports generated successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                          catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("$e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          finally {
                            setState(() => _isGenerating = false);
                          }
                        },
                      ),

                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
