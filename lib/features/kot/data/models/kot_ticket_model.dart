class KotTicketModel {
  String? id;
  String? type;
  String? reference;
  List<String>? items;
  String? time;
  String? status;

  KotTicketModel({
    this.id,
    this.type,
    this.reference,
    this.items,
    this.time,
    this.status,
  });

  factory KotTicketModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final items = itemsJson is List
        ? itemsJson.whereType<String>().toList()
        : null;

    return KotTicketModel(
      id: (json['id'] as String?)?.trim(),
      type: (json['type'] as String?)?.trim(),
      reference: (json['reference'] as String?)?.trim(),
      items: items,
      time: (json['time'] as String?)?.trim(),
      status: (json['status'] as String?)?.trim() ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'reference': reference,
      'items': items,
      'time': time,
      'status': status,
    };
  }
}
