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
  final Widget? topBanner;
  final Future<void> Function()? onRefresh;

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
    this.topBanner,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 700;
    final activeOrdersCount = activeOrders.length;
    final revenuePipeline = activeOrders.fold<double>(
      0,
      (total, order) => total + order.amount,
    );
    final avgTicket = activeOrdersCount == 0
        ? 0.0
        : revenuePipeline / activeOrdersCount;
    final recentHistory = orderHistory.take(4).toList();
    final expenseSum = expenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );
    final displayedMetrics = metrics.isNotEmpty
        ? metrics
        : _staticFallbackMetrics();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Admin Dashboard',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Today’s performance & operations',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
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
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: ScrollConfiguration(
          behavior: const _NoStretchScrollBehavior(),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowIndicator();
              return false;
            },
            child: _buildScrollableBody(
              context,
              theme: theme,
              isWide: isWide,
              activeOrdersCount: activeOrdersCount,
              revenuePipeline: revenuePipeline,
              avgTicket: avgTicket,
              recentHistory: recentHistory,
              displayedMetrics: displayedMetrics,
              expenses: expenses,
              expenseSum: expenseSum,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableBody(
    BuildContext context, {
    required ThemeData theme,
    required bool isWide,
    required int activeOrdersCount,
    required double revenuePipeline,
    required double avgTicket,
    required List<OrderHistoryEntryEntity> recentHistory,
    required List<DashboardMetricEntity> displayedMetrics,
    required List<ExpenseEntryEntity> expenses,
    required double expenseSum,
  }) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: _DashboardBody(
          theme: theme,
          isWide: isWide,
          topBanner: topBanner,
          activeOrdersCount: activeOrdersCount,
          revenuePipeline: revenuePipeline,
          avgTicket: avgTicket,
          onActiveOrdersTap: onActiveOrdersTap,
          displayedMetrics: displayedMetrics,
          recentHistory: recentHistory,
          expenses: expenses,
          expenseSum: expenseSum,
          onMetricTap: _handleMetricTap,
        ),
      ),
    );

    if (onRefresh == null) return content;

    return RefreshIndicator(onRefresh: onRefresh!, child: content);
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
    }
  }

  List<DashboardMetricEntity> _staticFallbackMetrics() {
    return const [
      DashboardMetricEntity(
        title: 'Analytics',
        value: '85% Efficiency',
        trend: 4.2,
        icon: Icons.show_chart_rounded,
        color: Colors.indigo,
      ),
      DashboardMetricEntity(
        title: 'Sales',
        value: '\$48.6K',
        trend: 6.1,
        icon: Icons.point_of_sale_rounded,
        color: Colors.deepOrange,
      ),
      DashboardMetricEntity(
        title: 'History',
        value: '248 Orders',
        trend: 2.4,
        icon: Icons.history_rounded,
        color: Colors.blueGrey,
      ),
      DashboardMetricEntity(
        title: 'Purchase',
        value: '\$12.4K',
        trend: -1.3,
        icon: Icons.shopping_cart_rounded,
        color: Colors.teal,
      ),
      DashboardMetricEntity(
        title: 'Income',
        value: '\$32.1K',
        trend: 3.7,
        icon: Icons.account_balance_wallet_rounded,
        color: Colors.green,
      ),
      DashboardMetricEntity(
        title: 'Expenses',
        value: '\$8.2K',
        trend: 1.1,
        icon: Icons.receipt_long_rounded,
        color: Colors.red,
      ),
    ];
  }
}

class _DashboardBody extends StatelessWidget {
  final ThemeData theme;
  final bool isWide;
  final Widget? topBanner;
  final int activeOrdersCount;
  final double revenuePipeline;
  final double avgTicket;
  final VoidCallback? onActiveOrdersTap;
  final List<DashboardMetricEntity> displayedMetrics;
  final List<OrderHistoryEntryEntity> recentHistory;
  final List<ExpenseEntryEntity> expenses;
  final double expenseSum;
  final MetricTapCallback onMetricTap;

  const _DashboardBody({
    required this.theme,
    required this.isWide,
    required this.topBanner,
    required this.activeOrdersCount,
    required this.revenuePipeline,
    required this.avgTicket,
    required this.onActiveOrdersTap,
    required this.displayedMetrics,
    required this.recentHistory,
    required this.expenses,
    required this.expenseSum,
    required this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget historySection = _HistorySection(
      theme: theme,
      recentHistory: recentHistory,
    );

    Widget expensesSection = _ExpensesSection(
      theme: theme,
      expenseSum: expenseSum,
      expensesCount: expenses.length,
    );

    Widget metricsSection = _MetricsSection(
      theme: theme,
      displayedMetrics: displayedMetrics,
      isWide: isWide,
      onMetricTap: onMetricTap,
    );

    Widget liveAnalytics = _LiveAnalyticsCard(
      theme: theme,
      activeOrdersCount: activeOrdersCount,
      revenuePipeline: revenuePipeline,
      avgTicket: avgTicket,
      onActiveOrdersTap: onActiveOrdersTap,
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topBanner != null) ...[topBanner!, const SizedBox(height: 12)],
          liveAnalytics,
          const SizedBox(height: 24),
          metricsSection,
          const SizedBox(height: 24),
          expensesSection,
          const SizedBox(height: 24),
          Text(
            'Activity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          historySection,
          const SizedBox(height: 24),
          _RecentExpensesSection(theme: theme, expenses: expenses),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topBanner != null) ...[topBanner!, const SizedBox(height: 12)],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  liveAnalytics,
                  const SizedBox(height: 24),
                  metricsSection,
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  historySection,
                  const SizedBox(height: 24),
                  expensesSection,
                  const SizedBox(height: 24),
                  _RecentExpensesSection(theme: theme, expenses: expenses),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiveAnalyticsCard extends StatelessWidget {
  final ThemeData theme;
  final int activeOrdersCount;
  final double revenuePipeline;
  final double avgTicket;
  final VoidCallback? onActiveOrdersTap;

  const _LiveAnalyticsCard({
    required this.theme,
    required this.activeOrdersCount,
    required this.revenuePipeline,
    required this.avgTicket,
    required this.onActiveOrdersTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        if (onActiveOrdersTap != null) {
          onActiveOrdersTap!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening active orders')),
          );
        }
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              primary.withValues(alpha: 0.18),
              primary.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today at a glance',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Live analytics for your restaurant',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      label: 'Active orders',
                      value: '$activeOrdersCount',
                      theme: theme,
                    ),
                  ),
                  Expanded(
                    child: _HeroStat(
                      label: 'Pipeline',
                      value: _formatCurrency(revenuePipeline),
                      theme: theme,
                    ),
                  ),
                  Expanded(
                    child: _HeroStat(
                      label: 'Avg ticket',
                      value: _formatCurrency(avgTicket),
                      theme: theme,
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

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MetricsSection extends StatelessWidget {
  final ThemeData theme;
  final List<DashboardMetricEntity> displayedMetrics;
  final bool isWide;
  final MetricTapCallback onMetricTap;

  const _MetricsSection({
    required this.theme,
    required this.displayedMetrics,
    required this.isWide,
    required this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isWide ? 3 : 2;
    final childAspectRatio = isWide ? 1.3 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          primary: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: displayedMetrics.length,
          itemBuilder: (context, index) {
            final metric = displayedMetrics[index];
            return _MetricCard(
              metric: metric,
              onTap: () => onMetricTap(context, metric),
            );
          },
        ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  final ThemeData theme;
  final List<OrderHistoryEntryEntity> recentHistory;

  const _HistorySection({required this.theme, required this.recentHistory});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Orders',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shadowColor: theme.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(recentHistory.length, (index) {
              final history = recentHistory[index];
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.06,
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(history.id),
                    subtitle: Text(
                      '${history.type} • ${history.status} • ${_formatTimestamp(history.timestamp)}',
                    ),
                    trailing: Text(_formatCurrency(history.amount)),
                  ),
                  if (index != recentHistory.length - 1)
                    const Divider(height: 0),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ExpensesSection extends StatelessWidget {
  final ThemeData theme;
  final double expenseSum;
  final int expensesCount;

  const _ExpensesSection({
    required this.theme,
    required this.expenseSum,
    required this.expensesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Snapshot',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 3,
            shadowColor: theme.shadowColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This week',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(expenseSum),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$expensesCount logged expenses',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentExpensesSection extends StatelessWidget {
  final ThemeData theme;
  final List<ExpenseEntryEntity> expenses;

  const _RecentExpensesSection({required this.theme, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final recentExpenses = expenses.take(4).toList();
    if (recentExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Expenses',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shadowColor: theme.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(recentExpenses.length, (index) {
              final expense = recentExpenses[index];
              return Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.payments_outlined),
                    ),
                    title: Text(expense.category),
                    subtitle: Text(expense.vendor),
                    trailing: Text(_formatCurrency(expense.amount)),
                  ),
                  if (index != recentExpenses.length - 1)
                    const Divider(height: 0),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final DashboardMetricEntity metric;
  final VoidCallback onTap;

  const _MetricCard({required this.metric, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendPositive = metric.trend >= 0;
    final trendColor = trendPositive
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final trendValue =
        '${trendPositive ? '+' : ''}${metric.trend.toStringAsFixed(1)}%';

    return Card(
      semanticContainer: true,
      elevation: 4,
      shadowColor: theme.shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        overlayColor: WidgetStateProperty.all(
          trendColor.withValues(alpha: 0.06),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: metric.color.withValues(alpha: 0.10),
                ),
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

String _formatTimestamp(String value) {
  try {
    final parsed = DateTime.parse(value);
    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')} '
        '${parsed.hour.toString().padLeft(2, '0')}:'
        '${parsed.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return value;
  }
}

class _NoStretchScrollBehavior extends ScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/////////////////////////////////a
///
///
///
///
///
///
///
///
///
///
///
///
///
///

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:yummy/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:yummy/features/auth/presentation/widgets/logout_confirmation_dialog.dart';
// import 'package:yummy/features/dashboard/domain/entities/dashboard_metric_entity.dart';
// import 'package:yummy/features/finance/domain/entities/expense_entry_entity.dart';
// import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
// import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';

// typedef MetricTapCallback =
//     void Function(BuildContext context, DashboardMetricEntity metric);

// class DashboardOverview extends StatelessWidget {
//   final String title;
//   final List<Widget> actions;
//   final MetricTapCallback? onMetricTap;
//   final bool automaticallyImplyLeading;
//   final List<DashboardMetricEntity> metrics;
//   final VoidCallback? onActiveOrdersTap;
//   final List<ActiveOrderEntity> activeOrders;
//   final List<OrderHistoryEntryEntity> orderHistory;
//   final List<ExpenseEntryEntity> expenses;
//   final Widget? topBanner;

//   const DashboardOverview({
//     super.key,
//     required this.title,
//     this.actions = const [],
//     this.onMetricTap,
//     this.automaticallyImplyLeading = true,
//     this.metrics = const [],
//     this.onActiveOrdersTap,
//     this.activeOrders = const [],
//     this.orderHistory = const [],
//     this.expenses = const [],
//     this.topBanner,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final activeOrdersCount = activeOrders.length;
//     final revenuePipeline = activeOrders.fold<double>(
//       0,
//       (total, order) => total + order.amount,
//     );
//     final avgTicket = activeOrdersCount == 0
//         ? 0.0
//         : revenuePipeline / activeOrdersCount;
//     final recentHistory = orderHistory.take(4).toList();
//     final expenseTotals = _categoryTotals(expenses);
//     final expenseSum = expenses.fold<double>(
//       0,
//       (total, expense) => total + expense.amount,
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         automaticallyImplyLeading: automaticallyImplyLeading,
//         actions: [
//           IconButton(
//             tooltip: 'Profile',
//             icon: const Icon(Icons.account_circle_outlined),
//             onPressed: () => Navigator.pushNamed(context, '/profile'),
//           ),
//           ...actions,
//           IconButton(
//             tooltip: 'Logout',
//             icon: const Icon(Icons.logout),
//             onPressed: () => _handleLogout(context),
//           ),
//         ],
//       ),
//       body: ScrollConfiguration(
//         behavior: const _NoStretchScrollBehavior(),
//         child: NotificationListener<OverscrollIndicatorNotification>(
//           onNotification: (notification) {
//             notification.disallowIndicator();
//             return true;
//           },
//           child: ListView(
//             physics: const ClampingScrollPhysics(),
//             padding: const EdgeInsets.all(16),
//             children: [
//               if (topBanner != null) ...[
//                 topBanner!,
//                 const SizedBox(height: 12),
//               ],
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(20),
//                   onTap: () {
//                     if (onActiveOrdersTap != null) {
//                       onActiveOrdersTap!();
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Opening active orders')),
//                       );
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Live Analytics',
//                                 style: theme.textTheme.titleMedium,
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Active orders: $activeOrdersCount',
//                                 style: theme.textTheme.headlineSmall?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Revenue pipeline ${_formatCurrency(revenuePipeline)}',
//                               ),
//                             ],
//                           ),
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(
//                               'Avg Ticket',
//                               style: theme.textTheme.labelLarge,
//                             ),
//                             Text(
//                               _formatCurrency(avgTicket),
//                               style: theme.textTheme.headlineSmall?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             FilledButton.tonalIcon(
//                               onPressed: () =>
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text('Analytics refreshed'),
//                                     ),
//                                   ),
//                               icon: const Icon(Icons.refresh),
//                               label: const Text('Refresh'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text('Key Metrics', style: theme.textTheme.titleMedium),
//               const SizedBox(height: 12),
//               GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 1,
//                 ),
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: metrics.length,
//                 itemBuilder: (context, index) {
//                   final metric = metrics[index];
//                   return _MetricCard(
//                     metric: metric,
//                     onTap: () => _handleMetricTap(context, metric),
//                   );
//                 },
//               ),
//               const SizedBox(height: 24),
//               Text('Recent History', style: theme.textTheme.titleMedium),
//               const SizedBox(height: 12),
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: recentHistory.length,
//                   separatorBuilder: (_, __) => const Divider(height: 0),
//                   itemBuilder: (context, index) {
//                     final history = recentHistory[index];
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: Colors.blueGrey.shade50,
//                         child: Icon(
//                           Icons.receipt_long,
//                           color: Colors.blueGrey.shade700,
//                         ),
//                       ),
//                       title: Text(history.id),
//                       subtitle: Text(
//                         '${history.type} • ${history.status} • ${history.timestamp}',
//                       ),
//                       trailing: Text(_formatCurrency(history.amount)),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text('Expense Snapshot', style: theme.textTheme.titleMedium),
//               const SizedBox(height: 12),
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('This week', style: theme.textTheme.labelLarge),
//                       const SizedBox(height: 4),
//                       Text(
//                         _formatCurrency(expenseSum),
//                         style: theme.textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text('${expenses.length} logged expenses'),
//                       const SizedBox(height: 12),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: expenseTotals.entries
//                             .map(
//                               (entry) => Chip(
//                                 label: Text(
//                                   '${entry.key}: ${_formatCurrency(entry.value)}',
//                                 ),
//                                 avatar: const Icon(
//                                   Icons.payments_outlined,
//                                   size: 18,
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleMetricTap(BuildContext context, DashboardMetricEntity metric) {
//     if (onMetricTap != null) {
//       onMetricTap!(context, metric);
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('${metric.title} insight tapped')));
//     }
//   }

//   Future<void> _handleLogout(BuildContext context) async {
//     final shouldLogout = await showLogoutConfirmationDialog(context);
//     if (shouldLogout && context.mounted) {
//       context.read<AuthBloc>().add(const LogoutRequested());
//       Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//     }
//   }
// }

// class _MetricCard extends StatelessWidget {
//   final DashboardMetricEntity metric;
//   final VoidCallback onTap;

//   const _MetricCard({required this.metric, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final trendPositive = metric.trend >= 0;
//     final trendColor = trendPositive ? Colors.green : Colors.red;
//     final trendValue =
//         '${trendPositive ? '+' : ''}${metric.trend.toStringAsFixed(1)}%';

//     return Card(
//       semanticContainer: true,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 backgroundColor: metric.color.withValues(alpha: 0.12),
//                 child: Icon(metric.icon, color: metric.color),
//               ),
//               const Spacer(),
//               Text(
//                 metric.title,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 metric.value,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(
//                     trendPositive ? Icons.trending_up : Icons.trending_down,
//                     color: trendColor,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     trendValue,
//                     style: TextStyle(
//                       color: trendColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

// Map<String, double> _categoryTotals(List<ExpenseEntryEntity> expenses) {
//   final totals = <String, double>{};
//   for (final expense in expenses) {
//     totals.update(
//       expense.category,
//       (current) => current + expense.amount,
//       ifAbsent: () => expense.amount,
//     );
//   }
//   return totals;
// }

// class _NoStretchScrollBehavior extends ScrollBehavior {
//   const _NoStretchScrollBehavior();

//   @override
//   Widget buildOverscrollIndicator(
//     BuildContext context,
//     Widget child,
//     ScrollableDetails details,
//   ) {
//     return child;
//   }
// }
