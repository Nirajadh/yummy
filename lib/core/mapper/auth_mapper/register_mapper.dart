import 'package:yummy/features/auth/data/models/register_model.dart';
import 'package:yummy/features/auth/domain/entities/register_entity.dart';

class RegisterMapper {
  static RegisterEntity toEntity(RegisterModel model) {
    return RegisterEntity(
      id: model.data?.id,
      name: model.data?.name ?? '',
      email: model.data?.email ?? '',
      role: model.data?.role ?? '',
      message: model.message,
    );
  }
}
