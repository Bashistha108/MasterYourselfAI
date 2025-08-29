class WeeklyGoal {
  final int id;
  final String title;
  final String? description;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final int rating;
  final bool completed;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyGoal({
    required this.id,
    required this.title,
    this.description,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.rating,
    required this.completed,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklyGoal.fromJson(Map<String, dynamic> json) {
    return WeeklyGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      weekStartDate: DateTime.parse(json['week_start_date']),
      weekEndDate: DateTime.parse(json['week_end_date']),
      rating: json['rating'] ?? 0,
      completed: json['completed'] ?? false,
      archived: json['archived'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'week_start_date': weekStartDate.toIso8601String(),
      'week_end_date': weekEndDate.toIso8601String(),
      'rating': rating,
      'completed': completed,
      'archived': archived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WeeklyGoal copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
    int? rating,
    bool? completed,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      rating: rating ?? this.rating,
      completed: completed ?? this.completed,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
