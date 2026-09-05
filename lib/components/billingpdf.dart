import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BillingReportPrinter {
  final String schoolName;
  final String schoolAddress;
  final String schoolEmail;
  final String schoolWebsite;
  final String schoolPhone;
  final String logoAssetPath;

  final String term;
  final String feeName;
  final String targetGroup;
  final List<Map<String, dynamic>> students;
  final String totalAmount;

  BillingReportPrinter({
    required this.schoolName,
    required this.schoolAddress,
    required this.schoolEmail,
    required this.schoolWebsite,
    required this.schoolPhone,
    required this.logoAssetPath,
    required this.term,
    required this.feeName,
    required this.targetGroup,
    required this.students,
    required this.totalAmount,
  });

  Future<Uint8List> generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(title: title, author: 'kologsoft');

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load(logoAssetPath);
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      logoImage = null;
    }

    final primaryColor = PdfColor.fromHex("#00496d");
    final secondaryColor = PdfColor.fromHex("#4a5568");
    final today = DateFormat('dd MMM yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        height: 50,
                        width: 50,
                        child: pw.Image(logoImage),
                      )
                    else
                      pw.Container(
                        height: 50,
                        width: 50,
                        color: primaryColor,
                        child: pw.Center(
                          child: pw.Text("Logo", style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                        ),
                      ),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(schoolName.toUpperCase(),
                            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.Text("Empowering Education",
                            style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: secondaryColor)),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(schoolAddress, style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(schoolPhone, style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(schoolEmail, style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(schoolWebsite, style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1.5, color: primaryColor),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.5, color: primaryColor),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(thickness: 0.5, color: PdfColors.grey300),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Billing Report - $schoolName", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                pw.Text("Generated: $today", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
              ],
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 30),
          pw.Center(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primaryColor, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                "OFFICIAL BILLING STATEMENT",
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 2),
              ),
            ),
          ),
          pw.SizedBox(height: 30),

          // Summary Section
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildMetaItem("Fee Category", feeName, primaryColor),
                    _buildMetaItem("Academic Term", term, primaryColor),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildMetaItem("Target Group", targetGroup, primaryColor),
                    _buildMetaItem("Statement ID", "BILL-${DateTime.now().millisecondsSinceEpoch}", primaryColor),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          // Students Table - zebra striped
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FixedColumnWidth(100),
              2: const pw.FlexColumnWidth(),
              3: const pw.FixedColumnWidth(60),
              4: const pw.FixedColumnWidth(100),
            },
            children: [
              // Header
              pw.TableRow(
                children: [
                  _headerCell("#", color: primaryColor),
                  _headerCell("STUDENT ID", color: primaryColor),
                  _headerCell("NAME", color: primaryColor),
                  _headerCell("SEX", color: primaryColor),
                  _headerCell("AMOUNT (GHS)", color: primaryColor, align: pw.TextAlign.right),
                ],
              ),
              // Data Rows
              ...List.generate(students.length, (index) {
                final s = students[index];
                final isEven = index % 2 == 0;
                final rowColor = isEven ? PdfColors.white : PdfColors.grey100;
                return pw.TableRow(
                  children: [
                    _dataCell((index + 1).toString(), color: rowColor),
                    _dataCell(s['studentId'] ?? '', color: rowColor),
                    _dataCell(s['name'] ?? '', color: rowColor),
                    _dataCell((s['sex'] ?? '').toString().toUpperCase(), color: rowColor),
                    _dataCell(s['amount'] ?? '0.00', color: rowColor, align: pw.TextAlign.right, weight: pw.FontWeight.bold),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 30),

          // Summary Footer
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      children: [
                        _summaryRow("Student Count:", students.length.toString()),
                        pw.SizedBox(height: 5),
                        pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("GRAND TOTAL:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor, fontSize: 11)),
                            pw.Text("GHS $totalAmount", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 50),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(width: 180, height: 0.5, color: PdfColors.black),
                  pw.SizedBox(height: 4),
                  pw.Text("Prepared By", style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(width: 180, height: 0.5, color: PdfColors.black),
                  pw.SizedBox(height: 4),
                  pw.Text("Authorized Signature & Stamp", style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              "This is a system-generated document and is valid only with an official school stamp.",
              style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  pw.Widget _buildMetaItem(String label, String value, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: "$label: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey700)),
            pw.TextSpan(text: value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  pw.Widget _headerCell(String text, {required PdfColor color, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      color: color,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9)),
    );
  }

  pw.Widget _dataCell(String text, {required PdfColor color, pw.TextAlign align = pw.TextAlign.left, pw.FontWeight? weight}) {
    return pw.Container(
      color: color,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(fontSize: 9, fontWeight: weight ?? pw.FontWeight.normal)),
    );
  }

  pw.Widget _summaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
}
