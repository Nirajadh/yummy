import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';
import 'package:yummy/features/menu/domain/repositories/menu_repository.dart';
import 'package:yummy/features/menu/mapper/menu_mapper.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl({required this.remote});

  final MenuRemoteDataSource remote;

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenusByRestaurant({
    required int restaurantId,
    int? itemCategoryId,
  }) async {
    try {
      final models = await remote.getMenusByRestaurant(
        restaurantId: restaurantId,
        itemCategoryId: itemCategoryId,
      );
      return Right(models.map(MenuMapper.toEntity).toList());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, MenuItemEntity>> createMenu({
    required int restaurantId,
    required String name,
    required double price,
    required int itemCategoryId,
    String? description,
    String? imagePath,
  }) async {
    try {
      final model = await remote.createMenu(
        restaurantId: restaurantId,
        name: name,
        price: price,
        itemCategoryId: itemCategoryId,
        description: description,
        imagePath: imagePath,
      );
      return Right(MenuMapper.toEntity(model));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, MenuItemEntity>> updateMenu({
    required int id,
    String? name,
    double? price,
    int? itemCategoryId,
    String? description,
    String? imagePath,
  }) async {
    try {
      final model = await remote.updateMenu(
        id: id,
        name: name,
        price: price,
        itemCategoryId: itemCategoryId,
        description: description,
        imagePath: imagePath,
      );
      return Right(MenuMapper.toEntity(model));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMenu({required int id}) async {
    try {
      await remote.deleteMenu(id: id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }
}
