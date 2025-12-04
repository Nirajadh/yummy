part of 'table_order_bloc.dart';

abstract class TableOrderEvent extends Equatable {
  const TableOrderEvent();

  @override
  List<Object?> get props => [];
}

class TableOrderStarted extends TableOrderEvent {
  final TableEntity? table;
  final int? tableId;
  final String? tableName;

  const TableOrderStarted({this.table, this.tableId, this.tableName});

  @override
  List<Object?> get props => [table, tableId, tableName];
}

class TableOrderCartUpdated extends TableOrderEvent {
  final List<BillLineItem> items;
  final String? message;

  const TableOrderCartUpdated({required this.items, this.message});

  @override
  List<Object?> get props => [items, message];
}

class TableOrderStatusChanged extends TableOrderEvent {
  final String status;
  final String? message;

  const TableOrderStatusChanged(this.status, {this.message});

  @override
  List<Object?> get props => [status, message];
}

class TableOrderTableUpdated extends TableOrderEvent {
  final TableEntity table;

  const TableOrderTableUpdated(this.table);

  @override
  List<Object?> get props => [table];
}
