import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'session_manager.dart';
import 'auth_service.dart';

class UserService {
  /// Fetch user profile details
  static Future<UserModel?> fetchUserProfile() async {
    final token = SessionManager.token;
    final user = SessionManager.currentUser;

    if (token == null || user == null) {
      return SessionManager.currentUser;
    }

    final uri = Uri.parse('${AuthService.baseUrl}/users/${user.id}');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final updatedUser = UserModel.fromJson(responseData);
        SessionManager.currentUser = updatedUser;
        return updatedUser;
      }
      return SessionManager.currentUser;
    } catch (e) {
      debugPrint('[UserService] Gagal sinkronisasi profil: $e');
      return SessionManager.currentUser;
    }
  }

  /// Update user profile details
  static Future<UserModel> updateUserProfile({
    required String name,
    required String email,
  }) async {
    final token = SessionManager.token;
    final user = SessionManager.currentUser;

    final mockUpdatedUser = UserModel(
      id: user?.id ?? 1,
      name: name,
      email: email,
      role: user?.role ?? 'user',
    );

    if (token == null || user == null) {
      SessionManager.currentUser = mockUpdatedUser;
      return mockUpdatedUser;
    }

    final uri = Uri.parse('${AuthService.baseUrl}/users/${user.id}');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedUser = UserModel.fromJson(responseData);
        SessionManager.currentUser = updatedUser;
        return updatedUser;
      } else {
        SessionManager.currentUser = mockUpdatedUser;
        return mockUpdatedUser;
      }
    } catch (e) {
      debugPrint('[UserService] Error updating profile. Fallback local.');
      SessionManager.currentUser = mockUpdatedUser;
      return mockUpdatedUser;
    }
  }
}
