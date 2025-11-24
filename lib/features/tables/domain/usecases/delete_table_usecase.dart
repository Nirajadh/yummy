import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';

class DeleteTableUseCase {
  final RestaurantRepository repository;

  const DeleteTableUseCase(this.repository);

  Future<void> call(String name) {
    return repository.deleteTable(name);
  }
}
