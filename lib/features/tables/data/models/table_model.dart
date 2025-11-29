import 'package:yummy/features/common/data/dummy_data.dart' as dummy;

class TableModel {
  String? name;
  int? capacity;
  String? status;
  String? notes;
  List<String>? activeItems;
  List<String>? pastOrders;
  String? reservationName;
  String? category;

  TableModel({
    this.name,
    this.capacity,
    this.status,
    this.notes,
    this.activeItems,
    this.pastOrders,
    this.reservationName,
    this.category,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      name: (json['name'] as String?)?.trim(),
      capacity: _parseInt(json['capacity']),
      status: (json['status'] as String?)?.trim(),
      notes: json['notes'] as String?,
      activeItems: _mapStringList(json['activeItems']),
      pastOrders: _mapStringList(json['pastOrders']),
      reservationName: (json['reservationName'] as String?)?.trim(),
      category: (json['category'] as String?)?.trim(),
    );
  }

  factory TableModel.fromDummy(dummy.TableInfo table) {
    return TableModel(
      name: table.name,
      capacity: table.capacity,
      status: table.status,
      notes: table.notes,
      activeItems: table.activeItems,
      pastOrders: table.pastOrders,
      reservationName: table.reservationName,
      category: table.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'capacity': capacity,
      'status': status,
      'notes': notes,
      'activeItems': activeItems,
      'pastOrders': pastOrders,
      'reservationName': reservationName,
      'category': category,
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
  }) {
    return TableModel(
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      activeItems: activeItems ?? this.activeItems,
      pastOrders: pastOrders ?? this.pastOrders,
      reservationName: reservationName ?? this.reservationName,
      category: category ?? this.category,
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
