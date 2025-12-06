import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/auth/domain/entities/admin_register_entity.dart';
import 'package:yummy/features/auth/domain/entities/login_entity.dart';
import 'package:yummy/features/auth/domain/entities/register_entity.dart';
import 'package:yummy/features/auth/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, LoginEntity>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, RegisterEntity>> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? confirmPassword,
  });
  Future<Either<Failure, AdminRegisterEntity>> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });
  Future<Either<Failure, AdminRegisterEntity>> verifyAdminRegister({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String otp,
  });
  Future<Either<Failure, AdminRegisterEntity>> resendAdminRegisterOtp({
    required String email,
  });
  Future<Either<Failure, List<UserEntity>>> getAllUsers();
  Future<Either<Failure, void>> logout();
}
