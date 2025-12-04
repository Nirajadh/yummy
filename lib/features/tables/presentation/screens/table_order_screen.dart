import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/presentation/screens/order_screen.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';
import 'package:yummy/features/tables/presentation/bloc/tables/tables_bloc.dart';
import 'package:yummy/features/tables/presentation/bloc/table_order/table_order_bloc.dart';
import 'package:yummy/features/tables/presentation/navigation/table_order_args.dart';

class TableOrderScreen extends StatefulWidget {
  final TableOrderArgs? args;

  const TableOrderScreen({super.key, this.args});

  @override
  State<TableOrderScreen> createState() => _TableOrderScreenState();
}

class _OrderLine {
  final int? menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;

  const _OrderLine({
    this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  _OrderLine copyWith({int? quantity, double? unitPrice}) {
    return _OrderLine(
      menuItemId: menuItemId,
      name: name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  double get lineTotal => unitPrice * quantity;
}

class _TableOrderScreenState extends State<TableOrderScreen> {
  static const _statusColorMap = <String, Color>{
    'FREE': Colors.green,
    'OCCUPIED': Colors.red,
    'BILL PRINTED': Colors.orange,
    'RESERVED': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    final args = widget.args;
    context.read<TableOrderBloc>().add(
      TableOrderStarted(
        table: args?.table,
        tableId: args?.tableId,
        tableName: args?.tableName,
      ),
    );
  }

  List<_OrderLine> _mapActiveItems(List<String> rawItems) {
    return rawItems.map((item) {
      final quantity = _extractQuantity(item);
      final name = _cleanItemName(item);
      return _OrderLine(name: name, quantity: quantity, unitPrice: 0);
    }).toList();
  }

  int _extractQuantity(String raw) {
    final match = RegExp(r'x(\d+)\s*$').firstMatch(raw);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 1;
    }
    return 1;
  }

  String _cleanItemName(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'x\d+\s*$'), '').trim();
    return cleaned.isNotEmpty ? cleaned : 'Item';
  }

  Color _statusColor(String status) => _statusColorMap[status] ?? Colors.grey;

  TableEntity? _currentTable(
    TableOrderState orderState,
    TablesState tablesState,
  ) {
    if (orderState.table != null) return orderState.table;
    final id = orderState.tableId;
    if (id == null) return null;
    for (final table in tablesState.tables) {
      if (table.id == id) return table;
    }
    return null;
  }

  void _handleTablesUpdate(TablesState state) {
    final orderState = context.read<TableOrderBloc>().state;
    final id = orderState.tableId;
    if (id == null) return;
    final updated = _findTableById(state, id);
    if (updated != null) {
      context.read<TableOrderBloc>().add(TableOrderTableUpdated(updated));
    }
  }

  TableEntity? _findTableById(TablesState state, int tableId) {
    for (final table in state.tables) {
      if (table.id == tableId) return table;
    }
    return null;
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _updateStatus(String status, TableEntity? table) {
    if (table == null) return;
    final updated = table.copyWith(status: status);
    context.read<TablesBloc>().add(TableSaved(updated));
    context.read<TableOrderBloc>().add(
      TableOrderStatusChanged(status, message: 'Status updated'),
    );
  }

  Future<void> _startOrAppendOrder(
    TableEntity? table, {
    ActiveOrderEntity? activeOrder,
  }) async {
    final orderBlocState = context.read<TableOrderBloc>().state;
    final tableId =
        orderBlocState.tableId ?? table?.id ?? widget.args?.tableId;
    final tableLabel = table?.name ?? orderBlocState.tableName ?? 'Table';
    final isAppending = activeOrder != null;

    final result = await Navigator.pushNamed(
      context,
      '/order-screen',
      arguments: OrderScreenArgs(
        contextLabel: isAppending
            ? 'Order ${activeOrder?.reference ?? ''}'
            : 'Table: $tableLabel',
        channel: OrderChannel.table,
        tableId: tableId,
        appendToExisting: isAppending,
        existingOrderId: activeOrder?.id,
        existingOrderReference: activeOrder?.reference,
        existingOrderItems: activeOrder?.items ?? const [],
      ),
    );

    if (!mounted) return;

    final orderResult = result is OrderScreenResult ? result : null;
    if (orderResult == null) {
      _showMessage('No items added.');
      return;
    }
    if (!orderResult.sentToKitchen) {
      _showMessage('Send to kitchen to add these items.');
      return;
    }

    _updateStatus('OCCUPIED', table);
    // Refresh active orders to reflect the updated order.
    final current = context.read<TableOrderBloc>().state;
    context.read<TableOrderBloc>().add(
          TableOrderStarted(
            table: table ?? current.table,
            tableId: current.tableId ?? tableId,
            tableName: current.tableName ?? tableLabel,
          ),
        );
    _showMessage(
      isAppending ? 'Items added to order.' : 'Order placed.',
    );
  }

  void _showOrderItems(ActiveOrderEntity order) {
    final theme = Theme.of(context);
    final items = order.items;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.type} • ${order.reference}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Status: ${order.status}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${order.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No items found for this order.'),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Qty: ${item.qty} • \$${item.unitPrice.toStringAsFixed(2)} each',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  if ((item.notes ?? '').isNotEmpty)
                                    Text(
                                      item.notes!,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${item.lineTotal.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _markFree(TableEntity? table) {
    if (table != null) {
      final cleared = table.copyWith(status: 'FREE', activeItems: const []);
      context.read<TablesBloc>().add(TableSaved(cleared));
      context.read<TableOrderBloc>().add(TableOrderTableUpdated(cleared));
      context.read<TableOrderBloc>().add(
        const TableOrderStatusChanged('FREE', message: 'Status updated'),
      );
    } else {
      _updateStatus('FREE', table);
    }
    _showMessage('Table marked free.');
  }

  @override
  Widget build(BuildContext context) {
    final tablesState = context.watch<TablesBloc>().state;
    final orderState = context.watch<TableOrderBloc>().state;
    final table = _currentTable(orderState, tablesState) ?? widget.args?.table;
    final tableName = table?.name ?? orderState.tableName ?? 'Table';
    final orders = orderState.activeOrders;
    // Only one active order is expected per table; use the first if present.
    final ActiveOrderEntity? activeOrder =
        orders.isNotEmpty ? orders.first : null;
    final hasActiveOrder = activeOrder != null;
    final pastOrders = table?.pastOrders ?? const [];
    final status = (table?.status ?? 'FREE').toUpperCase();
    final isFree = status == 'FREE';
    final hasHistory = pastOrders.isNotEmpty;
    final isLoading = orderState.status == TableOrderStatus.loading;
    final loadError = orderState.status == TableOrderStatus.failure
        ? orderState.errorMessage
        : null;
    final ctaLabel =
        hasActiveOrder ? 'Add Items to ${activeOrder!.reference}' : 'Create Order';

    return BlocListener<TablesBloc, TablesState>(
      listener: (context, state) => _handleTablesUpdate(state),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Table: $tableName'),
          bottom: null,
          actions: [
            TextButton.icon(
              onPressed: () => _markFree(table),
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
        body: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LinearProgressIndicator(),
              ),
            if (loadError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  loadError,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
                          tableName,
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
                            color: _statusColor(status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Category: ${table?.category ?? 'General'}'),
                    const SizedBox(height: 4),
                    Text('Capacity: ${table?.capacity ?? 0} guests'),
                    if ((table?.notes ?? '').isNotEmpty)
                      Text('Notes: ${table?.notes ?? ''}'),
                    if ((table?.reservationName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Reservation: ${table?.reservationName ?? ''}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _startOrAppendOrder(table, activeOrder: activeOrder),
                  icon: const Icon(Icons.playlist_add),
                  label: Text(ctaLabel),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (isFree) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.deepOrange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Table is free. Tap "Create Order" to start a brand new order.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (status == 'RESERVED' && (table?.notes ?? '').isNotEmpty) ...[
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
                      Text('Notes: ${table?.notes ?? ''}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Ordered Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (orders.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No orders for this table yet.'),
                ),
              )
            else
              Column(
                children: orders
                    .map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showOrderItems(order),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              order.reference,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              'Status: ${order.status}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '\$${order.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Items: ${order.itemsCount} • Guests: ${order.guests}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 24),
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
                  itemCount: pastOrders.length,
                  itemBuilder: (context, index) => Row(
                    children: [
                      const Icon(Icons.history, size: 18, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Expanded(child: Text(pastOrders[index])),
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: Text('Note ${index + 1} for $tableName'),
                subtitle: const Text('Sample update for staff coordination.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
