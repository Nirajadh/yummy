import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/admin/presentation/bloc/admin_dashboard/admin_dashboard_bloc.dart';
import 'package:yummy/features/dashboard/presentation/widgets/dashboard_overview.dart';

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
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state.status == AdminDashboardStatus.loading ||
            state.snapshot == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return DashboardOverview(
          title: 'Admin Dashboard',
          metrics: state.snapshot!.metrics,
          activeOrders: state.snapshot!.activeOrders,
          orderHistory: state.snapshot!.orderHistory,
          expenses: state.snapshot!.expenses,
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
      },
    );
  }

  List<Widget> _actions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'More',
        icon: const Icon(Icons.widgets_outlined),
        onPressed:
            onOpenMore ?? () => Navigator.pushNamed(context, '/admin-more'),
      ),
    ];
  }
}
