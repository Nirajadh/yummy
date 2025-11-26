import 'package:yummy/features/admin/domain/repositories/admin_repository.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';

class GetAdminDashboardSnapshotUseCase {
  final AdminRepository repository;

  const GetAdminDashboardSnapshotUseCase(this.repository);

  Future<DashboardSnapshot> call() {
    return repository.getDashboardSnapshot();
  }
}
