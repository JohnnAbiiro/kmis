
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

class TranscriptPrinter {
  final String schoolName;
  final String address;
  final String logoAssetLeft;
  final String logoAssetRight;

  final String studentName;
  final String programme;
  final String startDate;
  final String level;
  final String term;

  final List<List<String>> gradeInterpretation;
  final List<Map<String, dynamic>> courses;

  final String totalScore;
  final String averageScore;

  TranscriptPrinter({
    required this.schoolName,
    required this.address,
    required this.logoAssetLeft,
    required this.logoAssetRight,
    required this.studentName,
    required this.programme,
    required this.startDate,
    required this.level,
    required this.term,
    required this.gradeInterpretation,
    required this.courses,
    required this.totalScore,
    required this.averageScore,
  });

  Future<pw.Page> generatePage(PdfPageFormat format) async {
    pw.MemoryImage? logoL;
    pw.MemoryImage? logoR;

    try {
      final leftBytes = await rootBundle.load(logoAssetLeft);
      logoL = pw.MemoryImage(leftBytes.buffer.asUint8List());

      final rightBytes = await rootBundle.load(logoAssetRight);
      logoR = pw.MemoryImage(rightBytes.buffer.asUint8List());
    } catch (_) {}

    final PdfColor headerColor = PdfColor.fromInt(0xFF1E88E5);

    return pw.Page(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: headerColor,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                children: [
                  if (logoL != null)
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(image: logoL),
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
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          "TRANSCRIPT",
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          address,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (logoR != null)
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(image: logoR),
                      ),
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 15),

            // -----------------------------------------------------------
            // LETTER
            // -----------------------------------------------------------
            pw.Text("Dear Sir/Madam,", style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 8),

            // pw.Text(
            //   "I have the pleasure to forward to you the transcript of "
            //       "$studentName who was trained at the $schoolName from "
            //       "$startDate and studied $programme for your perusal and necessary action.",
            //   style: pw.TextStyle(fontSize: 12),
            //   textAlign: pw.TextAlign.justify,
            // ),

            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: "I have the pleasure to forward to you the transcript of ",
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.TextSpan(
                    text: studentName,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.TextSpan(
                    text: " who was trained at the $schoolName from $startDate and studied $programme for your perusal and necessary action.",
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 15),

            pw.Text(
              "LEVEL: $level     ||     TERM: $term",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 15),

            // -----------------------------------------------------------
            // 1️⃣ COURSE SUMMARY (MOVED TO TOP)
            // -----------------------------------------------------------
            pw.Text(
              "COURSE SUMMARY",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            pw.Table.fromTextArray(
              headers: ["#", "Course Code", "Course Title", "Mark"],
              data: courses.asMap().entries.map((e) {
                final i = e.key;
                final c = e.value;
                return [
                  "${i + 1}",
                  c["code"],
                  c["title"],
                  c["mark"],
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: pw.BoxDecoration(color: headerColor),
              border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
              cellStyle: pw.TextStyle(fontSize: 10),
            ),

            pw.SizedBox(height: 8),

            pw.Text("TOTAL: $totalScore",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text("AVERAGE SCORE: $averageScore",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

            pw.SizedBox(height: 20),

            // -----------------------------------------------------------
            // 2️⃣ INTERPRETATION OF GRADES
            // -----------------------------------------------------------
            pw.Text(
              "INTERPRETATION OF GRADES",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            pw.Table.fromTextArray(
              headers: ["#", "Grade", "Min", "Max", "Remarks"],
              data: gradeInterpretation,
              headerDecoration: pw.BoxDecoration(color: headerColor),
              headerStyle: pw.TextStyle(
                  color: PdfColors.white, fontWeight: pw.FontWeight.bold),
              border: pw.TableBorder.all(color: PdfColors.grey, width: .5),
              cellStyle: pw.TextStyle(fontSize: 10),
            ),

            pw.Spacer(),

            // -----------------------------------------------------------
            // SIGNATURE
            // -----------------------------------------------------------
            pw.Column(
              children: [
                pw.Container(width: 160, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 4),
                pw.Text("PRINCIPAL"),
              ],
            ),
          ],
        );
      },
    );
  }
}
