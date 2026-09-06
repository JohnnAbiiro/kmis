class CsvValidationException implements Exception {
  final String message;
  CsvValidationException(this.message);
}

class CsvService {
  static const maxCsvBytes = 10 * 1024 * 1024;
  static const maxMaterialBytes = 10 * 1024 * 1024 * 1024;

  static void validateCsv(String fileName, int sizeBytes) {
    if (!fileName.toLowerCase().endsWith('.csv')) {
      throw CsvValidationException('Only .csv files are allowed');
    }
    if (sizeBytes > maxCsvBytes) {
      throw CsvValidationException('CSV file must be under 10MB');
    }
  }

  static void validateMaterial(int sizeBytes) {
    if (sizeBytes > maxMaterialBytes) {
      throw CsvValidationException('File must be under 10GB');
    }
  }

  static String buildScoreTemplate(List<Map<String, String>> rows) {
    final buffer = StringBuffer('StudentId,StudentName,CA,Exams\n');
    for (final row in rows) {
      buffer.writeln('${row['id']},${row['name']},${row['ca'] ?? ''},${row['exams'] ?? ''}');
    }
    return buffer.toString();
  }

  static List<Map<String, String>> parse(String content) {
    final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.length < 2) return [];
    final headers = lines.first.split(',').map((h) => h.trim()).toList();
    return lines.skip(1).map((line) {
      final values = line.split(',');
      final row = <String, String>{};
      for (var i = 0; i < headers.length && i < values.length; i++) {
        row[headers[i]] = values[i].trim();
      }
      return row;
    }).toList();
  }
}
