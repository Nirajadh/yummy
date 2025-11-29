import 'package:yummy/features/tables/data/models/table_model.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';

class TableMapper {
  static TableEntity toEntity(TableModel model) {
    return TableEntity(
      id: model.id,
      name: model.name ?? '',
      capacity: model.capacity ?? 0,
      status: model.status ?? 'UNKNOWN',
      category: model.category ?? 'General',
      tableTypeId: model.tableTypeId ?? 0,
      notes: model.notes ?? '',
      activeItems: model.activeItems ?? const [],
      pastOrders: model.pastOrders ?? const [],
      reservationName: model.reservationName,
    );
  }

  static TableModel fromEntity(TableEntity entity) {
    return TableModel(
      id: entity.id,
      name: entity.name,
      capacity: entity.capacity,
      status: entity.status,
      category: entity.category,
      tableTypeId: entity.tableTypeId,
      notes: entity.notes,
      activeItems: entity.activeItems,
      pastOrders: entity.pastOrders,
      reservationName: entity.reservationName,
    );
  }
}
