import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';
import 'package:yummy/features/tables/presentation/bloc/tables/tables_bloc.dart';
import 'package:yummy/features/tables/presentation/models/table_order_args.dart';
import 'package:yummy/features/tables/presentation/screens/widgets/legend_dot.dart';

const _statusColorMap = <String, Color>{
  'FREE': Colors.green,
  'OCCUPIED': Colors.red,
  'BILL PRINTED': Colors.orange,
  'RESERVED': Colors.blue,
};

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
  String _selectedCategory = '';
  final List<String> _customCategories = [];

  void _openForm({TableEntity? table}) {
    final bloc = context.read<TablesBloc>();
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
          selectedCategory: _selectedCategory,
          onSave: (newTable) => bloc.add(TableSaved(newTable)),
          onDelete: table != null
              ? () => bloc.add(TableDeleted(table.name))
              : null,
        ),
      ),
    );
  }

  List<String> _allCategories(List<TableEntity> tables) {
    final set = <String>{..._customCategories};
    for (final table in tables) {
      set.add(table.category.isNotEmpty ? table.category : 'Unassigned');
    }
    final list = set.toList();
    list.sort();
    return list;
  }

  Color _statusColor(String status) => _statusColorMap[status] ?? Colors.grey;

  Future<void> _promptAddCategory() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Category / Hall / Floor name',
            hintText: 'e.g., Main Dining, Terrace, Outdoor',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      setState(() {
        if (!_customCategories.contains(name)) {
          _customCategories.add(name);
        }
        _selectedCategory = name;
      });
    }
  }

  void _goToDashboard(BuildContext context) {
    final target = widget.dashboardRoute.isNotEmpty
        ? widget.dashboardRoute
        : '/admin-dashboard';
    Navigator.pushNamedAndRemoveUntil(context, target, (route) => false);
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
      body: BlocBuilder<TablesBloc, TablesState>(
        builder: (context, state) {
          if (state.status == TablesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final tables = state.tables;
          if (tables.isEmpty) {
            return const Center(child: Text('No tables found.'));
          }
          final categories = _allCategories(tables);
          final filteredTables = _selectedCategory.isEmpty
              ? tables
              : tables.where((t) => t.category == _selectedCategory).toList();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Manage Tables',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Switch between halls/floors and add tables to the active category.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...categories.map((category) {
                        final selected = category == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: selected,
                            onSelected: (value) => setState(
                              () => _selectedCategory = value ? category : '',
                            ),
                          ),
                        );
                      }),
                      if (widget.allowManageTables)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: const Text('Add Category'),
                            avatar: const Icon(Icons.add),
                            onPressed: _promptAddCategory,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: const [
                    LegendDot(color: Colors.green, label: 'Available'),
                    LegendDot(color: Colors.red, label: 'Occupied'),
                    LegendDot(color: Colors.orange, label: 'Bill Printed'),
                    LegendDot(color: Colors.blue, label: 'Reserved'),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: filteredTables.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                    itemBuilder: (context, index) {
                      final table = filteredTables[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 1,
                        surfaceTintColor: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/table-order',
                            arguments: TableOrderArgs(
                              tableName: table.name,
                              status: table.status,
                              capacity: table.capacity,
                              category: table.category,
                              notes: table.notes,
                              activeItems: table.activeItems,
                              pastOrders: table.pastOrders,
                              reservationName: table.reservationName,
                            ),
                          ),
                          onLongPress: widget.allowManageTables
                              ? () => _openForm(table: table)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            table.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blueGrey.withValues(
                                                alpha: .08,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              table.category,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blueGrey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (widget.allowManageTables)
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () =>
                                            _openForm(table: table),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.group_outlined, size: 16),
                                    const SizedBox(width: 6),
                                    Text('Seats ${table.capacity}'),
                                  ],
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        table.status,
                                      ).withValues(alpha: .15),
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
              ],
            ),
          );
        },
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
  final TableEntity? table;
  final ValueChanged<TableEntity> onSave;
  final VoidCallback? onDelete;
  final String selectedCategory;

  const TableFormSheet({
    super.key,
    this.table,
    required this.onSave,
    this.onDelete,
    this.selectedCategory = '',
  });

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
    final category =
        widget.table?.category ??
        (widget.selectedCategory.isNotEmpty
            ? widget.selectedCategory
            : 'General');

    final existing = widget.table;
    widget.onSave(
      TableEntity(
        name: _nameController.text,
        capacity: capacity,
        status: existing?.status ?? 'FREE',
        category: category,
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
          Row(
            children: [
              const Icon(Icons.store_mall_directory_outlined, size: 18),
              const SizedBox(width: 6),
              Text(
                widget.table?.category ??
                    (widget.selectedCategory.isNotEmpty
                        ? widget.selectedCategory
                        : 'General'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Category is taken from the current filter.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
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
          FilledButton(onPressed: _handleSave, child: const Text('Save')),
          if (isEditing) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _handleDelete,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade50,
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
  }
}
