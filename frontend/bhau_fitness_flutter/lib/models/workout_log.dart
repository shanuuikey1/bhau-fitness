/// Mirrors WorkoutLogDto on the backend.
class WorkoutLog {
  final int id;
  final String exercise;
  final int sets;
  final int reps;
  final double weightKg;
  final DateTime loggedDate;

  WorkoutLog({
    required this.id,
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weightKg,
    required this.loggedDate,
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as int,
      exercise: json['exercise'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weightKg: (json['weightKg'] as num).toDouble(),
      loggedDate: DateTime.parse(json['loggedDate'] as String),
    );
  }
}
