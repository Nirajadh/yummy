import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/core/usecases/usecase.dart';
import 'package:yummy/features/auth/domain/entities/admin_register_entity.dart';
import 'package:yummy/features/auth/domain/repositories/auth_repository.dart';

class AdminRegisterVerifyUsecase implements
    UseCaseWithParams<AdminRegisterEntity, AdminRegisterVerifyParams> {
  AdminRegisterVerifyUsecase({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, AdminRegisterEntity>> call(
    AdminRegisterVerifyParams params,
  ) async {
    return authRepository.verifyAdminRegister(
      name: params.name,
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword,
      otp: params.otp,
    );
  }
}

class AdminRegisterVerifyParams {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String otp;

  AdminRegisterVerifyParams({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.otp,
  });
}

