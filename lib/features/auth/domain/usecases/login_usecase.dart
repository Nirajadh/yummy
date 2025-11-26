import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/core/usecases/usecase.dart';
import 'package:yummy/features/auth/domain/entities/login_entity.dart';
import 'package:yummy/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase implements UseCaseWithParams<LoginEntity, LoginParams> {
  final AuthRepository authRepository;

  LoginUsecase({required this.authRepository});

  @override
  Future<Either<Failure, LoginEntity>> call(LoginParams params) {
    return authRepository.login(email: params.email, password: params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
