class Reminder {
  final int id;
  final String title;
  final String type; // 'medication', 'vaccine', 'followup'
  final int hour;
  final int minute;
  final bool isDone;

  Reminder({
    required this.id,
    required this.title,
    required this.type,
    required this.hour,
    required this.minute,
    required this.isDone,
  });

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'],
        title: json['title'],
        type: json['type'],
        hour: json['hour'],
        minute: json['minute'],
        isDone: json['is_done'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'hour': hour,
        'minute': minute,
        'is_done': isDone,
      };
}