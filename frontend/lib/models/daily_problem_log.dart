class DailyProblemLog {
  final int id;
  final int problemId;
  final DateTime date;
  final bool faced;
  final int? intensity; // 1, 2, or 3 points
  final DateTime createdAt;

  DailyProblemLog({
    required this.id,
    required this.problemId,
    required this.date,
    required this.faced,
    this.intensity,
    required this.createdAt,
  });

  factory DailyProblemLog.fromJson(Map<String, dynamic> json) {
    return DailyProblemLog(
      id: json['id'],
      problemId: json['problem_id'],
      date: DateTime.parse(json['date']),
      faced: json['faced'] ?? false,
      intensity: json['intensity'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'problem_id': problemId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'faced': faced,
      'intensity': intensity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DailyProblemLog copyWith({
    int? id,
    int? problemId,
    DateTime? date,
    bool? faced,
    int? intensity,
    DateTime? createdAt,
  }) {
    return DailyProblemLog(
      id: id ?? this.id,
      problemId: problemId ?? this.problemId,
      date: date ?? this.date,
      faced: faced ?? this.faced,
      intensity: intensity ?? this.intensity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
