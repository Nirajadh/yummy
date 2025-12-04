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
import 'package:yummy/features/item_category/data/datasources/item_category_remote_data_source.dart';
import 'package:yummy/features/item_category/data/repositories/item_category_repository_impl.dart';
import 'package:yummy/features/item_category/domain/repositories/item_category_repository.dart';
import 'package:yummy/features/item_category/domain/usecases/create_item_category_usecase.dart';
import 'package:yummy/features/item_category/domain/usecases/delete_item_category_usecase.dart';
import 'package:yummy/features/item_category/domain/usecases/get_item_categories_usecase.dart';
import 'package:yummy/features/item_category/domain/usecases/update_item_category_usecase.dart';
import 'package:yummy/features/item_category/presentation/bloc/item_category_bloc.dart';
import 'package:yummy/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:yummy/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:yummy/features/menu/domain/repositories/menu_repository.dart';
import 'package:yummy/features/menu/domain/usecases/create_menu_usecase.dart';
import 'package:yummy/features/menu/domain/usecases/delete_menu_usecase.dart';
import 'package:yummy/features/menu/domain/usecases/get_menus_by_restaurant_usecase.dart';
import 'package:yummy/features/menu/domain/usecases/update_menu_usecase.dart';
import 'package:yummy/features/menu/presentation/bloc/menu/menu_bloc.dart';
import 'package:yummy/features/orders/domain/usecases/get_active_orders_usecase.dart';
import 'package:yummy/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:yummy/features/orders/domain/usecases/add_order_items_usecase.dart';
import 'package:yummy/features/orders/domain/repositories/order_repository.dart';
import 'package:yummy/features/orders/data/repositories/order_repository_impl.dart';
import 'package:yummy/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:yummy/features/orders/presentation/bloc/orders/orders_bloc.dart';
import 'package:yummy/features/orders/presentation/bloc/create_order/create_order_bloc.dart';
import 'package:yummy/features/orders/presentation/bloc/add_order_items/add_order_items_bloc.dart';
import 'package:yummy/features/restaurant/domain/usecases/update_restaurant_usecase.dart';
import 'package:yummy/features/staff_portal/data/repositories/staff_portal_repository_impl.dart';
import 'package:yummy/features/staff_portal/domain/repositories/staff_portal_repository.dart';
import 'package:yummy/features/staff_portal/domain/usecases/get_staff_active_orders_usecase.dart';
import 'package:yummy/features/staff_portal/domain/usecases/get_staff_dashboard_snapshot_usecase.dart';
import 'package:yummy/features/staff_portal/presentation/bloc/staff_dashboard/staff_dashboard_bloc.dart';
import 'package:yummy/features/tables/domain/usecases/delete_table_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/get_tables_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/upsert_table_usecase.dart';
import 'package:yummy/features/tables/presentation/bloc/tables/tables_bloc.dart';
import 'package:yummy/features/tables/domain/usecases/create_remote_table_usecase.dart';
import 'package:yummy/features/tables/domain/repositories/remote_table_repository.dart';
import 'package:yummy/features/tables/data/repositories/remote_table_repository_impl.dart';
import 'package:yummy/features/tables/data/datasources/table_remote_data_source.dart';
import 'package:yummy/features/tables/data/datasources/table_type_remote_data_source.dart';
import 'package:yummy/features/tables/data/repositories/table_type_repository_impl.dart';
import 'package:yummy/features/tables/domain/repositories/table_type_repository.dart';
import 'package:yummy/features/tables/domain/usecases/create_table_type_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/get_remote_tables_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/get_table_types_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/get_table_by_id_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/update_remote_table_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/delete_remote_table_usecase.dart';
import 'package:yummy/features/restaurant/data/datasources/restaurant_remote_data_source.dart';
import 'package:yummy/features/restaurant/data/repositories/restaurant_repository_impl.dart'
    as remote_restaurant_repo;
import 'package:yummy/features/restaurant/domain/repositories/restaurant_repository.dart'
    as remote_restaurant_repo_interface;
import 'package:yummy/features/restaurant/domain/usecases/create_restaurant_usecase.dart';
import 'package:yummy/features/restaurant/domain/usecases/get_restaurant_by_user_usecase.dart';
import 'package:yummy/features/restaurant/presentation/bloc/restaurant_bloc.dart';
import 'package:yummy/features/admin/presentation/bloc/settings/settings_bloc.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  sl.registerLazySingleton<AppApis>(() => AppApis());
  sl.registerLazySingleton<RestaurantDetailsService>(
    () => RestaurantDetailsService(),
  );

  // Repositories
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(),
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
  sl.registerLazySingleton<ItemCategoryRemoteDataSource>(
    () => ItemCategoryRemoteDataSourceImpl(appApis: sl()),
  );
  sl.registerLazySingleton<ItemCategoryRepository>(
    () => ItemCategoryRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(appApis: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<
    remote_restaurant_repo_interface.RestaurantRepository
  >(() => remote_restaurant_repo.RestaurantRepositoryImpl(remote: sl()));
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(appApis: sl()),
  );
  sl.registerLazySingleton<RemoteTableRepository>(
    () => RemoteTableRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton<TableRemoteDataSource>(
    () => TableRemoteDataSourceImpl(appApis: sl()),
  );
  sl.registerLazySingleton<TableTypeRepository>(
    () => TableTypeRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton<TableTypeRemoteDataSource>(
    () => TableTypeRemoteDataSourceImpl(appApis: sl()),
  );
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(appApis: sl()),
  );
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(appApis: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remote: sl()),
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
  sl.registerFactory(() => CreateOrderUseCase(sl()));
  sl.registerFactory(() => AddOrderItemsUseCase(sl()));
  sl.registerFactory(() => GetTablesUseCase(sl()));
  sl.registerFactory(() => UpsertTableUseCase(sl()));
  sl.registerFactory(() => DeleteTableUseCase(sl()));
  sl.registerFactory(() => GetGroupsUseCase(sl()));
  sl.registerFactory(() => UpsertGroupUseCase(sl()));
  sl.registerFactory(() => ToggleGroupStatusUseCase(sl()));
  sl.registerFactory(() => GetMenusByRestaurantUseCase(sl()));
  sl.registerFactory(() => CreateMenuUseCase(sl()));
  sl.registerFactory(() => UpdateMenuUseCase(sl()));
  sl.registerFactory(() => DeleteMenuUseCase(sl()));
  sl.registerFactory(() => GetKitchenKotTicketsUseCase(sl()));
  sl.registerFactory(() => GetItemCategoriesUseCase(sl()));
  sl.registerFactory(() => CreateItemCategoryUseCase(sl()));
  sl.registerFactory(() => UpdateItemCategoryUseCase(sl()));
  sl.registerFactory(() => DeleteItemCategoryUseCase(sl()));
  sl.registerFactory(() => CreateRestaurantUseCase(sl()));
  sl.registerFactory(() => UpdateRestaurantUseCase(sl()));
  sl.registerFactory(() => GetRestaurantByUserUsecase(sl()));
  sl.registerFactory(() => CreateRemoteTableUseCase(sl()));
  sl.registerFactory(() => CreateTableTypeUseCase(sl()));
  sl.registerFactory(() => GetRemoteTablesUseCase(sl()));
  sl.registerFactory(() => GetTableTypesUseCase(sl()));
  sl.registerFactory(() => DeleteRemoteTableUseCase(sl()));
  sl.registerFactory(() => UpdateRemoteTableUseCase(sl()));
  sl.registerFactory(() => GetTableByIdUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => AuthBloc(
      registerUsecase: sl(),
      adminRegisterUsecase: sl(),
      loginUsecase: sl(),
      logoutUsecase: sl(),
      getRestaurantByUserUsecase: sl(),
      restaurantDetailsService: sl(),
    ),
  );
  sl.registerFactory(() => AdminDashboardBloc(getSnapshot: sl()));
  sl.registerFactory(
    () => StaffDashboardBloc(getSnapshot: sl(), getActiveOrders: sl()),
  );
  sl.registerFactory(
    () => OrdersBloc(
      getActiveOrders: sl(),
      restaurantDetailsService: sl(),
    ),
  );
  sl.registerFactory(
    () => TablesBloc(
      upsertTable: sl(),
      deleteTable: sl(),
      createRemoteTable: sl(),
      createTableType: sl(),
      getTableTypes: sl(),
      getRemoteTables: sl(),
      deleteRemoteTable: sl(),
      updateRemoteTable: sl(),
    ),
  );
  sl.registerFactory(
    () =>
        GroupsBloc(getGroups: sl(), upsertGroup: sl(), toggleGroupStatus: sl()),
  );
  sl.registerFactory(
    () => MenuBloc(
      getMenus: sl(),
      createMenu: sl(),
      updateMenu: sl(),
      deleteMenu: sl(),
      restaurantDetailsService: sl(),
    ),
  );
  sl.registerFactory(() => KitchenKotBloc(getTickets: sl()));
  sl.registerFactory(
    () => RestaurantBloc(createRestaurant: sl(), updateRestaurant: sl()),
  );
  sl.registerFactory(
    () => CreateOrderBloc(
      createOrder: sl(),
      restaurantDetailsService: sl(),
    ),
  );
  sl.registerFactory(() => AddOrderItemsBloc(addItems: sl()));
  sl.registerFactory(
    () => ItemCategoryBloc(
      getCategories: sl(),
      createCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
      restaurantDetailsService: sl(),
    ),
  );
  sl.registerFactory(() => SettingsBloc());
}
