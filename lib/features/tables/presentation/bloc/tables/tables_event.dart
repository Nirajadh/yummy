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

class TableDeleted extends TablesEvent {
  final String tableName;

  const TableDeleted(this.tableName);

  @override
  List<Object?> get props => [tableName];
}
