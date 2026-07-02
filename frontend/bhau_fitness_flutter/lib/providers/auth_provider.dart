import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.unknown;
  Member? profile;
  bool isLoading = false;
  String? errorMessage;

  /// Call once on app startup — checks for a stored token and, if present,
  /// tries to load the profile to confirm it's still valid.
  Future<void> tryAutoLogin() async {
    final hasSession = await _authService.hasStoredSession();
    if (!hasSession) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      profile = await _authService.fetchProfile();
      status = AuthStatus.authenticated;
    } catch (_) {
      // Stored token is invalid/expired — fall back to logged-out state.
      await _authService.logout();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password, {bool remember = true}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await _authService.login(email: email, password: password, remember: remember);
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'Could not reach the server. Check the API is running and the base URL is correct.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String goal,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        goal: goal,
      );
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'Could not reach the server. Check the API is running and the base URL is correct.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    profile = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String goal,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await _authService.updateProfile(fullName: fullName, phone: phone, goal: goal);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'Could not reach the server. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
