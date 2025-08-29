class QuickNote {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuickNote({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuickNote.fromJson(Map<String, dynamic> json) {
    return QuickNote(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
