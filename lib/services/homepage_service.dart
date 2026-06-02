import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/homepage_config.dart';
import 'session_manager.dart';
import 'auth_service.dart';

class HomepageService {
  /// Fetch dynamic homepage configuration from backend based on user segment / ML output
  static Future<HomepageConfig> fetchHomepageConfig() async {
    final baseUrl = AuthService.baseUrl;
    final uri = Uri.parse('$baseUrl/homepage');

    final token = SessionManager.token;
    if (token == null) {
      throw Exception('Sesi tidak ditemukan. Silakan login kembali.');
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataJson = responseData['data'];
        if (dataJson == null) {
          throw Exception('Format respons salah: data kosong');
        }

        final userJson = responseData['user'];
        final String? userName = userJson?['name'];
        final double? userBalance = userJson?['balance'] != null
            ? double.tryParse(userJson!['balance'].toString())
            : null;

        return HomepageConfig.fromJson(
          dataJson,
          userName: userName,
          userBalance: userBalance,
        );
      } else {
        final errorMsg = responseData['message'] ?? responseData['error'] ?? 'Gagal mengambil konfigurasi beranda';
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }
}
