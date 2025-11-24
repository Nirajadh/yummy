import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/staff/domain/entities/staff_member_entity.dart';

class GetStaffMembersUseCase {
  final RestaurantRepository repository;

  const GetStaffMembersUseCase(this.repository);

  Future<List<StaffMemberEntity>> call() {
    return repository.getStaffMembers();
  }
}
