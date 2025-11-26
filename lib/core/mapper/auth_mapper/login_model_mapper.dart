import 'package:yummy/features/auth/data/models/login_model.dart';
import 'package:yummy/features/auth/domain/entities/login_entity.dart';

/// Maps login API model to domain entity.
class LoginModelMapper {
  static LoginEntity toEntity(LoginModel model) {
    final data = model.data;
    return LoginEntity(
      accessToken: data?.accessToken ?? '',
      tokenType: data?.tokenType ?? '',
      userId: data?.userId ?? 0,
      userName: data?.userName ?? '',
      email: data?.email ?? '',
      role: data?.role ?? '',
    );
  }
}
