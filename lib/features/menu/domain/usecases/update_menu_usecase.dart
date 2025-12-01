import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';
import 'package:yummy/features/menu/domain/repositories/menu_repository.dart';

class UpdateMenuUseCase {
  final MenuRepository repository;

  UpdateMenuUseCase(this.repository);

  Future<Either<Failure, MenuItemEntity>> call({
    required int id,
    String? name,
    double? price,
    int? itemCategoryId,
    String? description,
    String? imagePath,
  }) {
    return repository.updateMenu(
      id: id,
      name: name,
      price: price,
      itemCategoryId: itemCategoryId,
      description: description,
      imagePath: imagePath,
    );
  }
}
