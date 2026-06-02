import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'session_manager.dart';
import 'auth_service.dart';

class InteractionService {
  /// Log dynamic user interaction (e.g., clicks on dashboard features) in the background.
  /// This is completely non-blocking to keep UI rendering and transitions running at maximum FPS.
  static void logInteraction(int featureId, String interactionType) {
    // Run as an un-awaited background microtask so it does not block click animations
    Future.microtask(() async {
      final token = SessionManager.token;
      if (token == null) {
        debugPrint('[InteractionLogger] Sesi tidak ditemukan. Lewati pencatatan.');
        return;
      }

      final baseUrl = AuthService.baseUrl;
      final uri = Uri.parse('$baseUrl/interactions');

      try {
        debugPrint('[InteractionLogger] Mengirim data log interaksi (feature_id: $featureId, tipe: $interactionType) ke backend...');
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'feature_id': featureId,
            'interaction_type': interactionType,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('[InteractionLogger] Interaksi berhasil dicatat di server.');
        } else {
          debugPrint('[InteractionLogger] Gagal mencatat interaksi. Status: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('[InteractionLogger] Error mencatat interaksi: $e');
      }
    });
  }
}
