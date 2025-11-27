import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/core/usecases/usecase.dart';
import 'package:yummy/features/auth/domain/entities/admin_register_entity.dart';
import 'package:yummy/features/auth/domain/repositories/auth_repository.dart';

class AdminRegisterUsecase
    implements UseCaseWithParams<AdminRegisterEntity, AdminRegisterParams> {
  AdminRegisterUsecase({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, AdminRegisterEntity>> call(
    AdminRegisterParams params,
  ) async {
    return authRepository.registerAdmin(
      name: params.name,
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
  }
}

class AdminRegisterParams {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  AdminRegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}
