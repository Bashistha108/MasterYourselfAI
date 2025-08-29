class DailyGoalIntensity {
  final int id;
  final int goalId;
  final DateTime intensityDate;
  final int intensity;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyGoalIntensity({
    required this.id,
    required this.goalId,
    required this.intensityDate,
    required this.intensity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyGoalIntensity.fromJson(Map<String, dynamic> json) {
    return DailyGoalIntensity(
      id: json['id'],
      goalId: json['goal_id'],
      intensityDate: DateTime.parse(json['intensity_date']),
      intensity: json['intensity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'intensity_date': intensityDate.toIso8601String().split('T')[0],
      'intensity': intensity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DailyGoalIntensity copyWith({
    int? id,
    int? goalId,
    DateTime? intensityDate,
    int? intensity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyGoalIntensity(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      intensityDate: intensityDate ?? this.intensityDate,
      intensity: intensity ?? this.intensity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
