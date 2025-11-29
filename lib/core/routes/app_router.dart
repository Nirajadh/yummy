import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/services/shared_prefrences.dart';
import 'package:yummy/features/admin/presentation/screens/admin_dashboard_shell.dart';
import 'package:yummy/features/admin/presentation/screens/settings_screen.dart';

import 'package:yummy/features/auth/presentation/screens/auth_screen.dart';
import 'package:yummy/features/auth/presentation/screens/user_profile_screen.dart';
import 'package:yummy/features/finance/presentation/screens/expenses_screen.dart';
import 'package:yummy/features/finance/presentation/screens/income_screen.dart';
import 'package:yummy/features/finance/presentation/screens/purchase_screen.dart';
import 'package:yummy/features/finance/presentation/screens/reports_screen.dart';
import 'package:yummy/features/groups/presentation/screens/group_create_screen.dart';
import 'package:yummy/features/groups/presentation/screens/groups_screen.dart';
import 'package:yummy/features/kitchen/presentation/screens/kitchen_dashboard_screen.dart';
import 'package:yummy/features/restaurant/presentation/restaurant_details_screen.dart';

import 'package:yummy/features/restaurant/presentation/screens/restaurant_hub_screen.dart';
import 'package:yummy/features/restaurant/presentation/bloc/restaurant_bloc.dart';
import 'package:yummy/core/di/di.dart';
import 'package:yummy/features/admin/presentation/bloc/settings/settings_bloc.dart';
import 'package:yummy/features/menu/presentation/screens/menu_item_form_screen.dart';
import 'package:yummy/features/menu/presentation/screens/menu_management_screen.dart';
import 'package:yummy/features/orders/domain/entities/bill_preview.dart';
import 'package:yummy/features/orders/presentation/bloc/order_cart/order_cart_cubit.dart';
import 'package:yummy/features/orders/presentation/screens/bill_preview_screen.dart';
import 'package:yummy/features/orders/presentation/screens/group_order_screen.dart';
import 'package:yummy/features/orders/presentation/screens/order_history_screen.dart';
import 'package:yummy/features/orders/presentation/screens/order_screen.dart';
import 'package:yummy/features/orders/presentation/screens/orders_screen.dart';
import 'package:yummy/features/orders/presentation/screens/pickup_order_screen.dart';
import 'package:yummy/features/orders/presentation/screens/quick_billing_screen.dart';
import 'package:yummy/features/staff/presentation/screens/staff_management_screen.dart';
import 'package:yummy/features/staff_portal/presentation/screens/staff_dashboard_shell.dart';
import 'package:yummy/features/tables/presentation/bloc/table_order/table_order_bloc.dart';
import 'package:yummy/features/tables/presentation/models/tables_screen_args.dart';
import 'package:yummy/features/tables/presentation/screens/table_order_screen.dart';
import 'package:yummy/features/tables/presentation/screens/tables_screen.dart';

/// Centralized route generator to keep main.dart lean.
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const _LaunchScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      case '/restaurant-setup':
        final args = settings.arguments;
        final screenArgs = args is RestaurantDetailsArgs ? args : null;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<RestaurantBloc>(),
            child: RestaurantDetailsScreen(
              allowSkip: screenArgs?.allowSkip ?? false,
              redirectRoute: screenArgs?.redirectRoute,
            ),
          ),
        );
      case '/restaurant-settings':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<RestaurantBloc>(),
            child: const RestaurantDetailsScreen(),
          ),
        );

      case '/restaurant':
        return MaterialPageRoute(builder: (_) => const RestaurantHubScreen());
      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboardShell());
      case '/staff-dashboard':
        return MaterialPageRoute(builder: (_) => const StaffDashboardShell());
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
            : false;
        final dashboardRoute = args is TablesScreenArgs
            ? args.dashboardRoute
            : '/admin-dashboard';
        return MaterialPageRoute(
          builder: (_) => TablesScreen(
            allowManageTables: allowManageTables,
            dashboardRoute: dashboardRoute,
          ),
        );
      case '/tables-manage':
        return MaterialPageRoute(
          builder: (_) => const TablesScreen(
            allowManageTables: true,
            dashboardRoute: '/admin-dashboard',
          ),
        );
      case '/table-order':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => TableOrderBloc(),
            child: const TableOrderScreen(),
          ),
        );
      case '/groups':
        return MaterialPageRoute(builder: (_) => const GroupsScreen());
      case '/group-create':
        return MaterialPageRoute(builder: (_) => const GroupCreateScreen());
      case '/group-order':
        return MaterialPageRoute(builder: (_) => const GroupOrderScreen());
      case '/pickup-order':
        return MaterialPageRoute(builder: (_) => const PickupOrderScreen());
      case '/quick-billing':
        return MaterialPageRoute(builder: (_) => const QuickBillingScreen());
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
        return MaterialPageRoute(builder: (_) => const MenuManagementScreen());
      case '/menu-add':
        return MaterialPageRoute(
          builder: (_) => const MenuItemFormScreen(isEditing: false),
        );
      case '/menu-edit':
        return MaterialPageRoute(
          builder: (_) => const MenuItemFormScreen(isEditing: true),
        );
      case '/expenses':
        return MaterialPageRoute(builder: (_) => const ExpensesScreen());
      case '/purchase':
        return MaterialPageRoute(builder: (_) => const PurchaseScreen());
      case '/income':
        return MaterialPageRoute(builder: (_) => const IncomeScreen());
      case '/order-history':
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case '/reports':
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<SettingsBloc>(),
            child: const SettingsScreen(),
          ),
        );

      case '/staff-management':
        return MaterialPageRoute(builder: (_) => const StaffManagementScreen());
      case '/admin-more':
        // Legacy route: redirect to settings with bloc.
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<SettingsBloc>(),
            child: const SettingsScreen(),
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
    }
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
