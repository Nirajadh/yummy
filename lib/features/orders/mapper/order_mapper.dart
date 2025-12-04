import 'package:yummy/features/orders/data/models/active_order_model.dart';
import 'package:yummy/features/orders/data/models/order_history_entry_model.dart';
import 'package:yummy/features/orders/data/models/order_model.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_item_entity.dart';

class OrderMapper {
  static ActiveOrderEntity toActiveEntity(ActiveOrderModel model) {
    return ActiveOrderEntity(
      id: model.id ?? '',
      type: model.type ?? '',
      reference: model.reference ?? '',
      tableName: model.tableName,
      amount: model.amount ?? 0,
      itemsCount: model.itemsCount ?? 0,
      guests: model.guests ?? 0,
      startedAt: model.startedAt ?? '',
      status: model.status ?? 'Unknown',
      channel: model.channel ?? '',
      contact: model.contact,
      tableId: model.tableId,
      items: model.items.map((e) => e.toEntity()).toList(),
    );
  }

  static ActiveOrderModel fromActiveEntity(ActiveOrderEntity entity) {
    return ActiveOrderModel(
      id: entity.id,
      type: entity.type,
      reference: entity.reference,
      tableName: entity.tableName,
      amount: entity.amount,
      itemsCount: entity.itemsCount,
      guests: entity.guests,
      startedAt: entity.startedAt,
      status: entity.status,
      channel: entity.channel,
      contact: entity.contact,
      tableId: entity.tableId,
      items: entity.items
          .map(
            (OrderItemEntity e) => OrderItemModel(
              id: e.id,
              menuItemId: e.menuItemId,
              name: e.name,
              categoryName: e.categoryName,
              unitPrice: e.unitPrice,
              qty: e.qty,
              lineTotal: e.lineTotal,
              notes: e.notes,
            ),
          )
          .toList(),
    );
  }

  static OrderHistoryEntryEntity toHistoryEntity(OrderHistoryEntryModel model) {
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

  static OrderEntity toOrderEntity(OrderModel model) => model.toEntity();

  static ActiveOrderEntity toActiveFromOrder(OrderModel model) {
    String labelForChannel() {
      switch (model.channel) {
        case OrderChannel.table:
          return 'Table';
        case OrderChannel.group:
          return 'Group';
        case OrderChannel.pickup:
          return 'Pickup';
        case OrderChannel.quickBilling:
          return 'Quick Billing';
        case OrderChannel.delivery:
          return 'Delivery';
        case OrderChannel.online:
          return 'Online';
      }
    }

    return ActiveOrderEntity(
      id: model.id.toString(),
      type: labelForChannel(),
      reference:
          model.tableId?.toString() ??
          model.groupId?.toString() ??
          '#${model.id}',
      tableName: model.tableName,
      amount: model.grandTotal,
      itemsCount: model.items.length,
      guests: model.groupId ?? model.tableId ?? 0,
      startedAt: model.createdAt,
      status: model.status.apiValue,
      channel: model.channel.apiValue,
      contact: model.customerName ?? model.customerPhone,
      tableId: model.tableId,
      items: model.items.map((e) => e.toEntity()).toList(),
    );
  }
}
