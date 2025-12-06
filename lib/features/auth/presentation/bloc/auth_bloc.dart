import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/auth/domain/entities/login_entity.dart';
import 'package:yummy/features/auth/domain/entities/register_entity.dart';
import 'package:yummy/features/auth/domain/entities/admin_register_entity.dart';
import 'package:yummy/features/auth/domain/usecases/admin_register_resend_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/login_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/logout_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/register_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/admin_register_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/admin_register_verify_usecase.dart';
import 'package:yummy/features/restaurant/domain/usecases/get_restaurant_by_user_usecase.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.registerUsecase,
    required this.adminRegisterUsecase,
    required this.adminRegisterVerifyUsecase,
    required this.adminRegisterResendUsecase,
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getRestaurantByUserUsecase,
    required this.restaurantDetailsService,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<AdminRegisterRequested>(_onAdminRegisterRequested);
    on<AdminRegisterVerifyRequested>(_onAdminRegisterVerifyRequested);
    on<AdminRegisterResendRequested>(_onAdminRegisterResendRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final RegisterUsecase registerUsecase;
  final AdminRegisterUsecase adminRegisterUsecase;
  final AdminRegisterVerifyUsecase adminRegisterVerifyUsecase;
  final AdminRegisterResendUsecase adminRegisterResendUsecase;
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetRestaurantByUserUsecase getRestaurantByUserUsecase;
  final RestaurantDetailsService restaurantDetailsService;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUsecase(
      LoginParams(email: event.email, password: event.password),
    );

    await result.fold(
      (failure) async => emit(AuthFailure(message: failure.message)),
      (loginEntity) async {
        await _cacheRestaurantForUser();
        emit(
          AuthLoginSuccess(loginEntity: loginEntity, role: loginEntity.role),
        );
      },
    );
  }

  Future<void> _cacheRestaurantForUser() async {
    final restaurantResult = await getRestaurantByUserUsecase();
    await restaurantResult.fold((_) async {}, (restaurant) async {
      await restaurantDetailsService.saveDetails(
        RestaurantDetails(
          id: restaurant.id,
          name: restaurant.name,
          address: restaurant.address,
          phone: restaurant.phone,
          description: restaurant.description ?? '',
        ),
      );
    });
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final params = RegisterParams(
      name: event.name,
      email: event.email,
      password: event.password,
      role: event.role,
      confirmPassword: event.confirmPassword,
    );

    final result = await registerUsecase(params);
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (registerEntity) =>
          emit(AuthRegisterSuccess(registerEntity: registerEntity)),
    );
  }

  Future<void> _onAdminRegisterRequested(
    AdminRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final params = AdminRegisterParams(
      name: event.name,
      email: event.email,
      password: event.password,
      confirmPassword: event.confirmPassword,
    );

    final result = await adminRegisterUsecase(params);
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (adminEntity) =>
          emit(AuthAdminRegisterSuccess(adminRegisterEntity: adminEntity)),
    );
  }

  Future<void> _onAdminRegisterVerifyRequested(
    AdminRegisterVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final params = AdminRegisterVerifyParams(
      name: event.name,
      email: event.email,
      password: event.password,
      confirmPassword: event.confirmPassword,
      otp: event.otp,
    );

    final result = await adminRegisterVerifyUsecase(params);
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (adminEntity) => emit(
        AuthAdminRegisterVerifySuccess(adminRegisterEntity: adminEntity),
      ),
    );
  }

  Future<void> _onAdminRegisterResendRequested(
    AdminRegisterResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final params = AdminRegisterResendParams(email: event.email);

    final result = await adminRegisterResendUsecase(params);
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (adminEntity) => emit(
        AuthAdminRegisterResendSuccess(adminRegisterEntity: adminEntity),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await logoutUsecase();
    await result.fold<Future<void>>(
      (failure) async {
        emit(AuthFailure(message: failure.message));
      },
      (_) async {
        await restaurantDetailsService.clear();
        emit(AuthLoggedOut());
      },
    );
  }
}
