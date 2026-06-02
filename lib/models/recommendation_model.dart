class RecommendationModel {
  final int id;
  final int userId;
  final Map<String, dynamic> config;
  final DateTime expiredAt;
  final String mlVersion;
  final DateTime generatedAt;

  RecommendationModel({
    required this.id,
    required this.userId,
    required this.config,
    required this.expiredAt,
    required this.mlVersion,
    required this.generatedAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      config: json['config'] is String 
          ? {} 
          : (json['config'] as Map<String, dynamic>? ?? {}),
      expiredAt: DateTime.parse(json['expired_at'] ?? DateTime.now().toIso8601String()),
      mlVersion: json['ml_version'] ?? 'unknown',
      generatedAt: DateTime.parse(json['generated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'config': config,
      'expired_at': expiredAt.toIso8601String(),
      'ml_version': mlVersion,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}
