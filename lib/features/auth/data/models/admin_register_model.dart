/// DTO for admin registration response: BaseResponse[AdminRead]
class AdminRegisterModel {
  final String? status;
  final String message;
  final AdminRegisterData? data;

  AdminRegisterModel({
    this.status,
    required this.message,
    this.data,
  });

  factory AdminRegisterModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    return AdminRegisterModel(
      status: json['status']?.toString(),
      message: json['message']?.toString() ?? '',
      data: dataJson is Map<String, dynamic>
          ? AdminRegisterData.fromJson(dataJson)
          : null,
    );
  }
}

class AdminRegisterData {
  final int id;
  final String name;
  final String email;
  final String role;
  final String accessToken;
  final String tokenType;

  AdminRegisterData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.tokenType,
  });

  factory AdminRegisterData.fromJson(Map<String, dynamic> json) {
    return AdminRegisterData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? '',
    );
  }
}
