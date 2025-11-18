import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

class SubjectscorebestPrinter {
  final String schoolName;
  final String reportTitle;
  final String reportTitle1;
  final String className;
  final String logoAssetPathLeft;
  final String logoAssetPathRight;
  final List<Map<String, dynamic>> rows;

  SubjectscorebestPrinter({
    required this.schoolName,
    required this.reportTitle,
    required this.reportTitle1,
    required this.className,
    required this.rows,
    required this.logoAssetPathLeft,
    required this.logoAssetPathRight,
  });

  Future<void> printOrPreview(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        name: '${schoolName}_BEST_SUBJECT.pdf',
        onLayout: (format) async => await _buildPdf(format),
      );
    } catch (e) {
      debugPrint("PDF Generation Error: $e");
    }
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final pdf = pw.Document(title: '${schoolName}_BEST_SUBJECT');

    // Load Logos
    pw.MemoryImage? leftLogo;
    pw.MemoryImage? rightLogo;

    try {
      final bytes = await rootBundle.load(logoAssetPathLeft);
      leftLogo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    try {
      final bytes = await rootBundle.load(logoAssetPathRight);
      rightLogo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    // TABLE HEADERS
    final headers = [
      "#",
      "STUDENT ID",
      "STUDENT NAME",
      "TOTAL",
      "RANK",
    ];

    // TABLE ROWS
    final tableData = rows.map((r) {
      return [
        "",
        r["studentId"] ?? "",
        r["studentName"] ?? "",
        r["total"] ?? "",
        r["rank"] ?? ""
      ];
    }).toList();

    final primaryColor = PdfColor.fromInt(0xFF1E88E5);
    final accentColor = PdfColor.fromInt(0xFFF47820);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        pageFormat: format,
        build: (context) => [
          // ================= HEADER =====================
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 15),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                leftLogo != null
                    ? pw.Container(
                  width: 55,
                  height: 55,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    image: pw.DecorationImage(image: leftLogo),
                  ),
                )
                    : pw.SizedBox(width: 55),

                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        schoolName.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        reportTitle1.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        reportTitle,
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        className,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                rightLogo != null
                    ? pw.Container(
                  width: 55,
                  height: 55,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    image: pw.DecorationImage(image: rightLogo),
                  ),
                )
                    : pw.SizedBox(width: 55),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ================= TABLE =====================
          pw.Table(
            border: pw.TableBorder.all(color: primaryColor, width: 0.6),
            columnWidths: {
              0: pw.FlexColumnWidth(0.5), // #
              1: pw.FlexColumnWidth(1.5), // ID
              2: pw.FlexColumnWidth(3), // NAME
              3: pw.FlexColumnWidth(1.5), // TOTAL
              4: pw.FlexColumnWidth(1.2), // RANK
            },
            children: [
              // HEADER ROW
              pw.TableRow(
                decoration: pw.BoxDecoration(color: accentColor),
                children: headers.map((h) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Center(
                      child: pw.Text(
                        h,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // DATA ROWS
              for (int i = 0; i < tableData.length; i++)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i == 0 ? PdfColors.amber100 : PdfColors.white,
                  ),
                  children: [
                    pw.Center(
                      child: pw.Text(
                        "${i + 1}",
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),

                    // STUDENT ID — LEFT ALIGNED
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          tableData[i][1],
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ),

                    // STUDENT NAME — LEFT ALIGNED
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          tableData[i][2],
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ),

                    // TOTAL — CENTERED
                    pw.Center(
                      child: pw.Text(
                        tableData[i][3],
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),

                    // RANK — CENTERED
                    pw.Center(
                      child: pw.Text(
                        tableData[i][4],
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                )
            ],
          ),

          pw.SizedBox(height: 20),

          pw.Center(
            child: pw.Text(
              "Powered by Kologsoft",
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          )
        ],
      ),
    );

    return pdf.save();
  }
}
