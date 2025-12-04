

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class ReportCardPrinter {
  final String schoolName;
  final String reportTitle;
  final String examSession;
  final String logoAssetPathl;
  final String logoAssetPathr;
  final String studentName;
  final String studentId;
  final String studentClass;
  final String noInClass;
  final String reOpeningDate;
  final String promotedTo;
  final String nextTermFees;
  final String position;
  final String? caweight;
  final String? examweight;
  final List<Map<String, dynamic>> subjects;

  final String? areaOfStrength;
  final String? areaOfInterest;
  final String? weakness;
  final String attendance;
  final String teacherRemarks;
  final String headTeacherRemarks;
  final String? academicYearAverage; // 🔹 optional

  ReportCardPrinter({
    required this.schoolName,
    required this.reportTitle,
    required this.examSession,
    required this.logoAssetPathl,
    required this.logoAssetPathr,
    required this.studentName,
    required this.studentId,
    required this.studentClass,
    required this.noInClass,
    required this.reOpeningDate,
    required this.promotedTo,
    required this.nextTermFees,
    required this.position,
    required this.subjects,
    this.areaOfStrength,
    this.areaOfInterest,
    this.weakness,
    this.caweight,
    this.examweight,
    required this.attendance,
    required this.teacherRemarks,
    required this.headTeacherRemarks,
    this.academicYearAverage,
  });

  num parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    if (v is String) return num.tryParse(v) ?? 0;
    return 0;
  }

  /// 🔹 Find subject(s) with highest score
  String getTopSubject() {
    if (subjects.isEmpty) return "N/A";
    final maxScore = subjects.map((s) => parseNum(s['totalScore'])).reduce((a, b) => a > b ? a : b);
    final tops = subjects.where((s) => parseNum(s['totalScore']) == maxScore).map((s) => s['subject']).toList();
    return tops.join(", ");
  }

  /// 🔹 Find subject(s) with lowest score
  String getWeakSubject() {
    if (subjects.isEmpty) return "N/A";
    final minScore = subjects.map((s) => parseNum(s['totalScore'])).reduce((a, b) => a < b ? a : b);
    final lows = subjects.where((s) => parseNum(s['totalScore']) == minScore).map((s) => s['subject']).toList();
    return lows.join(", ");
  }

  /// 🔹 Find mid-range subject (interest area = between top and weak)
  String getInterestSubject() {
    if (subjects.isEmpty) return "N/A";
    final sorted = subjects.toList()
      ..sort((a, b) => parseNum(b['totalScore']).compareTo(parseNum(a['totalScore'])));
    if (sorted.length < 3) return sorted.first['subject'];
    return sorted[sorted.length ~/ 2]['subject'];
  }

  Future<pw.Page> generatePage(PdfPageFormat format, String title) async {
    pw.MemoryImage? logoImagel;
    pw.MemoryImage? logoImager;
    try {
      final logoBytesl = await rootBundle.load(logoAssetPathl);
      logoImagel = pw.MemoryImage(logoBytesl.buffer.asUint8List());
      final logoBytesr = await rootBundle.load(logoAssetPathr);
      logoImager = pw.MemoryImage(logoBytesr.buffer.asUint8List());
    } catch (_) {
      logoImagel = null;
      logoImager = null;
    }

    final totalScoreValue =
    subjects.fold<num>(0, (sum, s) => sum + parseNum(s['totalScore']));
    final avgScoreValue =
    subjects.isNotEmpty ? totalScoreValue / subjects.length : 0;

    // 🔹 Dynamic areas if not provided
    final computedStrength = areaOfStrength == null || areaOfStrength!.isEmpty
        ? getTopSubject()
        : areaOfStrength!;
    final computedWeakness = weakness == null || weakness!.isEmpty
        ? getWeakSubject()
        : weakness!;
    final computedInterest = areaOfInterest == null || areaOfInterest!.isEmpty
        ? getInterestSubject()
        : areaOfInterest!;

    // 🔹 Font scaling
    double subjectFontSize;
    if (subjects.length <= 6) {
      subjectFontSize = 12;
    } else if (subjects.length <= 9) {
      subjectFontSize = 11;
    } else if (subjects.length <= 12) {
      subjectFontSize = 9.5;
    } else if (subjects.length <= 15) {
      subjectFontSize = 8.5;
    } else {
      subjectFontSize = 7.5;
    }

    double remarksFontSize =
    (teacherRemarks.length + headTeacherRemarks.length > 300)
        ? subjectFontSize - 1
        : subjectFontSize;

    final headers = [
      'CODE',
      'SUBJECT',
      'CLASS ($caweight%)',
      'EXAM ($examweight%)',
      'TOTAL (100%)',
      'SUB POS.',
      'REMARKS',
    ];

    //final PdfColor primaryColor = PdfColor.fromInt(0xFF1E88E5);
    PdfColor primaryColor = PdfColor.fromInt(0xFFE0E0E0);
    return pw.Page(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            pw.Container(
              width: double.infinity,
              padding:
              const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: const pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(15),
                  bottomRight: pw.Radius.circular(15),
                ),
              ),
              child: pw.Row(
                children: [
                  if (logoImagel != null)
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(image: logoImagel),
                      ),
                    ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          schoolName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          reportTitle,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          examSession,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (logoImager != null)
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(image: logoImager),
                      ),
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // 🔹 Student Info
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text("Class:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text(studentClass),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text("No. in class:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text(noInClass),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text("Re-Opening:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text(reOpeningDate),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text("Position:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text(position),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text("ID:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text(studentId),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text("Promoted To:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text(promotedTo),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text("Name:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text(studentName),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text("Next Term Fees:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: pw.Text(nextTermFees),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 10),

            // 🔹 Subjects Table
            pw.Table.fromTextArray(
              headers: headers,
              data: subjects.map((s) {
                return [
                  s['code'].toString(),
                  s['subject'].toString(),
                  s['classScore'].toString(),
                  s['examScore'].toString(),
                  s['totalScore'].toString(),
                  s['position'].toString(),
                  s['remarks'].toString(),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
               // color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: subjectFontSize,
              ),
              headerDecoration: pw.BoxDecoration(
               //   color: primaryColor
              ),
              cellAlignment: pw.Alignment.center,
              cellStyle: pw.TextStyle(fontSize: subjectFontSize),
              border: pw.TableBorder.all(width: 0.3, color: PdfColors.grey),
            ),

            pw.SizedBox(height: 10),

            // 🔹 Totals / Average
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("TOTAL: ${totalScoreValue.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("AVERAGE: ${avgScoreValue.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (academicYearAverage != null)
                  pw.Text(
                    "YEAR AVG: ${(num.tryParse(academicYearAverage!) ?? 0).toStringAsFixed(2)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
              ],
            ),

            pw.SizedBox(height: 10),

            // 🔹 Remarks Section
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey, width: 0.5),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Area of strength: $computedStrength",
                      style: pw.TextStyle(fontSize: remarksFontSize)),
                  pw.Text("Area of interest: $computedInterest",
                      style: pw.TextStyle(fontSize: remarksFontSize)),
                  pw.Text("Weakness: $computedWeakness",
                      style: pw.TextStyle(fontSize: remarksFontSize)),
                  pw.Text("Attendance: $attendance",
                      style: pw.TextStyle(fontSize: remarksFontSize)),
                  pw.SizedBox(height: 4),
                  pw.Text("Teacher's Remarks: $teacherRemarks",
                      style: pw.TextStyle(fontSize: remarksFontSize)),
                  pw.Text("Head Teacher's Remarks: $headTeacherRemarks",
                      style: pw.TextStyle(fontSize: remarksFontSize)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
