/// Order-related enums with API serialization helpers.
enum OrderChannel { table, group, pickup, quickBilling, delivery, online }

extension OrderChannelX on OrderChannel {
  String get apiValue {
    switch (this) {
      case OrderChannel.table:
        return 'table';
      case OrderChannel.group:
        return 'group';
      case OrderChannel.pickup:
        return 'pickup';
      case OrderChannel.quickBilling:
        return 'quick_billing';
      case OrderChannel.delivery:
        return 'delivery';
      case OrderChannel.online:
        return 'online';
    }
  }

  static OrderChannel? fromApi(String? value) {
    switch (value) {
      case 'table':
        return OrderChannel.table;
      case 'group':
        return OrderChannel.group;
      case 'pickup':
        return OrderChannel.pickup;
      case 'quick_billing':
        return OrderChannel.quickBilling;
      case 'delivery':
        return OrderChannel.delivery;
      case 'online':
        return OrderChannel.online;
      default:
        return null;
    }
  }
}

enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  completed,
  canceled,
}

extension OrderStatusX on OrderStatus {
  String get apiValue => name;

  static OrderStatus? fromApi(String? value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'accepted':
        return OrderStatus.accepted;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'completed':
        return OrderStatus.completed;
      case 'canceled':
        return OrderStatus.canceled;
      default:
        return null;
    }
  }
}

enum PaymentMethod { cash, card, upi, other }

extension PaymentMethodX on PaymentMethod {
  String get apiValue => name;

  static PaymentMethod? fromApi(String? value) {
    switch (value) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'upi':
        return PaymentMethod.upi;
      case 'other':
        return PaymentMethod.other;
      default:
        return null;
    }
  }
}

enum PaymentStatus { success, pending, failed, refunded }

extension PaymentStatusX on PaymentStatus {
  String get apiValue => name;

  static PaymentStatus? fromApi(String? value) {
    switch (value) {
      case 'success':
        return PaymentStatus.success;
      case 'pending':
        return PaymentStatus.pending;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return null;
    }
  }
}
