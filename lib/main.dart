import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/di/di.dart';
import 'package:yummy/core/routes/app_router.dart';
import 'package:yummy/core/themes/app_theme.dart';
import 'package:yummy/features/admin/presentation/bloc/admin_dashboard/admin_dashboard_bloc.dart';
import 'package:yummy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/groups/presentation/bloc/groups/groups_bloc.dart';
import 'package:yummy/features/kitchen/presentation/bloc/kitchen_kot/kitchen_kot_bloc.dart';
import 'package:yummy/features/menu/presentation/bloc/menu/menu_bloc.dart';
import 'package:yummy/features/orders/presentation/bloc/orders/orders_bloc.dart';
import 'package:yummy/features/staff_portal/presentation/bloc/staff_dashboard/staff_dashboard_bloc.dart';
import 'package:yummy/features/tables/presentation/bloc/tables/tables_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const MyRestroApp());
}

class MyRestroApp extends StatelessWidget {
  const MyRestroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<RestaurantRepository>.value(
      value: sl<RestaurantRepository>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<AuthBloc>()),
          BlocProvider(
            create: (_) =>
                sl<AdminDashboardBloc>()..add(const AdminDashboardStarted()),
          ),
          BlocProvider(
            create: (_) =>
                sl<StaffDashboardBloc>()..add(const StaffDashboardStarted()),
          ),
          BlocProvider(
            create: (_) => sl<OrdersBloc>()..add(const OrdersRequested()),
          ),
          BlocProvider(
            create: (_) => sl<TablesBloc>()..add(const TablesRequested()),
          ),
          BlocProvider(
            create: (_) => sl<GroupsBloc>()..add(const GroupsRequested()),
          ),
          BlocProvider(
            create: (_) => sl<MenuBloc>()..add(const MenuRequested()),
          ),
          BlocProvider(
            create: (_) =>
                sl<KitchenKotBloc>()..add(const KitchenKotRequested()),
          ),
        ],
        child: MaterialApp(
          title: 'Yummy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: '/',
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
