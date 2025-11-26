import 'package:yummy/features/admin/domain/repositories/admin_repository.dart';
import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';

/// Thin adapter over the shared RestaurantRepository for admin-only needs.
class AdminRepositoryImpl implements AdminRepository {
  final RestaurantRepository base;

  AdminRepositoryImpl({required this.base});

  @override
  Future<DashboardSnapshot> getDashboardSnapshot() {
    return base.getDashboardSnapshot();
  }
}
