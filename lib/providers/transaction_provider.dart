import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  double _octoPayBalance = 1500000.0; // Base balance

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  double get octoPayBalance => _octoPayBalance;

  /// Fetch dynamic transactions from backend and recalculate balance
  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final txList = await TransactionService.fetchUserTransactions();
      _transactions = txList;

      // Recalculate balance dynamically
      double balance = 1500000.0;
      for (var tx in _transactions) {
        if (tx.status.toUpperCase() == 'SUCCESS') {
          if (tx.transactionType.toLowerCase() == 'credit') {
            balance += tx.amount;
          } else {
            balance -= tx.amount;
          }
        }
      }
      _octoPayBalance = balance;
    } catch (e) {
      debugPrint('[TransactionProvider] Error fetching: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a transfer/topup transaction
  Future<bool> sendTransaction({
    required String category,
    required double amount,
    required String type,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await TransactionService.createTransaction(
        transactionType: type,
        transactionCategory: category,
        amount: amount,
        status: 'SUCCESS',
      );

      // Re-fetch to synchronize all transactions and balances
      await fetchTransactions();
      return true;
    } catch (e) {
      debugPrint('[TransactionProvider] Error creating transaction: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set the balance directly (e.g. from homepage sync)
  void updateBalance(double balance) {
    _octoPayBalance = balance;
    notifyListeners();
  }

  /// Melakukan transfer saldo secara dinamis ke pengguna lain
  Future<bool> performTransfer({
    required int receiverId,
    required double amount,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await TransactionService.transfer(
        receiverId: receiverId,
        amount: amount,
      );

      if (success) {
        _octoPayBalance -= amount;
        await fetchTransactions();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[TransactionProvider] Error performing transfer: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
