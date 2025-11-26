import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/core/mapper/auth_mapper/login_model_mapper.dart';
import 'package:yummy/core/mapper/auth_mapper/register_mapper.dart';
import 'package:yummy/core/services/shared_prefrences.dart';
import 'package:yummy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yummy/features/auth/data/models/login_model.dart';
import 'package:yummy/features/auth/data/models/user_model.dart';
import 'package:yummy/features/auth/domain/entities/login_entity.dart';
import 'package:yummy/features/auth/domain/entities/register_entity.dart';
import 'package:yummy/features/auth/domain/entities/user_entity.dart';
import 'package:yummy/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.remoteDataSource});

  final AuthRemoteDataSource remoteDataSource;

  LoginEntity _mapLogin(LoginModel model) {
    return LoginModelMapper.toEntity(model);
  }

  List<UserEntity> _mapUsers(List<UserModel> models) {
    return models
        .map(
          (m) => UserEntity(
            id: m.id,
            name: m.name,
            email: m.email,
            role: m.role,
          ),
        )
        .toList();
  }

  @override
  Future<Either<Failure, LoginEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );
      final entity = _mapLogin(response);
      await SecureStorageService().setValue(key: 'token', value: entity.accessToken);
      await SecureStorageService().setValue(key: 'role', value: entity.role);
      await SecureStorageService().setValue(key: 'email', value: entity.email);
      await SecureStorageService().setValue(key: 'user_name', value: entity.userName);
      return Right(entity);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, RegisterEntity>> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? confirmPassword,
  }) async {
    try {
      final response = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
      );
      return Right(RegisterMapper.toEntity(response));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      final response = await remoteDataSource.getAllUsers();
      return Right(_mapUsers(response));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await SecureStorageService().delete(shouldDeleteAll: true);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to logout: $e'));
    }
  }
}
