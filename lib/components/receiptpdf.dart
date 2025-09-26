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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          // Header Row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                height: 60,
                width: 60,
                color: primaryColor,
                child: pw.Center(
                  child: logoImage != null
                      ? pw.Image(logoImage)
                      : pw.Text(
                    "Logo",
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(schoolAddress, style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(schoolEmail.toUpperCase(),
                      style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(schoolWebsite.toUpperCase(),
                      style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(schoolPhone, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),
          pw.Container(height: 30, color: primaryColor),
          pw.SizedBox(height: 60),

          // Title
          pw.Center(
            child: pw.Text(
              "${schoolName.toUpperCase()} SCHOOL FEES RECEIPT",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          // Date & Receipt
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  text: "Date: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  children: [
                    pw.TextSpan(
                      text: date,
                      style:  pw.TextStyle(fontWeight: pw.FontWeight.normal),
                    ),
                  ],
                ),
              ),
              pw.RichText(
                text: pw.TextSpan(
                  text: "Receipt No.: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  children: [
                    pw.TextSpan(
                      text: receiptNo,
                      style:  pw.TextStyle(fontWeight: pw.FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.Divider(height: 40, color: primaryColor),

          // Details
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  text: "Received From:\n",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  children: [
                    pw.TextSpan(
                      text: receivedFrom,
                      style:  pw.TextStyle(fontWeight: pw.FontWeight.normal),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.RichText(
                text: pw.TextSpan(
                  text: "Payment Type: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  children: [
                    pw.TextSpan(
                      text: paymentType,
                      style:  pw.TextStyle(fontWeight: pw.FontWeight.normal),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.RichText(
                text: pw.TextSpan(
                  text: "Payment For: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  children: [
                    pw.TextSpan(
                      text: paymentFor,
                      style:  pw.TextStyle(fontWeight: pw.FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Fees Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text("Description",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text("Amount (GHC)",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              ...records.entries.map((e) {
                return pw.TableRow(children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(e.key)),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e.value.toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                      )),
                ]);
              }).toList(),
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Total",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(total.toString(),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),
          pw.RichText(
            text: pw.TextSpan(
              text: "Payment Date: ",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              children: [
                pw.TextSpan(
                  text: paymentDate,
                  style:  pw.TextStyle(fontWeight: pw.FontWeight.normal),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),
          pw.Text(
            "Thank you for your payment. For any further inquiries, please contact us at $schoolEmail or call $schoolPhone.",
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }
}
