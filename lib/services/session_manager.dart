class UserModel {
  final int id;
  final String name;
  final String email;
  final String? role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

class SessionManager {
  static String? token;
  static UserModel? currentUser;
  static bool isInfoBannerDismissed = false;

  static bool get isLoggedIn => token != null;

  static void saveSession(String userToken, UserModel user) {
    token = userToken;
    currentUser = user;
    isInfoBannerDismissed = false;
  }

  static void clearSession() {
    token = null;
    currentUser = null;
    isInfoBannerDismissed = false;
  }
}
