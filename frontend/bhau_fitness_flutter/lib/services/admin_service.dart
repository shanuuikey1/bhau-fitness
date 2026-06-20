import '../models/admin_overview.dart';
import '../models/class_session.dart';
import '../models/plan.dart';
import 'api_service.dart';

/// All endpoints here require the caller's JWT to carry the "Admin" role —
/// the backend enforces that with [Authorize(Roles = "Admin")]; this service
/// just calls them the same way AuthService/PortalService call member routes.
class AdminService {
  final ApiService _api = ApiService();

  Future<AdminOverview> fetchOverview() async {
    final res = await _api.get('/admin/overview', auth: true);
    return AdminOverview.fromJson(res as Map<String, dynamic>);
  }

  Future<List<AdminMemberSummary>> fetchMembers({String? search}) async {
    final query = (search == null || search.isEmpty) ? '' : '?search=${Uri.encodeQueryComponent(search)}';
    final res = await _api.get('/admin/members$query', auth: true) as List<dynamic>;
    return res.map((m) => AdminMemberSummary.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<void> promoteToAdmin(String userId) async {
    await _api.post('/admin/members/$userId/promote', {}, auth: true);
  }

  Future<void> grantMembership({required String userId, required int planId}) async {
    await _api.post('/admin/members/$userId/grant', {'planId': planId}, auth: true);
  }

  Future<void> deactivateMember(String userId) async {
    await _api.post('/admin/members/$userId/deactivate', {}, auth: true);
  }

  Future<Plan> createPlan({
    required String name,
    required double price,
    required int durationDays,
    String? description,
  }) async {
    final res = await _api.post('/plans', {
      'name': name,
      'price': price,
      'durationDays': durationDays,
      'description': description,
    }, auth: true);
    return Plan.fromJson(res as Map<String, dynamic>);
  }

  Future<Plan> updatePlan({
    required int id,
    required String name,
    required double price,
    required int durationDays,
    required bool isActive,
    String? description,
  }) async {
    final res = await _api.put('/plans/$id', {
      'name': name,
      'price': price,
      'durationDays': durationDays,
      'isActive': isActive,
      'description': description,
    }, auth: true);
    return Plan.fromJson(res as Map<String, dynamic>);
  }

  Future<ClassSession> createClass({
    required int dayOfWeek,
    required String startTime, // "HH:mm:ss"
    required String title,
    required String trainerName,
    required String level,
    required String type,
    required int durationMin,
    required String dayLabel,
    required int capacity,
  }) async {
    final res = await _api.post('/classes', {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'title': title,
      'trainerName': trainerName,
      'level': level,
      'type': type,
      'durationMin': durationMin,
      'dayLabel': dayLabel,
      'capacity': capacity,
    }, auth: true);
    return ClassSession.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deactivateClass(int id) async {
    await _api.delete('/classes/$id', auth: true);
  }
}
