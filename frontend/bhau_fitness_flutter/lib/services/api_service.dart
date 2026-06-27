import 'dart:convert';
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
  //
  // Check the exact port your API is actually running on (printed in the
  // terminal when you `dotnet run` — it's often 5000/5001 or a random one
  // assigned by Visual Studio; adjust below to match).
  // ─────────────────────────────────────────────────────────────────────
  // Overridable at build time so the hosted web build can point at the deployed
  // API instead of localhost. Production build:
  //   flutter build web --dart-define=API_BASE_URL=https://<your-api>.onrender.com/api
  // With no override it falls back to localhost for local development.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

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
}
