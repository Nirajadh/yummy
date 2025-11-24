import 'package:flutter/material.dart';
import 'package:yummy/features/common/data/dummy_data.dart' as dummy;
import 'package:yummy/features/groups/domain/entities/group_entity.dart';
import 'package:yummy/features/groups/domain/entities/group_person_entity.dart';
import 'package:yummy/features/orders/domain/entities/bill_preview.dart';
import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';
import 'group_order/cart_sheet.dart';
import 'group_order/models.dart';
import 'group_order/order_group_sheet.dart';
import 'order_screen.dart';

// Backward compatibility for hot-reload/lookups referencing old private classes.

class GroupOrderArgs {
  final String groupName;
  final int peopleCount;
  final String contactName;
  final String contactPhone;
  final String type;
  final String notes;
  final List<GroupPersonEntity> people;
  final bool isActive;

  const GroupOrderArgs({
    required this.groupName,
    required this.peopleCount,
    required this.contactName,
    required this.contactPhone,
    this.type = '',
    this.notes = '',
    this.people = const [],
    this.isActive = true,
  });
}

class GroupOrderScreen extends StatefulWidget {
  const GroupOrderScreen({super.key});

  @override
  State<GroupOrderScreen> createState() => _GroupOrderScreenState();
}

class _GroupOrderScreenState extends State<GroupOrderScreen> {
  late GroupOrderArgs _args;
  late List<OrderHistoryEntryEntity> _history;
  List<GroupPaymentEntry> _payments = [];
  late List<GroupOrderLine> _orderLines;
  double _total = 0;
  double _paid = 0;
  bool _loaded = false;
  late List<GroupPersonEntity> _people;
  late int _maxPeople;
  late bool _isActive;
  Map<String, double> _personTotals = {};
  List<String> get _paymentTargets => [
    'All',
    ...{..._peopleNames, ..._personTotals.keys},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    _args = routeArgs is GroupOrderArgs
        ? routeArgs
        : const GroupOrderArgs(
            groupName: 'Group',
            peopleCount: 5,
            contactName: '',
            contactPhone: '',
          );
    _people = List.of(_args.people);
    _maxPeople = _args.peopleCount;
    _isActive = _args.isActive;
    _history = (dummy.groupOrderHistory[_args.groupName] ??
            const <dummy.OrderHistoryEntry>[])
        .map(
          (entry) => OrderHistoryEntryEntity(
            id: entry.id,
            type: entry.type,
            amount: entry.amount,
            status: entry.status,
            timestamp: entry.timestamp,
          ),
        )
        .toList();
    _orderLines = _history
        .map(
          (entry) => GroupOrderLine(
            id: entry.id,
            label: entry.id,
            items: const ['Legacy order'],
            amount: entry.amount,
            target: null,
            isHistoric: true,
          ),
        )
        .toList();
    _recalcTotals();
    _loaded = true;
  }

  double get _due => (_total - _paid).clamp(0, _total);
  List<String> get _peopleNames =>
      _people.map((person) => person.name).toList();
  bool get _canAddMorePeople => _people.length < _maxPeople;
  bool _isDuplicatePerson(String name) =>
      _people.any((p) => p.name.toLowerCase() == name.toLowerCase());
  double _personDue(String person) =>
      (_personTotals[person] ?? 0) - _paidForTarget(person);
  double _paidForTarget(String target) => _payments
      .where((p) => p.target == target)
      .fold<double>(0, (sum, p) => sum + p.amount);
  double _targetDue(String? target) {
    if (target == null || target == 'All') return _due;
    if (!_personTotals.containsKey(target)) return _due;
    return _personDue(target).clamp(0, _total);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _recalcTotals() {
    _personTotals = {};
    for (final line in _orderLines) {
      if (line.target != null && line.target != 'All') {
        _personTotals[line.target!] =
            (_personTotals[line.target!] ?? 0) + line.amount;
      }
    }
    _total = _orderLines.fold<double>(0, (sum, line) => sum + line.amount);
    _paid = _payments.fold<double>(0, (sum, payment) => sum + payment.amount);
    if (_paid > _total) {
      _paid = _total;
    }
  }

  void _openCartSheet() {
    showGroupCartSheet(
      context: context,
      orderLines: _orderLines,
      total: _total,
      due: _due,
      onTapTarget: _openOrdersForTarget,
    );
  }

  void _openOrdersForTarget(String? target) {
    final filtered = _orderLines.where((line) {
      if (target == null) {
        return line.target == null;
      }
      return line.target == target;
    }).toList();
    final label = target ?? 'All';
    showOrderGroupSheet(
      context: context,
      title: 'Orders for $label',
      lines: filtered,
      onRecordPayment: () {
        Navigator.pop(context);
        _openPaymentSheet(fixedTarget: target ?? 'All', lockTarget: true);
      },
    );
  }

  void _openPersonDetail(int index) {
    final person = _people[index];
    final nameController = TextEditingController(text: person.name);
    final phoneController = TextEditingController(text: person.phone ?? '');
    final emailController = TextEditingController(text: person.email ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Person Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final updatedName = nameController.text.trim();
                if (updatedName.isEmpty) {
                  _showMessage('Name is required.');
                  return;
                }
                final duplicate = _people.asMap().entries.any(
                  (entry) =>
                      entry.key != index &&
                      entry.value.name.toLowerCase() ==
                          updatedName.toLowerCase(),
                );
                if (duplicate) {
                  _showMessage('Another person already has this name.');
                  return;
                }
                final oldName = person.name;
                setState(() {
                  _people[index] = GroupPersonEntity(
                    name: updatedName,
                    phone: phoneController.text.trim().isEmpty
                        ? null
                        : phoneController.text.trim(),
                    email: emailController.text.trim().isEmpty
                        ? null
                        : emailController.text.trim(),
                  );
                  if (oldName != updatedName) {
                    _orderLines = _orderLines
                        .map(
                          (line) => line.target == oldName
                              ? line.copyWith(
                                  target: updatedName,
                                  label: line.target == null
                                      ? line.label
                                      : 'Order for $updatedName',
                                )
                              : line,
                        )
                        .toList();
                    _payments = _payments
                        .map(
                          (p) => p.target == oldName
                              ? p.copyWith(target: updatedName)
                              : p,
                        )
                        .toList();
                  }
                  _recalcTotals();
                });
                Navigator.pop(context);
                _showMessage('Person updated.');
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddPersonSheet() {
    if (!_canAddMorePeople) {
      _showMessage('Group is already at capacity.');
      return;
    }

    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Add Person', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Person name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isEmpty) {
                  _showMessage('Enter a person name.');
                  return;
                }
                if (_isDuplicatePerson(name)) {
                  _showMessage('This person is already added.');
                  return;
                }
                if (!_canAddMorePeople) {
                  _showMessage('Group is already at capacity.');
                  return;
                }
                setState(() {
                  _people.add(
                    GroupPersonEntity(
                      name: name,
                      phone: phone.isEmpty ? null : phone,
                    ),
                  );
                });
                Navigator.pop(context);
                _showMessage('$name added to the group.');
              },
              child: const Text('Save Person'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addItems() async {
    final result = await Navigator.pushNamed(
      context,
      '/order-screen',
      arguments: OrderScreenArgs(contextLabel: 'Group: ${_args.groupName}'),
    );

    final bool sentToKitchen = result is OrderScreenResult
        ? result.sentToKitchen
        : result == true;
    final double? orderAmount = result is OrderScreenResult
        ? result.subtotal
        : null;

    if (!sentToKitchen) {
      _showMessage('Send to kitchen to add these items.');
      return;
    }

    String? target = _peopleNames.isNotEmpty ? _peopleNames.first : 'All';
    bool addNewPerson = false;
    final newPersonNameController = TextEditingController();
    final newPersonPhoneController = TextEditingController();
    final initialDue = (orderAmount != null && orderAmount > 0)
        ? orderAmount
        : _targetDue(target);
    final fallbackAmount = initialDue > 0 ? initialDue : _due;
    final controller = TextEditingController(
      text: initialDue > 0 ? initialDue.toStringAsFixed(2) : '',
    );

    void _syncAmount(StateSetter setModalState) {
      final due = _targetDue(
        addNewPerson ? newPersonNameController.text.trim() : target,
      );
      setModalState(() {
        final next = due > 0
            ? due
            : (orderAmount != null && orderAmount > 0
                  ? orderAmount
                  : fallbackAmount);
        controller.text = next > 0 ? next.toStringAsFixed(2) : '';
      });
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) => SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Assign items to',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: addNewPerson ? 'ADD_NEW' : target,
                  decoration: const InputDecoration(labelText: 'Assign to'),
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text('All')),
                    ..._peopleNames.map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    ),
                    const DropdownMenuItem(
                      value: 'ADD_NEW',
                      child: Text('Add new person'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    if (value == 'ADD_NEW' && !_canAddMorePeople) {
                      _showMessage('Group is already at capacity.');
                      return;
                    }
                    setModalState(() {
                      if (value == 'ADD_NEW') {
                        addNewPerson = true;
                        target = null;
                      } else {
                        addNewPerson = false;
                        target = value;
                      }
                      _syncAmount(setModalState);
                    });
                  },
                ),
                if (addNewPerson) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPersonNameController,
                    decoration: const InputDecoration(labelText: 'Person name'),
                    onChanged: (_) => _syncAmount(setModalState),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newPersonPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Amount (auto-calculated)',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text) ?? 0;
                    if (amount <= 0) {
                      Navigator.pop(sheetContext);
                      _showMessage('Enter a valid amount.');
                      return;
                    }
                    String assignedTo = addNewPerson
                        ? newPersonNameController.text.trim()
                        : (target ?? 'All');
                    if (assignedTo.isEmpty) {
                      _showMessage('Enter a name for the individual.');
                      return;
                    }
                    if (addNewPerson) {
                      if (!_canAddMorePeople) {
                        _showMessage('Group is already at capacity.');
                        return;
                      }
                      if (_isDuplicatePerson(assignedTo)) {
                        _showMessage('This person is already added.');
                        return;
                      }
                      setState(() {
                        _people.add(
                          GroupPersonEntity(
                            name: assignedTo,
                            phone: newPersonPhoneController.text.trim().isEmpty
                                ? null
                                : newPersonPhoneController.text.trim(),
                          ),
                        );
                      });
                    }
                    setState(() {
                      _orderLines.add(
                        GroupOrderLine(
                          id: 'G-LINE-${_orderLines.length + 1}',
                          label: assignedTo == 'All'
                              ? 'Order for all'
                              : 'Order for $assignedTo',
                          items: [
                            'Group items (${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')})',
                          ],
                          amount: amount,
                          target: assignedTo == 'All' ? null : assignedTo,
                          isHistoric: false,
                        ),
                      );
                      _recalcTotals();
                    });
                    Navigator.pop(sheetContext);
                    _showMessage('Items added to group order');
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPaymentSheet({String? fixedTarget, bool lockTarget = false}) {
    final amountController = TextEditingController(
      text: _due.toStringAsFixed(2),
    );
    final coversController = TextEditingController();
    final newPayerController = TextEditingController();
    String? target =
        fixedTarget ??
        (_paymentTargets.isNotEmpty ? _paymentTargets.first : 'All');
    bool addNewPerson = false;
    String method = 'Cash';

    void _syncAmount(StateSetter setModalState) {
      final due = _targetDue(addNewPerson ? newPayerController.text : target);
      setModalState(() {
        amountController.text = due.toStringAsFixed(2);
      });
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Record Payment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (_paymentTargets.isNotEmpty && !lockTarget)
                  DropdownButtonFormField<String>(
                    value: addNewPerson ? 'ADD_NEW' : target,
                    decoration: const InputDecoration(labelText: 'Paying for'),
                    items: [
                      ..._paymentTargets.map(
                        (t) => DropdownMenuItem(value: t, child: Text(t)),
                      ),
                      const DropdownMenuItem(
                        value: 'ADD_NEW',
                        child: Text('Add new person'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      if (value == 'ADD_NEW' && !_canAddMorePeople) {
                        _showMessage('Group is already at capacity.');
                        return;
                      }
                      setModalState(() {
                        if (value == 'ADD_NEW') {
                          addNewPerson = true;
                          target = null;
                        } else {
                          addNewPerson = false;
                          target = value;
                        }
                        _syncAmount(setModalState);
                      });
                    },
                  ),
                if (addNewPerson) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPayerController,
                    decoration: const InputDecoration(
                      labelText: 'New person name',
                    ),
                    onChanged: (_) => _syncAmount(setModalState),
                  ),
                ],
                if (lockTarget && target != null && !addNewPerson) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text('Paying for: $target'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: coversController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Covers (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: method,
                  decoration: const InputDecoration(labelText: 'Method'),
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'Wallet', child: Text('Wallet')),
                  ],
                  onChanged: (value) {
                    if (value != null) method = value;
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) {
                      _showMessage('Enter a valid amount.');
                      return;
                    }
                    String? targetName = addNewPerson
                        ? newPayerController.text.trim()
                        : target;
                    if (addNewPerson &&
                        (targetName == null || targetName.isEmpty)) {
                      _showMessage('Enter a name for the person.');
                      return;
                    }
                    if (addNewPerson) {
                      if (!_canAddMorePeople) {
                        _showMessage('Group is already at capacity.');
                        return;
                      }
                      if (targetName != null &&
                          _isDuplicatePerson(targetName)) {
                        _showMessage('This person is already added.');
                        return;
                      }
                      setState(() {
                        _people.add(GroupPersonEntity(name: targetName ?? ''));
                      });
                    }
                    final personTarget = targetName == 'All'
                        ? null
                        : targetName ?? 'All';
                    final maxDue = _targetDue(targetName);
                    final double appliedAmount = maxDue > 0
                        ? amount.clamp(0, maxDue)
                        : amount;
                    final payer = 'Guest';
                    final covers = int.tryParse(coversController.text);
                    setState(() {
                      _payments.add(
                        GroupPaymentEntry(
                          payer: payer,
                          amount: appliedAmount,
                          method: method,
                          target: personTarget,
                          covers: covers,
                        ),
                      );
                      _recalcTotals();
                    });
                    Navigator.pop(context);
                    _showMessage(
                      'Payment of ${_currency(appliedAmount)} recorded via $method',
                    );
                  },
                  child: const Text('Record Payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GroupEntity _currentGroupInfo() {
    return GroupEntity(
      name: _args.groupName,
      peopleCount: _maxPeople,
      contactName: _args.contactName,
      contactPhone: _args.contactPhone,
      type: _args.type,
      notes: _args.notes,
      people: _people,
      isActive: _isActive,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _currentGroupInfo());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _currentGroupInfo()),
          ),
          title: Text('Group: ${_args.groupName}'),
          actions: [
            TextButton.icon(
              onPressed: () => _showMessage('Group closed (UI only).'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text('Close Group'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
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
                      children: [
                        Expanded(
                          child: Text('People: ${_people.length}/$_maxPeople'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _openAddPersonSheet,
                          icon: const Icon(Icons.person_add_alt_rounded),
                          label: Text(
                            _canAddMorePeople ? 'Add Person' : 'Full',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_people.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _people
                            .asMap()
                            .entries
                            .map(
                              (entry) => InputChip(
                                label: Text(entry.value.name),
                                onPressed: () => _openPersonDetail(entry.key),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      )
                    else
                      const Text(
                        'No people added yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact: ${_args.contactName} (${_args.contactPhone})',
                    ),
                    if (_args.type.isNotEmpty) Text('Type: ${_args.type}'),
                    if (_args.notes.isNotEmpty) Text('Notes: ${_args.notes}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MoneyColumn(label: 'Total', value: _total),
                    _MoneyColumn(label: 'Paid', value: _paid),
                    _MoneyColumn(label: 'Due', value: _due),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addItems,
                    icon: const Icon(Icons.add),
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
                    onPressed: () => _openPaymentSheet(),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Record Payment'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final bill = BillPreviewArgs(
                        orderLabel: 'Group • ${_args.groupName}',
                        items: const [
                          BillLineItem(
                            name: 'Group order',
                            quantity: 1,
                            price: 0,
                          ),
                        ],
                        subtotal: _total,
                        tax: 0,
                        serviceCharge: 0,
                        grandTotal: _total,
                        allowMultiplePayments: false,
                        paymentTargets: null,
                      );
                      Navigator.pushNamed(
                        context,
                        '/bill-preview',
                        arguments: bill,
                      );
                    },
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Checkout'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Payments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_payments.isEmpty)
              const Text('No payments recorded yet.')
            else
              ..._payments.map(
                (payment) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text('${payment.payer} • ${payment.method}'),
                    subtitle: payment.covers != null && payment.covers! > 0
                        ? Text('Covers: ${payment.covers}')
                        : const Text(''),
                    trailing: Text(
                      _currency(payment.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Previous Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_history.isEmpty)
              const Text('No previous orders.')
            else
              ..._history.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(entry.id),
                    subtitle: Text(entry.timestamp),
                    trailing: Text(_currency(entry.amount)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MoneyColumn extends StatelessWidget {
  final String label;
  final double value;

  const _MoneyColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          _currency(value),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';
