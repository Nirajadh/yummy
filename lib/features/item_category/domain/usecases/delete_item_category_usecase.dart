import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/item_category/domain/repositories/item_category_repository.dart';

class DeleteItemCategoryUseCase {
  final ItemCategoryRepository repository;

  DeleteItemCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteItemCategory(id: id);
  }
}
