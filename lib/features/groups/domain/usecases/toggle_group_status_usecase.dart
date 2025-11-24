import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';

class ToggleGroupStatusUseCase {
  final RestaurantRepository repository;

  const ToggleGroupStatusUseCase(this.repository);

  Future<void> call(String groupName) {
    return repository.toggleGroupStatus(groupName);
  }
}
