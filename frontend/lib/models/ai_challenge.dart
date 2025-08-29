class AIChallenge {
  final int? id;
  final String userId;
  final String challengeText;
  final DateTime challengeDate;
  final bool completed;
  final DateTime? completedAt;
  final int intensity; // -3 to 3 scale
  final int? regenerationCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  AIChallenge({
    this.id,
    required this.userId,
    required this.challengeText,
    required this.challengeDate,
    required this.completed,
    this.completedAt,
    this.intensity = 0,
    this.regenerationCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AIChallenge.fromJson(Map<String, dynamic> json) {
    return AIChallenge(
      id: json['id'],
      userId: json['user_id'],
      challengeText: json['challenge_text'],
      challengeDate: DateTime.parse(json['challenge_date']),
      completed: json['completed'],
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      intensity: json['intensity'] ?? 0,
      regenerationCount: json['regeneration_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'challenge_text': challengeText,
      'challenge_date': challengeDate.toIso8601String().split('T')[0],
      'completed': completed,
      'completed_at': completedAt?.toIso8601String(),
      'intensity': intensity,
      'regeneration_count': regenerationCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AIChallenge copyWith({
    int? id,
    String? userId,
    String? challengeText,
    DateTime? challengeDate,
    bool? completed,
    DateTime? completedAt,
    int? intensity,
    int? regenerationCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AIChallenge(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeText: challengeText ?? this.challengeText,
      challengeDate: challengeDate ?? this.challengeDate,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      intensity: intensity ?? this.intensity,
      regenerationCount: regenerationCount ?? this.regenerationCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
