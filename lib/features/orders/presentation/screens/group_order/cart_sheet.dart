import 'package:flutter/material.dart';

import 'models.dart';

Future<void> showGroupCartSheet({
  required BuildContext context,
  required List<GroupOrderLine> orderLines,
  required double total,
  required double due,
  required void Function(String? target) onTapTarget,
}) async {
  // Group lines by target (null/All grouped together).
  final groups = <String?, List<GroupOrderLine>>{};
  for (final line in orderLines) {
    final key = line.target; // null means All
    groups.putIfAbsent(key, () => []).add(line);
  }
  final summaries =
      groups.entries
          .map((entry) => _GroupSummary.fromEntry(entry.key, entry.value))
          .toList()
        ..sort((a, b) {
          if (a.isAll) return -1;
          if (b.isAll) return 1;
          return a.label.compareTo(b.label);
        });

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final colorScheme = Theme.of(context).colorScheme;
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Group Cart',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (orderLines.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${orderLines.length} item${orderLines.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (orderLines.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'No items added yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: summaries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final summary = summaries[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () =>
                          onTapTarget(summary.isAll ? null : summary.label),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
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
                                    summary.isAll
                                        ? 'All'
                                        : 'Person: ${summary.label}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${summary.orderCount} order${summary.orderCount == 1 ? '' : 's'}'
                                    '${summary.itemCount > 0 ? ' • ${summary.itemCount} items' : ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currency(summary.total),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total', style: TextStyle(color: Colors.grey)),
                      Text(
                        _currency(total),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Due', style: TextStyle(color: Colors.grey)),
                      Text(
                        _currency(due),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';

class _GroupSummary {
  final String label;
  final bool isAll;
  final int orderCount;
  final int itemCount;
  final double total;
  final List<String> items;

  _GroupSummary({
    required this.label,
    required this.isAll,
    required this.orderCount,
    required this.itemCount,
    required this.total,
    required this.items,
  });

  factory _GroupSummary.fromEntry(String? key, List<GroupOrderLine> lines) {
    final combinedItems = <String>[];
    for (final l in lines) {
      combinedItems.addAll(l.items ?? const []);
    }
    final total = lines.fold<double>(0, (sum, l) => sum + l.amount);
    return _GroupSummary(
      label: key ?? 'All',
      isAll: key == null,
      orderCount: lines.length,
      itemCount: combinedItems.length,
      total: total,
      items: combinedItems,
    );
  }
}
