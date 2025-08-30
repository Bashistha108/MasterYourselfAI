class Email {
  final String id;
  final String subject;
  final String sender;
  final String? recipient;
  final String content;
  final DateTime date;
  final String type;
  bool isRead;

  Email({
    required this.id,
    required this.subject,
    required this.sender,
    this.recipient,
    required this.content,
    required this.date,
    required this.type,
    this.isRead = false,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      id: json['id'],
      subject: json['subject'],
      sender: json['sender'],
      recipient: json['recipient'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      type: json['type'] ?? 'received',
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'sender': sender,
      'recipient': recipient,
      'content': content,
      'date': date.toIso8601String(),
      'type': type,
      'isRead': isRead,
    };
  }

  String get preview {
    return content.length > 100 
        ? '${content.substring(0, 100)}...' 
        : content;
  }
}
