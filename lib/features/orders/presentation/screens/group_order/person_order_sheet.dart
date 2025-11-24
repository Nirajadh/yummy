import 'package:flutter/material.dart';

import 'models.dart';

Future<void> showPersonOrderSheet({
  required BuildContext context,
  required GroupOrderLine line,
  required void Function(GroupOrderLine updated) onSave,
}) async {
  final items = _buildItems(line);

  void recalcAndSave() {
    final total = items.fold<double>(
      0,
      (sum, item) => sum + item.price * item.qty,
    );
    final updatedLine = line.copyWith(
      amount: total,
      items: items.map((i) => '${i.name} x${i.qty}').toList(),
    );
    onSave(updatedLine);
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Items for ${line.target ?? 'All'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _currency(item.price),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (item.qty <= 1) return;
                            item.qty -= 1;
                            recalcAndSave();
                          },
                        ),
                        Text('${item.qty}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            item.qty += 1;
                            recalcAndSave();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                recalcAndSave();
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PersonOrderItem {
  final String name;
  final double price;
  int qty;

  _PersonOrderItem({
    required this.name,
    required this.price,
    required this.qty,
  });
}

List<_PersonOrderItem> _buildItems(GroupOrderLine line) {
  final items = line.items ?? const <String>[];
  final count = items.isEmpty ? 1 : items.length;
  final unitPrice = count > 0 && line.amount > 0
      ? line.amount / count
      : 0.0;

  if (items.isEmpty) {
    return [
      _PersonOrderItem(name: 'Item 1', price: unitPrice, qty: 1),
    ];
  }

  return items.map((raw) {
    final parts = raw.split('x');
    final qtyPart = parts.length > 1 ? parts.last.trim() : '1';
    final qty = int.tryParse(qtyPart) ?? 1;
    final name = parts.first.trim();
    return _PersonOrderItem(name: name, price: unitPrice, qty: qty);
  }).toList();
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';
