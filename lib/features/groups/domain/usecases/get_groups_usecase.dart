import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/groups/domain/entities/group_entity.dart';

class GetGroupsUseCase {
  final RestaurantRepository repository;

  const GetGroupsUseCase(this.repository);

  Future<List<GroupEntity>> call() {
    return repository.getGroups();
  }
}
