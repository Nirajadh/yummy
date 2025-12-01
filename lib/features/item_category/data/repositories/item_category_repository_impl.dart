import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/item_category/data/datasources/item_category_remote_data_source.dart';
import 'package:yummy/features/item_category/domain/entities/item_category_entity.dart';
import 'package:yummy/features/item_category/domain/repositories/item_category_repository.dart';
import 'package:yummy/features/item_category/mapper/item_category_mapper.dart';

class ItemCategoryRepositoryImpl implements ItemCategoryRepository {
  ItemCategoryRepositoryImpl({required this.remote});

  final ItemCategoryRemoteDataSource remote;

  @override
  Future<Either<Failure, List<ItemCategoryEntity>>> getItemCategories({
    required int restaurantId,
  }) async {
    try {
      final models = await remote.getItemCategories(restaurantId: restaurantId);
      return Right(models.map(ItemCategoryMapper.toEntity).toList());
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
  Future<Either<Failure, ItemCategoryEntity>> createItemCategory({
    required int restaurantId,
    required String name,
  }) async {
    try {
      final model = await remote.createItemCategory(
        restaurantId: restaurantId,
        name: name,
      );
      return Right(ItemCategoryMapper.toEntity(model));
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
  Future<Either<Failure, ItemCategoryEntity>> updateItemCategory({
    required int id,
    required String name,
  }) async {
    try {
      final model = await remote.updateItemCategory(id: id, name: name);
      return Right(ItemCategoryMapper.toEntity(model));
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
  Future<Either<Failure, void>> deleteItemCategory({required int id}) async {
    try {
      await remote.deleteItemCategory(id: id);
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
