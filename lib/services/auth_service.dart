import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class AuthService {
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // BASE URL FOR BACKEND API
  // Automatically detects platform:
  // - Web (Chrome/Firefox/Edge) -> 'http://localhost:3000'
  // - Android Emulator -> 'http://10.0.2.2:3000'
  // - iOS Emulator / Windows / Desktop -> 'http://localhost:3000'
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    return 'https://acrobat-gaffe-compile.ngrok-free.dev';
  }

  /// Register a new user
  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String token = data['token'];
        final UserModel user = UserModel.fromJson(data['user']);
        SessionManager.saveSession(token, user);
      } else {
        final String errorMsg =
            data['error'] ?? data['message'] ?? 'Pendaftaran gagal';
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Login an existing user
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String token = data['token'];
        final UserModel user = UserModel.fromJson(data['user']);
        SessionManager.saveSession(token, user);
      } else {
        final String errorMsg =
            data['message'] ?? data['error'] ?? 'Login gagal';
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }
}
