import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/auth/presentation/screens/login_screen.dart';
import 'package:yummy/features/auth/presentation/screens/register_screen.dart';
import 'package:yummy/features/common/data/datasources/local_dummy_data_source.dart';
import 'package:yummy/features/common/data/repositories/restaurant_repository_impl.dart';
import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/dashboard/domain/usecases/get_dashboard_snapshot_usecase.dart';
import 'package:yummy/features/dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:yummy/features/dashboard/presentation/screens/admin_dashboard_shell.dart';
import 'package:yummy/features/dashboard/presentation/screens/admin_more_screen.dart';
import 'package:yummy/features/dashboard/presentation/screens/kitchen_dashboard_screen.dart';
import 'package:yummy/features/dashboard/presentation/screens/settings_screen.dart';
import 'package:yummy/features/dashboard/presentation/screens/staff_dashboard_shell.dart';
import 'package:yummy/features/groups/domain/usecases/get_groups_usecase.dart';
import 'package:yummy/features/groups/domain/usecases/toggle_group_status_usecase.dart';
import 'package:yummy/features/groups/domain/usecases/upsert_group_usecase.dart';
import 'package:yummy/features/groups/presentation/bloc/groups/groups_bloc.dart';
import 'package:yummy/features/groups/presentation/screens/group_create_screen.dart';
import 'package:yummy/features/groups/presentation/screens/groups_screen.dart';
import 'package:yummy/features/kot/domain/usecases/get_kot_tickets_usecase.dart';
import 'package:yummy/features/kot/presentation/bloc/kot/kot_bloc.dart';
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
import 'package:yummy/features/tables/domain/usecases/delete_table_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/get_tables_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/upsert_table_usecase.dart';
import 'package:yummy/features/tables/presentation/bloc/tables/tables_bloc.dart';
import 'package:yummy/features/tables/presentation/models/tables_screen_args.dart';
import 'package:yummy/features/tables/presentation/screens/table_order_screen.dart';
import 'package:yummy/features/tables/presentation/screens/tables_screen.dart';
import 'package:yummy/features/finance/presentation/screens/expenses_screen.dart';
import 'package:yummy/features/finance/presentation/screens/income_screen.dart';
import 'package:yummy/features/finance/presentation/screens/purchase_screen.dart';
import 'package:yummy/features/finance/presentation/screens/reports_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dataSource = LocalDummyDataSource();
  final RestaurantRepository repository = RestaurantRepositoryImpl(
    local: dataSource,
  );

  runApp(MyRestroApp(repository: repository));
}

class MyRestroApp extends StatelessWidget {
  final RestaurantRepository repository;

  const MyRestroApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.light,
    );
    return RepositoryProvider.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => DashboardBloc(
              getDashboardSnapshot: GetDashboardSnapshotUseCase(repository),
            )..add(const DashboardStarted()),
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
                KotBloc(getKotTicketsUseCase: GetKotTicketsUseCase(repository))
                  ..add(const KotRequested()),
          ),
        ],
        child: MaterialApp(
          title: 'MyRestro',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: colorScheme,
            scaffoldBackgroundColor: Colors.grey.shade50,
          ),
          initialRoute: '/login',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case '/register':
                return MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
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
                return MaterialPageRoute(builder: (_) => const LoginScreen());
            }
          },
        ),
      ),
    );
  }
}
