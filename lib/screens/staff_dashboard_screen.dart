import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../widgets/dashboard_overview.dart';

const _staffMetricTitles = {'Analytics', 'History'};
final List<DashboardMetric> _staffMetrics =
    dashboardMetrics.where((metric) => _staffMetricTitles.contains(metric.title)).toList();

class StaffDashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToOrders;

  const StaffDashboardScreen({super.key, this.onNavigateToOrders});

  @override
  Widget build(BuildContext context) {
    return DashboardOverview(
      title: 'Staff Dashboard',
      automaticallyImplyLeading: false,
      onActiveOrdersTap: onNavigateToOrders,
      metrics: _staffMetrics,
      onMetricTap: (context, metric) => _handleMetricTap(context, metric),
    );
  }

  void _handleMetricTap(BuildContext context, DashboardMetric metric) {
    if (metric.title == 'History') {
      Navigator.pushNamed(context, '/order-history');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This insight is available to admins.')),
    );
  }
}
