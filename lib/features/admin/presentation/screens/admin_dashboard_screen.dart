import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:yummy/features/admin/presentation/bloc/admin_dashboard/admin_dashboard_bloc.dart';
import 'package:yummy/features/dashboard/presentation/widgets/dashboard_overview.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';

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
          topBanner: _restaurantBanner(context),
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
        tooltip: 'Settings',
        icon: const Icon(Icons.settings_outlined),
        onPressed:
            onOpenMore ?? () => Navigator.pushNamed(context, '/settings'),
      ),
    ];
  }

  Widget _restaurantBanner(BuildContext context) {
    return FutureBuilder<RestaurantDetails>(
      future: RestaurantDetailsService().getDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 12),
                  Text('Checking your restaurant profile...'),
                ],
              ),
            ),
          );
        }
        final details = snapshot.data ?? const RestaurantDetails();
        final hasProfile = (details.id ?? 0) > 0 || details.hasAnyData;
        if (hasProfile) return const SizedBox.shrink();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFEFF4FF),
              child: Icon(Icons.store_mall_directory_outlined),
            ),
            title: const Text(
              'Complete restaurant details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),

            trailing: FilledButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/restaurant-setup'),
              child: const Text('Add details'),
            ),
          ),
        );
      },
    );
  }
}
