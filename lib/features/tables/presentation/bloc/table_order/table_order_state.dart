part of 'table_order_bloc.dart';

enum TableOrderStatus { initial, loading, success, failure }

class TableOrderState extends Equatable {
  final TableOrderStatus status;
  final TableEntity? table;
  final int? tableId;
  final String? tableName;
  final List<BillLineItem> cartItems;
  final List<ActiveOrderEntity> activeOrders;
  final String? errorMessage;
  final String? lastMessage;

  const TableOrderState({
    this.status = TableOrderStatus.initial,
    this.table,
    this.tableId,
    this.tableName,
    this.cartItems = const [],
    this.activeOrders = const [],
    this.errorMessage,
    this.lastMessage,
  });

  TableOrderState copyWith({
    TableOrderStatus? status,
    TableEntity? table,
    int? tableId,
    String? tableName,
    List<BillLineItem>? cartItems,
    List<ActiveOrderEntity>? activeOrders,
    String? errorMessage,
    String? lastMessage,
  }) {
    return TableOrderState(
      status: status ?? this.status,
      table: table ?? this.table,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      cartItems: cartItems ?? this.cartItems,
      activeOrders: activeOrders ?? this.activeOrders,
      errorMessage: errorMessage ?? this.errorMessage,
      lastMessage: lastMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        table,
        tableId,
        tableName,
        cartItems,
        activeOrders,
        errorMessage,
        lastMessage,
      ];
}
