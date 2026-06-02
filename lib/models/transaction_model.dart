class TransactionModel {
  final int id;
  final int userId;
  final String transactionType;
  final String transactionCategory;
  final double amount;
  final String status;
  final DateTime transactionTime;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.transactionCategory,
    required this.amount,
    required this.status,
    required this.transactionTime,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      transactionType: json['transaction_type'] ?? 'debit',
      transactionCategory: json['transaction_category'] ?? 'transfer',
      amount: json['amount'] is double
          ? json['amount']
          : double.parse(json['amount'].toString()),
      status: json['status'] ?? 'SUCCESS',
      transactionTime: DateTime.parse(json['transaction_time'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'transaction_type': transactionType,
      'transaction_category': transactionCategory,
      'amount': amount,
      'status': status,
      'transaction_time': transactionTime.toIso8601String(),
    };
  }
}
