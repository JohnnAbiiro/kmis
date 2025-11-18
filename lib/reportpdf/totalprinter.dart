
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

class SubjectscorePrinter {
  final String schoolName;
  final String reportTitle;
  final String reportTitle1;
  final String className;
  final String logoAssetPathLeft;
  final String logoAssetPathRight;
  final List<Map<String, String>> rows;
  final String totalMarks;
  final Map<String, String>? criteriaHeaders;

  final bool showRank;

  SubjectscorePrinter({
    required this.schoolName,
    required this.reportTitle,
    required this.reportTitle1,
    required this.className,
    required this.rows,
    required this.totalMarks,
    required this.logoAssetPathLeft,
    required this.logoAssetPathRight,
    this.criteriaHeaders,
    this.showRank = true,
  });

  Future<void> printOrPreview(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        name: '${schoolName}_STUDENT_SCORE_REPORT.pdf',
        onLayout: (format) async => await _buildPdf(format),
      );
    } catch (e) {
      debugPrint("PDF Generation Error: $e");
    }
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final pdf = pw.Document(title: '${schoolName}_STUDENT_SCORE_REPORT');

    // Load logos
    pw.MemoryImage? leftLogo;
    pw.MemoryImage? rightLogo;

    try {
      final leftBytes = await rootBundle.load(logoAssetPathLeft);
      leftLogo = pw.MemoryImage(leftBytes.buffer.asUint8List());
    } catch (_) {}

    try {
      final rightBytes = await rootBundle.load(logoAssetPathRight);
      rightLogo = pw.MemoryImage(rightBytes.buffer.asUint8List());
    } catch (_) {}

    // Extract criteria
    final criteria = <String>[];
    if (rows.isNotEmpty) {
      criteria.addAll(
        rows.first.keys.where(
              (k) => k != "name" && k != "total" && k != "code" && k != "rank",
        ),
      );
    }

    final List<Map<String, String>> finalRows = rows;

    // Build table data
    final tableData = List.generate(finalRows.length, (i) {
      final row = finalRows[i];

      final cells = [
        (row['name'] ?? '').toUpperCase(),
        ...criteria.map((c) => row[c] ?? ''),
        row['total'] ?? '',
      ];

      if (showRank) {
        cells.add(row['rank'] ?? '');
      }

      return cells;
    });

    // Headers
    final headers = [
      "#",
      "STUDENT NAME",
      ...criteria.map((c) =>
      criteriaHeaders?[c]?.toUpperCase() ?? c.toUpperCase()),
      "TOTAL ($totalMarks)",
    ];

    if (showRank) {
      headers.add("RANK");
    }

    final PdfColor primaryColor = PdfColor.fromInt(0xFF1E88E5);
    final PdfColor accentColor = PdfColor.fromInt(0xFFF47820);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(20),
        build: (_) => [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 15),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (leftLogo != null)
                  pw.Container(
                    width: 55,
                    height: 55,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      image: pw.DecorationImage(image: leftLogo),
                    ),
                  )
                else
                  pw.SizedBox(width: 55),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        schoolName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        reportTitle,
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        "CLASS: $className",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (rightLogo != null)
                  pw.Container(
                    width: 55,
                    height: 55,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      image: pw.DecorationImage(image: rightLogo),
                    ),
                  )
                else
                  pw.SizedBox(width: 55),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Table(
            border: pw.TableBorder.all(color: primaryColor, width: 0.6),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.4),
              1: const pw.FlexColumnWidth(3.5),
              for (int i = 0; i < criteria.length; i++)
                i + 1: const pw.FlexColumnWidth(1.5),
              criteria.length + 1: const pw.FlexColumnWidth(1.8),
              if (showRank)
                criteria.length + 2: const pw.FlexColumnWidth(1.0),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: accentColor),
                children: headers
                    .map(
                      (h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Center(
                      child: pw.Text(
                        h,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),

              for (int i = 0; i < tableData.length; i++)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i == 0 ? PdfColors.yellow100 : PdfColors.white,
                  ),
                  children: [
                    // NUMBERING COLUMN
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(
                          "${i + 1}",     // ← Adds numbering
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                    // EXISTING CELLS
                    ...List.generate(tableData[i].length, (colIndex) {
                      final text = tableData[i][colIndex];
                      pw.Widget child;

                      if (colIndex == 0) {
                        // student name
                        child = pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(
                            text,
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        );
                      } else if (showRank &&
                          colIndex == tableData[i].length - 1) {
                        child = pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            text,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        );
                      } else {
                        child = pw.Center(
                          child: pw.Text(
                            text,
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        );
                      }

                      return pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: child,
                      );
                    }),
                  ],
                ),
            ],
          ),

          pw.SizedBox(height: 20),

          pw.Center(
            child: pw.Text(
              "Powered by Kologsoft",
              style: pw.TextStyle(
                fontSize: 10,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}