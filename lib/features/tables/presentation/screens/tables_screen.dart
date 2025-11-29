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
          selectedCategory: context.read<TablesBloc>().state.selectedCategory,
          onSave: (newTable) => bloc.add(TableSaved(newTable)),
          onDelete: table != null
              ? () => bloc.add(
                TableDeleted(
                  table.name,
                  tableId: table.id,
                ),
              )
              : null,
        ),
      ),
    );
  }

  List<String> _allCategories(TablesState state, List<TableEntity> tables) {
    final set = <String>{
      ...(state.tableTypes ?? const []).map((t) => t.name),
    };
    for (final table in tables) {
      if (table.category.isNotEmpty) {
        set.add(table.category);
      }
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
      context.read<TablesBloc>().add(TableCategoryAdded(name));
      context.read<TablesBloc>().add(TableCategorySelected(name));
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
      body: BlocConsumer<TablesBloc, TablesState>(
        listener: (context, state) {
          final message = state.lastMessage;
          if (message != null && message.isNotEmpty && mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (context, state) {
          if (state.status == TablesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final tables = state.tables;
          final categories = _allCategories(state, tables);
          final selectedCategory =
              state.filterCategory.isNotEmpty && categories.isNotEmpty
                  ? state.filterCategory
                  : (categories.isNotEmpty ? categories.first : '');
          final filteredTables = selectedCategory.isEmpty
              ? tables
              : tables.where((t) => t.category == selectedCategory).toList();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Tables',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Switch halls/floors and add tables to the active category.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...categories.map((category) {
                        final selected = category == selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: selected,
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            labelStyle: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: selected
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer
                                      : null,
                                  fontWeight: FontWeight.w600,
                                ),
                            onSelected: (_) => context
                                .read<TablesBloc>()
                                .add(TableCategoryFilterChanged(category)),
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
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            labelStyle: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const LegendDot(color: Colors.green, label: 'Available'),
                    LegendDot(color: Colors.red.shade400, label: 'Occupied'),
                    LegendDot(
                      color: Theme.of(context).colorScheme.secondary,
                      label: 'Bill Printed',
                    ),
                    LegendDot(
                      color: Theme.of(context).colorScheme.primary,
                      label: 'Reserved',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredTables.isEmpty
                      ? const Center(child: Text('No tables found.'))
                      : GridView.builder(
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
                              color: Theme.of(context).cardColor,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/table-order',
                            arguments: TableOrderArgs(
                              tableId: table.id,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: .08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    table.category,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (widget.allowManageTables)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _openForm(table: table),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.group_outlined,
                                            size: 16,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withValues(alpha: 0.7),
                                          ),
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
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
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
        id: existing?.id,
        name: _nameController.text,
        capacity: capacity,
        status: existing?.status ?? 'FREE',
        category: category,
        tableTypeId: existing?.tableTypeId ?? 0,
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
