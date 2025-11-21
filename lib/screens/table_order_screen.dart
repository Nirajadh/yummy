import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/table_order_args.dart';
import 'order_screen.dart';
import '../models/bill_preview.dart';

class TableOrderScreen extends StatefulWidget {
  const TableOrderScreen({super.key});

  @override
  State<TableOrderScreen> createState() => _TableOrderScreenState();
}

class _TableOrderScreenState extends State<TableOrderScreen> {
  late TableOrderArgs _args;
  bool _loaded = false;
  late List<String> _activeItems;
  late List<String> _pastOrders;
  late String _status;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    _args = routeArgs is TableOrderArgs
        ? routeArgs
        : const TableOrderArgs(tableName: 'Table', status: 'FREE');
    _activeItems = List.of(_args.activeItems);
    _pastOrders = List.of(_args.pastOrders);
    _status = _args.status;
    _loaded = true;
  }

  Color _statusColor(String status) => statusColors[status] ?? Colors.grey;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _addItems() async {
    final sentToKitchen = await Navigator.pushNamed(
      context,
      '/order-screen',
      arguments: OrderScreenArgs(contextLabel: 'Table: ${_args.tableName}'),
    );
    if (sentToKitchen == true) {
      setState(() {
        _status = 'OCCUPIED';
        _activeItems.add(
          'New items added (${TimeOfDay.now().format(context)})',
        );
      });
    }
  }

  BillPreviewArgs _buildBill() {
    final items = _activeItems
        .map((name) => BillLineItem(name: name, quantity: 1, price: 12.0))
        .toList();
    final subtotal =
        items.fold<double>(0, (sum, item) => sum + item.lineTotal);
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
    final hasOrderedItems = _activeItems.isNotEmpty;
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
              ).colorScheme.primary.withOpacity(0.12),
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
                            color: _statusColor(_status).withOpacity(.15),
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showMessage('Table marked free (UI only).'),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Free'),
                  ),
                ),
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
                  itemBuilder: (context, index) => Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_activeItems[index])),
                    ],
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: _activeItems.length,
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
