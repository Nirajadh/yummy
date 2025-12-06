import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/core/usecases/usecase.dart';
import 'package:yummy/features/auth/domain/entities/admin_register_entity.dart';
import 'package:yummy/features/auth/domain/repositories/auth_repository.dart';

class AdminRegisterResendUsecase implements
    UseCaseWithParams<AdminRegisterEntity, AdminRegisterResendParams> {
  AdminRegisterResendUsecase({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, AdminRegisterEntity>> call(
    AdminRegisterResendParams params,
  ) async {
    return authRepository.resendAdminRegisterOtp(email: params.email);
  }
}

class AdminRegisterResendParams {
  final String email;

  AdminRegisterResendParams({required this.email});
}

