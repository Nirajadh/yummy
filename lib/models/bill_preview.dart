class BillLineItem {
  final String name;
  final int quantity;
  final double price;

  const BillLineItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => quantity * price;
}

class BillPreviewArgs {
  final String orderLabel;
  final List<BillLineItem> items;
  final double subtotal;
  final double tax;
  final double serviceCharge;
  final double grandTotal;
  final bool allowMultiplePayments;
  final Map<String, double>? paymentTargets;

  const BillPreviewArgs({
    required this.orderLabel,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.serviceCharge,
    required this.grandTotal,
    this.allowMultiplePayments = true,
    this.paymentTargets,
  });
}
