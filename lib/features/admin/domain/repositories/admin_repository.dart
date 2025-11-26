import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';

/// Admin-facing repository wrapper to expose privileged dashboard data.
abstract interface class AdminRepository {
  Future<DashboardSnapshot> getDashboardSnapshot();
}
