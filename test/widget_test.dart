// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ksoftsms/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget( MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

/*
  EvictionpreviewPDFVote2(meta) async {
    final rows = tableData2.where(
          (row) =>
      row["region"] == meta["region"] &&
          row["zone"] == meta["zone"] &&
          row["level"] == meta["level"] &&
          row["episode"] == meta["episode"],
    )
        .map((row) {
      return {
        "contestant": row["contestant"],
        "tjs": row["judges"],          // TJS
        "judge60": row["judge60"],     // 60%
        "votes": row["votes"],         // CWW
        "votes40": row["votes40"],     // 40%
        "overallTotal": row["overallTotal"], // TOTAL
      };
    })
        .toList();

    final weeks = meta['weeks'] ?? '';
    final regionquery = await db
        .collection("regions")
        .where("name", isEqualTo: meta["region"])
        .where("episode", isEqualTo: meta["episode"])
        .where("zone", isEqualTo: meta["zone"])
        .get();

    String _season = '';
    String _zone = '';
    String _week = '';

    if (regionquery.docs.isNotEmpty) {
      final regionData = regionquery.docs.first.data();
      _season = regionData["season"] ?? '';
      _zone = regionData["zone"] ?? '';
      _week = regionData["week"] ?? '';
    }
    final printer = EvictionScoreSheetPrinter(
      eventTitle: 'BOOKWORM REALITY SHOW - ${meta['region'] ?? ''}',
      subtitle: '$_season OFFICIAL EVICTION RESULTS ($_week)',
      //  zone: meta['zone'] ?? '',
      zone:  '',
      episode: meta['episode'] ?? '',
      division: meta['level'] ?? 'UPPER CATEGORY',
      logoAssetPath: 'assets/images/bookwormlogo.jpg',
      rows: rows,
    );
    String doctitle="${meta['region']}_${meta['level']}_${meta['episode']}".toUpperCase();
    final pdfBytes = await printer.generatePdf(PdfPageFormat.a4,doctitle);
    final pdfUint8List = Uint8List.fromList(pdfBytes);
    await Printing.layoutPdf(
      onLayout: (_) => pdfUint8List,
      name: 'Eviction Results',
    );
  }
  fetchWeeklyVotescoringData() async {
    try {
      isLoadingweeklysheet = true;
      notifyListeners();

      Query scoringQuery = db.collection('scoringMark');
      if (accesslevel == "Super Admin") {
        scoringQuery = scoringQuery;
      } else if (accesslevel == "Admin") {
        scoringQuery = scoringQuery.where("region", isEqualTo: regionName);
      } else if (accesslevel == "Judge") {
        tableData1 = [];
        judgeColumns1 = [];
        weeklysheetdistinctMeta = [];
        isLoadingweeklysheet = false;
        notifyListeners();
        return;
      }

      final snap = await scoringQuery.get();
      final episodesSnap = await db.collection('episodes').get();

      final List<Map<String, dynamic>> rows = [];
      final Set<String> allJudges = {};
      final Set<String> seenMeta = {};
      final List<Map<String, String>> metaList = [];


      final Map<String, double> episodeCmtMap = {};
      for (var doc in episodesSnap.docs) {
        final data = doc.data();
        final String epName = data['name'] ?? '';
        final double cmt = _toInt(data['cmt'] ?? '0.0');
        if (epName.isNotEmpty) {
          episodeCmtMap[epName] = cmt;
          // print(episodeCmtMap[epName]);
        }
      }

      // First pass: find maximum votes per (region-zone-level-episode)
      final Map<String, double> maxVotesPerGroup = {};
      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final String region = data['region'] ?? "";
        final String zone = data['zone'] ?? "";
        final String level = data['level'] ?? "";
        final String episodeId = data['episodeId'] ?? "";
        final double votes = _toInt(data['votes'] ?? '0');

        final String groupKey = "$region-$zone-$level-$episodeId";

        if (!maxVotesPerGroup.containsKey(groupKey) ||
            votes > maxVotesPerGroup[groupKey]!) {
          maxVotesPerGroup[groupKey] = votes;
        }
      }

      // Second pass: process each contestant
      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final contestantName = data['studentName'] ?? '';
        final code = data['studentId'] ?? '';
        final double votes = _toInt(data['votes'] ?? '0');

        final String region = data['region'] ?? "";
        final String zone = data['zone'] ?? "";
        final String level = data['level'] ?? "";
        final String episodeId = data['episodeId'] ?? "Unknown";
        final String episodeTitle = data['episodeId'] ?? "Unknown";

        final String groupKey = "$region-$zone-$level-$episodeId";
        final double maxVotesThisGroup = maxVotesPerGroup[groupKey] ?? 0;

        Map<String, double> judgeScores = {};
        double totalJudgeScore = 0;

        for (var key in data.keys) {
          if (key == "studentName" ||
              key == "studentId" ||
              key == "episodeId" ||
              key == "episodeTitle" ||
              key == "level" ||
              key == "zone" ||
              key == "region" ||
              key == "photoUrl" ||
              key == "status" ||
              key == "scores" ||
              key == "votes" ||
              key == "timestamp" ||
              key.startsWith("scored")) {
            continue;
          }

          final judgeData = data[key];
          if (judgeData is Map) {
            final score = _toInt(judgeData["totalScore"]);
            judgeScores[key] = score;
            allJudges.add(key);

            totalJudgeScore += score;
          }
        }

        //Lookup cmt from map
        double cmt = episodeCmtMap[episodeId] ?? 0;
        // Judges part (60%)
        double judge60 = 0.0;
        if (cmt > 0) {
          judge60 = (totalJudgeScore / cmt) * 60;
        }

        // Votes part (40%) – based on region-zone-level-episode group
        double votes40 = 0.0;
        if (maxVotesThisGroup > 0) {
          votes40 = (votes / maxVotesThisGroup) * 40;
        }

        // Overall
        double overallTotal = judge60 + votes40;

        // Format to 2 decimals
        judge60 = double.parse(judge60.toStringAsFixed(2));
        votes40 = double.parse(votes40.toStringAsFixed(2));
        overallTotal = double.parse(overallTotal.toStringAsFixed(2));

        rows.add({
          "contestant": contestantName,
          "code": code,
          "judges": judgeScores,
          "TJS": totalJudgeScore,
          "cmt": cmt,
          "votes": votes,
          "judge60": judge60,
          "votes40": votes40,
          "overallTotal": overallTotal,
          "region": region,
          "zone": zone,
          "level": level,
          "episodeId": episodeId,
          "episode": episodeId,
        });

        // Distinct metadata
        final metaKey = "$region-$zone-$level-$episodeId";
        if (!seenMeta.contains(metaKey)) {
          metaList.add({
            "region": region,
            "zone": zone,
            "level": level,
            "episode": episodeId,
          });
          seenMeta.add(metaKey);
        }
      }

      tableData1 = rows;
      judgeColumns1 = allJudges.toList()..sort();
      weeklysheetdistinctMeta = metaList
        ..sort((a, b) => (a['region'] ?? '').compareTo(b['region'] ?? ''));
      isLoadingweeklysheet = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching data: $e");
      isLoadingweeklysheet = false;
      notifyListeners();
    }
  }
  weeklysheetpreviewPDFVote( meta) async {
    try {
      final rows = tableData1.where((
          row) =>
      row["region"] == meta["region"] &&
          row["zone"] == meta["zone"] &&
          row["level"] == meta["level"] &&
          row["episode"] == meta["episode"],
      )
          .toList();

      final regionQuery = await db.collection("regions")
          .where("name", isEqualTo: meta["region"])
          .where("episode", isEqualTo: meta["episode"])
          .where("zone", isEqualTo: meta["zone"])
          .get();

      String season = '';
      String zone = '';
      String weeka = '';

      if (regionQuery.docs.isNotEmpty) {
        final regionData = regionQuery.docs.first.data();
        season = regionData["season"] ?? '';
        zone = regionData["zone"] ?? '';
        weeka = regionData["week"] ?? '';
      }
      final formattedRows = rows.asMap().entries.map((entry) {
        final index = entry.key + 1; // numbering
        final row = entry.value;
        return {
          "no": index.toString(),
          "name": row["contestant"] ?? "",
          "code": row["code"] ?? "",
          "tjs": row["TJS"]?.toString() ?? "0",
          "judge60": row["judge60"]?.toString() ?? "0.0",
          "cvw": row["votes"]?.toString() ?? "0",
          "votes40": row["votes40"]?.toString() ?? "0",
          "total": row["overallTotal"]?.toString() ?? "0",
        };
      }).toList();
      String doctitle="${meta['region']}_${meta['level']}_${meta['episode']}".toUpperCase();
      final printer = WeeklyScoreSheetPrinter(
        eventTitle: "BOOKWORM REALITY SHOW - ${meta['region'] ??''}",
        subtitle: " $season OFFICIAL RESULTS FOR  (${meta['episode'] ?? ''}) ",
        // zone: meta['zone'] ?? '',
        zone:  '',
        episode: meta['episode'] ?? '',
        division: meta['level'] ?? '',
        logoAssetPath: 'assets/images/bookwormlogo.jpg',
        rows: formattedRows,
        totalMarks: '',
      );

      final pdfBytes = await printer.generatePdf(PdfPageFormat.a4,doctitle);
      final pdfUint8List = Uint8List.fromList(pdfBytes);

      await Printing.layoutPdf(
        onLayout: (_) => pdfUint8List,
        name: 'Score Sheet',
      );
    } catch (e, st) {
      debugPrint("Error generating PDF: $e");
      //debugPrint(st.toString());
    }
  }
  fetchBestCriteria() async {
    try {
      isLoadingjudge = true;
      notifyListeners();

      Query scoringQuery = db.collection('scoringMark');

      //Apply filters based on access level
      if (accesslevel == "Super Admin") {
        // no filter, get everything
      } else if (accesslevel == "Admin") {
        scoringQuery = scoringQuery
            .where("region", isEqualTo: regionName)
            .where("zone", isEqualTo: zone);
      } else if (accesslevel == "Judge") {
        // judge sees nothing for weekly report
        distinctMeta = [];
        isLoadingjudge = false;
        notifyListeners();
        return; // 🔹 stop here so judges get blank
      }

      final snap = await scoringQuery.get();
      final seenMeta = <String>{};
      final metaList = <Map<String, String>>[];
      final groupedScores = <String, Map<String, dynamic>>{};

      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final contestantName = data['studentName'] ?? '';
        final code = data['studentId'] ?? '';
        final metaKey =
            "${data['region'] ?? ''}-${data['zone'] ?? ''}-${data['level'] ?? ''}-${data['episodeId'] ?? ''}";

        groupedScores.putIfAbsent(metaKey, () => {
          "criteria": <String>{},
          "scores": <String, Map<String, Map<String, num>>>{},
        });

        // 🔹 Loop through judge IDs (digits only)
        for (var key in data.keys.where((k) => RegExp(r'^\d+$').hasMatch(k))) {
          final judgeData = data[key];
          if (judgeData is Map && judgeData["scores"] is Map) {
            (judgeData["scores"] as Map).forEach((criteria, value) {
              num? parsed;
              if (value is num) {
                parsed = value;
              } else {
                parsed = num.tryParse("$value");
              }

              if (parsed != null) {
                (groupedScores[metaKey]!["criteria"] as Set<String>)
                    .add(criteria);

                final scoresMap =
                groupedScores[metaKey]!["scores"] as Map<String, Map<String, Map<String, num>>>;

                final criteriaMap = scoresMap.putIfAbsent(criteria, () => {});
                final contestantMap =
                criteriaMap.putIfAbsent(contestantName, () => {});
                contestantMap[key] = parsed;
              }
            });
          }
        }

        if (seenMeta.add(metaKey)) {
          metaList.add({
            "region": data['region'] ?? '',
            "zone": data['zone'] ?? '',
            "level": data['level'] ?? '',
            "episode": data['episodeId'] ?? '',
            "metaKey": metaKey,
          });
        }
      }

      bestCriteriaData = {
        for (var e in groupedScores.entries)
          e.key: {
            "criteria": (e.value["criteria"] as Set<String>).toList(),
            "scores": e.value["scores"],
          }
      };
      // 🔹 sort by region safely
      metaList.sort((a, b) =>
          (a['region'] ?? '').compareTo(b['region'] ?? ''));
      distinctMeta = metaList;
    } catch (e) {
      debugPrint("Error fetching criteria: $e");
    } finally {
      isLoadingjudge = false;
      notifyListeners();
    }
  }
  criteriaPDF( meta, selectedCriteria,) async {
    try {
      final metaKey =
          "${meta["region"]}-${meta["zone"]}-${meta["level"]}-${meta["episode"]}";

      if (!bestCriteriaData.containsKey(metaKey)) {
        debugPrint(" No data found for $metaKey");
        return;
      }

      final criteriaData = bestCriteriaData[metaKey]!["scores"]
      as Map<String, Map<String, Map<String, num>>>;

      if (!criteriaData.containsKey(selectedCriteria)) {
        debugPrint(" Criteria $selectedCriteria not found in $metaKey");
        return;
      }

      final Map<String, Map<String, num>> contestantScores =
      criteriaData[selectedCriteria]!;

      // 🔹 Build rows
      final rows = contestantScores.entries.map((entry) {
        final contestant = entry.key.toUpperCase();
        final judgeScores = entry.value; // { judgeId: score }

        final total = judgeScores.values.fold<num>(0, (sum, v) => sum + v);

        return {
          "contestant": contestant,
          "judgeScores": judgeScores,
          "total": total,
        };
      }).toList();

      // 🔹 Collect judge columns dynamically
      final allJudgeIds = <String>{};
      for (var r in rows) {
        allJudgeIds.addAll((r["judgeScores"] as Map<String, num>).keys);
      }
      final judgeColumns = allJudgeIds.toList()..sort();

      // Fetch additional info from 'regions' collection
      final regionQuery = await db.collection("regions")
          .where("name", isEqualTo: meta["region"])
          .where("episode", isEqualTo: meta["episode"])
          .where("zone", isEqualTo: meta["zone"])
          .get();

      String season = '';
      String zone = '';
      String weekss = '';

      if (regionQuery.docs.isNotEmpty) {
        final regionData = regionQuery.docs.first.data();
        season = regionData["season"] ?? '';
        zone = regionData["zone"] ?? meta["zone"];
        week = regionData["week"] ?? '';
      }
      final printer = CriteriaPdfsheet(
        eventTitle: 'BOOKWORM REALITY SHOW $season'.toUpperCase(),
        subtitle: "$selectedCriteria $weekss".toUpperCase(),
        zone: meta['zone'] ?? ''.toUpperCase(),
        episode: meta['episode'] ?? ''.toUpperCase(),
        division: meta['level'] ?? ''.toUpperCase(),
        logoAssetPath: 'assets/images/bookwormlogo.jpg',
        rows: rows,
        totalMarks: '',
        criteriaColumns: judgeColumns, //judge1, judge2, etc.
      );
      String doctitle="${meta['region']}_${meta['level']}_${meta['episode']}".toUpperCase();
      final pdfBytes = await printer.generatePdf(PdfPageFormat.a4,doctitle);
      final pdfUint8List = Uint8List.fromList(pdfBytes);

      await Printing.layoutPdf(
        onLayout: (_) => pdfUint8List,
        name: 'Score Sheet - $selectedCriteria',
      );
    } catch (e, stack) {
      debugPrint("Error generating criteria PDF: $e");
      // debugPrintStack(stackTrace: stack);
    }
  }
  double _toDouble(dynamic v) {
    try {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    } catch (e) {
      debugPrint('Error converting to double: $e');
      return 0.0;
    }
  }

  fetchEvictionVotescoringData() async {
    try {
      isLoadingEvictionvote = true;
      notifyListeners();
      //final snap = await db.collection('scoringMark').get();
      Query scoringQuery = db.collection('scoringMark');
      if (accesslevel == "Super Admin") {
        scoringQuery = scoringQuery;
      } else if (accesslevel == "Admin") {
        scoringQuery = scoringQuery.where("region", isEqualTo: regionName);
      } else if (accesslevel == "Judge") {

        tableData2 = [];
        judgeColumns2 = [];
        EvictionWeeklyMeta2 = [];
        isLoadingEvictionvote = false;
        notifyListeners();
        return;
      }

      final snap = await scoringQuery.get();

      final episodesSnap = await db.collection('episodes').get();

      final List<Map<String, dynamic>> rows = [];
      final Set<String> allJudges = {};
      final Set<String> seenMeta = {};
      final List<Map<String, String>> metaList = [];

      //Build episode cmt map
      final Map<String, double> episodeCmtMap = {};
      for (var doc in episodesSnap.docs) {
        final data = doc.data();
        final String epName = data['name'] ?? '';
        final double cmt = _toInt(data['cmt'] ?? '0');
        if (epName.isNotEmpty) {
          episodeCmtMap[epName] = cmt;
        }
      }

      //1st pass: find maxVotes per (region-zone-level-episodeId)
      final Map<String, double> groupMaxVotes = {};
      for (final doc in snap.docs) {
        final data = doc.data()as Map<String, dynamic>;

        final String region = data['region'] ?? "";
        final String zone = data['zone'] ?? "";
        final String level = data['level'] ?? "";
        final String episodeId = data['episodeId'] ?? "";
        final double votes = _toInt(data['votes']);

        final String groupKey = "$region-$zone-$level-$episodeId";

        if (!groupMaxVotes.containsKey(groupKey) ||
            votes > groupMaxVotes[groupKey]!) {
          groupMaxVotes[groupKey] = votes;
        }
      }

      // process each row
      for (final doc in snap.docs) {
        final data = doc.data()as Map<String, dynamic>;

        final contestantName = data['studentName'] ?? '';
        final studentId = data['studentId'] ?? '';
        final code = data['studentId'] ?? '';
        final double votes = _toInt(data['votes']);

        final String region = data['region'] ?? "";
        final String zone = data['zone'] ?? "";
        final String level = data['level'] ?? "";
        final String episodeId = data['episodeId'] ?? "";
        final String episodeTitle = data['episodeId'] ?? "";

        Map<String, double> judgeScores = {};
        double totalJudgeScore = 0;

        for (var key in data.keys) {
          if (key.startsWith("scored") ||
              key == "studentName" ||
              key == "studentId" ||
              key == "episodeId" ||
              key == "episodeId" ||
              key == "level" ||
              key == "zone" ||
              key == "region" ||
              key == "photoUrl" ||
              key == "status" ||
              key == "criteriatotal" ||
              key == "scores" ||
              key == "votes" ||
              key == "timestamp") {
            continue;
          }

          final judgeData = data[key];
          if (judgeData is Map && judgeData.containsKey("totalScore")) {
            final score = _toInt(judgeData["totalScore"]);
            judgeScores[key] = score;
            allJudges.add(key);

            totalJudgeScore += score;
          }
        }

        // Lookup cmt from episodes
        double cmt = episodeCmtMap[episodeId] ?? 0;

        // Judges part (60%)
        double judge60 = 0.0;
        if (cmt > 0) {
          judge60 = (totalJudgeScore / cmt) * 60;
        }

        // Votes part (40%) → per (region, zone, level, episode)
        double votes40 = 0.0;
        final String groupKey = "$region-$zone-$level-$episodeId";
        final double maxVotesThisGroup = groupMaxVotes[groupKey] ?? 0;

        if (maxVotesThisGroup > 0) {
          votes40 = (votes / maxVotesThisGroup) * 40;
        }

        // Overall
        double overallTotal = judge60 + votes40;

        final String tjsStr = totalJudgeScore.toString();
        final String votesStr = votes.toString();
        final String judge60Str = judge60.toStringAsFixed(2);
        final String votes40Str = votes40.toStringAsFixed(2);
        final String overallStr = overallTotal.toStringAsFixed(2);

        //row with corrected column naming
        rows.add({
          "contestant": contestantName,
          "code": studentId,
          "judges": judgeScores,
          "TJS": tjsStr,
          "cmt": cmt.toString(),
          "60%": judge60Str,
          "CWW": votesStr,
          "40%": votes40Str,
          "TOTAL": overallStr,
          "region": region,
          "zone": zone,
          "level": level,
          "episodeId": episodeId,
          "episode": episodeId,
        });
        //Meta distinct per (region, zone, level, episode)
        final metaKey = "$region-$zone-$level-$episodeId";
        if (!seenMeta.contains(metaKey)) {
          metaList.add({
            "region": region,
            "zone": zone,
            "level": level,
            "episodeId": episodeId,
            "episode": episodeId,
          });
          seenMeta.add(metaKey);
        }
      }
      tableData2 = rows;
      judgeColumns2 = allJudges.toList()..sort();
      EvictionWeeklyMeta2 = [...metaList]
        ..sort((a, b) => a["region"]!.compareTo(b["region"]!));
      // EvictionWeeklyMeta2 = metaList;
      isLoadingEvictionvote = false;

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error fetching eviction data: $e");
      // debugPrintStack(stackTrace: stackTrace);
      isLoadingEvictionvote = false;
      notifyListeners();
    }
  }
  bool isLoadinghightlightnvote =false;
  fetchHightlightweekData() async {
    try {
      isLoadinghightlightnvote = true;
      notifyListeners();
      //final snap = await db.collection('scoringMark').get();
      Query scoringQuery = db.collection('scoringMark');
      if (accesslevel == "Super Admin") {
        scoringQuery = scoringQuery;
      } else if (accesslevel == "Admin") {
        scoringQuery = scoringQuery.where("region", isEqualTo: regionName);
      } else if (accesslevel == "Judge") {

        tableData2 = [];
        judgeColumns2 = [];
        EvictionWeeklyMeta2 = [];
        isLoadinghightlightnvote = false;
        notifyListeners();
        return;
      }

      final snap = await scoringQuery.get();

      final episodesSnap = await db.collection('episodes').get();

      final List<Map<String, dynamic>> rows = [];
      final Set<String> allJudges = {};
      final Set<String> seenMeta = {};
      final List<Map<String, String>> metaList = [];

      //Build episode cmt map
      final Map<String, double> episodeCmtMap = {};
      for (var doc in episodesSnap.docs) {
        final data = doc.data();
        final String epName = data['name'] ?? '';
        final double cmt = _toInt(data['cmt'] ?? '0');
        if (epName.isNotEmpty) {
          episodeCmtMap[epName] = cmt;
        }
      }

      //1st pass: find maxVotes per (region-zone-level-episodeId)
      final Map<String, double> groupMaxVotes = {};
      for (final doc in snap.docs) {
        final data = doc.data()as Map<String, dynamic>;

        final String region = data['region'] ?? "";
        final String zone = data['zone'] ?? "";
        final String level = data['level'] ?? "";
        final String episodeId = data['episodeId'] ?? "";
        final double votes = _toInt(data['votes']);

        final String groupKey = "$region-$zone-$level-$episodeId";

        if (!groupMaxVotes.containsKey(groupKey) ||
            votes > groupMaxVotes[groupKey]!) {
          groupMaxVotes[groupKey] = votes;
        }
      }

      // process each row
      for (final doc in snap.docs) {
        final data = doc.data()as Map<String, dynamic>;

        final contestantName = data['studentName'] ?? '';
        final studentId = data['studentId'] ?? '';
        final code = data['studentId'] ?? '';
        final double votes = _toInt(data['votes']);

        final String region = data['region'] ?? "";
        final String zone = data['zone'] ?? "";
        final String level = data['level'] ?? "";
        final String episodeId = data['episodeId'] ?? "";
        final String episodeTitle = data['episodeId'] ?? "";

        Map<String, double> judgeScores = {};
        double totalJudgeScore = 0;

        for (var key in data.keys) {
          if (key.startsWith("scored") ||
              key == "studentName" ||
              key == "studentId" ||
              key == "episodeId" ||
              key == "episodeId" ||
              key == "level" ||
              key == "zone" ||
              key == "region" ||
              key == "photoUrl" ||
              key == "status" ||
              key == "criteriatotal" ||
              key == "scores" ||
              key == "votes" ||
              key == "timestamp") {
            continue;
          }

          final judgeData = data[key];
          if (judgeData is Map && judgeData.containsKey("totalScore")) {
            final score = _toInt(judgeData["totalScore"]);
            judgeScores[key] = score;
            allJudges.add(key);

            totalJudgeScore += score;
          }
        }

        // Lookup cmt from episodes
        double cmt = episodeCmtMap[episodeId] ?? 0;

        // Judges part (60%)
        double judge60 = 0.0;
        if (cmt > 0) {
          judge60 = (totalJudgeScore / (cmt+cmt)) * 60;
        }

        // Votes part (40%) → per (region, zone, level, episode)
        double votes40 = 0.0;
        final String groupKey = "$region-$zone-$level-$episodeId";
        final double maxVotesThisGroup = groupMaxVotes[groupKey] ?? 0;

        if (maxVotesThisGroup > 0) {
          votes40 = (votes / maxVotesThisGroup) * 40;
        }

        // Overall
        double overallTotal = judge60 + votes40;

        final String tjsStr = totalJudgeScore.toString();
        final String votesStr = votes.toString();
        final String judge60Str = judge60.toStringAsFixed(2);
        final String votes40Str = votes40.toStringAsFixed(2);
        final String overallStr = overallTotal.toStringAsFixed(2);

        //row with corrected column naming
        rows.add({
          "contestant": contestantName,
          "code": studentId,
          "judges": judgeScores,
          "TJS": tjsStr,
          "cmt": cmt.toString(),
          "60%": judge60Str,
          "CWW": votesStr,
          "40%": votes40Str,
          "TOTAL": overallStr,
          "region": region,
          "zone": zone,
          "level": level,
          "episodeId": episodeId,
          "episode": episodeId,
        });
        //Meta distinct per (region, zone, level, episode)
        final metaKey = "$region-$zone-$level-$episodeId";
        if (!seenMeta.contains(metaKey)) {
          metaList.add({
            "region": region,
            "zone": zone,
            "level": level,
            "episodeId": episodeId,
            "episode": episodeId,
          });
          seenMeta.add(metaKey);
        }
      }
      tableData2 = rows;
      judgeColumns2 = allJudges.toList()..sort();
      EvictionWeeklyMeta2 = [...metaList]
        ..sort((a, b) => a["region"]!.compareTo(b["region"]!));
      // EvictionWeeklyMeta2 = metaList;
      isLoadinghightlightnvote = false;

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error fetching Hightlight week  data: $e");
      // debugPrintStack(stackTrace: stackTrace);
      isLoadinghightlightnvote = false;
      notifyListeners();
    }
  }
  HightWeekPDFVote( meta, {selectedEpisodeIds,weeksLabel,int evictionnum = 0,}) async {
    try {
      final String? fRegion = meta["region"];
      final String? fZone = meta["zone"];
      final String? fLevel = meta["level"];
      if (fRegion == null || fZone == null || fLevel == null) {
        debugPrint("Hightlight week PDF: Missing essential metadata!");
        return;
      }

      // Fetch additional info from 'regions' collection
      final regionQuery = await db.collection("regions")
          .where("name", isEqualTo: meta['region'])
          .where("episode", isEqualTo: meta['episode'])
          .where("zone", isEqualTo: meta['zone'])
          .get();

      String season = '';
      String zone = '';
      String week = '';

      if (regionQuery.docs.isNotEmpty) {
        final regionData = regionQuery.docs.first.data();
        season = regionData["season"] ?? '';
        zone = regionData["zone"] ?? '';
        week = regionData["week"] ?? '';
      }

      final Set<String> selectedSet = selectedEpisodeIds?.toSet() ?? {};

      final filtered = tableData2.where((row) {
        final bool regionOk = (fRegion == null || fRegion.isEmpty)
            ? true
            : row["region"] == fRegion;
        final bool zoneOk = (fZone == null || fZone.isEmpty)
            ? true
            : row["zone"] == fZone;
        final bool levelOk = (fLevel == null || fLevel.isEmpty)
            ? true
            : row["level"] == fLevel;

        final bool episodeOk = selectedSet.isEmpty
            ? true
            : selectedSet.contains((row["episodeId"] ?? '').toString());

        return regionOk && zoneOk && levelOk && episodeOk;
      }).toList();

      final Map<String, Map<String, String>> grouped = {};

      for (final r in filtered) {
        final String sid = (r["studentId"]?.toString().trim().isNotEmpty ?? false)
            ? r["studentId"].toString()
            : (r["contestant"]?.toString().trim().isNotEmpty ?? false)
            ? r["contestant"].toString()
            : (r["code"]?.toString().trim().isNotEmpty ?? false)
            ? r["code"].toString()
            : '${r["contestant"]}_${r["episodeId"]}';


        if (!grouped.containsKey(sid)) {
          grouped[sid] = {
            "studentId": sid,
            "contestant": r["contestant"] ?? "",
            "code": r["code"] ?? "",
            "TJS": "0",
            "60%": "0.00",
            "CWW": "0",
            "40%": "0.00",
            "TOTAL": "0.00",
          };
        }

        final currentTJS = _toInt(grouped[sid]!["TJS"]);
        final current60 = _toDouble(grouped[sid]!["60%"]);
        final currentCWW = _toInt(grouped[sid]!["CWW"]);
        final current40 = _toDouble(grouped[sid]!["40%"]);
        final currentTotal = _toDouble(grouped[sid]!["TOTAL"]);

        final newTJS = currentTJS + _toInt(r["TJS"]);
        final new60 = current60 + _toDouble(r["60%"]);
        final newCWW = currentCWW + _toInt(r["CWW"]);
        final new40 = current40 + _toDouble(r["40%"]);
        final newTotal = currentTotal + _toDouble(r["TOTAL"]);

        grouped[sid]!["TJS"] = newTJS.toString();
        grouped[sid]!["60%"] = new60.toStringAsFixed(2);
        grouped[sid]!["CWW"] = newCWW.toString();
        grouped[sid]!["40%"] = new40.toStringAsFixed(2);
        grouped[sid]!["TOTAL"] = newTotal.toStringAsFixed(2);
      }

      final List<Map<String, String>> rows = grouped.values.toList()
        ..sort((a, b) =>
            _toDouble(b["TOTAL"]).compareTo(_toDouble(a["TOTAL"])));

      String finalWeeksLabel = weeksLabel ??
          filtered
              .map((e) => (e["episode"] ?? '').toString())
              .where((s) => s.isNotEmpty)
              .toSet()
              .join("+");
      final subtitleText = evictionnum == 0
          ? '$season OFFICIAL RESULTS '.toUpperCase()
          : '$season OFFICIAL EVICTION RESULTS '.toUpperCase();
      final printer = HightlightweekSheetPrinter(
        eventTitle: 'BOOKWORM REALITY SHOW - ${meta['region'] ?? ''}',
        subtitle: subtitleText,
        division: meta['level'] ?? '',
        logoAssetPath: 'assets/images/bookwormlogo.jpg',
        rows: rows,
        zone: meta['zone'],
        highlightBottom: evictionnum,
        episode: selectedEpisodeIds?.isEmpty ?? true ? null :finalWeeksLabel.toUpperCase(),
      );
      String doctitle="${meta['region']}_${meta['level']}_${meta['episode']}_Evic".toUpperCase();
      final pdfBytes = await printer.generatePdf(PdfPageFormat.a4,doctitle);
      final pdfUint8List = Uint8List.fromList(pdfBytes);

      await Printing.layoutPdf(
        onLayout: (_) => pdfUint8List,
        name: 'Eviction Results',
      );
    } catch (e, stackTrace) {
      print('Error generating eviction PDF: $e');
      // print(stackTrace);
    }
  }
  EvictionpreviewPDFVote( meta, {selectedEpisodeIds,weeksLabel,int evictionnum = 0,}) async {
    try {
      final String? fRegion = meta["region"];
      final String? fZone = meta["zone"];
      final String? fLevel = meta["level"];
      if (fRegion == null || fZone == null || fLevel == null) {
        debugPrint("Eviction PDF: Missing essential metadata!");
        return;
      }

      // Fetch additional info from 'regions' collection
      final regionQuery = await db.collection("regions")
          .where("name", isEqualTo: meta['region'])
          .where("episode", isEqualTo: meta['episode'])
          .where("zone", isEqualTo: meta['zone'])
          .get();

      String season = '';
      String zone = '';
      String week = '';

      if (regionQuery.docs.isNotEmpty) {
        final regionData = regionQuery.docs.first.data();
        season = regionData["season"] ?? '';
        zone = regionData["zone"] ?? '';
        week = regionData["week"] ?? '';
      }

      final Set<String> selectedSet = selectedEpisodeIds?.toSet() ?? {};

      final filtered = tableData2.where((row) {
        final bool regionOk = (fRegion == null || fRegion.isEmpty)
            ? true
            : row["region"] == fRegion;
        final bool zoneOk = (fZone == null || fZone.isEmpty)
            ? true
            : row["zone"] == fZone;
        final bool levelOk = (fLevel == null || fLevel.isEmpty)
            ? true
            : row["level"] == fLevel;

        final bool episodeOk = selectedSet.isEmpty
            ? true
            : selectedSet.contains((row["episodeId"] ?? '').toString());

        return regionOk && zoneOk && levelOk && episodeOk;
      }).toList();

      final Map<String, Map<String, String>> grouped = {};

      for (final r in filtered) {
        final String sid = (r["studentId"]?.toString().trim().isNotEmpty ?? false)
            ? r["studentId"].toString()
            : (r["contestant"]?.toString().trim().isNotEmpty ?? false)
            ? r["contestant"].toString()
            : (r["code"]?.toString().trim().isNotEmpty ?? false)
            ? r["code"].toString()
            : '${r["contestant"]}_${r["episodeId"]}';


        if (!grouped.containsKey(sid)) {
          grouped[sid] = {
            "studentId": sid,
            "contestant": r["contestant"] ?? "",
            "code": r["code"] ?? "",
            "TJS": "0",
            "60%": "0.00",
            "CWW": "0",
            "40%": "0.00",
            "TOTAL": "0.00",
          };
        }

        final currentTJS = _toInt(grouped[sid]!["TJS"]);
        final current60 = _toDouble(grouped[sid]!["60%"]);
        final currentCWW = _toInt(grouped[sid]!["CWW"]);
        final current40 = _toDouble(grouped[sid]!["40%"]);
        final currentTotal = _toDouble(grouped[sid]!["TOTAL"]);

        final newTJS = currentTJS + _toInt(r["TJS"]);
        final new60 = current60 + _toDouble(r["60%"]);
        final newCWW = currentCWW + _toInt(r["CWW"]);
        final new40 = current40 + _toDouble(r["40%"]);
        final newTotal = currentTotal + _toDouble(r["TOTAL"]);

        grouped[sid]!["TJS"] = newTJS.toString();
        grouped[sid]!["60%"] = new60.toStringAsFixed(2);
        grouped[sid]!["CWW"] = newCWW.toString();
        grouped[sid]!["40%"] = new40.toStringAsFixed(2);
        grouped[sid]!["TOTAL"] = newTotal.toStringAsFixed(2);
      }

      final List<Map<String, String>> rows = grouped.values.toList()
        ..sort((a, b) =>
            _toDouble(b["TOTAL"]).compareTo(_toDouble(a["TOTAL"])));

      String finalWeeksLabel = weeksLabel ??
          filtered
              .map((e) => (e["episode"] ?? '').toString())
              .where((s) => s.isNotEmpty)
              .toSet()
              .join("+");
      final subtitleText = evictionnum == 0
          ? '$season OFFICIAL RESULTS '.toUpperCase()
          : '$season OFFICIAL EVICTION RESULTS'.toUpperCase();
      final printer = EvictionScoreSheetPrinter(
        eventTitle: 'BOOKWORM REALITY SHOW - ${meta['region'] ?? ''}',
        subtitle: subtitleText,
        division: meta['level'] ?? '',
        logoAssetPath: 'assets/images/bookwormlogo.jpg',
        rows: rows,
        zone: meta['zone'],
        highlightBottom: evictionnum,
        episode: selectedEpisodeIds?.isEmpty ?? true ? null :finalWeeksLabel.toUpperCase(),
      );
      String doctitle="${meta['region']}_${meta['level']}_${meta['episode']}_Evic".toUpperCase();
      final pdfBytes = await printer.generatePdf(PdfPageFormat.a4,doctitle);
      final pdfUint8List = Uint8List.fromList(pdfBytes);

      await Printing.layoutPdf(
        onLayout: (_) => pdfUint8List,
        name: 'Eviction Results',
      );
    } catch (e, stackTrace) {
      print('Error generating eviction PDF: $e');
      // print(stackTrace);
    }
  }
  calculateCriteriaTotal( keys) {
    try {
      int sum = 0;
      for (final key in keys) {
        final matchingComponent = accessComponents.firstWhere(
              (comp) => comp['name'] == key,
          orElse: () => {},
        );
        if (matchingComponent.isNotEmpty) {
          final totalMark = int.tryParse(matchingComponent['totalmark']?.toString() ?? '0') ?? 0;
          sum += totalMark;
        }
      }
      criteriaTotal = sum;
      notifyListeners();
    } catch (e) {
      print('Error calculating criteria total: $e');
      criteriaTotal = 0;
      notifyListeners();
    }
  }
*/


// Future<void> saveTeacherSetupMulti({required List<Staff> teacherIds,required String schoolId,required String academicYear, required String term,    required List<ClassModel> classes, required List<SubjectModel> subjects,  required List<ComponentModel> components,  }) async {
//   if (teacherIds.isEmpty) throw Exception("No teachers selected.");
//   if (subjects.isEmpty) throw Exception("No subjects selected.");
//   if (academicYear.trim().isEmpty || term.trim().isEmpty) {
//     throw Exception("Academic year and term are required.");
//   }
//
//   savingSetup = true;
//   notifyListeners();
//   const int _batchLimit = 450;
//
//   try {
//     WriteBatch batch = db.batch();
//     int writes = 0;
//
//     final classNames = classes.map((c) => c.name).toList();
//     final departlevel = classes.map((c) => c.department).toList();
//
//     final teacherInfo = {
//       for (final t in teacherIds)
//         t.id ?? t.email: {
//           "tcherid": t.id ?? "",
//           "tchername": t.name,
//           "tcheremail": t.email,
//           "schoolId": t.schoolId,
//           "school": t.schoolname,
//         }
//     };
//     final studentSnap = await db
//         .collection("students")
//         .where("schoolId", isEqualTo: schoolId)
//         .where("level", whereIn: classNames)
//         .get();
//
//     for (final studentDoc in studentSnap.docs) {
//       final studentData = studentDoc.data() as Map<String, dynamic>;
//       final studentId = studentDoc.id;
//       final studentClass = studentData['level'] ?? '';
//
//       if (!classNames.contains(studentClass)) continue;
//       // subject scaffolding
//       final Map<String, dynamic> subjectMap = {};
//       final Map<String, String> scoredFlags = {};
//       final Map<String, dynamic> scores = {};
//       final Map<String, String> totalScores = {};
//
//       for (final subject in subjects) {
//         final scoring = SubjectScoring.create(
//             studentId: studentId,
//             studentName: studentData['name'] ?? '',
//             academicYear: year,
//             term: term,
//             staff: name,
//             classes: studentClass,
//             level: studentData['level'] ?? '',
//             department: studentData['department'] ?? '',
//             region: studentData['region'] ?? '',
//             schoolId: schoolId,
//             school: studentData['school'] ?? '',
//             photoUrl: studentData['photourl'] ?? '',
//             dob: studentData['dob'] ?? '',
//             email: studentData['email'] ?? '',
//             phone: studentData['phone'] ?? '',
//             sex: studentData['sex'] ?? '',
//             status: studentData['status'] ?? 'active',
//             yeargroup: studentData['yeargroup'] ?? '',
//             subjectId: subject.id,
//             subjectName: subject.name,
//             components: components,
//             teacher: teacherInfo,
//             scores: {},
//             attendance: '',
//             remarks: '',
//             reopening: '',
//             nextclass: '',
//             nextfees: ''
//         );
//         scores[subject.id] = {
//           "subjectId": subject.id,
//           "subjectName": subject.name,
//           "code": subject.code,
//           "CA": '0',
//           "convertedca": '0',
//           "convertedexams": '0',
//           "Exams": '0',
//           "totalScore": '0',
//           "scored": 'no',
//         };
//         subjectMap[subject.id] = {
//           "subjectId": subject.id,
//           "subjectName": subject.name,
//           "code": subject.code,
//           "isComplete": "no",
//           "CA": "0",
//           "convertedca": "0",
//           "Exams": "0",
//           "convertedexams": "0",
//           "totalScore": "0",
//           "scored": "no",
//         };
//       }
//
//       final scoringId = "${studentId}_${academicyrid}_$term";
//       final scoringRef = db.collection("subjectScoring").doc(scoringId);
//       final scoringData = {
//         "studentId": studentId,
//         "studentName": studentData['name'] ?? '',
//         "academicYear": year,
//         "term": term,
//         "level": studentData['level'] ?? '',
//         "class": studentClass,
//         "department": studentData['department'] ?? '',
//         "region": studentData['region'] ?? '',
//         "schoolId": schoolId,
//         "school": studentData['school'] ?? '',
//         "photourl": studentData['photourl'] ?? '',
//         "dob": studentData['dob'] ?? '',
//         "email": studentData['email'] ?? '',
//         "phone": studentData['phone'] ?? '',
//         "sex": studentData['sex'] ?? '',
//         "status": studentData['status'] ?? 'active',
//         "yeargroup": studentData['yeargroup'] ?? '',
//         "subjects": subjectMap,
//         "teacher": teacherInfo,
//         "scores": scores,
//         ...scoredFlags,
//         ...totalScores,
//         "timestamp": DateTime.now(),
//       };
//
//       batch.set(scoringRef, scoringData, SetOptions(merge: true));
//       writes++;
//
//       if (writes >= _batchLimit) {
//         await batch.commit();
//         batch = db.batch();
//         writes = 0;
//       }
//     }
//
//     if (writes > 0) await batch.commit();
//
//     // ----------------------------
//     // Save TeacherSetup
//     // ----------------------------
//       batch = db.batch();
//       writes = 0;
//       for (final teacher in teacherIds) {
//         final teacherSetupId = "${teacher.id}_${academicYear}_$term";
//         final classesMap = classes.map((s) => ClassModel(id: s.id,name: s.name, department: s.department,staff: s.staff,status: 'no')).toList();
//         final componentsMap = components.map((s) => ComponentModel(id: s.id,name: s.name, staff: s.staff, schoolId: s.schoolId, totalMark: s.totalMark, type: '',)).toList();
//         final subjectsList = subjects.map((s) => SubjectModel(id: s.id,name: s.name,)).toList();
//
//         final teacherSetup = TeacherSetup(
//           staffid: teacher.id ?? teacher.email,
//           staffname: teacher.name,
//           classname: classesMap,
//           schoolId: schoolId,
//           academicyear:year,
//           term: term,
//           component: componentsMap,
//           subjects: subjectsList,
//           createby: name,
//           email: teacher.email,
//           phone: teacher.phone,
//         );
//
//         final teacherSetupRef = db.collection("teacherSetup").doc(teacherSetupId);
//         batch.set(teacherSetupRef, teacherSetup.toJson(), SetOptions(merge: true));
//         writes++;
//
//         if (writes >= _batchLimit) {
//           await batch.commit();
//           batch = db.batch();
//           writes = 0;
//         }
//       }
//
//       if (writes > 0) await batch.commit();
//
//   } catch (e, stack) {
//     debugPrint("Error in saveTeacherSetupMulti: $e");
//     debugPrintStack(stackTrace: stack);
//     rethrow;
//   } finally {
//     savingSetup = false;
//     notifyListeners();
//   }
// }


// ----------------------------
// Save TeacherSetup
// batch = db.batch();
// writes = 0;
// for (final teacher in selectedTeachers) {
//   final teacherSetupId = "${teacher.id}_${academicYear}_$term";
//   final classesMap = selectedClasses.map((s) => ClassModel(id: s.id,name: s.name, department: s.department,staff: s.staff,status: 'no')).toList();
//   final componentsMap = selectedComponents.map((s) => ComponentModel(id: s.id,name: s.name, staff: s.staff, schoolId: s.schoolId, totalMark: s.totalMark, type: '',)).toList();
//   final subjectsList = selectedSubjects.map((s) => SubjectModel(id: s.id,name: s.name,)).toList();
//
//   final teacherSetup = TeacherSetup(
//     staffid: teacher.id ?? teacher.email,
//     staffname: teacher.name,
//     classname: classesMap,
//     schoolId: schoolId,
//     academicyear:year,
//     term: term,
//     component: componentsMap,
//     subjects: subjectsList,
//     createby: name,
//     email: teacher.email,
//     phone: teacher.phone,
//   );
//
//   final teacherSetupRef = db.collection("teacherSetup").doc(teacherSetupId);
//   batch.set(teacherSetupRef, teacherSetup.toJson(), SetOptions(merge: true));
//   writes++;
//
//   if (writes >= _batchLimit) {
//     await batch.commit();
//     batch = db.batch();
//     writes = 0;
//   }
// }
//
// if (writes > 0) await batch.commit();
