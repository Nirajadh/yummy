class RegisterModel {
  final String? status;
  final String message;
  final RegisterUserData? data;

  RegisterModel({this.status, required this.message, this.data});

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    return RegisterModel(
      status: json['status']?.toString(),
      message: json['message']?.toString() ?? '',
      data: dataJson is Map<String, dynamic>
          ? RegisterUserData.fromJson(dataJson)
          : null,
    );
  }
}

class RegisterUserData {
  final int id;
  final String name;
  final String email;
  final String role;

  RegisterUserData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory RegisterUserData.fromJson(Map<String, dynamic> json) {
    return RegisterUserData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}
