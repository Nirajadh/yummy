import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';

/// Staff-facing repository wrapper that constrains accessible data.
abstract interface class StaffPortalRepository {
  Future<DashboardSnapshot> getDashboardSnapshot();
  Future<List<ActiveOrderEntity>> getActiveOrders();
}
