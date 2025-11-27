part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final LoginEntity loginEntity;
  final String role;

  const AuthLoginSuccess({required this.loginEntity, required this.role});

  @override
  List<Object?> get props => [loginEntity, role];
}

class AuthRegisterSuccess extends AuthState {
  final RegisterEntity registerEntity;

  const AuthRegisterSuccess({required this.registerEntity});

  @override
  List<Object?> get props => [registerEntity];
}

class AuthAdminRegisterSuccess extends AuthState {
  final AdminRegisterEntity adminRegisterEntity;

  const AuthAdminRegisterSuccess({required this.adminRegisterEntity});

  @override
  List<Object?> get props => [adminRegisterEntity];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthLoggedOut extends AuthState {}
