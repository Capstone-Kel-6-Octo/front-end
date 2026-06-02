class ConsentModel {
  final int id;
  final int userId;
  final bool consentGiven;
  final String consentType;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsentModel({
    required this.id,
    required this.userId,
    required this.consentGiven,
    required this.consentType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsentModel.fromJson(Map<String, dynamic> json) {
    return ConsentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      consentGiven: json['consent_given'] is bool
          ? json['consent_given']
          : json['consent_given'] == 'true' || json['consent_given'] == 1,
      consentType: json['consent_type'] ?? 'data_sharing',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'consent_given': consentGiven,
      'consent_type': consentType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
