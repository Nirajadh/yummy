import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/menu/domain/repositories/menu_repository.dart';

class DeleteMenuUseCase {
  final MenuRepository repository;

  DeleteMenuUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteMenu(id: id);
  }
}
