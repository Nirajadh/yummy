import 'package:flutter/material.dart';
import 'package:yummy/features/staff_portal/presentation/screens/staff_dashboard_screen.dart';
import 'package:yummy/features/orders/presentation/screens/orders_screen.dart';

class StaffDashboardShell extends StatefulWidget {
  const StaffDashboardShell({super.key});

  @override
  State<StaffDashboardShell> createState() => _StaffDashboardShellState();
}

class _StaffDashboardShellState extends State<StaffDashboardShell> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      StaffDashboardScreen(onNavigateToOrders: () => setState(() => _index = 1)),
      const OrdersScreen(
        allowMenuManagement: false,
        allowTableManagement: false,
        dashboardRoute: '/staff-dashboard',
      ),
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
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Orders'),
        ],
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}
