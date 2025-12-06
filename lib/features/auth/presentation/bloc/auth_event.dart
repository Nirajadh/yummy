part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? confirmPassword;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, password, role, confirmPassword];
}

class AdminRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const AdminRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, password, confirmPassword];
}

class AdminRegisterVerifyRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String otp;

  const AdminRegisterVerifyRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.otp,
  });

  @override
  List<Object?> get props => [name, email, password, confirmPassword, otp];
}

class AdminRegisterResendRequested extends AuthEvent {
  final String email;

  const AdminRegisterResendRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
