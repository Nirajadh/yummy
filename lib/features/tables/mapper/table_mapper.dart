import 'package:yummy/features/tables/data/models/table_model.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';

class TableMapper {
  static TableEntity toEntity(TableModel model) {
    return TableEntity(
      name: model.name ?? '',
      capacity: model.capacity ?? 0,
      status: model.status ?? 'UNKNOWN',
      notes: model.notes ?? '',
      activeItems: model.activeItems ?? const [],
      pastOrders: model.pastOrders ?? const [],
      reservationName: model.reservationName,
    );
  }

  static TableModel fromEntity(TableEntity entity) {
    return TableModel(
      name: entity.name,
      capacity: entity.capacity,
      status: entity.status,
      notes: entity.notes,
      activeItems: entity.activeItems,
      pastOrders: entity.pastOrders,
      reservationName: entity.reservationName,
    );
  }
}
