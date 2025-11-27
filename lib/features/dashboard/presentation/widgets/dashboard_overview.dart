import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yummy/features/auth/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_metric_entity.dart';
import 'package:yummy/features/finance/domain/entities/expense_entry_entity.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';

typedef MetricTapCallback =
    void Function(BuildContext context, DashboardMetricEntity metric);

class DashboardOverview extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final MetricTapCallback? onMetricTap;
  final bool automaticallyImplyLeading;
  final List<DashboardMetricEntity> metrics;
  final VoidCallback? onActiveOrdersTap;
  final List<ActiveOrderEntity> activeOrders;
  final List<OrderHistoryEntryEntity> orderHistory;
  final List<ExpenseEntryEntity> expenses;

  const DashboardOverview({
    super.key,
    required this.title,
    this.actions = const [],
    this.onMetricTap,
    this.automaticallyImplyLeading = true,
    this.metrics = const [],
    this.onActiveOrdersTap,
    this.activeOrders = const [],
    this.orderHistory = const [],
    this.expenses = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeOrdersCount = activeOrders.length;
    final revenuePipeline = activeOrders.fold<double>(
      0,
      (total, order) => total + order.amount,
    );
    final avgTicket = activeOrdersCount == 0
        ? 0.0
        : revenuePipeline / activeOrdersCount;
    final recentHistory = orderHistory.take(4).toList();
    final expenseTotals = _categoryTotals(expenses);
    final expenseSum = expenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          ...actions,
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (onActiveOrdersTap != null) {
                  onActiveOrdersTap!();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening active orders')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Analytics',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Active orders: $activeOrdersCount',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Revenue pipeline ${_formatCurrency(revenuePipeline)}',
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Avg Ticket', style: theme.textTheme.labelLarge),
                        Text(
                          _formatCurrency(avgTicket),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Analytics refreshed'),
                                ),
                              ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Key Metrics', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return _MetricCard(
                metric: metric,
                onTap: () => _handleMetricTap(context, metric),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Recent History', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentHistory.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final history = recentHistory[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey.shade50,
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  title: Text(history.id),
                  subtitle: Text(
                    '${history.type} • ${history.status} • ${history.timestamp}',
                  ),
                  trailing: Text(_formatCurrency(history.amount)),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Expense Snapshot', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This week', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(expenseSum),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${expenses.length} logged expenses'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: expenseTotals.entries
                        .map(
                          (entry) => Chip(
                            label: Text(
                              '${entry.key}: ${_formatCurrency(entry.value)}',
                            ),
                            avatar: const Icon(
                              Icons.payments_outlined,
                              size: 18,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMetricTap(BuildContext context, DashboardMetricEntity metric) {
    if (onMetricTap != null) {
      onMetricTap!(context, metric);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${metric.title} insight tapped')));
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showLogoutConfirmationDialog(context);
    if (shouldLogout && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}

class _MetricCard extends StatelessWidget {
  final DashboardMetricEntity metric;
  final VoidCallback onTap;

  const _MetricCard({required this.metric, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final trendPositive = metric.trend >= 0;
    final trendColor = trendPositive ? Colors.green : Colors.red;
    final trendValue =
        '${trendPositive ? '+' : ''}${metric.trend.toStringAsFixed(1)}%';

    return Card(
      semanticContainer: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: metric.color.withValues(alpha: 0.12),
                child: Icon(metric.icon, color: metric.color),
              ),
              const Spacer(),
              Text(
                metric.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metric.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    trendPositive ? Icons.trending_up : Icons.trending_down,
                    color: trendColor,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trendValue,
                    style: TextStyle(
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

Map<String, double> _categoryTotals(List<ExpenseEntryEntity> expenses) {
  final totals = <String, double>{};
  for (final expense in expenses) {
    totals.update(
      expense.category,
      (current) => current + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return totals;
}
