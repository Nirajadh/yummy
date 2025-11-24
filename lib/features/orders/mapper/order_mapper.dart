import 'package:yummy/features/orders/data/models/active_order_model.dart';
import 'package:yummy/features/orders/data/models/order_history_entry_model.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';

class OrderMapper {
  static ActiveOrderEntity toActiveEntity(ActiveOrderModel model) {
    return ActiveOrderEntity(
      id: model.id ?? '',
      type: model.type ?? '',
      reference: model.reference ?? '',
      amount: model.amount ?? 0,
      itemsCount: model.itemsCount ?? 0,
      guests: model.guests ?? 0,
      startedAt: model.startedAt ?? '',
      status: model.status ?? 'Unknown',
      channel: model.channel ?? '',
      contact: model.contact,
    );
  }

  static ActiveOrderModel fromActiveEntity(ActiveOrderEntity entity) {
    return ActiveOrderModel(
      id: entity.id,
      type: entity.type,
      reference: entity.reference,
      amount: entity.amount,
      itemsCount: entity.itemsCount,
      guests: entity.guests,
      startedAt: entity.startedAt,
      status: entity.status,
      channel: entity.channel,
      contact: entity.contact,
    );
  }

  static OrderHistoryEntryEntity toHistoryEntity(
    OrderHistoryEntryModel model,
  ) {
    return OrderHistoryEntryEntity(
      id: model.id ?? '',
      type: model.type ?? '',
      amount: model.amount ?? 0,
      status: model.status ?? '',
      timestamp: model.timestamp ?? '',
    );
  }

  static OrderHistoryEntryModel fromHistoryEntity(
    OrderHistoryEntryEntity entity,
  ) {
    return OrderHistoryEntryModel(
      id: entity.id,
      type: entity.type,
      amount: entity.amount,
      status: entity.status,
      timestamp: entity.timestamp,
    );
  }
}
