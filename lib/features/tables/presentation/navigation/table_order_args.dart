import 'package:yummy/features/tables/domain/entities/table_entity.dart';

class TableOrderArgs {
  final TableEntity? table;
  final int? tableId;
  final String? tableName;

  const TableOrderArgs({this.table, this.tableId, this.tableName});
}
