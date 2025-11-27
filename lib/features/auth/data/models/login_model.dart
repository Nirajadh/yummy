class LoginModel {
  final String? status;
  final String message;
  final LoginData? data;

  LoginModel({this.status, required this.message, this.data});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    return LoginModel(
      status: json['status']?.toString(),
      message: json['message']?.toString() ?? '',
      data: dataJson is Map<String, dynamic>
          ? LoginData.fromJson(dataJson)
          : null,
    );
  }
}

class LoginData {
  final String accessToken;
  final String tokenType;
  final int userId;
  final String userName;
  final String email;
  final String role;

  LoginData({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? '',
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      userName: json['user_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['user_role']?.toString() ?? '',
    );
  }
}
