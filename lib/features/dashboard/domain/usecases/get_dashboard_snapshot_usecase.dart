import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';

class GetDashboardSnapshotUseCase {
  final RestaurantRepository repository;

  const GetDashboardSnapshotUseCase(this.repository);

  Future<DashboardSnapshot> call() {
    return repository.getDashboardSnapshot();
  }
}
