/// Mirrors BookingDto on the backend.
class Booking {
  final int id;
  final int classSessionId;
  final String classTitle;
  final String trainerName;
  final String startTime;
  final DateTime classDate;
  final String status;

  Booking({
    required this.id,
    required this.classSessionId,
    required this.classTitle,
    required this.trainerName,
    required this.startTime,
    required this.classDate,
    required this.status,
  });

  String get startTimeShort => startTime.length >= 5 ? startTime.substring(0, 5) : startTime;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      classSessionId: json['classSessionId'] as int,
      classTitle: json['classTitle'] as String,
      trainerName: json['trainerName'] as String,
      startTime: json['startTime'] as String,
      classDate: DateTime.parse(json['classDate'] as String),
      status: json['status'] as String,
    );
  }
}
