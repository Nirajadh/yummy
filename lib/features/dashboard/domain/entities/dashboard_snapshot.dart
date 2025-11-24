import 'package:equatable/equatable.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_metric_entity.dart';
import 'package:yummy/features/finance/domain/entities/expense_entry_entity.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';

class DashboardSnapshot extends Equatable {
  final List<DashboardMetricEntity> metrics;
  final List<ActiveOrderEntity> activeOrders;
  final List<OrderHistoryEntryEntity> orderHistory;
  final List<ExpenseEntryEntity> expenses;

  const DashboardSnapshot({
    required this.metrics,
    required this.activeOrders,
    required this.orderHistory,
    required this.expenses,
  });

  @override
  List<Object?> get props => [metrics, activeOrders, orderHistory, expenses];
}
