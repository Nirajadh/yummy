import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'orders_screen.dart';
import 'tables_screen.dart';
import 'groups_screen.dart';

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
        onOpenMore: () => Navigator.pushNamed(context, '/admin-more'),
      ),
      const OrdersScreen(),
      const TablesScreen(),
      const GroupsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = _index >= _pages.length ? _pages.length - 1 : _index;
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
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
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Groups',
          ),
        ],
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}
