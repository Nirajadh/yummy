part of 'tables_bloc.dart';

sealed class TablesEvent extends Equatable {
  const TablesEvent();

  @override
  List<Object?> get props => [];
}

class TablesRequested extends TablesEvent {
  const TablesRequested();
}

class TableSaved extends TablesEvent {
  final TableEntity table;

  const TableSaved(this.table);

  @override
  List<Object?> get props => [table];
}

class TableCategoryAdded extends TablesEvent {
  final String name;

  const TableCategoryAdded(this.name);

  @override
  List<Object?> get props => [name];
}

class TableCategorySelected extends TablesEvent {
  final String? name;

  const TableCategorySelected(this.name);

  @override
  List<Object?> get props => [name];
}

class TableCategoryFilterChanged extends TablesEvent {
  final String category;
  const TableCategoryFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class TableDeleted extends TablesEvent {
  final String tableName;
  final int? tableId;

  const TableDeleted(this.tableName, {this.tableId});

  @override
  List<Object?> get props => [tableName, tableId];
}
