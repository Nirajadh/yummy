import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/staff_portal/domain/repositories/staff_portal_repository.dart';

/// Thin adapter over RestaurantRepository for staff-limited views.
class StaffPortalRepositoryImpl implements StaffPortalRepository {
  final RestaurantRepository base;

  StaffPortalRepositoryImpl({required this.base});

  @override
  Future<DashboardSnapshot> getDashboardSnapshot() {
    // In a real impl, filter to staff-scoped metrics.
    return base.getDashboardSnapshot();
  }

  @override
  Future<List<ActiveOrderEntity>> getActiveOrders() {
    return base.getActiveOrders();
  }
}
