import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/item_category/domain/entities/item_category_entity.dart';
import 'package:yummy/features/item_category/domain/repositories/item_category_repository.dart';

class UpdateItemCategoryUseCase {
  final ItemCategoryRepository repository;

  UpdateItemCategoryUseCase(this.repository);

  Future<Either<Failure, ItemCategoryEntity>> call({
    required int id,
    required String name,
  }) {
    return repository.updateItemCategory(id: id, name: name);
  }
}
