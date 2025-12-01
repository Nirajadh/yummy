class LoginEntity {
  final String accessToken;
  final String tokenType;
  final String refreshToken;
  final int userId;
  final String userName;
  final String email;
  final String role;

  LoginEntity({
    required this.accessToken,
    required this.tokenType,
    required this.refreshToken,
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
  });
}
