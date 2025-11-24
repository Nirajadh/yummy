import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';
import 'package:yummy/features/tables/domain/usecases/delete_table_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/get_tables_usecase.dart';
import 'package:yummy/features/tables/domain/usecases/upsert_table_usecase.dart';

part 'tables_event.dart';
part 'tables_state.dart';

class TablesBloc extends Bloc<TablesEvent, TablesState> {
  final GetTablesUseCase _getTables;
  final UpsertTableUseCase _upsertTable;
  final DeleteTableUseCase _deleteTable;

  TablesBloc({
    required GetTablesUseCase getTables,
    required UpsertTableUseCase upsertTable,
    required DeleteTableUseCase deleteTable,
  })  : _getTables = getTables,
        _upsertTable = upsertTable,
        _deleteTable = deleteTable,
        super(const TablesState()) {
    on<TablesRequested>(_onRequested);
    on<TableSaved>(_onSaved);
    on<TableDeleted>(_onDeleted);
  }

  Future<void> _onRequested(
    TablesRequested event,
    Emitter<TablesState> emit,
  ) async {
    emit(state.copyWith(status: TablesStatus.loading));
    try {
      final tables = await _getTables();
      emit(state.copyWith(status: TablesStatus.success, tables: tables));
    } catch (e) {
      emit(
        state.copyWith(
          status: TablesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSaved(
    TableSaved event,
    Emitter<TablesState> emit,
  ) async {
    await _upsertTable(event.table);
    add(const TablesRequested());
  }

  Future<void> _onDeleted(
    TableDeleted event,
    Emitter<TablesState> emit,
  ) async {
    await _deleteTable(event.tableName);
    add(const TablesRequested());
  }
}
