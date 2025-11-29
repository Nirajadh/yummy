import 'package:yummy/features/common/data/dummy_data.dart' as dummy;

class TableModel {
  int? id;
  String? name;
  int? capacity;
  String? status;
  String? notes;
  List<String>? activeItems;
  List<String>? pastOrders;
  String? reservationName;
  String? category;
  int? tableTypeId;

  TableModel({
    this.id,
    this.name,
    this.capacity,
    this.status,
    this.notes,
    this.activeItems,
    this.pastOrders,
    this.reservationName,
    this.category,
    this.tableTypeId,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: _parseInt(json['id']),
      name: (json['name'] as String?)?.trim(),
      capacity: _parseInt(json['capacity']),
      status: (json['status'] as String?)?.trim(),
      notes: json['notes'] as String?,
      activeItems: _mapStringList(json['activeItems']),
      pastOrders: _mapStringList(json['pastOrders']),
      reservationName: (json['reservationName'] as String?)?.trim(),
      category: (json['category'] as String?)?.trim(),
      tableTypeId: _parseInt(json['table_type_id']),
    );
  }

  factory TableModel.fromDummy(dummy.TableInfo table) {
    return TableModel(
      id: table.id,
      name: table.name,
      capacity: table.capacity,
      status: table.status,
      notes: table.notes,
      activeItems: table.activeItems,
      pastOrders: table.pastOrders,
      reservationName: table.reservationName,
      category: table.category,
      tableTypeId: table.tableTypeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'status': status,
      'notes': notes,
      'activeItems': activeItems,
      'pastOrders': pastOrders,
      'reservationName': reservationName,
      'category': category,
      'table_type_id': tableTypeId,
    };
  }

  TableModel copyWith({
    String? name,
    int? capacity,
    String? status,
    String? notes,
    List<String>? activeItems,
    List<String>? pastOrders,
    String? reservationName,
    String? category,
    int? tableTypeId,
  }) {
    return TableModel(
      id: id ?? id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      activeItems: activeItems ?? this.activeItems,
      pastOrders: pastOrders ?? this.pastOrders,
      reservationName: reservationName ?? this.reservationName,
      category: category ?? this.category,
      tableTypeId: tableTypeId ?? this.tableTypeId,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String>? _mapStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return null;
  }
}
