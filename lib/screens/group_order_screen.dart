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

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _addItems() async {
    await Navigator.pushNamed(
      context,
      '/order-screen',
      arguments: OrderScreenArgs(contextLabel: 'Group: ${_args.groupName}'),
    );

    setState(() {
      const newAmount = 120.0;
      _history = List.of(_history)
        ..add(
          OrderHistoryEntry(
            id: 'G-NEW-${_history.length + 1}',
            type: 'Group',
            amount: newAmount,
            status: 'Unpaid',
            timestamp: 'Just now',
          ),
        );
      _total += newAmount;
    });
    _showMessage('Items added to group order');
  }

  void _openSplitBill() {
    final people = _args.peopleCount > 0 ? _args.peopleCount : 1;
    final perHead = _due / people;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text('Split Bill', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('People: $people'),
            Text('Total due: ${_currency(_due)}'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text('Equal split for $people'),
                subtitle: Text('Each pays ${_currency(perHead)}'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Use this as guidance. Record multiple payments for guests who settle individually or combined.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _openPaymentSheet() {
    final controller = TextEditingController(text: _due.toStringAsFixed(2));
    final payerController = TextEditingController();
    final coversController = TextEditingController();
    String method = 'Card';
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
              'Record Payment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: payerController,
              decoration: const InputDecoration(labelText: 'Payer (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: coversController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Covers (optional)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: method,
              decoration: const InputDecoration(labelText: 'Method'),
              items: const [
                DropdownMenuItem(value: 'Card', child: Text('Card')),
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                DropdownMenuItem(value: 'Wallet', child: Text('Wallet')),
              ],
              onChanged: (value) {
                if (value != null) method = value;
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0;
                if (amount <= 0) {
                  _showMessage('Enter a valid amount.');
                  return;
                }
                final covers = int.tryParse(coversController.text) ?? 0;
                final payer = payerController.text.trim().isEmpty
                    ? 'Guest'
                    : payerController.text.trim();
                setState(() {
                  _paid = (_paid + amount).clamp(0, _total);
                  _payments.add(
                    _PaymentEntry(
                      payer: payer,
                      amount: amount,
                      method: method,
                      covers: covers,
                    ),
                  );
                });
                Navigator.pop(context);
                _showMessage(
                  'Payment of ${_currency(amount)} recorded via $method',
                );
              },
              child: const Text('Record Payment'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Group: ${_args.groupName}')),
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: _addItems,
                icon: const Icon(Icons.add),
                label: const Text('Add Items'),
              ),
              FilledButton.tonalIcon(
                onPressed: _openSplitBill,
                icon: const Icon(Icons.call_split),
                label: const Text('Split Bill'),
              ),
              FilledButton.icon(
                onPressed: _openPaymentSheet,
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Record Payment'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  final tax = _total * 0.1;
                  final service = _total * 0.05;
                  final bill = BillPreviewArgs(
                    orderLabel: 'Group • ${_args.groupName}',
                    items: const [
                      BillLineItem(name: 'Group order', quantity: 1, price: 0),
                    ],
                    subtotal: _total,
                    tax: tax,
                    serviceCharge: service,
                    grandTotal: _total + tax + service,
                  );
                  Navigator.pushNamed(context, '/bill-preview', arguments: bill);
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Checkout'),
              ),
              OutlinedButton.icon(
                onPressed: () => _showMessage('Group closed (UI only).'),
                icon: const Icon(Icons.check_circle),
                label: const Text('Close Group'),
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
  final int? covers;

  const _PaymentEntry({
    required this.payer,
    required this.amount,
    required this.method,
    this.covers,
  });
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';
