import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard_shell.dart';
import 'screens/staff_dashboard_shell.dart';
import 'screens/kitchen_dashboard_screen.dart';
import 'models/bill_preview.dart';
import 'screens/bill_preview_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/tables_screen.dart';
import 'screens/table_order_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/group_create_screen.dart';
import 'screens/group_order_screen.dart';
import 'screens/pickup_order_screen.dart';
import 'screens/quick_billing_screen.dart';
import 'screens/order_screen.dart';
import 'screens/menu_management_screen.dart';
import 'screens/menu_item_form_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/staff_management_screen.dart';
import 'screens/admin_more_screen.dart';
import 'screens/purchase_screen.dart';
import 'screens/income_screen.dart';
import 'models/tables_screen_args.dart';

void main() {
  runApp(const MyRestroApp());
}

class MyRestroApp extends StatelessWidget {
  const MyRestroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.light,
    );
    return MaterialApp(
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
            return MaterialPageRoute(builder: (_) => const TableOrderScreen());
          case '/groups':
            return MaterialPageRoute(builder: (_) => const GroupsScreen());
          case '/group-create':
            return MaterialPageRoute(builder: (_) => const GroupCreateScreen());
          case '/group-order':
            return MaterialPageRoute(builder: (_) => const GroupOrderScreen());
          case '/pickup-order':
            return MaterialPageRoute(builder: (_) => const PickupOrderScreen());
          case '/quick-billing':
            return MaterialPageRoute(
              builder: (_) => const QuickBillingScreen(),
            );
          case '/order-screen':
            return MaterialPageRoute(builder: (_) => const OrderScreen());
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
            return MaterialPageRoute(builder: (_) => const ExpensesScreen());
          case '/purchase':
            return MaterialPageRoute(builder: (_) => const PurchaseScreen());
          case '/income':
            return MaterialPageRoute(builder: (_) => const IncomeScreen());
          case '/order-history':
            return MaterialPageRoute(
              builder: (_) => const OrderHistoryScreen(),
            );
          case '/reports':
            return MaterialPageRoute(builder: (_) => const ReportsScreen());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case '/staff-management':
            return MaterialPageRoute(
              builder: (_) => const StaffManagementScreen(),
            );
          case '/admin-more':
            return MaterialPageRoute(builder: (_) => const AdminMoreScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
