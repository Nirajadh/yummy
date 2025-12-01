import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:yummy/features/finance/domain/entities/income_entry_entity.dart';
import 'package:yummy/features/finance/domain/entities/purchase_entry_entity.dart';
import 'package:yummy/features/groups/domain/entities/group_entity.dart';
import 'package:yummy/features/kot/domain/entities/kot_ticket_entity.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';
import 'package:yummy/features/staff/domain/entities/staff_member_entity.dart';
import 'package:yummy/features/staff/domain/entities/staff_record_entity.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';

abstract class RestaurantRepository {
  Future<List<TableEntity>> getTables();
  Future<void> upsertTable(TableEntity table);
  Future<void> deleteTable(String tableName);

  Future<List<GroupEntity>> getGroups();
  Future<void> upsertGroup(GroupEntity group);
  Future<void> toggleGroupStatus(String groupName);

  Future<DashboardSnapshot> getDashboardSnapshot();
  Future<List<ActiveOrderEntity>> getActiveOrders();
  Future<List<OrderHistoryEntryEntity>> getOrderHistory();

  Future<List<KotTicketEntity>> getKotTickets();

  Future<List<StaffMemberEntity>> getStaffMembers();
  Future<List<StaffRecordEntity>> getStaffRecords();

  Future<List<PurchaseEntryEntity>> getPurchases();
  Future<List<IncomeEntryEntity>> getIncome();
}
