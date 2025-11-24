part of 'tables_bloc.dart';

enum TablesStatus { initial, loading, success, failure }

class TablesState extends Equatable {
  final TablesStatus status;
  final List<TableEntity> tables;
  final String? errorMessage;

  const TablesState({
    this.status = TablesStatus.initial,
    this.tables = const [],
    this.errorMessage,
  });

  TablesState copyWith({
    TablesStatus? status,
    List<TableEntity>? tables,
    String? errorMessage,
  }) {
    return TablesState(
      status: status ?? this.status,
      tables: tables ?? this.tables,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tables, errorMessage];
}
