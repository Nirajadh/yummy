import 'package:yummy/features/common/data/datasources/local_dummy_data_source.dart';
import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:yummy/features/dashboard/mapper/dashboard_mapper.dart';
import 'package:yummy/features/finance/domain/entities/income_entry_entity.dart';
import 'package:yummy/features/finance/domain/entities/purchase_entry_entity.dart';
import 'package:yummy/features/finance/mapper/finance_mapper.dart';
import 'package:yummy/features/groups/domain/entities/group_entity.dart';
import 'package:yummy/features/groups/mapper/group_mapper.dart';
import 'package:yummy/features/kot/domain/entities/kot_ticket_entity.dart';
import 'package:yummy/features/kot/mapper/kot_ticket_mapper.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';
import 'package:yummy/features/orders/mapper/order_mapper.dart';
import 'package:yummy/features/staff/domain/entities/staff_member_entity.dart';
import 'package:yummy/features/staff/domain/entities/staff_record_entity.dart';
import 'package:yummy/features/staff/mapper/staff_mapper.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';
import 'package:yummy/features/tables/mapper/table_mapper.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final LocalDummyDataSource local;

  RestaurantRepositoryImpl({required this.local});

  @override
  Future<List<TableEntity>> getTables() async {
    return local.getTables().map(TableMapper.toEntity).toList();
  }

  @override
  Future<void> upsertTable(TableEntity table) async {
    final dto = TableMapper.fromEntity(table);
    local.upsertTable(dto);
  }

  @override
  Future<void> deleteTable(String tableName) async {
    local.deleteTable(tableName);
  }

  @override
  Future<List<GroupEntity>> getGroups() async {
    return local.getGroups().map(GroupMapper.toEntity).toList();
  }

  @override
  Future<void> upsertGroup(GroupEntity group) async {
    final dto = GroupMapper.fromEntity(group);
    local.upsertGroup(dto);
  }

  @override
  Future<void> toggleGroupStatus(String groupName) async {
    local.toggleGroupStatus(groupName);
  }

  @override
  Future<DashboardSnapshot> getDashboardSnapshot() async {
    return DashboardSnapshot(
      metrics: local
          .getDashboardMetrics()
          .map(DashboardMapper.toEntity)
          .toList(),
      activeOrders: local
          .getActiveOrders()
          .map(OrderMapper.toActiveEntity)
          .toList(),
      orderHistory: local
          .getOrderHistory()
          .map(OrderMapper.toHistoryEntity)
          .toList(),
      expenses: local.getExpenses().map(FinanceMapper.toExpenseEntity).toList(),
    );
  }

  @override
  Future<List<ActiveOrderEntity>> getActiveOrders() async {
    return local.getActiveOrders().map(OrderMapper.toActiveEntity).toList();
  }

  @override
  Future<List<OrderHistoryEntryEntity>> getOrderHistory() async {
    return local.getOrderHistory().map(OrderMapper.toHistoryEntity).toList();
  }

  @override
  Future<List<KotTicketEntity>> getKotTickets() async {
    return local.getKotTickets().map(KotTicketMapper.toEntity).toList();
  }

  @override
  Future<List<StaffMemberEntity>> getStaffMembers() async {
    return local.getStaffMembers().map(StaffMapper.toMemberEntity).toList();
  }

  @override
  Future<List<StaffRecordEntity>> getStaffRecords() async {
    return local.getStaffRecords().map(StaffMapper.toRecordEntity).toList();
  }

  @override
  Future<List<PurchaseEntryEntity>> getPurchases() async {
    return local.getPurchases().map(FinanceMapper.toPurchaseEntity).toList();
  }

  @override
  Future<List<IncomeEntryEntity>> getIncome() async {
    return local.getIncome().map(FinanceMapper.toIncomeEntity).toList();
  }
}
