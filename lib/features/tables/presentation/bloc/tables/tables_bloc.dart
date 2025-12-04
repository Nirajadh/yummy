import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';
import 'package:yummy/features/tables/domain/entities/table_type_entity.dart';
import 'package:yummy/features/tables/domain/usecases/delete_table_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/upsert_table_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/create_remote_table_usecase.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';
import 'package:yummy/features/tables/domain/usecases/create_table_type_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/get_table_types_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/get_remote_tables_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/delete_remote_table_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/update_remote_table_usecase.dart';
import 'package:yummy/core/error/failure.dart';

part 'tables_event.dart';
part 'tables_state.dart';

class TablesBloc extends Bloc<TablesEvent, TablesState> {
  final UpsertTableUseCase _upsertTable;
  final DeleteTableUseCase _deleteTable;
  final CreateRemoteTableUseCase _createRemoteTable;
  final RestaurantDetailsService _detailsService = RestaurantDetailsService();
  final CreateTableTypeUseCase _createTableType;
  final GetTableTypesUseCase _getTableTypes;
  final GetRemoteTablesUseCase _getRemoteTables;
  final DeleteRemoteTableUseCase _deleteRemoteTable;
  final UpdateRemoteTableUseCase _updateRemoteTable;

  TablesBloc({
    required UpsertTableUseCase upsertTable,
    required DeleteTableUseCase deleteTable,
    required CreateRemoteTableUseCase createRemoteTable,
    required CreateTableTypeUseCase createTableType,
    required GetTableTypesUseCase getTableTypes,
    required GetRemoteTablesUseCase getRemoteTables,
    required DeleteRemoteTableUseCase deleteRemoteTable,
    required UpdateRemoteTableUseCase updateRemoteTable,
  }) : _upsertTable = upsertTable,
       _deleteTable = deleteTable,
       _createRemoteTable = createRemoteTable,
       _createTableType = createTableType,
       _getTableTypes = getTableTypes,
       _getRemoteTables = getRemoteTables,
       _deleteRemoteTable = deleteRemoteTable,
       _updateRemoteTable = updateRemoteTable,
       super(const TablesState()) {
    on<TablesRequested>(_onRequested);
    on<TableSaved>(_onSaved);
    on<TableDeleted>(_onDeleted);
    on<TableCategoryAdded>(_onCategoryAdded);
    on<TableCategorySelected>(_onCategorySelected);
    on<TableCategoryFilterChanged>(_onCategoryFilterChanged);
  }

  Future<void> _onRequested(
    TablesRequested event,
    Emitter<TablesState> emit,
  ) async {
    emit(state.copyWith(status: TablesStatus.loading));
    final details = await _detailsService.getDetails();
    final restaurantId = details.id;
    if (restaurantId == null || restaurantId <= 0) {
      emit(
        state.copyWith(
          status: TablesStatus.success,
          tables: const [],
          errorMessage: null,
          lastMessage: null,
        ),
      );
      return;
    }

    if (state.tableTypes == null || state.tableTypes!.isEmpty) {
      await _syncRemoteTableTypes(emit, restaurantId);
    }

    final tablesResult = await _getRemoteTables(restaurantId: restaurantId);
    tablesResult.fold(
      (failure) => emit(
        state.copyWith(
          status: TablesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (tables) {
        final idToName = <int, String>{
          for (final entry in state.categoryTypeIds.entries)
            entry.value: entry.key,
        };
        final defaultCategory =
            state.selectedCategory.isNotEmpty &&
                idToName.values.contains(state.selectedCategory)
            ? state.selectedCategory
            : (idToName.values.isNotEmpty ? idToName.values.first : '');
        final effectiveCategory = state.selectedCategory.isNotEmpty
            ? state.selectedCategory
            : defaultCategory;
        final mappedTables = tables
            .map(
              (t) =>
                  t.copyWith(category: idToName[t.tableTypeId] ?? t.category),
            )
            .toList();
        emit(
          state.copyWith(
            status: TablesStatus.success,
            tables: mappedTables,
            errorMessage: null,
            lastMessage: null,
            selectedCategory: effectiveCategory,
            filterCategory: effectiveCategory,
          ),
        );
      },
    );
  }

  Future<void> _onSaved(TableSaved event, Emitter<TablesState> emit) async {
    final details = await _detailsService.getDetails();
    final restaurantId = details.id;

    if (restaurantId != null && restaurantId > 0) {
      final tableTypeId = state.categoryTypeIds[event.table.category] ?? 1;
      final tableWithType = event.table.copyWith(tableTypeId: tableTypeId);
      final remoteResult = event.table.id != null
          ? await _updateRemoteTable(
            tableId: event.table.id!,
            name: event.table.name,
            capacity: event.table.capacity,
            tableTypeId: tableTypeId,
            status: event.table.status,
          )
          : await _createRemoteTable(
            restaurantId: restaurantId,
            name: event.table.name,
            capacity: event.table.capacity,
            tableTypeId: tableTypeId,
            status: event.table.status,
          );
      remoteResult.fold(
        (_) async {
          await _upsertTable(tableWithType);
        },
        (remoteTable) async {
          await _upsertTable(
            remoteTable.copyWith(
              category: event.table.category,
              notes: event.table.notes,
              activeItems: event.table.activeItems,
              pastOrders: event.table.pastOrders,
              reservationName: event.table.reservationName,
            ),
          );
        },
      );
    } else {
      await _upsertTable(event.table);
    }
    add(const TablesRequested());
  }

  Future<void> _onDeleted(TableDeleted event, Emitter<TablesState> emit) async {
    final details = await _detailsService.getDetails();
    final restaurantId = details.id;
    if (restaurantId != null && restaurantId > 0 && event.tableId != null) {
      final result = await _deleteRemoteTable(tableId: event.tableId!);
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: TablesStatus.failure,
            errorMessage: failure.message,
            lastMessage: null,
          ),
        ),
        (_) async {
          await _deleteTable(event.tableName);
        },
      );
    } else {
      await _deleteTable(event.tableName);
    }
    add(const TablesRequested());
  }

  Future<void> _onCategoryAdded(
    TableCategoryAdded event,
    Emitter<TablesState> emit,
  ) async {
    final details = await _detailsService.getDetails();
    final restaurantId = details.id;
    if (restaurantId == null || restaurantId <= 0) return;
    final result = await _createTableType(
      restaurantId: restaurantId,
      name: event.name,
    );
    result.fold(
      (Failure failure) => emit(
        state.copyWith(
          status: TablesStatus.failure,
          errorMessage: failure.message,
          lastMessage: null,
        ),
      ),
      (tableType) {
        final updatedTypes = [
          ...(state.tableTypes ?? const []).where(
            (t) => t.name != tableType.name,
          ),
          tableType,
        ];
        emit(
          state.copyWith(
            status: TablesStatus.success,
            lastMessage: 'Category "${event.name}" added',
            categoryTypeIds: {
              ...state.categoryTypeIds,
              event.name: tableType.id,
            },
            tableTypes: updatedTypes,
            selectedCategory: event.name,
          ),
        );
      },
    );
  }

  void _onCategorySelected(
    TableCategorySelected event,
    Emitter<TablesState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategory: event.name ?? '',
        filterCategory: event.name ?? '',
      ),
    );
  }

  void _onCategoryFilterChanged(
    TableCategoryFilterChanged event,
    Emitter<TablesState> emit,
  ) {
    emit(
      state.copyWith(
        filterCategory: event.category,
        selectedCategory: event.category,
      ),
    );
  }

  Future<void> _syncRemoteTableTypes(
    Emitter<TablesState> emit,
    int restaurantId,
  ) async {
    final result = await _getTableTypes(restaurantId: restaurantId);
    result.fold(
      (failure) => emit(
        state.copyWith(errorMessage: failure.message, lastMessage: null),
      ),
      (types) {
        final mapping = <String, int>{
          for (final type in types) type.name: type.id,
        };
        debugPrint(
          'Fetched ${types.length} table type(s) for restaurant $restaurantId',
        );
        final newSelected = state.selectedCategory.isNotEmpty
            ? state.selectedCategory
            : (types.isNotEmpty ? types.first.name : '');
        emit(
          state.copyWith(
            tableTypes: types,
            categoryTypeIds: mapping,
            errorMessage: null,
            lastMessage: 'Loaded ${types.length} table categories',
            selectedCategory: newSelected,
          ),
        );
      },
    );
  }
}
