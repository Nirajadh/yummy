import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/core/usecases/usecase.dart';
import 'package:yummy/features/auth/domain/repositories/auth_repository.dart';

class LogoutUsecase implements UseCaseWithoutParams<void> {
  final AuthRepository authRepository;

  LogoutUsecase({required this.authRepository});

  @override
  Future<Either<Failure, void>> call() {
    return authRepository.logout();
  }
}
