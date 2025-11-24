import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/staff/domain/entities/staff_record_entity.dart';

class GetStaffRecordsUseCase {
  final RestaurantRepository repository;

  const GetStaffRecordsUseCase(this.repository);

  Future<List<StaffRecordEntity>> call() {
    return repository.getStaffRecords();
  }
}
