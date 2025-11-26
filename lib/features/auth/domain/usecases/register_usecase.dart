import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/core/usecases/usecase.dart';
import 'package:yummy/features/auth/domain/entities/register_entity.dart';
import 'package:yummy/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase
    implements UseCaseWithParams<RegisterEntity, RegisterParams> {
  RegisterUsecase({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, RegisterEntity>> call(RegisterParams params) async {
    return authRepository.registerUser(
      name: params.name,
      email: params.email,
      password: params.password,
      role: params.role,
      confirmPassword: params.confirmPassword,
    );
  }
}

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? confirmPassword;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.confirmPassword,
  });
}
