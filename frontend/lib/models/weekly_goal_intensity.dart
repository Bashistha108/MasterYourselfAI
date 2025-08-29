class WeeklyGoalIntensity {
  final int id;
  final int goalId;
  final DateTime weekStart;
  final int intensity;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyGoalIntensity({
    required this.id,
    required this.goalId,
    required this.weekStart,
    required this.intensity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklyGoalIntensity.fromJson(Map<String, dynamic> json) {
    return WeeklyGoalIntensity(
      id: json['id'],
      goalId: json['goal_id'],
      weekStart: DateTime.parse(json['week_start']),
      intensity: json['intensity'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'week_start': weekStart.toIso8601String(),
      'intensity': intensity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WeeklyGoalIntensity copyWith({
    int? id,
    int? goalId,
    DateTime? weekStart,
    int? intensity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyGoalIntensity(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      weekStart: weekStart ?? this.weekStart,
      intensity: intensity ?? this.intensity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
