import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:yummy/features/groups/domain/entities/group_entity.dart';
import 'package:yummy/features/groups/presentation/bloc/groups/groups_bloc.dart';
import 'package:yummy/features/orders/presentation/screens/group_order_screen.dart';

class GroupsScreen extends StatefulWidget {
  final String dashboardRoute;

  const GroupsScreen({super.key, this.dashboardRoute = '/admin-dashboard'});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  void _openForm({GroupEntity? group}) {
    final bloc = context.read<GroupsBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: GroupFormSheet(
          group: group,
          onSave: (newGroup) => bloc.add(GroupSaved(newGroup)),
        ),
      ),
    );
  }

  void _toggleStatus(GroupEntity group) {
    context.read<GroupsBloc>().add(GroupStatusToggled(group.name));
  }

  Future<void> _openGroupOrder(GroupEntity group) async {
    final result = await Navigator.pushNamed(
      context,
      '/group-order',
      arguments: GroupOrderArgs(
        groupName: group.name,
        peopleCount: group.peopleCount,
        contactName: group.contactName,
        contactPhone: group.contactPhone,
        type: group.type,
        notes: group.notes,
        people: group.people,
        isActive: group.isActive,
      ),
    );

    if (!mounted) return;
    if (result is GroupEntity) {
      context.read<GroupsBloc>().add(GroupSaved(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        final groups = state.groups;
        final activeEntries = groups.where((g) => g.isActive).toList();
        final closedEntries = groups.where((g) => !g.isActive).toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Groups'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  final target = widget.dashboardRoute.isNotEmpty
                      ? widget.dashboardRoute
                      : '/admin-dashboard';
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    target,
                    (route) => false,
                  );
                },
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Active Groups'),
                  Tab(text: 'Closed Groups'),
                ],
              ),
            ),
            body: state.status == GroupsStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _GroupList(
                        entries: activeEntries,
                        onEdit: (group) => _openForm(group: group),
                        onToggleStatus: _toggleStatus,
                        enableNavigate: true,
                        onOpenGroup: (group) => _openGroupOrder(group),
                      ),
                      _GroupList(
                        entries: closedEntries,
                        onEdit: (group) => _openForm(group: group),
                        onToggleStatus: _toggleStatus,
                        enableNavigate: false,
                      ),
                    ],
                  ),
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'groups-fab',
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Group'),
            ),
          ),
        );
      },
    );
  }
}

class _GroupList extends StatelessWidget {
  final List<GroupEntity> entries;
  final ValueChanged<GroupEntity> onEdit;
  final ValueChanged<GroupEntity> onToggleStatus;
  final bool enableNavigate;
  // Called when a group tile is tapped to open orders.
  final Future<void> Function(GroupEntity group)? onOpenGroup;

  const _GroupList({
    required this.entries,
    required this.onEdit,
    required this.onToggleStatus,
    required this.enableNavigate,
    this.onOpenGroup,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('No groups'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final group = entries[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enableNavigate
                ? () => onOpenGroup?.call(group)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (group.isActive ? Colors.green : Colors.orange)
                              .withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          group.isActive ? 'Active' : 'Closed',
                          style: TextStyle(
                            color: group.isActive
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('People: ${group.people.length}/${group.peopleCount}'),
                  if (group.people.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ...group.people.map(
                          (person) => Chip(
                            label: Text(person.name),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (group.people.isEmpty)
                    const Text(
                      'No people added yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  Text('Contact: ${group.contactName} (${group.contactPhone})'),
                  Text('Type: ${group.type}'),
                  if (group.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Notes: ${group.notes}'),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => onToggleStatus(group),
                        icon: Icon(
                          group.isActive ? Icons.close : Icons.refresh,
                        ),
                        label: Text(group.isActive ? 'Close' : 'Reopen'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => onEdit(group),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class GroupFormSheet extends StatefulWidget {
  final GroupEntity? group;
  final ValueChanged<GroupEntity> onSave;

  const GroupFormSheet({super.key, this.group, required this.onSave});

  @override
  State<GroupFormSheet> createState() => _GroupFormSheetState();
}

class _GroupFormSheetState extends State<GroupFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _countController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _contactPhoneController;
  late final TextEditingController _typeController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final group = widget.group;
    _nameController = TextEditingController(text: group?.name ?? '');
    _countController = TextEditingController(
      text: group != null ? group.peopleCount.toString() : '',
    );
    _contactNameController = TextEditingController(
      text: group?.contactName ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: group?.contactPhone ?? '',
    );
    _typeController = TextEditingController(text: group?.type ?? '');
    _notesController = TextEditingController(text: group?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _typeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.group != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Text(
              isEditing ? 'Edit Group' : 'Add Group',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _countController,
              decoration: const InputDecoration(labelText: 'People Count'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const Text(
              'Add people inside the group order view.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactNameController,
              decoration: const InputDecoration(labelText: 'Contact Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactPhoneController,
              decoration: const InputDecoration(labelText: 'Contact Phone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _handleSave,
              child: Text(isEditing ? 'Save Changes' : 'Add Group'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    final peopleCount = int.tryParse(_countController.text) ?? 0;
    if (_nameController.text.trim().isEmpty || peopleCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and a valid people count are required.'),
        ),
      );
      return;
    }

    widget.onSave(
      GroupEntity(
        name: _nameController.text.trim(),
        peopleCount: peopleCount,
        contactName: _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        type:
            _typeController.text.trim().isEmpty ? 'General' : _typeController.text.trim(),
        notes: _notesController.text.trim(),
        isActive: widget.group?.isActive ?? true,
        people: widget.group?.people ?? const [],
      ),
    );
    Navigator.pop(context);
  }
}
