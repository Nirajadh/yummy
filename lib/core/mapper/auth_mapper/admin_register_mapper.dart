import 'package:yummy/features/auth/data/models/admin_register_model.dart';
import 'package:yummy/features/auth/domain/entities/admin_register_entity.dart';

class AdminRegisterMapper {
  static AdminRegisterEntity toEntity(AdminRegisterModel model) {
    final data = model.data;
    return AdminRegisterEntity(
      id: data?.id ?? 0,
      name: data?.name ?? '',
      email: data?.email ?? '',
      role: data?.role ?? '',
      accessToken: data?.accessToken ?? '',
      tokenType: data?.tokenType ?? '',
      message: model.message,
    );
  }
}
