import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/bill_preview.dart';
import 'order_screen.dart';

class GroupOrderArgs {
  final String groupName;
  final int peopleCount;
  final String contactName;
  final String contactPhone;
  final String type;
  final String notes;

  const GroupOrderArgs({
    required this.groupName,
    required this.peopleCount,
    required this.contactName,
    required this.contactPhone,
    this.type = '',
    this.notes = '',
  });
}

class GroupOrderScreen extends StatefulWidget {
  const GroupOrderScreen({super.key});

  @override
  State<GroupOrderScreen> createState() => _GroupOrderScreenState();
}

class _GroupOrderScreenState extends State<GroupOrderScreen> {
  late GroupOrderArgs _args;
  late List<OrderHistoryEntry> _history;
  final List<_PaymentEntry> _payments = [];
  double _total = 0;
  double _paid = 0;
  bool _loaded = false;
  final Map<String, double> _personTotals = {};
  List<String> get _paymentTargets => [
    'All',
    ...{..._peopleLabels, ..._personTotals.keys},
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
            peopleCount: 0,
            contactName: '',
            contactPhone: '',
          );
    _history =
        groupOrderHistory[_args.groupName] ?? const <OrderHistoryEntry>[];
    _total = _history.fold<double>(0, (sum, entry) => sum + entry.amount);
    if (_total == 0) _total = 500; // fallback demo amount
    _loaded = true;
  }

  double get _due => (_total - _paid).clamp(0, _total);
  List<String> get _peopleLabels =>
      List.generate(_args.peopleCount, (i) => 'Person ${i + 1}');
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

  Future<void> _addItems() async {
    final sentToKitchen = await Navigator.pushNamed(
      context,
      '/order-screen',
      arguments: OrderScreenArgs(contextLabel: 'Group: ${_args.groupName}'),
    );

    if (sentToKitchen != true) {
      _showMessage('Send to kitchen to add these items.');
      return;
    }

    String mode = 'All';
    String individualName = '';
    final nameController = TextEditingController();
    final controller = TextEditingController(text: _due.toStringAsFixed(2));

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
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: mode == 'All',
                      onSelected: (_) => setModalState(() {
                        mode = 'All';
                        nameController.clear();
                        individualName = '';
                      }),
                    ),
                    ChoiceChip(
                      label: const Text('Individual'),
                      selected: mode == 'Individual',
                      onSelected: (_) =>
                          setModalState(() => mode = 'Individual'),
                    ),
                  ],
                ),
                if (mode == 'Individual') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Person name'),
                    onChanged: (value) => individualName = value.trim(),
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
                    final assignedTo = mode == 'All'
                        ? 'All'
                        : individualName.trim();
                    if (mode == 'Individual' && assignedTo.isEmpty) {
                      _showMessage('Enter a name for the individual.');
                      return;
                    }
                    setState(() {
                      _total += amount;
                      if (mode == 'Individual') {
                        _personTotals[assignedTo] =
                            (_personTotals[assignedTo] ?? 0) + amount;
                      }
                      _history = List.of(_history)
                        ..add(
                          OrderHistoryEntry(
                            id: 'G-NEW-${_history.length + 1}',
                            type: 'Group',
                            amount: amount,
                            status: 'Unpaid',
                            timestamp: 'Just now',
                          ),
                        );
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

  void _openPaymentSheet() {
    final amountController = TextEditingController(
      text: _due.toStringAsFixed(2),
    );
    final payerController = TextEditingController();
    final coversController = TextEditingController();
    final newPayerController = TextEditingController();
    String? target = _paymentTargets.isNotEmpty ? _paymentTargets.first : 'All';
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
              if (_paymentTargets.isNotEmpty)
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
                    _paid = (_paid + appliedAmount).clamp(0, _total) as double;
                    if (addNewPerson && targetName != null) {
                      _personTotals.putIfAbsent(targetName, () => 0);
                    }
                    _payments.add(
                      _PaymentEntry(
                        payer: payer,
                        amount: appliedAmount,
                        method: method,
                        target: personTarget,
                        covers: covers,
                      ),
                    );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group: ${_args.groupName}'),
        actions: [
          TextButton.icon(
            onPressed: () => _showMessage('Group closed (UI only).'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.12),
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
                  Text('People: ${_args.peopleCount}'),
                  Text('Contact: ${_args.contactName} (${_args.contactPhone})'),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _openPaymentSheet,
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

class _PaymentEntry {
  final String payer;
  final double amount;
  final String method;
  final String? target;
  final int? covers;

  const _PaymentEntry({
    required this.payer,
    required this.amount,
    required this.method,
    this.target,
    this.covers,
  });
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';
