class Problem {
  final int id;
  final String title;
  final String? description;
  final String category;
  final double weight;
  final String status;
  final DateTime? lastLoggedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Problem({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.weight,
    required this.status,
    this.lastLoggedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'],
      title: json['name'] ?? json['title'], // Backend uses 'name', frontend uses 'title'
      description: json['description'],
      category: json['category'] ?? 'general',
      weight: (json['weight'] ?? 1.0).toDouble(),
      status: json['status'] ?? 'active',
      lastLoggedDate: json['last_logged_date'] != null ? DateTime.parse(json['last_logged_date']) : null,
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
      'weight': weight,
      'status': status,
      'last_logged_date': lastLoggedDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Problem copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? weight,
    String? status,
    DateTime? lastLoggedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Problem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      lastLoggedDate: lastLoggedDate ?? this.lastLoggedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
