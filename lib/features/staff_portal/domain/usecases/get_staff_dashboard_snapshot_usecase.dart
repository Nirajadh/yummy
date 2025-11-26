import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:yummy/features/staff_portal/domain/repositories/staff_portal_repository.dart';

class GetStaffDashboardSnapshotUseCase {
  final StaffPortalRepository repository;

  const GetStaffDashboardSnapshotUseCase(this.repository);

  Future<DashboardSnapshot> call() {
    return repository.getDashboardSnapshot();
  }
}
