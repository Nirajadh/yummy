import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/core/usecases/usecase.dart';
import 'package:yummy/features/auth/domain/entities/user_entity.dart';
import 'package:yummy/features/auth/domain/repositories/auth_repository.dart';

class GetUsersUsecase implements UseCaseWithoutParams<List<UserEntity>> {
  final AuthRepository authRepository;

  GetUsersUsecase({required this.authRepository});

  @override
  Future<Either<Failure, List<UserEntity>>> call() {
    return authRepository.getAllUsers();
  }
}
