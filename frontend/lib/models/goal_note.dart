class GoalNote {
  final int id;
  final int goalId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalNote({
    required this.id,
    required this.goalId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalNote.fromJson(Map<String, dynamic> json) {
    return GoalNote(
      id: json['id'],
      goalId: json['goal_id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GoalNote copyWith({
    int? id,
    int? goalId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalNote(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
