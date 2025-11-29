import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/orders/domain/entities/bill_preview.dart';
import 'package:yummy/features/orders/presentation/screens/order_screen.dart';
import 'package:yummy/features/tables/presentation/bloc/table_order/table_order_bloc.dart';
import 'package:yummy/features/tables/presentation/models/table_order_args.dart';
import 'package:yummy/features/tables/presentation/screens/widgets/cart_summary.dart';

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
    _pastOrders = List.of(_args.pastOrders);
    _status = _args.status;
    _category = _args.category;
    context.read<TableOrderBloc>().add(TableOrderInitialized(_args.activeItems));
    _loaded = true;
  }

  Color _statusColor(String status) => _statusColorMap[status] ?? Colors.grey;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openCartSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = theme.cardColor;
    final textColor =
        theme.textTheme.bodyLarge?.color ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);
    final subtle = textColor.withValues(alpha: 0.65);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return BlocProvider.value(
          value: context.read<TableOrderBloc>(),
          child: BlocBuilder<TableOrderBloc, TableOrderState>(
            builder: (context, state) {
            final subtotal = state.subtotal;
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
                        'Confirmation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.add, color: colorScheme.primary),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _addItems();
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Orders #${_args.tableName}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: subtle),
                  ),
                  const SizedBox(height: 12),
                  if (state.lines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'No items added yet.',
                          style: TextStyle(fontSize: 16, color: subtle),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.lines.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final line = state.lines[index];
                          final note = state.notes[line.name] ?? '';
                          return Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: colorScheme.primary
                                          .withValues(alpha: 0.12),
                                      child: Icon(
                                        Icons.restaurant_menu,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            '\$12.00',
                                            style: TextStyle(
                                              color: subtle,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface
                                            .withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove,
                                              color: subtle,
                                              size: 18,
                                            ),
                                            onPressed: () => context
                                                .read<TableOrderBloc>()
                                                .add(
                                                  TableOrderDecremented(
                                                    line.name,
                                                  ),
                                                ),
                                          ),
                                          Text(
                                            '${line.quantity}',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  color: textColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.add,
                                              color: subtle,
                                              size: 18,
                                            ),
                                            onPressed: () => context
                                                .read<TableOrderBloc>()
                                                .add(
                                                  TableOrderIncremented(
                                                    line.name,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${(12.0 * line.quantity).toStringAsFixed(2)}',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: textColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: colorScheme.primary,
                                          ),
                                          onPressed: () => context
                                              .read<TableOrderBloc>()
                                              .add(
                                                TableOrderItemRemoved(
                                                  line.name,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: TextEditingController(text: note),
                                  style: TextStyle(color: textColor),
                                  decoration: InputDecoration(
                                    hintText: 'Order note...',
                                    hintStyle: TextStyle(color: subtle),
                                    filled: true,
                                    fillColor: theme
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.4),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (value) => context
                                      .read<TableOrderBloc>()
                                      .add(
                                        TableOrderNoteChanged(
                                          line.name,
                                          value,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  CartSummary(subtotal: subtotal, discount: 0),
                ],
              ),
            );
            },
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
      });
      for (final item in result.items) {
        context.read<TableOrderBloc>().add(
              TableOrderItemAdded(item.name, item.quantity),
            );
      }
    }
  }

  BillPreviewArgs _buildBill() {
    final items = context.read<TableOrderBloc>().state.lines
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
    final hasOrderedItems =
        context.read<TableOrderBloc>().state.lines.isNotEmpty;
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
                child: BlocBuilder<TableOrderBloc, TableOrderState>(
                  builder: (context, state) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final line = state.lines[index];
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
                      itemCount: state.lines.length,
                    );
                  },
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
