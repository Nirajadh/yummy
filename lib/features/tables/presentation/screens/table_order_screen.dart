import 'package:flutter/material.dart';
import 'package:yummy/features/orders/domain/entities/bill_preview.dart';
import 'package:yummy/features/orders/presentation/screens/order_screen.dart';
import 'package:yummy/features/tables/presentation/models/table_order_args.dart';

class TableOrderScreen extends StatefulWidget {
  const TableOrderScreen({super.key});

  @override
  State<TableOrderScreen> createState() => _TableOrderScreenState();
}

class _TableOrderScreenState extends State<TableOrderScreen> {
  static const _statusColorMap = <String, Color>{
    'FREE': Colors.green,
    'OCCUPIED': Colors.red,
    'BILL PRINTED': Colors.orange,
    'RESERVED': Colors.blue,
  };

  late TableOrderArgs _args;
  bool _loaded = false;
  late List<_TableLine> _activeLines;
  late List<String> _pastOrders;
  late String _status;
  late String _category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    _args = routeArgs is TableOrderArgs
        ? routeArgs
        : const TableOrderArgs(tableName: 'Table', status: 'FREE');
    _activeLines = _buildLinesFromStrings(_args.activeItems);
    _pastOrders = List.of(_args.pastOrders);
    _status = _args.status;
    _category = _args.category;
    _loaded = true;
  }

  Color _statusColor(String status) => _statusColorMap[status] ?? Colors.grey;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  List<_TableLine> _buildLinesFromStrings(List<String> items) {
    final map = <String, int>{};
    for (final item in items) {
      map[item] = (map[item] ?? 0) + 1;
    }
    return map.entries
        .map((e) => _TableLine(name: e.key, quantity: e.value))
        .toList();
  }

  void _changeQty(int index, int delta) {
    if (index < 0 || index >= _activeLines.length) return;
    setState(() {
      final line = _activeLines[index];
      final next = line.quantity + delta;
      if (next <= 0) {
        _activeLines.removeAt(index);
      } else {
        _activeLines[index] = line.copyWith(quantity: next);
      }
    });
  }

  void _openCartSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
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
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Table Cart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_activeLines.isNotEmpty)
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
                        '${_activeLines.length} item${_activeLines.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_activeLines.isEmpty)
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
                    itemCount: _activeLines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final line = _activeLines[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$12.00 each',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _changeQty(index, -1),
                                ),
                                Text('${line.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _changeQty(index, 1),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${(12.0 * line.quantity).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addItems() async {
    final result = await Navigator.pushNamed(
      context,
      '/order-screen',
      arguments: OrderScreenArgs(contextLabel: 'Table: ${_args.tableName}'),
    );
    final bool sentToKitchen = result is OrderScreenResult
        ? result.sentToKitchen
        : result == true;
    if (sentToKitchen && result is OrderScreenResult) {
      setState(() {
        _status = 'OCCUPIED';
        final newLines = result.items
            .map((item) => _TableLine(name: item.name, quantity: item.quantity))
            .toList();
        _activeLines.addAll(newLines);
      });
    }
  }

  BillPreviewArgs _buildBill() {
    final items = _activeLines
        .map(
          (line) => BillLineItem(
            name: line.name,
            quantity: line.quantity,
            price: 12.0,
          ),
        )
        .toList();
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    final total = subtotal;
    return BillPreviewArgs(
      orderLabel: 'Table • ${_args.tableName}',
      items: items,
      subtotal: subtotal,
      tax: 0,
      serviceCharge: 0,
      grandTotal: total,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _status.toUpperCase();
    final isFree = status == 'FREE';
    final isOccupied = status == 'OCCUPIED';
    final hasOrderedItems = _activeLines.isNotEmpty;
    final hasHistory = _pastOrders.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Table: ${_args.tableName}'),
        actions: [
          TextButton.icon(
            onPressed: () => _showMessage('Table marked free (UI only).'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark Free'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _args.tableName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(
                              _status,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _status,
                            style: TextStyle(
                              color: _statusColor(_status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Category: $_category'),
                    const SizedBox(height: 4),
                    Text('Capacity: ${_args.capacity} guests'),
                    if (_args.notes.isNotEmpty) Text('Notes: ${_args.notes}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addItems,
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Add Items'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openCartSheet,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Cart'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final bill = _buildBill();
                      Navigator.pushNamed(
                        context,
                        '/bill-preview',
                        arguments: bill,
                      );
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Checkout'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 24),
            if (isFree) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.deepOrange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Table is free. Tap "Add Items" to start a brand new order.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (status == 'RESERVED' && _args.reservationName != null) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reservation Details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Name: ${_args.reservationName}'),
                      if (_args.notes.isNotEmpty) Text('Notes: ${_args.notes}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (isOccupied && hasOrderedItems) ...[
              const Text(
                'Ordered Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final line = _activeLines[index];
                    return Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Qty: ${line.quantity}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${(12.0 * line.quantity).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: _activeLines.length,
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (hasHistory) ...[
              const Text(
                'Previous Orders',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _pastOrders.length,
                  itemBuilder: (context, index) => Row(
                    children: [
                      const Icon(Icons.history, size: 18, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_pastOrders[index])),
                    ],
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Recent Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: 3,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.note_alt_outlined),
                  title: Text('Note ${index + 1} for ${_args.tableName}'),
                  subtitle: const Text('Sample update for staff coordination.'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableLine {
  final String name;
  final int quantity;

  const _TableLine({required this.name, required this.quantity});

  _TableLine copyWith({String? name, int? quantity}) {
    return _TableLine(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
    );
  }
}
