import 'package:flutter/material.dart';

import '../widgets/dashboard_overview.dart';

class AdminDashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onOpenMore;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateToOrders,
    this.onOpenMore,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardOverview(
      title: 'Admin Dashboard',
      actions: _actions(context),
      automaticallyImplyLeading: false,
      onActiveOrdersTap: onNavigateToOrders,
      onMetricTap: (context, metric) {
        switch (metric.title) {
          case 'History':
            Navigator.pushNamed(context, '/order-history');
            break;
          case 'Expenses':
            Navigator.pushNamed(context, '/expenses');
            break;
          case 'Purchase':
            Navigator.pushNamed(context, '/purchase');
            break;
          case 'Income':
            Navigator.pushNamed(context, '/income');
            break;
          default:
            Navigator.pushNamed(context, '/reports');
            break;
        }
      },
    );
  }

  List<Widget> _actions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Reports',
        icon: const Icon(Icons.bar_chart_outlined),
        onPressed: () => Navigator.pushNamed(context, '/reports'),
      ),
      IconButton(
        tooltip: 'More',
        icon: const Icon(Icons.widgets_outlined),
        onPressed:
            onOpenMore ?? () => Navigator.pushNamed(context, '/admin-more'),
      ),
    ];
  }
}
