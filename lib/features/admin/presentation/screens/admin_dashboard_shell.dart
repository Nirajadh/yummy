import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:yummy/features/orders/presentation/screens/orders_screen.dart';
import 'package:yummy/features/tables/presentation/screens/tables_screen.dart';
import 'package:yummy/features/tables/presentation/bloc/tables/tables_bloc.dart';

class AdminDashboardShell extends StatefulWidget {
  const AdminDashboardShell({super.key});

  @override
  State<AdminDashboardShell> createState() => _AdminDashboardShellState();
}

class _AdminDashboardShellState extends State<AdminDashboardShell> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      AdminDashboardScreen(
        onNavigateToOrders: () => setState(() => _index = 1),
        onOpenMore: () => Navigator.pushNamed(context, '/settings'),
      ),
      const OrdersScreen(),
      const TablesScreen(
        allowManageTables: false,
        loadOnInit: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = _index >= _pages.length ? _pages.length - 1 : _index;
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: IndexedStack(index: safeIndex, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_bar_outlined),
            selectedIcon: Icon(Icons.table_bar),
            label: 'Tables',
          ),
        ],
        onDestinationSelected: (value) {
          setState(() => _index = value);
          if (value == 2) {
            final bloc = context.read<TablesBloc>();
            if (bloc.state.status == TablesStatus.initial ||
                bloc.state.status == TablesStatus.failure) {
              bloc.add(const TablesRequested());
            }
          }
        },
      ),
    );
  }
}
