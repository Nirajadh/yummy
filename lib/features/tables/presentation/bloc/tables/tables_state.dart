part of 'tables_bloc.dart';

enum TablesStatus { initial, loading, success, failure }

class TablesState extends Equatable {
  final TablesStatus status;
  final List<TableEntity> tables;
  final String? errorMessage;
  final String? lastMessage;
  final Map<String, int> categoryTypeIds;
  final List<TableTypeEntity>? tableTypes;
  final String selectedCategory;
  final String filterCategory;

  const TablesState({
    this.status = TablesStatus.initial,
    this.tables = const [],
    this.errorMessage,
    this.lastMessage,
    this.categoryTypeIds = const {},
    this.tableTypes = const [],
    this.selectedCategory = '',
    this.filterCategory = '',
  });

  TablesState copyWith({
    TablesStatus? status,
    List<TableEntity>? tables,
    String? errorMessage,
    String? lastMessage,
    Map<String, int>? categoryTypeIds,
    List<TableTypeEntity>? tableTypes,
    String? selectedCategory,
    String? filterCategory,
  }) {
    return TablesState(
      status: status ?? this.status,
      tables: tables ?? this.tables,
      errorMessage: errorMessage ?? this.errorMessage,
      lastMessage: lastMessage,
      categoryTypeIds: categoryTypeIds ?? this.categoryTypeIds,
      tableTypes: tableTypes ?? this.tableTypes ?? const [],
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filterCategory: filterCategory ?? this.filterCategory,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tables,
        errorMessage,
        lastMessage,
        categoryTypeIds,
        tableTypes,
        selectedCategory,
        filterCategory,
      ];
}
