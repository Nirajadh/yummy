import 'package:get_it/get_it.dart';
import 'package:yummy/core/app_apis.dart';
import 'package:yummy/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:yummy/features/admin/domain/repositories/admin_repository.dart';
import 'package:yummy/features/admin/domain/usecases/get_admin_dashboard_snapshot_usecase.dart';
import 'package:yummy/features/admin/presentation/bloc/admin_dashboard/admin_dashboard_bloc.dart';
import 'package:yummy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yummy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yummy/features/auth/domain/repositories/auth_repository.dart';
import 'package:yummy/features/auth/domain/usecases/admin_register_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/login_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/logout_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/register_usecase.dart';
import 'package:yummy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yummy/features/common/data/datasources/local_dummy_data_source.dart';
import 'package:yummy/features/common/data/repositories/restaurant_repository_impl.dart';
import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/groups/domain/usecases/get_groups_usecase.dart';
import 'package:yummy/features/groups/domain/usecases/toggle_group_status_usecase.dart';
import 'package:yummy/features/groups/domain/usecases/upsert_group_usecase.dart';
import 'package:yummy/features/groups/presentation/bloc/groups/groups_bloc.dart';
import 'package:yummy/features/kitchen/data/repositories/kitchen_repository_impl.dart';
import 'package:yummy/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:yummy/features/kitchen/domain/usecases/get_kitchen_kot_tickets_usecase.dart';
import 'package:yummy/features/kitchen/presentation/bloc/kitchen_kot/kitchen_kot_bloc.dart';
import 'package:yummy/features/menu/domain/usecases/get_menu_items_usecase.dart';
import 'package:yummy/features/menu/domain/usecases/upsert_menu_item_usecase.dart';
import 'package:yummy/features/menu/presentation/bloc/menu/menu_bloc.dart';
import 'package:yummy/features/orders/domain/usecases/get_active_orders_usecase.dart';
import 'package:yummy/features/orders/presentation/bloc/orders/orders_bloc.dart';
import 'package:yummy/features/staff_portal/data/repositories/staff_portal_repository_impl.dart';
import 'package:yummy/features/staff_portal/domain/repositories/staff_portal_repository.dart';
import 'package:yummy/features/staff_portal/domain/usecases/get_staff_active_orders_usecase.dart';
import 'package:yummy/features/staff_portal/domain/usecases/get_staff_dashboard_snapshot_usecase.dart';
import 'package:yummy/features/staff_portal/presentation/bloc/staff_dashboard/staff_dashboard_bloc.dart';
import 'package:yummy/features/tables/domain/usecases/delete_table_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/get_tables_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/upsert_table_usecase.dart';
import 'package:yummy/features/tables/presentation/bloc/tables/tables_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  sl.registerLazySingleton<AppApis>(() => AppApis());
  sl.registerLazySingleton<LocalDummyDataSource>(() => LocalDummyDataSource());

  // Repositories
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(local: sl()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(base: sl()),
  );
  sl.registerLazySingleton<StaffPortalRepository>(
    () => StaffPortalRepositoryImpl(base: sl()),
  );
  sl.registerLazySingleton<KitchenRepository>(
    () => KitchenRepositoryImpl(base: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(appApis: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerFactory(() => RegisterUsecase(authRepository: sl()));
  sl.registerFactory(() => AdminRegisterUsecase(authRepository: sl()));
  sl.registerFactory(() => LoginUsecase(authRepository: sl()));
  sl.registerFactory(() => LogoutUsecase(authRepository: sl()));
  sl.registerFactory(() => GetAdminDashboardSnapshotUseCase(sl()));
  sl.registerFactory(() => GetStaffDashboardSnapshotUseCase(sl()));
  sl.registerFactory(() => GetStaffActiveOrdersUseCase(sl()));
  sl.registerFactory(() => GetActiveOrdersUseCase(sl()));
  sl.registerFactory(() => GetTablesUseCase(sl()));
  sl.registerFactory(() => UpsertTableUseCase(sl()));
  sl.registerFactory(() => DeleteTableUseCase(sl()));
  sl.registerFactory(() => GetGroupsUseCase(sl()));
  sl.registerFactory(() => UpsertGroupUseCase(sl()));
  sl.registerFactory(() => ToggleGroupStatusUseCase(sl()));
  sl.registerFactory(() => GetMenuItemsUseCase(sl()));
  sl.registerFactory(() => UpsertMenuItemUseCase(sl()));
  sl.registerFactory(() => GetKitchenKotTicketsUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => AuthBloc(
      registerUsecase: sl(),
      adminRegisterUsecase: sl(),
      loginUsecase: sl(),
      logoutUsecase: sl(),
    ),
  );
  sl.registerFactory(
    () => AdminDashboardBloc(getSnapshot: sl()),
  );
  sl.registerFactory(
    () => StaffDashboardBloc(
      getSnapshot: sl(),
      getActiveOrders: sl(),
    ),
  );
  sl.registerFactory(
    () => OrdersBloc(getActiveOrders: sl()),
  );
  sl.registerFactory(
    () => TablesBloc(
      getTables: sl(),
      upsertTable: sl(),
      deleteTable: sl(),
    ),
  );
  sl.registerFactory(
    () => GroupsBloc(
      getGroups: sl(),
      upsertGroup: sl(),
      toggleGroupStatus: sl(),
    ),
  );
  sl.registerFactory(
    () => MenuBloc(
      getMenuItems: sl(),
      upsertMenuItem: sl(),
    ),
  );
  sl.registerFactory(
    () => KitchenKotBloc(getTickets: sl()),
  );
}
