/// Mirrors WaterLogDto on the backend.
class WaterLog {
  final DateTime logDate;
  final int glassCount;

  WaterLog({required this.logDate, required this.glassCount});

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      logDate: DateTime.parse(json['logDate'] as String),
      glassCount: json['glassCount'] as int,
    );
  }
}
