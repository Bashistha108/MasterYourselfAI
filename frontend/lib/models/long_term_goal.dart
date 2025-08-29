class LongTermGoal {
  final int id;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? targetDate;
  final String status;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  LongTermGoal({
    required this.id,
    required this.title,
    this.description,
    this.startDate,
    this.targetDate,
    required this.status,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LongTermGoal.fromJson(Map<String, dynamic> json) {
    return LongTermGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      targetDate: json['target_date'] != null ? DateTime.parse(json['target_date']) : null,
      status: json['status'] ?? 'active',
      archived: json['archived'] ?? false,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'target_date': targetDate?.toIso8601String(),
      'status': status,
      'archived': archived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LongTermGoal copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? targetDate,
    String? status,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LongTermGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed properties
  bool get isCompleted => status == 'completed';
  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';

  /// Calculate progress percentage based on days passed vs total target days
  double get progressPercentage {
    // If completed, show 100%
    if (isCompleted) return 1.0;
    
    // If paused, show 50%
    if (isPaused) return 0.5;
    
    // If no start date or target date, show 0%
    if (startDate == null || targetDate == null) return 0.0;
    
    final now = DateTime.now();
    final start = startDate!;
    final end = targetDate!;
    
    // If past target date, show 100%
    if (now.isAfter(end)) return 1.0;
    
    // If before start date, show 0%
    if (now.isBefore(start)) return 0.0;
    
    final totalDays = end.difference(start).inDays;
    final daysPassed = now.difference(start).inDays;
    
    // Avoid division by zero
    if (totalDays <= 0) return 1.0;
    
    // Progress = daysPassed / totalDays
    // Example: If target is 200 days and 100 days passed, progress = 100/200 = 0.5 (50%)
    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }

  /// Get days remaining until target date
  int? get daysRemaining {
    if (startDate == null || targetDate == null || isCompleted) return null;
    
    final now = DateTime.now();
    final remaining = targetDate!.difference(now).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Get formatted time remaining string
  String? get timeRemainingString {
    final days = daysRemaining;
    if (days == null) return null;
    
    if (days == 0) return 'Due today';
    if (days == 1) return '1 day left';
    if (days < 7) return '$days days left';
    if (days < 30) return '${(days / 7).round()} weeks left';
    return '${(days / 30).round()} months left';
  }

  /// Get total days for the goal (from start to target)
  int? get totalDays {
    if (startDate == null || targetDate == null) return null;
    
    final total = targetDate!.difference(startDate!).inDays;
    return total > 0 ? total : 1;
  }
}
