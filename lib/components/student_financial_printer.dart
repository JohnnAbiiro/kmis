import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../controller/dbmodels/ledgerModel.dart';

class StudentFinancialPrinter {
  final String schoolName;
  final String schoolAddress;
  final String schoolEmail;
  final String schoolPhone;
  final String logoAssetPath;
  final String studentName;
  final String studentId;
  final String level;
  final List<LedgerTransaction> transactions;
  final double currentBalance;
  final double totalBilled;
  final double totalPaid;

  StudentFinancialPrinter({
    required this.schoolName,
    required this.schoolAddress,
    required this.schoolEmail,
    required this.schoolPhone,
    required this.logoAssetPath,
    required this.studentName,
    required this.studentId,
    required this.level,
    required this.transactions,
    required this.currentBalance,
    required this.totalBilled,
    required this.totalPaid,
  });

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document(title: "Financial Statement - $studentName");

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load(logoAssetPath);
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      logoImage = null;
    }

    final primaryColor = PdfColor.fromHex("#00496d");
    final secondaryColor = PdfColor.fromHex("#4a5568");

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(children: [
                  if (logoImage != null) pw.Container(height: 50, width: 50, child: pw.Image(logoImage)),
                  pw.SizedBox(width: 10),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(schoolName.toUpperCase(), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text("Student Financial Statement", style: pw.TextStyle(fontSize: 10, color: secondaryColor)),
                    ],
                  ),
                ]),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(schoolAddress, style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(schoolPhone, style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: primaryColor),
            pw.SizedBox(height: 10),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(thickness: 0.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Generated on ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 7)),
                pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: const pw.TextStyle(fontSize: 7)),
              ],
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _infoRow("Student:", studentName),
                _infoRow("Student ID:", studentId),
                _infoRow("Level:", level),
              ]),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  _summaryRow("Total Billed:", totalBilled),
                  _summaryRow("Total Paid:", totalPaid),
                  pw.Divider(thickness: 1),
                  _summaryRow("Current Balance:", currentBalance, isBold: true, color: currentBalance > 0 ? PdfColors.red : PdfColors.green),
                ]),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ["Date", "Activity", "Description", "Debit (Billed)", "Credit (Paid)"],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
            headerDecoration: pw.BoxDecoration(color: primaryColor),
            cellStyle: const pw.TextStyle(fontSize: 8),
            data: transactions.map((tx) {
              return [
                DateFormat('dd/MM/yy').format(tx.createdAt),
                tx.activityType,
                tx.feeName.isNotEmpty ? tx.feeName : tx.note,
                tx.debitValue > 0 ? NumberFormat("#,##0.00").format(tx.debitValue) : "",
                tx.creditValue > 0 ? NumberFormat("#,##0.00").format(tx.creditValue) : "",
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return await pdf.save();
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.RichText(text: pw.TextSpan(children: [
        pw.TextSpan(text: "$label ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
        pw.TextSpan(text: value, style: const pw.TextStyle(fontSize: 9)),
      ])),
    );
  }

  pw.Widget _summaryRow(String label, double value, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Text(NumberFormat("#,##0.00").format(value), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: color)),
      ]),
    );
  }
}
