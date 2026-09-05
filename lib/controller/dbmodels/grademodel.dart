class GradeBand {
  final double min;
  final double max;
  final String grade;
  final double weight;
  final String remarks;

  const GradeBand({
    required this.min,
    required this.max,
    required this.grade,
    required this.weight,
    required this.remarks,
  });

  GradeBand copyWith({
    double? min,
    double? max,
    String? grade,
    double? weight,
    String? remarks,
  }) {
    return GradeBand(
      min: min ?? this.min,
      max: max ?? this.max,
      grade: grade ?? this.grade,
      weight: weight ?? this.weight,
      remarks: remarks ?? this.remarks,
    );
  }

  factory GradeBand.fromMap(Map<String, dynamic> map) => GradeBand(
    min: (map['min'] as num?)?.toDouble() ?? 0,
    max: (map['max'] as num?)?.toDouble() ?? 0,
    grade: map['grade']?.toString() ?? '',
    weight: (map['weight'] as num?)?.toDouble() ?? 0,
    remarks: map['remarks']?.toString() ?? '',
  );

  Map<String, dynamic> toMap() => {
    'min': min,
    'max': max,
    'grade': grade,
    'weight': weight,
    'remarks': remarks,
  };
}

class GradingModel {
  final String id;
  final String schoolId;
  final String scope;
  final String? departmentId;
  final String? facultyName;
  final String name;
  final List<GradeBand> bands;
  final DateTime? updatedAt;
  final String? staff;

  const GradingModel({
    required this.id,
    required this.schoolId,
    required this.scope,
    this.departmentId,
    this.facultyName,
    required this.name,
    required this.bands,
    this.updatedAt,
    this.staff,
  });

  bool get isDefault => scope == 'default';

  factory GradingModel.fromMap(Map<String, dynamic> map) => GradingModel(
    id: map['id']?.toString() ?? '',
    schoolId: map['schoolId']?.toString() ?? map['schoolid']?.toString() ?? '',
    scope: map['scope']?.toString() ?? 'default',
    departmentId: map['departmentId']?.toString(),
    facultyName: map['facultyName']?.toString(),
    name: map['name']?.toString() ?? '',
    bands: (map['bands'] as List? ?? [])
        .map((e) => GradeBand.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    updatedAt: map['updatedAt'] != null
        ? DateTime.tryParse(map['updatedAt'].toString())
        : null,
    staff: map['staff']?.toString(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'schoolId': schoolId,
    'scope': scope,
    'departmentId': departmentId,
    'facultyName': facultyName,
    'name': name,
    'bands': bands.map((b) => b.toMap()).toList(),
    'staff': staff,
  };

  static String buildId(String schoolId, {required bool isDefault, String? departmentId}) {
    if (isDefault) return '${schoolId}_default';
    final key = (departmentId ?? '').toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return '${schoolId}_dept_$key';
  }


  static String? validate(List<GradeBand> bands) {
    if (bands.isEmpty) return 'Add at least one grade band.';
    final ranges = <List<double>>[];
    for (final band in bands) {
      if (band.grade.trim().isEmpty) return 'Every band needs a grade letter.';
      if (band.remarks.trim().isEmpty) return 'Every band needs a remark.';
      if (band.max <= band.min) {
        return 'Band "${band.grade}" has an invalid range (max must be greater than min).';
      }
      ranges.add([band.min, band.max]);
    }
    ranges.sort((a, b) => a[0].compareTo(b[0]));
    for (var i = 1; i < ranges.length; i++) {
      if (ranges[i][0] < ranges[i - 1][1] + 0.1) {
        return 'Grade ranges overlap. Leave at least 0.1 between boundaries.';
      }
    }
    return null;
  }
}