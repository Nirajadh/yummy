import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_metric_entity.dart';
import 'package:yummy/features/staff_portal/presentation/bloc/staff_dashboard/staff_dashboard_bloc.dart';
import 'package:yummy/features/dashboard/presentation/widgets/dashboard_overview.dart';

const _staffMetricTitles = {'Analytics', 'History'};

class StaffDashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToOrders;

  const StaffDashboardScreen({super.key, this.onNavigateToOrders});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffDashboardBloc, StaffDashboardState>(
      builder: (context, state) {
        final snapshot = state.snapshot;
        if (snapshot == null || state.status == StaffDashboardStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final filteredMetrics = snapshot.metrics
            .where((metric) => _staffMetricTitles.contains(metric.title))
            .toList();

        return DashboardOverview(
          title: 'Staff Dashboard',
          automaticallyImplyLeading: false,
          onActiveOrdersTap: onNavigateToOrders,
          metrics: filteredMetrics,
          orderHistory: snapshot.orderHistory,
          activeOrders: snapshot.activeOrders,
          expenses: snapshot.expenses,
          onMetricTap: (context, metric) => _handleMetricTap(context, metric),
        );
      },
    );
  }

  void _handleMetricTap(BuildContext context, DashboardMetricEntity metric) {
    if (metric.title == 'History') {
      Navigator.pushNamed(context, '/order-history');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This insight is available to admins.')),
    );
  }
}
