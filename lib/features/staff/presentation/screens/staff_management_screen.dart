import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/app_apis.dart';
import 'package:yummy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yummy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yummy/features/auth/domain/entities/user_entity.dart';
import 'package:yummy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yummy/features/common/data/dummy_data.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  late List<StaffMember> _staffMembers;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _staffMembers = [];
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final totalHeadcount = _staffMembers.length;
    final activeStaff = _staffMembers
        .where((member) => member.status == 'Active')
        .length;
    final monthlyPayroll = _staffMembers.fold<double>(
      0,
      (total, member) => total + member.salary,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            tooltip: 'Export',
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _showSnack(context, 'Exported staff report'),
          ),
          IconButton(
            tooltip: 'Add Staff',
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => _openStaffForm(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Card(
              color: Colors.orange.withValues(alpha: .12),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: Text(_error!),
                subtitle: const Text(
                  'Showing any locally added staff for now.',
                ),
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Headcount',
                  value: '$totalHeadcount',
                  subtitle:
                      '$activeStaff active • ${totalHeadcount - activeStaff} inactive',
                  color: Colors.indigo,
                  icon: Icons.groups_2_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Monthly Payroll',
                  value: _currency(monthlyPayroll),
                  subtitle: 'Next cycle: 25th',
                  color: Colors.deepOrange,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Staff Details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ..._staffMembers.asMap().entries.map(
            (entry) => _StaffTile(
              member: entry.value,
              onEdit: () => _openStaffForm(
                context,
                member: entry.value,
                index: entry.key,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Records',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dummyStaffRecords.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final record = dummyStaffRecords[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withValues(alpha: .12),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.teal,
                    ),
                  ),
                  title: Text('${record.type} • ${record.staffName}'),
                  subtitle: Text('${record.date}\n${record.note}'),
                  isThreeLine: true,
                  trailing: Text(
                    _currency(record.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showSnack(context, 'Opened staff records'),
            icon: const Icon(Icons.folder_shared_outlined),
            label: const Text('View All Records'),
          ),
        ],
      ),
    );
  }

  void _openStaffForm(BuildContext context, {StaffMember? member, int? index}) {
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
        child: StaffFormSheet(
          member: member,
          onSave: (newMember) {
            setState(() {
              if (index != null) {
                _staffMembers[index] = newMember;
              } else {
                _staffMembers.add(newMember);
              }
            });
          },
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(appApis: AppApis()),
      );
      final result = await repo.getAllUsers();
      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _staffMembers = List.of(dummyStaffMembers);
          });
        },
        (users) {
          setState(() {
            _staffMembers = _mapUsersToStaff(users);
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _staffMembers = List.of(dummyStaffMembers);
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<StaffMember> _mapUsersToStaff(List<UserEntity> users) {
    return users.map((u) {
      return StaffMember(
        name: u.name,
        role: u.role,
        salary: 0,
        phone: '',
        email: u.email,
        joinedDate: '—',
        status: 'Active',
        shift: 'Not set',
        loginId: '',
        tempPin: '',
      );
    }).toList();
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  final StaffMember member;
  final VoidCallback onEdit;

  const _StaffTile({required this.member, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        member.role,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEdit,
                    ),
                    _StatusChip(status: member.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.payments_outlined, size: 18),
                  label: Text(_currency(member.salary)),
                ),
                Chip(
                  avatar: const Icon(Icons.schedule_outlined, size: 18),
                  label: Text('Shift: ${member.shift}'),
                ),
                Chip(
                  avatar: const Icon(Icons.event_available_outlined, size: 18),
                  label: Text('Joined ${member.joinedDate}'),
                ),
                Chip(
                  avatar: const Icon(Icons.badge_outlined, size: 18),
                  label: Text('Login: ${member.loginId}'),
                ),
                Chip(
                  avatar: const Icon(Icons.key_outlined, size: 18),
                  label: Text('Temp PIN: ${member.tempPin}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(member.phone)),
                IconButton(
                  tooltip: 'View records',
                  icon: const Icon(Icons.receipt_long_outlined),
                  onPressed: () =>
                      _showSnack(context, 'Records for ${member.name}'),
                ),
                FilledButton(
                  onPressed: () =>
                      _showSnack(context, 'Salary recorded for ${member.name}'),
                  child: const Text('Record Salary'),
                ),
              ],
            ),
            if (member.notes != null && member.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(member.notes!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Active':
        color = Colors.green;
        break;
      case 'On Leave':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class StaffFormSheet extends StatefulWidget {
  final StaffMember? member;
  final ValueChanged<StaffMember> onSave;

  const StaffFormSheet({super.key, this.member, required this.onSave});

  @override
  State<StaffFormSheet> createState() => _StaffFormSheetState();
}

class _StaffFormSheetState extends State<StaffFormSheet> {
  static const _statuses = ['Active', 'On Leave', 'Inactive'];
  static const _roles = ['staff', 'kitchen'];

  late final TextEditingController _nameController;
  late final TextEditingController _salaryController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _joinedController;
  late final TextEditingController _shiftController;
  late final TextEditingController _notesController;
  late final TextEditingController _loginController;
  late final TextEditingController _pinController;
  late String _role;
  late String _status;
  bool _submitting = false;
  StaffMember? _pendingStaff;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _nameController = TextEditingController(text: member?.name ?? '');
    _salaryController = TextEditingController(
      text: member != null ? member.salary.toStringAsFixed(0) : '',
    );
    _phoneController = TextEditingController(text: member?.phone ?? '');
    _emailController = TextEditingController(text: member?.email ?? '');
    _joinedController = TextEditingController(text: member?.joinedDate ?? '');
    _shiftController = TextEditingController(text: member?.shift ?? '');
    _notesController = TextEditingController(text: member?.notes ?? '');
    _loginController = TextEditingController(text: member?.loginId ?? '');
    _pinController = TextEditingController(text: member?.tempPin ?? '');
    final existingRole = member?.role.toLowerCase();
    _role = existingRole != null && _roles.contains(existingRole)
        ? existingRole
        : _roles.first;
    _status = member?.status ?? _statuses.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _joinedController.dispose();
    _shiftController.dispose();
    _notesController.dispose();
    _loginController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.member != null;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, __) => _submitting,
      listener: (context, state) {
        if (!_submitting) return;

        if (state is AuthRegisterSuccess) {
          if (_pendingStaff != null) {
            widget.onSave(_pendingStaff!);
          }
          setState(() {
            _submitting = false;
            _pendingStaff = null;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.registerEntity.message)));
          Navigator.pop(context);
        } else if (state is AuthFailure) {
          setState(() {
            _submitting = false;
            _pendingStaff = null;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Padding(
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
                isEditing ? 'Edit Staff' : 'Add Staff',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: _roles
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _role = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salary (per month)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _statuses
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _shiftController,
                decoration: const InputDecoration(labelText: 'Shift'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(
                  labelText: 'Login ID / Username',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pinController,
                decoration: const InputDecoration(
                  labelText: 'Temporary PIN / Password',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _joinedController,
                decoration: const InputDecoration(
                  labelText: 'Joined (e.g. Jan 2022)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : _handleSave,
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Save Changes' : 'Add Staff'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    final salary = double.tryParse(_salaryController.text) ?? 0;
    final name = _nameController.text.trim();
    final role = _roles.contains(_role) ? _role : _roles.first;
    final email = _emailController.text.trim();
    final password = _pinController.text.trim().isEmpty
        ? '0000'
        : _pinController.text.trim();

    if (name.isEmpty || role.isEmpty || email.isEmpty || salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Name, role, email, password, and a valid salary are required.',
          ),
        ),
      );
      return;
    }

    final newMember = StaffMember(
      name: name,
      role: role,
      salary: salary,
      phone: _phoneController.text.trim(),
      email: email,
      joinedDate: _joinedController.text.trim().isEmpty
          ? 'Today'
          : _joinedController.text.trim(),
      status: _status,
      shift: _shiftController.text.trim().isEmpty
          ? 'Not set'
          : _shiftController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      loginId: _loginController.text.trim().isEmpty
          ? 'user${DateTime.now().millisecondsSinceEpoch}'
          : _loginController.text.trim(),
      tempPin: password,
    );

    if (widget.member != null) {
      widget.onSave(newMember);
      Navigator.pop(context);
      return;
    }

    setState(() {
      _pendingStaff = newMember;
      _submitting = true;
    });

    context.read<AuthBloc>().add(
      RegisterRequested(
        name: newMember.name,
        email: newMember.email,
        password: newMember.tempPin,
        confirmPassword: newMember.tempPin,
        role: newMember.role,
      ),
    );
  }
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';
