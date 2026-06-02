import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/consent_model.dart';
import 'session_manager.dart';
import 'auth_service.dart';

class ConsentService {
  static bool _localSimulatedConsent = true;

  /// Fetch user privacy consent
  static Future<ConsentModel?> fetchUserConsent() async {
    final token = SessionManager.token;
    final user = SessionManager.currentUser;

    if (token == null || user == null) {
      return ConsentModel(
        id: 1,
        userId: 1,
        consentGiven: _localSimulatedConsent,
        consentType: 'data_sharing',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      );
    }

    final uri = Uri.parse('${AuthService.baseUrl}/consents/${user.id}');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return ConsentModel.fromJson(data[0]);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[ConsentService] Gagal memuat consent dari server. Menggunakan offline fallback: $e');
      return ConsentModel(
        id: 1,
        userId: user.id,
        consentGiven: _localSimulatedConsent,
        consentType: 'data_sharing',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Create initial consent
  static Future<ConsentModel> createConsent(bool consentGiven) async {
    final token = SessionManager.token;
    final user = SessionManager.currentUser;

    _localSimulatedConsent = consentGiven;

    final mockResponse = ConsentModel(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: user?.id ?? 1,
      consentGiven: consentGiven,
      consentType: 'data_sharing',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (token == null || user == null) {
      return mockResponse;
    }

    final uri = Uri.parse('${AuthService.baseUrl}/consents');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'consent_given': consentGiven,
          'consent_type': 'data_sharing',
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ConsentModel.fromJson(responseData['data']);
      } else {
        return mockResponse;
      }
    } catch (e) {
      return mockResponse;
    }
  }

  /// Update privacy consent (e.g. from Settings screen)
  static Future<ConsentModel> updateConsent(bool consentGiven) async {
    final token = SessionManager.token;
    final user = SessionManager.currentUser;

    _localSimulatedConsent = consentGiven;

    final mockResponse = ConsentModel(
      id: 1,
      userId: user?.id ?? 1,
      consentGiven: consentGiven,
      consentType: 'data_sharing',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    );

    if (token == null || user == null) {
      return mockResponse;
    }

    final uri = Uri.parse('${AuthService.baseUrl}/consents/${user.id}');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'consent_given': consentGiven,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ConsentModel.fromJson(responseData['data']);
      } else {
        return mockResponse;
      }
    } catch (e) {
      return mockResponse;
    }
  }
}
