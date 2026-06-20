/// Mirrors ClassSessionDto on the backend.
class ClassSession {
  final int id;
  final int dayOfWeek; // ISO: 1=Monday .. 7=Sunday
  final String startTime; // "HH:mm:ss" as serialized by ASP.NET's TimeOnly
  final String title;
  final String trainerName;
  final String level;
  final String type;
  final int durationMin;
  final String dayLabel;
  final int capacity;
  final int bookedCount;

  ClassSession({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.title,
    required this.trainerName,
    required this.level,
    required this.type,
    required this.durationMin,
    required this.dayLabel,
    required this.capacity,
    required this.bookedCount,
  });

  /// "06:00:00" -> "06:00" for display.
  String get startTimeShort => startTime.length >= 5 ? startTime.substring(0, 5) : startTime;

  bool get isFull => bookedCount >= capacity;

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      id: json['id'] as int,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      title: json['title'] as String,
      trainerName: json['trainerName'] as String,
      level: json['level'] as String,
      type: json['type'] as String? ?? 'General',
      durationMin: json['durationMin'] as int? ?? 60,
      dayLabel: json['dayLabel'] as String? ?? '',
      capacity: json['capacity'] as int,
      bookedCount: json['bookedCount'] as int,
    );
  }
}

const weekdayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
