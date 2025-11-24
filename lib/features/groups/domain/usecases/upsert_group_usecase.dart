import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/groups/domain/entities/group_entity.dart';

class UpsertGroupUseCase {
  final RestaurantRepository repository;

  const UpsertGroupUseCase(this.repository);

  Future<void> call(GroupEntity group) {
    return repository.upsertGroup(group);
  }
}
