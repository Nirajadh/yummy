import 'package:flutter/material.dart';

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(value, style: textStyle),
      ],
    );
  }
}

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double discount;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    final total = (subtotal - discount).clamp(0, double.infinity);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Discount',
            value: '-\$${discount.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Sub total',
            value: '\$${total.toStringAsFixed(2)}',
            bold: true,
          ),
        ],
      ),
    );
  }
}
