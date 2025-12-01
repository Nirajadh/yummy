import 'package:yummy/features/common/data/dummy_data.dart' as dummy;
import 'package:yummy/features/dashboard/data/models/dashboard_metric_model.dart';
import 'package:yummy/features/finance/data/models/expense_entry_model.dart';
import 'package:yummy/features/finance/data/models/income_entry_model.dart';
import 'package:yummy/features/finance/data/models/purchase_entry_model.dart';
import 'package:yummy/features/groups/data/models/group_model.dart';
import 'package:yummy/features/kot/data/models/kot_ticket_model.dart';
import 'package:yummy/features/orders/data/models/active_order_model.dart';
import 'package:yummy/features/orders/data/models/order_history_entry_model.dart';
import 'package:yummy/features/staff/data/models/staff_member_model.dart';
import 'package:yummy/features/staff/data/models/staff_record_model.dart';
import 'package:yummy/features/tables/data/models/table_model.dart';

class LocalDummyDataSource {
  final List<TableModel> _tables = dummy.dummyTables
      .map(TableModel.fromDummy)
      .toList();
  final List<GroupModel> _groups = dummy.dummyGroups
      .map(GroupModel.fromDummy)
      .toList();
  final List<ActiveOrderModel> _activeOrders = dummy.dummyActiveOrders
      .map(ActiveOrderModel.fromDummy)
      .toList();
  final List<OrderHistoryEntryModel> _orderHistory = dummy.dummyOrderHistory
      .map(OrderHistoryEntryModel.fromDummy)
      .toList();

  List<TableModel> getTables() => List.unmodifiable(_tables);

  void upsertTable(TableModel table) {
    final index = _tables.indexWhere((t) => t.name == table.name);
    if (index == -1) {
      _tables.add(table);
    } else {
      _tables[index] = table;
    }
  }

  void deleteTable(String tableName) {
    _tables.removeWhere((t) => t.name == tableName);
  }

  List<GroupModel> getGroups() => List.unmodifiable(_groups);

  void upsertGroup(GroupModel group) {
    final index = _groups.indexWhere((g) => g.name == group.name);
    if (index == -1) {
      _groups.add(group);
    } else {
      _groups[index] = group;
    }
  }

  void toggleGroupStatus(String groupName) {
    final index = _groups.indexWhere((g) => g.name == groupName);
    if (index != -1) {
      final current = _groups[index];
      final isActive = current.isActive ?? true;
      _groups[index] = current.copyWith(isActive: !isActive);
    }
  }

  List<DashboardMetricModel> getDashboardMetrics() =>
      dummy.dashboardMetrics.map(DashboardMetricModel.fromDummy).toList();

  List<ActiveOrderModel> getActiveOrders() => List.unmodifiable(_activeOrders);

  List<OrderHistoryEntryModel> getOrderHistory() =>
      List.unmodifiable(_orderHistory);

  List<ExpenseEntryModel> getExpenses() =>
      dummy.dummyExpenses.map(ExpenseEntryModel.fromDummy).toList();

  List<KotTicketModel> getKotTickets() =>
      dummy.dummyKotTickets.map(KotTicketModel.fromDummy).toList();

  List<StaffMemberModel> getStaffMembers() =>
      dummy.dummyStaffMembers.map(StaffMemberModel.fromDummy).toList();

  List<StaffRecordModel> getStaffRecords() =>
      dummy.dummyStaffRecords.map(StaffRecordModel.fromDummy).toList();

  List<PurchaseEntryModel> getPurchases() =>
      dummy.dummyPurchases.map(PurchaseEntryModel.fromDummy).toList();

  List<IncomeEntryModel> getIncome() =>
      dummy.dummyIncome.map(IncomeEntryModel.fromDummy).toList();
}
