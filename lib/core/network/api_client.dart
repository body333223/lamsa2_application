import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/exceptions.dart';

/// Clean Architecture HTTP client.
/// Handles headers, auth tokens, timeout, and exceptions.
class ApiClient {
  static const String baseUrl = 'http://192.168.1.24:3000/api'; // Local Wi-Fi network (iPhone & PC)
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'https://your-api.com/api'; // Production

  static const Duration _timeout = Duration(seconds: 30);
  static String? _cachedToken;

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('jwt_token');
    return _cachedToken;
  }

  static Future<void> setToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    bool auth = false,
    Map<String, String>? query,
  }) async {
    var url = Uri.parse('$baseUrl$path');
    if (query != null && query.isNotEmpty) {
      url = url.replace(queryParameters: query);
    }
    try {
      final response = await http
          .get(url, headers: await _headers(auth: auth))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    dynamic body,
    bool auth = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http
          .post(
            url,
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    dynamic body,
    bool auth = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http
          .put(
            url,
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<Map<String, dynamic>> patch(
    String path, {
    dynamic body,
    bool auth = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http
          .patch(
            url,
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http
          .delete(url, headers: await _headers(auth: auth))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<Map<String, dynamic>> uploadFile(
    String path, {
    required File file,
    required String fieldName,
    Map<String, String>? extraFields,
    bool auth = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final request = http.MultipartRequest('POST', url);
      if (auth) {
        final token = await getToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      if (extraFields != null) {
        request.fields.addAll(extraFields);
      }
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      data = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = data['message'] as String? ?? 'Error: ${response.statusCode}';
    if (response.statusCode == 401) {
      clearToken();
      throw UnauthorizedException(message);
    }
    throw ServerException(message, statusCode: response.statusCode);
  }
}
