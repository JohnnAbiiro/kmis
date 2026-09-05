import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SchoolReceiptPrinter {
  final String schoolName;
  final String schoolAddress;
  final String schoolEmail;
  final String schoolWebsite;
  final String schoolPhone;
  final String logoAssetPath;

  final String date;
  final String receiptNo;
  final String receivedFrom;
  final String paymentType;
  final String paymentFor;
  final String paymentDate;
  final Map<String, dynamic> records;
  final String total;
  final String? outstandingBalance;
  final String? totalBilled;
  final String? totalPaid;

  SchoolReceiptPrinter({
    required this.schoolName,
    required this.schoolAddress,
    required this.schoolEmail,
    required this.schoolWebsite,
    required this.schoolPhone,
    required this.logoAssetPath,
    required this.date,
    required this.receiptNo,
    required this.receivedFrom,
    required this.paymentType,
    required this.paymentFor,
    required this.paymentDate,
    required this.records,
    required this.total,
    this.outstandingBalance,
    this.totalBilled,
    this.totalPaid,
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
    final accentColor = PdfColor.fromHex("#e53e3e");

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
                        height: 55,
                        width: 55,
                        child: pw.Image(logoImage),
                      )
                    else
                      pw.Container(
                        height: 55,
                        width: 55,
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.Center(
                          child: pw.Text("LOGO", style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        ),
                      ),
                    pw.SizedBox(width: 15),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(schoolName.toUpperCase(),
                            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.Text("Official Payment Receipt",
                            style: pw.TextStyle(fontSize: 9, color: secondaryColor, fontStyle: pw.FontStyle.italic)),
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
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("KMIS - Professional School Management System", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
              ],
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 25),
          // Receipt ID & Date Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("RECEIPT NO.", style: pw.TextStyle(fontSize: 8, color: secondaryColor, fontWeight: pw.FontWeight.bold)),
                  pw.Text(receiptNo, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("DATE ISSUED", style: pw.TextStyle(fontSize: 8, color: secondaryColor, fontWeight: pw.FontWeight.bold)),
                  pw.Text(date, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 35),

          // Core Info Container
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              border: pw.Border.all(color: PdfColors.grey200),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _metaInfo("RECEIVED FROM", receivedFrom),
                    pw.SizedBox(height: 12),
                    _metaInfo("PAYMENT METHOD", paymentType),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _metaInfo("ACADEMIC TERM", paymentFor, align: pw.TextAlign.right),
                    pw.SizedBox(height: 12),
                    _metaInfo("PAYMENT DATE", paymentDate, align: pw.TextAlign.right),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 40),

          // Items Table
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FixedColumnWidth(140),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: primaryColor),
                children: [
                  _headerCell("DESCRIPTION"),
                  _headerCell("AMOUNT (GHS)", align: pw.TextAlign.right),
                ],
              ),
              ...records.entries.map((e) {
                final isEven = records.keys.toList().indexOf(e.key) % 2 == 0;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: isEven ? PdfColors.white : PdfColors.grey50),
                  children: [
                    _dataCell(e.key),
                    _dataCell(e.value.toStringAsFixed(2), align: pw.TextAlign.right, weight: pw.FontWeight.bold),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 25),

          // Financial Summary Section
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("REMARKS:", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                    pw.SizedBox(height: 6),
                    pw.Text(paymentFor, style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
                    pw.SizedBox(height: 20),
                    pw.Text("SIGNATURE:", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                    pw.SizedBox(height: 20),
                    pw.Container(width: 150, height: 0.5, color: PdfColors.grey600),
                    pw.SizedBox(height: 4),
                    pw.Text("School Accountant", style: const pw.TextStyle(fontSize: 7)),
                  ],
                ),
              ),
              pw.SizedBox(width: 40),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _summaryLine("SUBTOTAL PAID", "GHS $total", primaryColor, isMain: true),
                  pw.SizedBox(height: 8),
                  pw.SizedBox(width: 200, child: pw.Divider(thickness: 0.5, color: PdfColors.grey300)),
                  pw.SizedBox(height: 8),
                  if (totalBilled != null) _summaryLine("TOTAL BILLED TO DATE", "GHS $totalBilled", PdfColors.black),
                  if (totalPaid != null) _summaryLine("TOTAL PAID TO DATE", "GHS $totalPaid", PdfColors.black),
                  pw.SizedBox(height: 12),
                  if (outstandingBalance != null && outstandingBalance != "0.00" && outstandingBalance != "-1.00")
                    _summaryLine("OUTSTANDING BALANCE", "GHS $outstandingBalance", accentColor, isMain: true)
                  else if (outstandingBalance == "0.00")
                    _summaryLine("ACCOUNT STATUS", "FULLY SETTLED", PdfColor.fromHex("#008000"), isMain: true),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 60),

          // Stamp and Disclaimer
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Issued on: $date", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.Container(
                width: 100,
                height: 50,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 1, style: pw.BorderStyle.dashed),
                ),
                child: pw.Center(child: pw.Text("STAMP HERE", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400))),
              ),
            ],
          ),

          pw.SizedBox(height: 40),
          pw.Center(
            child: pw.Text("Thank you for your payment. This is an official system-generated document.", 
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
          ),
        ],
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  pw.Widget _metaInfo(String label, String value, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Column(
      crossAxisAlignment: align == pw.TextAlign.right ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _summaryLine(String label, String value, PdfColor color, {bool isMain = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text("$label: ", style: pw.TextStyle(fontSize: isMain ? 10 : 8, fontWeight: isMain ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
        pw.SizedBox(width: 15),
        pw.Text(value, style: pw.TextStyle(fontSize: isMain ? 12 : 10, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  pw.Widget _headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
    );
  }

  pw.Widget _dataCell(String text, {pw.TextAlign align = pw.TextAlign.left, pw.FontWeight? weight}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(fontSize: 10, fontWeight: weight ?? pw.FontWeight.normal)),
    );
  }
}
