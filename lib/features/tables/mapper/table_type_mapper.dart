import 'package:yummy/features/tables/data/models/table_type_model.dart';
import 'package:yummy/features/tables/domain/entities/table_type_entity.dart';

class TableTypeMapper {
  static TableTypeEntity toEntity(TableTypeModel model) {
    return TableTypeEntity(
      id: model.id,
      name: model.name,
      restaurantId: model.restaurantId,
    );
  }
}
