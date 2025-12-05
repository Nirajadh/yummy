import 'package:flutter/material.dart';
import 'package:yummy/core/di/di.dart';
import 'package:yummy/features/orders/domain/entities/bill_preview.dart';
import 'package:yummy/features/orders/domain/entities/order_inputs.dart';
import 'package:yummy/features/orders/domain/repositories/order_repository.dart';

class OrderCartLine {
  final int? menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;

  const OrderCartLine({
    this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get lineTotal => unitPrice * quantity;

  OrderCartLine copyWith({
    int? menuItemId,
    String? name,
    int? quantity,
    double? unitPrice,
  }) {
    return OrderCartLine(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

Future<void> showOrderCartSheet(
  BuildContext context, {
  required String title,
  required int orderId,
  required List<OrderCartLine> lines,
}) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final surface = theme.cardColor;
  final textColor =
      theme.textTheme.bodyLarge?.color ??
      (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);
  final subtle = textColor.withValues(alpha: 0.65);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
      final editableLines = List<OrderCartLine>.from(lines);
      return StatefulBuilder(
        builder: (context, setState) {
          double subtotal() =>
              editableLines.fold<double>(0, (sum, line) => sum + line.lineTotal);

          void updateQuantity(int index, int delta) {
            if (index < 0 || index >= editableLines.length) return;
            final current = editableLines[index];
            final newQty = current.quantity + delta;
            if (newQty <= 0) {
              editableLines.removeAt(index);
            } else {
              editableLines[index] = current.copyWith(quantity: newQty);
            }
            setState(() {});
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: subtle),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
                if (editableLines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'No items in cart yet.',
                        style: TextStyle(fontSize: 16, color: subtle),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: editableLines.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final line = editableLines[index];
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              child: Icon(
                                Icons.restaurant_menu,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${line.unitPrice.toStringAsFixed(2)} each',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: subtle),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => updateQuantity(index, -1),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text(
                                  '${line.quantity}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                IconButton(
                                  onPressed: () => updateQuantity(index, 1),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${line.lineTotal.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                if (editableLines.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${subtotal().toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                if (editableLines.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final repo = sl<OrderRepository>();
                        final payload = editableLines
                            .where(
                              (line) =>
                                  line.menuItemId != null && line.quantity >= 0,
                            )
                            .map(
                              (line) => OrderItemInput(
                                menuItemId: line.menuItemId!,
                                qty: line.quantity,
                                notes: null,
                              ),
                            )
                            .toList();
                        final result = await repo.updateOrderItems(
                          orderId: orderId,
                          items: payload,
                        );
                        if (!context.mounted) return;
                        result.match(
                          (failure) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(failure.message)),
                          ),
                          (_) {
                            Navigator.pop(sheetContext);
                            final billItems = editableLines
                                .map(
                                  (line) => BillLineItem(
                                    name: line.name,
                                    quantity: line.quantity,
                                    price: line.unitPrice,
                                  ),
                                )
                                .toList();
                            final bill = BillPreviewArgs(
                              orderLabel: title,
                              items: billItems,
                              subtotal: subtotal(),
                              tax: 0,
                              serviceCharge: 0,
                              grandTotal: subtotal(),
                            );
                            Navigator.pushNamed(
                              context,
                              '/bill-preview',
                              arguments: bill,
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Checkout'),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}
