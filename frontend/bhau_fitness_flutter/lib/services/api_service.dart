import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

/// Thrown when the API returns a non-2xx response, carrying the server's
/// error message (the backend always returns { "error": "..." } on failure).
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiService {
  // ─────────────────────────────────────────────────────────────────────
  // IMPORTANT — this URL almost never works as-is on first run. "localhost"
  // means different things depending on where the app is actually running:
  //
  //   • Android emulator  -> use http://10.0.2.2:5000  (special alias the
  //                          emulator maps to your host machine's localhost)
  //   • iOS simulator     -> http://localhost:5000 works fine as-is
  //   • Physical device   -> use your computer's actual LAN IP, e.g.
  //                          http://192.168.1.42:5000  (device and computer
  //                          must be on the same Wi-Fi network)
  //   • Flutter web (chrome) -> http://localhost:5000 works fine as-is
  // ─────────────────────────────────────────────────────────────────────
  
  static String get baseUrl {
    const definedUrl = String.fromEnvironment('API_BASE_URL');
    if (definedUrl.isNotEmpty) return definedUrl;
    
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _tokenStorage.readToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decode(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    
    String message = 'Request failed (${res.statusCode}).';
    if (body is Map) {
      if (body['error'] != null) {
        message = body['error'].toString();
      } else if (body['errors'] != null) {
        final errs = body['errors'];
        if (errs is Map) {
          final messages = <String>[];
          errs.forEach((key, value) {
            if (value is List) {
              messages.addAll(value.map((e) => e.toString()));
            } else {
              messages.add(value.toString());
            }
          });
          if (messages.isNotEmpty) {
            message = messages.join(' ');
          }
        }
      } else if (body['title'] != null) {
        message = body['title'].toString();
      }
    }
    
    throw ApiException(res.statusCode, message);
  }

  Future<dynamic> get(String path, {bool auth = false}) async {
    final res = await http
        .get(Uri.parse('$baseUrl$path'), headers: await _headers(auth: auth))
        .timeout(const Duration(seconds: 15));
    return _decode(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = false}) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(auth: auth),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _decode(res);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body, {bool auth = false}) async {
    final res = await http
        .put(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(auth: auth),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _decode(res);
  }

  Future<dynamic> delete(String path, {bool auth = false}) async {
    final res = await http
        .delete(Uri.parse('$baseUrl$path'), headers: await _headers(auth: auth))
        .timeout(const Duration(seconds: 15));
    return _decode(res);
  }

  Future<Map<String, dynamic>> getWorkoutPlan(Map<String, dynamic> body) async {
    final res = await post('/ai/workout-plan', body, auth: true);
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> getDietPlan(Map<String, dynamic> body) async {
    final res = await post('/ai/diet-plan', body, auth: true);
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> getMotivationalTip() async {
    final res = await get('/ai/tip', auth: true);
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> createPaymentOrder(int planId) async {
    final res = await post('/payments/create-order', {'planId': planId}, auth: true);
    return Map<String, dynamic>.from(res);
  }

  Future<void> verifyPayment(String orderId, String paymentId, String signature) async {
    await post('/payments/verify', {
      'razorpayOrderId': orderId,
      'razorpayPaymentId': paymentId,
      'razorpaySignature': signature,
    }, auth: true);
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final res = await get('/payments/history', auth: true) as List;
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> getAnalyticsOverview() async {
    final res = await get('/analytics/overview', auth: true);
    return Map<String, dynamic>.from(res);
  }

  Future<List<Map<String, dynamic>>> getRevenueTrend() async {
    final res = await get('/analytics/revenue-trend', auth: true) as List;
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getPopularClasses() async {
    final res = await get('/analytics/popular-classes', auth: true) as List;
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getMembershipDistribution() async {
    final res = await get('/analytics/membership-distribution', auth: true) as List;
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final res = await get('/notifications', auth: true) as List;
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<int> getUnreadCount() async {
    final res = await get('/notifications/unread-count', auth: true);
    return res['count'] as int;
  }

  Future<void> markNotificationRead(int id) async {
    await put('/notifications/$id/read', {}, auth: true);
  }

  Future<void> markAllNotificationsRead() async {
    await put('/notifications/read-all', {}, auth: true);
  }
}
