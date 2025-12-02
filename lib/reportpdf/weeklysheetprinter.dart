
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class WeeklyScoreSheetPrinter {
  final String eventTitle;
  final String subtitle;
  final String zone;
  final String episode;
  final String division;
  final String logoAssetPath;
  final String? totalMarks;
  final List<Map<String, dynamic>> rows;

  WeeklyScoreSheetPrinter({
    required this.eventTitle,
    required this.subtitle,
    required this.zone,
    required this.episode,
    required this.division,
    required this.logoAssetPath,
    this.totalMarks,
    required this.rows,
  });

  String formatNum(dynamic value, {int decimals = 2}) {
    try {
      if (value == null) return '0';
      final num? parsed = num.tryParse(value.toString());
      if (parsed == null) return '0';
      return parsed.toStringAsFixed(decimals);
    } catch (_) {
      return '0';
    }
  }

  // Treat 0, 0.0, "0", "00", "000" (any zero-like) as zero.
  bool _isZeroLike(dynamic v) {
    try {
      if (v == null) return true;
      final s = v.toString().trim();
      if (s.isEmpty) return true;
      final normalized = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
      if (normalized.isEmpty) return true;
      final parsed = double.tryParse(normalized) ?? 0.0;
      return parsed == 0.0;
    } catch (_) {
      return true;
    }
  }

  Future<List<int>> generatePdf(PdfPageFormat format,title) async {
    final pdf = pw.Document(title: title);


    // --- Load logo ---
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load(logoAssetPath);
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      logoImage = null;
    }

    // --- Sort rows safely ---
    List<Map<String, dynamic>> sortedRows = [...rows];
    try {
      sortedRows.sort((a, b) {
        final numA = num.tryParse(a['total']?.toString() ?? '0') ?? 0;
        final numB = num.tryParse(b['total']?.toString() ?? '0') ?? 0;
        return numB.compareTo(numA);
      });
    } catch (_) {
      // if sorting fails, just keep unsorted rows
      sortedRows = [...rows];
    }

    // --- Filter rows safely ---
    List<Map<String, dynamic>> filteredRows;
    try {
      filteredRows = sortedRows.where((r) {
        final tjsZero = _isZeroLike(r['tjs']);
        final votesSource = r['cwv'] ?? r['votes'] ?? r['votes40'];
        final votesZero = _isZeroLike(votesSource);
        return !(tjsZero && votesZero);
      }).toList();
    } catch (_) {
      filteredRows = [];
    }

    // --- Build display rows safely ---
    final displayRows = <List<String>>[];
    try {
      for (var i = 0; i < filteredRows.length; i++) {
        final r = filteredRows[i];
        displayRows.add(<String>[
          (i + 1).toString(),
          (r['name'] ?? '').toString().toUpperCase(),
          (r['code'] ?? '').toString().toUpperCase(),
          formatNum(r['tjs'], decimals: 0),
          formatNum(r['judge60']),
         // formatNum(r['cvw'], decimals: 0),
         // formatNum(r['votes40']),
          formatNum(r['total']),
        ]);
      }
    } catch (_) {
      // if row building fails, leave it empty
    }

   // final headers = <String>['#', 'NAMES','CODE', 'TJS', '60%', 'CWV', '40%', 'TOTAL'];
    final headers = <String>['#', 'NAMES','CODE', 'TJS', '60%',  'TOTAL'];
    final PdfColor secondaryColor = PdfColor.fromHex("#F57C00");
    final PdfColor primaryColor = PdfColor.fromHex("#1E88E5"); // Blue
    final PdfColor brandColor = PdfColor.fromInt(0xFFF47820);

    // --- Build PDF Page ---
    try {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: format.copyWith(marginLeft: 15, marginRight: 15),
          build: (context) => [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: const pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(12),
                  bottomRight: pw.Radius.circular(12),
                ),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoImage != null)
                    pw.Container(
                      width: 55,
                      height: 55,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(image: logoImage),
                      ),
                    ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(eventTitle.toUpperCase(),
                            style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white)),
                        pw.SizedBox(height: 2),
                        pw.Text(subtitle.toUpperCase(),
                            style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white)),
                        pw.SizedBox(height: 4),
                        pw.Text('${division.toUpperCase()} CATEGORY',
                            style: const pw.TextStyle(
                                fontSize: 12, color: PdfColors.white)),
                            /*  pw.Text("${zone.toUpperCase()}",
                            style: const pw.TextStyle(
                                fontSize: 11, color: PdfColors.white)),*/
                        pw.SizedBox(height: 10.0),
                        // pw.Text("EPISODE: ${episode.toUpperCase()}",
                        //     style: const pw.TextStyle(
                        //         fontSize: 11, color: PdfColors.white)),
                       // pw.Text("TOTAL MARKS: ${totalMarks.toUpperCase()}",
                       //     style: const pw.TextStyle(
                       //         fontSize: 11, color: PdfColors.white)),
                      ],
                    ),
                  ),
                  if (logoImage != null)
                    pw.Container(
                      width: 55,
                      height: 55,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(image: logoImage),
                      ),
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
              columnWidths: {0: const pw.FixedColumnWidth(25), 1: const pw.FlexColumnWidth(2.5)},
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: brandColor),
                  children: headers.map((h) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(h,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              fontSize: 11),
                          textAlign: pw.TextAlign.center),
                    );
                  }).toList(),
                ),

                // Data rows
                for (var i = 0; i < displayRows.length; i++)
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: i < 1 ? PdfColors.yellow100 : PdfColors.white),
                    children: [
                      for (var j = 0; j < displayRows[i].length; j++)
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                          child: pw.Text(displayRows[i][j],
                              style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
                              textAlign: j == 1 ? pw.TextAlign.left : pw.TextAlign.center),
                        ),
                    ],
                  ),
              ],
            ),

            pw.SizedBox(height: 18),
            pw.Center(
              child: pw.Text('Powered by Kologsoft',
                  style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic,
                      fontSize: 10,
                      color: PdfColors.grey600)),
            ),
          ],
        ),
      );
    } catch (_) {

    }

    return pdf.save();
  }
}

