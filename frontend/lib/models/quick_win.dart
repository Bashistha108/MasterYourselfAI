class QuickWin {
  final int id;
  final String title;
  final String? description;
  final String category;
  final int points;
  final DateTime winDate;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuickWin({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.points,
    required this.winDate,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuickWin.fromJson(Map<String, dynamic> json) {
    return QuickWin(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'] ?? 'general',
      points: json['points'] ?? 1,
      winDate: DateTime.parse(json['win_date']),
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'win_date': winDate.toIso8601String(),
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  QuickWin copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    int? points,
    DateTime? winDate,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuickWin(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      points: points ?? this.points,
      winDate: winDate ?? this.winDate,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
