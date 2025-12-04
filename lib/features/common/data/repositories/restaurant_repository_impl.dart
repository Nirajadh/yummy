import 'package:yummy/features/common/data/dummy_data.dart' as dummy;
import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:yummy/features/finance/domain/entities/income_entry_entity.dart';
import 'package:yummy/features/finance/domain/entities/purchase_entry_entity.dart';
import 'package:yummy/features/groups/data/models/group_model.dart';
import 'package:yummy/features/groups/domain/entities/group_entity.dart';
import 'package:yummy/features/groups/mapper/group_mapper.dart';
import 'package:yummy/features/kot/domain/entities/kot_ticket_entity.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';
import 'package:yummy/features/staff/domain/entities/staff_member_entity.dart';
import 'package:yummy/features/staff/domain/entities/staff_record_entity.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';

/// Minimal stub repository: only dummy group data is kept, everything else empty.
class RestaurantRepositoryImpl implements RestaurantRepository {
  RestaurantRepositoryImpl();

  @override
  Future<List<TableEntity>> getTables() async => const <TableEntity>[];

  @override
  Future<void> upsertTable(TableEntity table) async {}

  @override
  Future<void> deleteTable(String tableName) async {}

  @override
  Future<List<GroupEntity>> getGroups() async {
    return dummy.dummyGroups
        .map(GroupModel.fromDummy)
        .map(GroupMapper.toEntity)
        .toList();
  }

  @override
  Future<void> upsertGroup(GroupEntity group) async {}

  @override
  Future<void> toggleGroupStatus(String groupName) async {}

  @override
  Future<DashboardSnapshot> getDashboardSnapshot() async =>
      const DashboardSnapshot(
        metrics: [],
        orderHistory: [],
        expenses: [],
        activeOrders: [],
      );

  @override
  Future<List<ActiveOrderEntity>> getActiveOrders() async =>
      const <ActiveOrderEntity>[];

  @override
  Future<List<OrderHistoryEntryEntity>> getOrderHistory() async =>
      const <OrderHistoryEntryEntity>[];

  @override
  Future<List<KotTicketEntity>> getKotTickets() async =>
      const <KotTicketEntity>[];

  @override
  Future<List<StaffMemberEntity>> getStaffMembers() async =>
      const <StaffMemberEntity>[];

  @override
  Future<List<StaffRecordEntity>> getStaffRecords() async =>
      const <StaffRecordEntity>[];

  @override
  Future<List<PurchaseEntryEntity>> getPurchases() async =>
      const <PurchaseEntryEntity>[];

  @override
  Future<List<IncomeEntryEntity>> getIncome() async =>
      const <IncomeEntryEntity>[];
}
