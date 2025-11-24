class GroupPaymentEntry {
  final String payer;
  final double amount;
  final String method;
  final String? target;
  final int? covers;

  const GroupPaymentEntry({
    required this.payer,
    required this.amount,
    required this.method,
    this.target,
    this.covers,
  });

  GroupPaymentEntry copyWith({
    String? payer,
    double? amount,
    String? method,
    String? target,
    int? covers,
  }) {
    return GroupPaymentEntry(
      payer: payer ?? this.payer,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      target: target ?? this.target,
      covers: covers ?? this.covers,
    );
  }
}

class GroupOrderLine {
  final String id;
  final String label;
  final List<String>? items;
  final double amount;
  final String? target;
  final bool isHistoric;

  const GroupOrderLine({
    required this.id,
    required this.label,
    List<String>? items,
    required this.amount,
    this.target,
    this.isHistoric = false,
  }) : items = items ?? const [];

  GroupOrderLine copyWith({
    String? id,
    String? label,
    List<String>? items,
    double? amount,
    String? target,
    bool? isHistoric,
  }) {
    return GroupOrderLine(
      id: id ?? this.id,
      label: label ?? this.label,
      items: items ?? this.items,
      amount: amount ?? this.amount,
      target: target ?? this.target,
      isHistoric: isHistoric ?? this.isHistoric,
    );
  }
}
