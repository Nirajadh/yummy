class AdminRegisterEntity {
  final int id;
  final String name;
  final String email;
  final String role;
  final String accessToken;
  final String tokenType;
  final String message;

  AdminRegisterEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.tokenType,
    required this.message,
  });
}
