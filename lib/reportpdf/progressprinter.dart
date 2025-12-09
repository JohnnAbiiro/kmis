import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class ProgressPrinter {
  // Header
  final String schoolName;
  final String reportTitle;
  final String examSession;
  final String logoAssetPathl;
  final String logoAssetPathr;

  // Student details
  final String studentName;
  final String studentId;
  final String studentClass;
  final String department;
  final String term;

  // Each field holds a single-letter grade: "A", "M", "O", "H", "N"
  // Participation in class
  final String contributesInClassGrade;
  final String disturbsClassGrade;
  final String hyperActiveGrade;

  // Relationship with mates
  final String goodAttitudeGrade;
  final String noPlayGrade;
  final String bullyGrade;

  // Health, eating and toilet habits
  final String neatAlwaysGrade;
  final String neatButDirtyGrade;
  final String washHandsGrade;
  final String eatAloneGrade;
  final String eatingHabitsGrade;
  final String toiletControlGrade;
  final String noExerciseGrade;

  // Discovery and Cognitive
  final String knowsItemsGrade;
  final String identifyTextureGrade;
  final String identifyShapesGrade;
  final String dressUpGrade;
  final String politeWordsGrade;

  // Creativity & Arts
  final String buildBlocksGrade;
  final String drawSimpleGrade;
  final String colorShapesGrade;
  final String creativeWorkGrade;

  // Mathematics
  final String recogniseNumbersGrade;
  final String writeNumbersGrade;
  final String countObjectsGrade;
  final String sortObjectsGrade;
  final String additionSubtractionGrade;

  // Phonics
  final String alphabetSoundsGrade;
  final String pronounceWordsGrade;
  final String jollyPhonicsGrade;
  final String combineLettersGrade;

  // Writing
  final String writePatternGrade;
  final String writeLettersGrade;
  final String writeWordsGrade;
  final String copyBoardGrade;
  final String dictationWritingGrade;

  // Nature and Environment
  final String identifyEnvironmentGrade;
  final String identifyBodyPartsGrade;

  // Music & Movement
  final String likesMusicGrade;
  final String singRhymesGrade;
  final String dancePerformanceGrade;

  // Comments
  final String observations;
  final String recommendation;
  final String teacherComment;
  final String principalComment;

  ProgressPrinter({
    // header
    required this.schoolName,
    required this.reportTitle,
    required this.examSession,
    required this.logoAssetPathl,
    required this.logoAssetPathr,
    // student
    required this.studentName,
    required this.studentId,
    required this.studentClass,
    required this.department,
    required this.term,
    // participation
    required this.contributesInClassGrade,
    required this.disturbsClassGrade,
    required this.hyperActiveGrade,
    // relationship
    required this.goodAttitudeGrade,
    required this.noPlayGrade,
    required this.bullyGrade,
    // health
    required this.neatAlwaysGrade,
    required this.neatButDirtyGrade,
    required this.washHandsGrade,
    required this.eatAloneGrade,
    required this.eatingHabitsGrade,
    required this.toiletControlGrade,
    required this.noExerciseGrade,
    // discovery
    required this.knowsItemsGrade,
    required this.identifyTextureGrade,
    required this.identifyShapesGrade,
    required this.dressUpGrade,
    required this.politeWordsGrade,
    // creativity
    required this.buildBlocksGrade,
    required this.drawSimpleGrade,
    required this.colorShapesGrade,
    required this.creativeWorkGrade,
    // math
    required this.recogniseNumbersGrade,
    required this.writeNumbersGrade,
    required this.countObjectsGrade,
    required this.sortObjectsGrade,
    required this.additionSubtractionGrade,
    // phonics
    required this.alphabetSoundsGrade,
    required this.pronounceWordsGrade,
    required this.jollyPhonicsGrade,
    required this.combineLettersGrade,
    // writing
    required this.writePatternGrade,
    required this.writeLettersGrade,
    required this.writeWordsGrade,
    required this.copyBoardGrade,
    required this.dictationWritingGrade,
    // nature
    required this.identifyEnvironmentGrade,
    required this.identifyBodyPartsGrade,
    // music
    required this.likesMusicGrade,
    required this.singRhymesGrade,
    required this.dancePerformanceGrade,
    // comments
    required this.observations,
    required this.recommendation,
    required this.teacherComment,
    required this.principalComment,
  });

  // Helper: draw a small checkbox box and a tick if selected.
  pw.Widget _gradeBox(String expected, String selected) {
    final bool checked = (expected == selected);
    return pw.Container(
      width: 18,
      height: 18,
      margin: const pw.EdgeInsets.all(2),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.6, color: PdfColors.grey800),
      ),
      child: pw.Center(
        child: checked
            ? pw.Text('✓', style: pw.TextStyle(fontSize: 12))
            : pw.SizedBox(width: 0, height: 0),
      ),
    );
  }

  // Helper: single row for a labeled progress item
  pw.Widget _progressRow(int number, String label, String grade) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(width: 20, child: pw.Text(number.toString(), style: pw.TextStyle(fontSize: 10))),
          pw.SizedBox(width: 6),
          pw.Expanded(child: pw.Text(label, style: pw.TextStyle(fontSize: 10))),
          pw.SizedBox(width: 6),
          // checkboxes A, M, O, H, N
          _gradeBox('A', grade),
          _gradeBox('M', grade),
          _gradeBox('O', grade),
          _gradeBox('H', grade),
          _gradeBox('N', grade),
        ],
      ),
    );
  }

  // Helper: section header
  pw.Widget _sectionHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
    );
  }

  Future<pw.Document> buildPdf({PdfPageFormat format = PdfPageFormat.a4}) async {
    final doc = pw.Document();

    // load logos if possible
    pw.MemoryImage? leftLogo;
    pw.MemoryImage? rightLogo;
    try {
      final l = await rootBundle.load(logoAssetPathl);
      leftLogo = pw.MemoryImage(l.buffer.asUint8List());
    } catch (_) {}
    try {
      final r = await rootBundle.load(logoAssetPathr);
      rightLogo = pw.MemoryImage(r.buffer.asUint8List());
    } catch (_) {}

    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(18),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // header banner
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF1E88E5),
                  borderRadius: pw.BorderRadius.only(
                    bottomLeft: pw.Radius.circular(8),
                    bottomRight: pw.Radius.circular(8),
                  ),
                ),
                child: pw.Row(
                  children: [
                    if (leftLogo != null)
                      pw.Container(
                        width: 50,
                        height: 50,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          image: pw.DecorationImage(image: leftLogo),
                        ),
                      ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(schoolName.toUpperCase(),
                              style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text(reportTitle,
                              style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text(examSession, style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                    if (rightLogo != null)
                      pw.Container(
                        width: 50,
                        height: 50,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          image: pw.DecorationImage(image: rightLogo),
                        ),
                      ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // legend A M O H N
              pw.Text('A- Always   M- Most times   O- Occasionally   H- Helped   N- No cannot/ Does not',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),

              pw.SizedBox(height: 8),

              // student info
              pw.Container(
                child: pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(3),
                  },
                  children: [
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Class:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(studentClass)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Department:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(department)),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Student ID:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(studentId)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Term:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(term)),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Name:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(studentName)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
                    ]),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // Participation in class section
              _sectionHeader('Participation in class'),
              // header row for checkboxes labels
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                child: pw.Row(
                  children: [
                    pw.Container(width: 20, child: pw.Text('#', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.SizedBox(width: 6),
                    pw.Expanded(child: pw.Text('', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Container(width: 20, child: pw.Text('A', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Container(width: 20, child: pw.Text('M', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Container(width: 20, child: pw.Text('O', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Container(width: 20, child: pw.Text('H', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Container(width: 20, child: pw.Text('N', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
              ),
              // rows
              _progressRow(1, 'Contributes in class/quite reserved in class but pays attention', contributesInClassGrade),
              _progressRow(2, 'Disturbs and disrupt class', disturbsClassGrade),
              _progressRow(3, 'Highly hyperactive/less hyperactive', hyperActiveGrade),

              pw.SizedBox(height: 12),

              // Relationship with mates
              _sectionHeader('Relationship with mates and social development'),
              _progressRow(1, 'Has a good attitudes towards mates, share food and play items with mates', goodAttitudeGrade),
              _progressRow(2, 'Does not like playing and sharing play items', noPlayGrade),
              _progressRow(3, 'Hits/Bites/Hurts other children (bullying of other kids)', bullyGrade),

              pw.SizedBox(height: 12),

              // Health, eating and toilet habits
              _sectionHeader('Health, eating and toilet habits'),
              _progressRow(1, 'Neatly dressed and does not get dirty during school hours', neatAlwaysGrade),
              _progressRow(2, 'Neatly dressed but gets dirty during school hours', neatButDirtyGrade),
              _progressRow(3, 'Can wash hands adequately/uses a handkerchief well', washHandsGrade),
              _progressRow(4, 'Can eat without any help from attendants and finishes up', eatAloneGrade),
              _progressRow(5, 'Exhibits good eating habits/ exhibits poor eating habits', eatingHabitsGrade),
              _progressRow(6, 'Can say I will popoo and weewee; does not soil him/herself', toiletControlGrade),
              _progressRow(7, 'Does not participate in exercises/dance classes', noExerciseGrade),

              pw.SizedBox(height: 12),

              // Discovery & Cognitive
              _sectionHeader('Discovery and Cognitive'),
              _progressRow(1, 'Knows the correct names and uses of most items', knowsItemsGrade),
              _progressRow(2, 'Can recognise and identify their texture and sound', identifyTextureGrade),
              _progressRow(3, 'Identify shapes and colours well/ not too well', identifyShapesGrade),
              _progressRow(4, 'Can dress up (clothes, socks, shoes) well', dressUpGrade),
              _progressRow(5, 'Says please/Sorry/Thank you, very polite child', politeWordsGrade),

              pw.SizedBox(height: 12),

              // Creativity & Arts
              _sectionHeader('Creativity and Arts'),
              _progressRow(1, 'Can build very well with logos and building blocks', buildBlocksGrade),
              _progressRow(2, 'Can draw simple diagrams e.g. Human/Animals/ Fruits/star/Ball', drawSimpleGrade),
              _progressRow(3, 'Can colour shapes and diagrams well/ not too well', colorShapesGrade),
              _progressRow(4, 'Can paint/sand glue/cut with scissors/paste/mould, etc.', creativeWorkGrade),

              pw.SizedBox(height: 12),

              // Mathematics
              _sectionHeader('Mathematics'),
              _progressRow(1, 'Recognises/Writes/Recites numerals 0-5/0-20/0-50/0-100 etc.', recogniseNumbersGrade),
              _progressRow(2, 'Can write 0-5/0-20/0-50/0-100 etc.', writeNumbersGrade),
              _progressRow(3, 'Can count objects and writes the numbers accurately', countObjectsGrade),
              _progressRow(4, 'Can sort things according to shapes, colour, size etc.', sortObjectsGrade),
              _progressRow(5, 'Attempts addition/ Subtraction', additionSubtractionGrade),

              pw.SizedBox(height: 12),

              // Phonics
              _sectionHeader('Phonics'),
              _progressRow(1, 'Able to make sounds of alphabets a-e/f-j/k-o/p-t/q-z', alphabetSoundsGrade),
              _progressRow(2, 'Can pronounce 2/3/4 letter words', pronounceWordsGrade),
              _progressRow(3, 'Can perform the jolly phonics of a-e/f-j/k-o/p-t/q-z', jollyPhonicsGrade),
              _progressRow(4, 'Can combine alphabets to pronounce a word', combineLettersGrade),

              pw.SizedBox(height: 12),

              // Writing
              _sectionHeader('Writing'),
              _progressRow(1, 'Can write any pattern', writePatternGrade),
              _progressRow(2, 'Can write letter (Capital/Small) a-e/f-j/k-o/p-t/q-z', writeLettersGrade),
              _progressRow(3, 'Can write 2, 3, 4 etc. in words', writeWordsGrade),
              _progressRow(4, 'Can copy from the board', copyBoardGrade),
              _progressRow(5, 'Can write alphabets, numbers, words when dictated', dictationWritingGrade),

              pw.SizedBox(height: 12),

              // Nature & Environment
              _sectionHeader('Nature and Environment'),
              _progressRow(1, 'Can identify/Recognises plants/animals/fruits etc.', identifyEnvironmentGrade),
              _progressRow(2, 'Can identify and name parts of human body', identifyBodyPartsGrade),

              pw.SizedBox(height: 12),

              // Music & Movement
              _sectionHeader('Music and Movement (Rhymes, Songs, Drumming and Dance)'),
              _progressRow(1, 'Appreciates music and recites and acts out most rhymes and songs', likesMusicGrade),
              _progressRow(2, 'Can sing all/most of the rhymes at school', singRhymesGrade),
              _progressRow(3, 'Enjoys drumming and dances well/not too well', dancePerformanceGrade),

              pw.SizedBox(height: 14),

              // Observations / Recommendation / Comments
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.6, color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Observations', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(observations),
                    pw.SizedBox(height: 8),
                    pw.Text('Recommendation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(recommendation),
                    pw.SizedBox(height: 8),
                    pw.Text('Class Teacher’s comments', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(teacherComment),
                    pw.SizedBox(height: 8),
                    pw.Text('Principal’s comments', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(principalComment),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // signature lines
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(children: [
                    pw.Text('Class Teacher:', style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 30),
                    pw.Container(width: 140, height: 0.5, color: PdfColors.grey600),
                  ]),
                  pw.Column(children: [
                    pw.Text('Principal:', style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 30),
                    pw.Container(width: 140, height: 0.5, color: PdfColors.grey600),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    return doc;
  }
}
final printer = ProgressPrinter(
  schoolName: 'LAMP&LIGHT MODEL SCHOOL',
  reportTitle: 'CHILD’S PROGRESS ASSESSMENT REPORT SHEET',
  examSession: 'END OF FIRST TERM',
  logoAssetPathl: 'assets/logo_left.png',
  logoAssetPathr: 'assets/logo_right.png',
  studentName: 'ABA-ENGE SAMUEL',
  studentId: 'LAMP00788',
  studentClass: 'BS1B',
  department: 'BASIC',
  term: 'First Term',
  // Participation
  contributesInClassGrade: 'A',
  disturbsClassGrade: 'N',
  hyperActiveGrade: 'O',
  // Relationship
  goodAttitudeGrade: 'A',
  noPlayGrade: 'O',
  bullyGrade: 'N',
  // Health
  neatAlwaysGrade: 'A',
  neatButDirtyGrade: 'N',
  washHandsGrade: 'A',
  eatAloneGrade: 'A',
  eatingHabitsGrade: 'M',
  toiletControlGrade: 'A',
  noExerciseGrade: 'O',
  // Discovery
  knowsItemsGrade: 'A',
  identifyTextureGrade: 'M',
  identifyShapesGrade: 'A',
  dressUpGrade: 'M',
  politeWordsGrade: 'A',
  // Creativity
  buildBlocksGrade: 'A',
  drawSimpleGrade: 'M',
  colorShapesGrade: 'A',
  creativeWorkGrade: 'O',
  // Math
  recogniseNumbersGrade: 'A',
  writeNumbersGrade: 'M',
  countObjectsGrade: 'A',
  sortObjectsGrade: 'M',
  additionSubtractionGrade: 'O',
  // Phonics
  alphabetSoundsGrade: 'A',
  pronounceWordsGrade: 'M',
  jollyPhonicsGrade: 'A',
  combineLettersGrade: 'O',
  // Writing
  writePatternGrade: 'A',
  writeLettersGrade: 'M',
  writeWordsGrade: 'A',
  copyBoardGrade: 'A',
  dictationWritingGrade: 'M',
  // Nature
  identifyEnvironmentGrade: 'A',
  identifyBodyPartsGrade: 'A',
  // Music
  likesMusicGrade: 'A',
  singRhymesGrade: 'A',
  dancePerformanceGrade: 'O',
  // comments
  observations: 'Child is active and responsive.',
  recommendation: 'Encourage group play and sharing.',
  teacherComment: 'Good progress.',
  principalComment: 'Keep up the good work.',
);

// create the PDF
//final doc = await printer.buildPdf();
// save or share `doc` (e.g., doc.save() returns Uint8List)