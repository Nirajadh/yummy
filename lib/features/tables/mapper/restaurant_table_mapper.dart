import 'package:yummy/features/tables/data/models/restaurant_table_model.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';

class RestaurantTableMapper {
  static TableEntity toEntity(RestaurantTableModel model) {
    return TableEntity(
      id: model.id,
      name: model.tableName,
      capacity: model.capacity,
      status: model.status.toUpperCase(),
      category: 'Type ${model.tableTypeId}',
      tableTypeId: model.tableTypeId,
      notes: '',
      activeItems: const [],
      pastOrders: const [],
      reservationName: null,
    );
  }
}
