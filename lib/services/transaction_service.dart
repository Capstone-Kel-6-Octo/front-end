import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import 'session_manager.dart';
import 'auth_service.dart';

class TransactionService {
  static final List<TransactionModel> _localMockTransactions = [
    TransactionModel(
      id: 101,
      userId: 1,
      transactionType: 'credit',
      transactionCategory: 'payroll',
      amount: 1500000.0,
      status: 'SUCCESS',
      transactionTime: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionModel(
      id: 102,
      userId: 1,
      transactionType: 'debit',
      transactionCategory: 'transfer',
      amount: 120000.0,
      status: 'SUCCESS',
      transactionTime: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TransactionModel(
      id: 103,
      userId: 1,
      transactionType: 'debit',
      transactionCategory: 'pembayaran',
      amount: 45000.0,
      status: 'SUCCESS',
      transactionTime: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  /// Fetch transaction history from backend
  static Future<List<TransactionModel>> fetchUserTransactions() async {
    final token = SessionManager.token;
    final user = SessionManager.currentUser;

    if (token == null || user == null) {
      return _localMockTransactions;
    }

    final uri = Uri.parse('${AuthService.baseUrl}/transactions/${user.id}');

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
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        debugPrint('[TransactionService] Server error. Menggunakan fallback lokal.');
        return _localMockTransactions;
      }
    } catch (e) {
      debugPrint('[TransactionService] Network failure. Menggunakan fallback lokal: $e');
      return _localMockTransactions;
    }
  }

  /// Create a new transaction (send money/topup)
  static Future<TransactionModel> createTransaction({
    required String transactionType,
    required String transactionCategory,
    required double amount,
    required String status,
  }) async {
    final token = SessionManager.token;
    final user = SessionManager.currentUser;

    final mockResponse = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: user?.id ?? 1,
      transactionType: transactionType,
      transactionCategory: transactionCategory,
      amount: amount,
      status: status,
      transactionTime: DateTime.now(),
    );

    if (token == null || user == null) {
      _localMockTransactions.insert(0, mockResponse);
      return mockResponse;
    }

    final uri = Uri.parse('${AuthService.baseUrl}/transactions');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'transaction_type': transactionType,
          'transaction_category': transactionCategory,
          'amount': amount,
          'status': status,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newTx = TransactionModel.fromJson(responseData['data']);
        _localMockTransactions.insert(0, newTx);
        return newTx;
      } else {
        debugPrint('[TransactionService] Server save failed. Menggunakan fallback lokal.');
        _localMockTransactions.insert(0, mockResponse);
        return mockResponse;
      }
    } catch (e) {
      debugPrint('[TransactionService] Network error during post. Menggunakan fallback lokal.');
      _localMockTransactions.insert(0, mockResponse);
      return mockResponse;
    }
  }

  /// Melakukan transfer dana ke pengguna lain
  static Future<bool> transfer({
    required int receiverId,
    required double amount,
  }) async {
    final token = SessionManager.token;
    if (token == null) {
      throw Exception('Sesi tidak ditemukan. Silakan login kembali.');
    }

    final uri = Uri.parse('${AuthService.baseUrl}/transactions/transfer');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'receiver_id': receiverId,
          'amount': amount,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorMsg = responseData['message'] ?? responseData['error'] ?? 'Gagal melakukan transfer';
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mengambil nama penerima berdasarkan ID (Lookup)
  static Future<String> fetchRecipientName(int userId) async {
    final token = SessionManager.token;
    if (token == null) {
      throw Exception('Sesi tidak ditemukan. Silakan login kembali.');
    }

    final uri = Uri.parse('${AuthService.baseUrl}/users/$userId');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData['name'] ?? 'Pengguna Tanpa Nama';
      } else {
        final errorMsg = responseData['message'] ?? 'Penerima tidak ditemukan';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Penerima tidak ditemukan');
    }
  }
}
