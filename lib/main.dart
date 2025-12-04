import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/di/di.dart';
import 'package:yummy/core/app_apis.dart';
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
import 'package:yummy/features/admin/presentation/bloc/settings/settings_bloc.dart';
import 'package:yummy/features/tables/presentation/bloc/tables/tables_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const MyRestroApp());
}

class MyRestroApp extends StatefulWidget {
  const MyRestroApp({super.key});

  @override
  State<MyRestroApp> createState() => _MyRestroAppState();
}

class _MyRestroAppState extends State<MyRestroApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _sessionKey = 0;

  void _resetFeatureBlocs() {
    setState(() => _sessionKey++);
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<RestaurantRepository>.value(
      value: sl<RestaurantRepository>(),
      child: BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              current is AuthLoggedOut || current is AuthLoginSuccess,
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              _resetFeatureBlocs();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/auth',
                  (route) => false,
                );
              });
            } else if (state is AuthLoginSuccess) {
              _resetFeatureBlocs();
            }
          },
          child: _AppScope(
            navigatorKey: _navigatorKey,
            sessionKey: _sessionKey,
          ),
        ),
      ),
    );
  }
}

class _AppScope extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final int sessionKey;

  const _AppScope({required this.navigatorKey, required this.sessionKey});

  @override
  State<_AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<_AppScope> {
  StreamSubscription<void>? _logoutSub;

  @override
  void initState() {
    super.initState();
    _logoutSub = sl<AppApis>().onUnauthorizedLogout.listen((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const LogoutRequested());
    });
  }

  @override
  void dispose() {
    _logoutSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      key: ValueKey('session-${widget.sessionKey}'),
      providers: [
        BlocProvider(
          create: (_) => sl<SettingsBloc>(),
        ),
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
        BlocProvider(create: (_) => sl<TablesBloc>()),
        BlocProvider(
          create: (_) => sl<GroupsBloc>()..add(const GroupsRequested()),
        ),
        BlocProvider(create: (_) => sl<MenuBloc>()..add(const MenuRequested())),
        BlocProvider(
          create: (_) => sl<KitchenKotBloc>()..add(const KitchenKotRequested()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            navigatorKey: widget.navigatorKey,
            title: 'Yummy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.appearance,
            initialRoute: '/',
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
