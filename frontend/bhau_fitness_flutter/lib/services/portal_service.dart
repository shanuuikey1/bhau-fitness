import '../models/booking.dart';
import '../models/class_session.dart';
import '../models/water_log.dart';
import '../models/workout_log.dart';
import 'api_service.dart';

/// Mirrors AuthService's pattern — thin wrapper over ApiService for the
/// member-portal endpoints (classes, bookings, workout logs, water logs).
class PortalService {
  final ApiService _api = ApiService();

  Future<List<ClassSession>> fetchClasses({DateTime? date}) async {
    final query = date == null ? '' : '?date=${_dateOnly(date)}';
    final res = await _api.get('/classes$query') as List<dynamic>;
    return res.map((c) => ClassSession.fromJson(c as Map<String, dynamic>)).toList();
  }

  Future<List<Booking>> fetchMyBookings() async {
    final res = await _api.get('/bookings/me', auth: true) as List<dynamic>;
    return res.map((b) => Booking.fromJson(b as Map<String, dynamic>)).toList();
  }

  Future<Booking> bookClass({required int classSessionId, required DateTime classDate}) async {
    final res = await _api.post('/bookings', {
      'classSessionId': classSessionId,
      'classDate': _dateOnly(classDate),
    }, auth: true);
    return Booking.fromJson(res as Map<String, dynamic>);
  }

  Future<void> cancelBooking(int bookingId) async {
    await _api.delete('/bookings/$bookingId', auth: true);
  }

  Future<List<WorkoutLog>> fetchWorkoutLogs() async {
    final res = await _api.get('/workoutlogs', auth: true) as List<dynamic>;
    return res.map((w) => WorkoutLog.fromJson(w as Map<String, dynamic>)).toList();
  }

  Future<WorkoutLog> addWorkoutLog({
    required String exercise,
    required int sets,
    required int reps,
    required double weightKg,
  }) async {
    final res = await _api.post('/workoutlogs', {
      'exercise': exercise,
      'sets': sets,
      'reps': reps,
      'weightKg': weightKg,
    }, auth: true);
    return WorkoutLog.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteWorkoutLog(int id) async {
    await _api.delete('/workoutlogs/$id', auth: true);
  }

  Future<WaterLog> fetchTodayWater() async {
    final res = await _api.get('/waterlogs/today', auth: true);
    return WaterLog.fromJson(res as Map<String, dynamic>);
  }

  Future<WaterLog> setTodayWater(int glassCount) async {
    final res = await _api.put('/waterlogs/today', {'glassCount': glassCount}, auth: true);
    return WaterLog.fromJson(res as Map<String, dynamic>);
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
