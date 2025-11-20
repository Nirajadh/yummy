import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/table_order_args.dart';

class TablesScreen extends StatefulWidget {
  final bool allowManageTables;
  final String dashboardRoute;

  const TablesScreen({
    super.key,
    this.allowManageTables = true,
    this.dashboardRoute = '/admin-dashboard',
  });

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  late List<TableInfo> _tables;

  @override
  void initState() {
    super.initState();
    _tables = List.of(dummyTables);
  }

  void _openForm({TableInfo? table, int? index}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TableFormSheet(
          table: table,
          onSave: (newTable) {
            setState(() {
              if (index != null) {
                _tables[index] = newTable;
              } else {
                _tables.add(newTable);
              }
            });
          },
          onDelete: index != null
              ? () {
                  setState(() {
                    _tables.removeAt(index);
                  });
                }
              : null,
        ),
      ),
    );
  }

  Color _statusColor(String status) => statusColors[status] ?? Colors.grey;

  void _goToDashboard(BuildContext context) {
    final target =
        widget.dashboardRoute.isNotEmpty ? widget.dashboardRoute : '/admin-dashboard';
    Navigator.pushNamedAndRemoveUntil(
      context,
      target,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goToDashboard(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _tables.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final table = _tables[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/table-order',
                  arguments: TableOrderArgs(
                    tableName: table.name,
                    status: table.status,
                    capacity: table.capacity,
                    notes: table.notes,
                    activeItems: table.activeItems,
                    pastOrders: table.pastOrders,
                    reservationName: table.reservationName,
                  ),
                ),
                onLongPress: widget.allowManageTables ? () => _openForm(table: table, index: index) : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            table.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (widget.allowManageTables)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _openForm(table: table, index: index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Capacity: ${table.capacity}'),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(table.status).withOpacity(.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            table.status,
                            style: TextStyle(
                              color: _statusColor(table.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: widget.allowManageTables
          ? FloatingActionButton.extended(
              heroTag: 'tables-fab',
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Table'),
            )
          : null,
    );
  }
}

class TableFormSheet extends StatefulWidget {
  final TableInfo? table;
  final ValueChanged<TableInfo> onSave;
  final VoidCallback? onDelete;

  const TableFormSheet({super.key, this.table, required this.onSave, this.onDelete});

  @override
  State<TableFormSheet> createState() => _TableFormSheetState();
}

class _TableFormSheetState extends State<TableFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _capacityController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.table?.name ?? '');
    _capacityController = TextEditingController(
      text: widget.table != null ? widget.table!.capacity.toString() : '',
    );
    _notesController = TextEditingController(text: widget.table?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final capacity = int.tryParse(_capacityController.text) ?? 0;
    if (_nameController.text.isEmpty || capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and capacity are required.')),
      );
      return;
    }

    final existing = widget.table;
    widget.onSave(
      TableInfo(
        name: _nameController.text,
        capacity: capacity,
        status: existing?.status ?? 'FREE',
        notes: _notesController.text,
        activeItems: existing?.activeItems ?? const [],
        pastOrders: existing?.pastOrders ?? const [],
        reservationName: existing?.reservationName,
      ),
    );
    Navigator.pop(context);
  }

  void _handleDelete() {
    widget.onDelete?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.table != null;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Edit Table' : 'Add Table',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Table Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Capacity'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _handleSave,
            child: const Text('Save'),
          ),
          if (isEditing) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _handleDelete,
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade50),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
  }
}
