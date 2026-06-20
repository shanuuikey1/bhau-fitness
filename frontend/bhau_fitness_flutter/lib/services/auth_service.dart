import '../models/member.dart';
import '../models/plan.dart';
import '../models/membership.dart';
import 'api_service.dart';
import 'token_storage.dart';

class AuthService {
  final ApiService _api = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Member> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String goal,
  }) async {
    final res = await _api.post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'goal': goal,
    });
    await _tokenStorage.saveToken(res['token'] as String);
    return Member.fromJson(res['profile'] as Map<String, dynamic>);
  }

  Future<Member> login({required String email, required String password}) async {
    final res = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    await _tokenStorage.saveToken(res['token'] as String);
    return Member.fromJson(res['profile'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  /// Always succeeds (the API never reveals whether the email exists).
  Future<void> forgotPassword(String email) async {
    await _api.post('/auth/forgot-password', {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    await _api.post('/auth/reset-password', {
      'email': email,
      'token': token,
      'newPassword': newPassword,
    });
  }

  Future<bool> hasStoredSession() async {
    final token = await _tokenStorage.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<Member> fetchProfile() async {
    final res = await _api.get('/members/me', auth: true);
    return Member.fromJson(res as Map<String, dynamic>);
  }

  Future<Member> updateProfile({
    required String fullName,
    required String phone,
    required String goal,
  }) async {
    final res = await _api.put('/members/me', {
      'fullName': fullName,
      'phone': phone,
      'goal': goal,
    }, auth: true);
    return Member.fromJson(res as Map<String, dynamic>);
  }

  Future<List<Plan>> fetchPlans() async {
    final res = await _api.get('/plans') as List<dynamic>;
    return res.map((p) => Plan.fromJson(p as Map<String, dynamic>)).toList();
  }

  /// Returns null if the member has no active membership (API returns 404,
  /// which surfaces here as an ApiException — caught and treated as "none").
  Future<Membership?> fetchMyMembership() async {
    try {
      final res = await _api.get('/memberships/me', auth: true);
      return Membership.fromJson(res as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Membership> joinPlan(int planId) async {
    final res = await _api.post('/memberships', {'planId': planId}, auth: true);
    return Membership.fromJson(res as Map<String, dynamic>);
  }
}
