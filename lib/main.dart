import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/app_apis.dart';
import 'package:yummy/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:yummy/features/admin/domain/usecases/get_admin_dashboard_snapshot_usecase.dart';
import 'package:yummy/features/admin/presentation/bloc/admin_dashboard/admin_dashboard_bloc.dart';
import 'package:yummy/features/admin/presentation/screens/admin_dashboard_shell.dart';
import 'package:yummy/features/admin/presentation/screens/admin_more_screen.dart';
import 'package:yummy/features/admin/presentation/screens/settings_screen.dart';
import 'package:yummy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yummy/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:yummy/features/auth/domain/usecases/login_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/logout_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/register_usecase.dart';
import 'package:yummy/features/auth/domain/usecases/admin_register_usecase.dart';
import 'package:yummy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yummy/features/auth/presentation/screens/auth_screen.dart';
import 'package:yummy/features/auth/presentation/screens/user_profile_screen.dart';
import 'package:yummy/features/common/data/datasources/local_dummy_data_source.dart';
import 'package:yummy/features/common/data/repositories/restaurant_repository_impl.dart';
import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/finance/presentation/screens/expenses_screen.dart';
import 'package:yummy/features/finance/presentation/screens/income_screen.dart';
import 'package:yummy/features/finance/presentation/screens/purchase_screen.dart';
import 'package:yummy/features/finance/presentation/screens/reports_screen.dart';
import 'package:yummy/features/groups/domain/usecases/get_groups_usecase.dart';
import 'package:yummy/features/groups/domain/usecases/toggle_group_status_usecase.dart';
import 'package:yummy/features/groups/domain/usecases/upsert_group_usecase.dart';
import 'package:yummy/features/groups/presentation/bloc/groups/groups_bloc.dart';
import 'package:yummy/features/groups/presentation/screens/group_create_screen.dart';
import 'package:yummy/features/groups/presentation/screens/groups_screen.dart';
import 'package:yummy/features/kitchen/data/repositories/kitchen_repository_impl.dart';
import 'package:yummy/features/kitchen/domain/usecases/get_kitchen_kot_tickets_usecase.dart';
import 'package:yummy/features/kitchen/presentation/bloc/kitchen_kot/kitchen_kot_bloc.dart';
import 'package:yummy/features/kitchen/presentation/screens/kitchen_dashboard_screen.dart';
import 'package:yummy/features/menu/domain/usecases/get_menu_items_usecase.dart';
import 'package:yummy/features/menu/domain/usecases/upsert_menu_item_usecase.dart';
import 'package:yummy/features/menu/presentation/bloc/menu/menu_bloc.dart';
import 'package:yummy/features/menu/presentation/screens/menu_item_form_screen.dart';
import 'package:yummy/features/menu/presentation/screens/menu_management_screen.dart';
import 'package:yummy/features/orders/domain/entities/bill_preview.dart';
import 'package:yummy/features/orders/domain/usecases/get_active_orders_usecase.dart';
import 'package:yummy/features/orders/presentation/bloc/order_cart/order_cart_cubit.dart';
import 'package:yummy/features/orders/presentation/bloc/orders/orders_bloc.dart';
import 'package:yummy/features/orders/presentation/screens/bill_preview_screen.dart';
import 'package:yummy/features/orders/presentation/screens/group_order_screen.dart';
import 'package:yummy/features/orders/presentation/screens/order_history_screen.dart';
import 'package:yummy/features/orders/presentation/screens/order_screen.dart';
import 'package:yummy/features/orders/presentation/screens/orders_screen.dart';
import 'package:yummy/features/orders/presentation/screens/pickup_order_screen.dart';
import 'package:yummy/features/orders/presentation/screens/quick_billing_screen.dart';
import 'package:yummy/features/staff/presentation/screens/staff_management_screen.dart';
import 'package:yummy/features/staff_portal/data/repositories/staff_portal_repository_impl.dart';
import 'package:yummy/features/staff_portal/domain/usecases/get_staff_active_orders_usecase.dart';
import 'package:yummy/features/staff_portal/domain/usecases/get_staff_dashboard_snapshot_usecase.dart';
import 'package:yummy/features/staff_portal/presentation/bloc/staff_dashboard/staff_dashboard_bloc.dart';
import 'package:yummy/features/staff_portal/presentation/screens/staff_dashboard_shell.dart';
import 'package:yummy/features/tables/domain/usecases/delete_table_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/get_tables_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/upsert_table_usecase.dart';
import 'package:yummy/features/tables/presentation/bloc/tables/tables_bloc.dart';
import 'package:yummy/features/tables/presentation/models/tables_screen_args.dart';
import 'package:yummy/features/tables/presentation/screens/table_order_screen.dart';
import 'package:yummy/features/tables/presentation/screens/tables_screen.dart';
import 'package:yummy/core/services/shared_prefrences.dart';
import 'package:yummy/core/themes/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dataSource = LocalDummyDataSource();
  final RestaurantRepository repository = RestaurantRepositoryImpl(
    local: dataSource,
  );
  final appApis = AppApis();
  final authRemoteDataSource = AuthRemoteDataSourceImpl(appApis: appApis);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );
  final registerUsecase = RegisterUsecase(authRepository: authRepository);
  final adminRegisterUsecase = AdminRegisterUsecase(
    authRepository: authRepository,
  );
  final loginUsecase = LoginUsecase(authRepository: authRepository);
  final logoutUsecase = LogoutUsecase(authRepository: authRepository);
  final adminRepository = AdminRepositoryImpl(base: repository);
  final staffRepository = StaffPortalRepositoryImpl(base: repository);
  final kitchenRepository = KitchenRepositoryImpl(base: repository);

  runApp(
    MyRestroApp(
      repository: repository,
      registerUsecase: registerUsecase,
      loginUsecase: loginUsecase,
      logoutUsecase: logoutUsecase,
      adminDashboardUseCase: GetAdminDashboardSnapshotUseCase(adminRepository),
      staffDashboardUseCase: GetStaffDashboardSnapshotUseCase(staffRepository),
      staffActiveOrdersUseCase: GetStaffActiveOrdersUseCase(staffRepository),
      kitchenKotTicketsUseCase: GetKitchenKotTicketsUseCase(kitchenRepository),
      adminRegisterUsecase: adminRegisterUsecase,
    ),
  );
}

class MyRestroApp extends StatelessWidget {
  final RestaurantRepository repository;
  final RegisterUsecase registerUsecase;
  final AdminRegisterUsecase adminRegisterUsecase;
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetAdminDashboardSnapshotUseCase adminDashboardUseCase;
  final GetStaffDashboardSnapshotUseCase staffDashboardUseCase;
  final GetStaffActiveOrdersUseCase staffActiveOrdersUseCase;
  final GetKitchenKotTicketsUseCase kitchenKotTicketsUseCase;

  const MyRestroApp({
    super.key,
    required this.repository,
    required this.registerUsecase,
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.adminDashboardUseCase,
    required this.staffDashboardUseCase,
    required this.staffActiveOrdersUseCase,
    required this.kitchenKotTicketsUseCase,
    required this.adminRegisterUsecase,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(
              registerUsecase: registerUsecase,
              adminRegisterUsecase: adminRegisterUsecase,
              loginUsecase: loginUsecase,
              logoutUsecase: logoutUsecase,
            ),
          ),
          BlocProvider(
            create: (_) =>
                AdminDashboardBloc(getSnapshot: adminDashboardUseCase)
                  ..add(const AdminDashboardStarted()),
          ),
          BlocProvider(
            create: (_) => StaffDashboardBloc(
              getSnapshot: staffDashboardUseCase,
              getActiveOrders: staffActiveOrdersUseCase,
            )..add(const StaffDashboardStarted()),
          ),
          BlocProvider(
            create: (_) =>
                OrdersBloc(getActiveOrders: GetActiveOrdersUseCase(repository))
                  ..add(const OrdersRequested()),
          ),
          BlocProvider(
            create: (_) => TablesBloc(
              getTables: GetTablesUseCase(repository),
              upsertTable: UpsertTableUseCase(repository),
              deleteTable: DeleteTableUseCase(repository),
            )..add(const TablesRequested()),
          ),
          BlocProvider(
            create: (_) => GroupsBloc(
              getGroups: GetGroupsUseCase(repository),
              upsertGroup: UpsertGroupUseCase(repository),
              toggleGroupStatus: ToggleGroupStatusUseCase(repository),
            )..add(const GroupsRequested()),
          ),
          BlocProvider(
            create: (_) => MenuBloc(
              getMenuItems: GetMenuItemsUseCase(repository),
              upsertMenuItem: UpsertMenuItemUseCase(repository),
            )..add(const MenuRequested()),
          ),
          BlocProvider(
            create: (_) =>
                KitchenKotBloc(getTickets: kitchenKotTicketsUseCase)
                  ..add(const KitchenKotRequested()),
          ),
        ],
        child: MaterialApp(
          title: 'MyRestro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => const _LaunchScreen());
              case '/auth':
                return MaterialPageRoute(builder: (_) => const AuthScreen());

              case '/profile':
                return MaterialPageRoute(
                  builder: (_) => const UserProfileScreen(),
                );
              case '/admin-dashboard':
                return MaterialPageRoute(
                  builder: (_) => const AdminDashboardShell(),
                );
              case '/staff-dashboard':
                return MaterialPageRoute(
                  builder: (_) => const StaffDashboardShell(),
                );
              case '/kitchen-dashboard':
                return MaterialPageRoute(
                  builder: (_) => const KitchenDashboardScreen(),
                );
              case '/new-order':
                return MaterialPageRoute(builder: (_) => const OrdersScreen());
              case '/tables':
                final args = settings.arguments;
                final allowManageTables = args is TablesScreenArgs
                    ? args.allowManageTables
                    : true;
                final dashboardRoute = args is TablesScreenArgs
                    ? args.dashboardRoute
                    : '/admin-dashboard';
                return MaterialPageRoute(
                  builder: (_) => TablesScreen(
                    allowManageTables: allowManageTables,
                    dashboardRoute: dashboardRoute,
                  ),
                );
              case '/table-order':
                return MaterialPageRoute(
                  builder: (_) => const TableOrderScreen(),
                );
              case '/groups':
                return MaterialPageRoute(builder: (_) => const GroupsScreen());
              case '/group-create':
                return MaterialPageRoute(
                  builder: (_) => const GroupCreateScreen(),
                );
              case '/group-order':
                return MaterialPageRoute(
                  builder: (_) => const GroupOrderScreen(),
                );
              case '/pickup-order':
                return MaterialPageRoute(
                  builder: (_) => const PickupOrderScreen(),
                );
              case '/quick-billing':
                return MaterialPageRoute(
                  builder: (_) => const QuickBillingScreen(),
                );
              case '/order-screen':
                return MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => OrderCartCubit(),
                    child: const OrderScreen(),
                  ),
                );
              case '/bill-preview':
                return MaterialPageRoute(
                  builder: (context) {
                    final args = settings.arguments;
                    if (args is BillPreviewArgs) {
                      return BillPreviewScreen(args: args);
                    }
                    return const BillPreviewScreen(
                      args: BillPreviewArgs(
                        orderLabel: 'Bill Preview',
                        items: [],
                        subtotal: 0,
                        tax: 0,
                        serviceCharge: 0,
                        grandTotal: 0,
                      ),
                    );
                  },
                );
              case '/menu-management':
                return MaterialPageRoute(
                  builder: (_) => const MenuManagementScreen(),
                );
              case '/menu-add':
                return MaterialPageRoute(
                  builder: (_) => const MenuItemFormScreen(isEditing: false),
                );
              case '/menu-edit':
                return MaterialPageRoute(
                  builder: (_) => const MenuItemFormScreen(isEditing: true),
                );
              case '/expenses':
                return MaterialPageRoute(
                  builder: (_) => const ExpensesScreen(),
                );
              case '/purchase':
                return MaterialPageRoute(
                  builder: (_) => const PurchaseScreen(),
                );
              case '/income':
                return MaterialPageRoute(builder: (_) => const IncomeScreen());
              case '/order-history':
                return MaterialPageRoute(
                  builder: (_) => const OrderHistoryScreen(),
                );
              case '/reports':
                return MaterialPageRoute(builder: (_) => const ReportsScreen());
              case '/settings':
                return MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                );
              case '/staff-management':
                return MaterialPageRoute(
                  builder: (_) => const StaffManagementScreen(),
                );
              case '/admin-more':
                return MaterialPageRoute(
                  builder: (_) => const AdminMoreScreen(),
                );
              default:
                return MaterialPageRoute(builder: (_) => const AuthScreen());
            }
          },
        ),
      ),
    );
  }
}

/// Lightweight launch screen that routes based on persisted auth state.
class _LaunchScreen extends StatefulWidget {
  const _LaunchScreen();

  @override
  State<_LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<_LaunchScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final storage = SecureStorageService();
    final token = await storage.getValue(key: 'token');
    final role = await storage.getValue(key: 'role');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      switch ((role ?? '').toLowerCase()) {
        case 'kitchen':
          Navigator.pushReplacementNamed(context, '/kitchen-dashboard');
          return;
        case 'staff':
          Navigator.pushReplacementNamed(context, '/staff-dashboard');
          return;
        default:
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
          return;
      }
    }

    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
