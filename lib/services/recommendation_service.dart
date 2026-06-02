import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/recommendation_model.dart';
import 'session_manager.dart';
import 'auth_service.dart';

class RecommendationService {
  /// Fetch ML recommendations for products
  static Future<RecommendationModel?> fetchRecommendations() async {
    final token = SessionManager.token;
    final user = SessionManager.currentUser;

    if (token == null || user == null) {
      return null;
    }

    final uri = Uri.parse('${AuthService.baseUrl}/recommendations/${user.id}');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return RecommendationModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('[RecommendationService] Gagal memuat rekomendasi ML: $e');
      return null;
    }
  }
}
