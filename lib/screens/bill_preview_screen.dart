import 'package:flutter/material.dart';

import '../models/bill_preview.dart';

class BillPreviewScreen extends StatefulWidget {
  final BillPreviewArgs args;

  const BillPreviewScreen({super.key, required this.args});

  @override
  State<BillPreviewScreen> createState() => _BillPreviewScreenState();
}

class _BillPreviewScreenState extends State<BillPreviewScreen> {
  final List<_PaymentEntry> _payments = [];
  double _paid = 0;

  double get _due =>
      (widget.args.grandTotal - _paid).clamp(0, widget.args.grandTotal);
  double get _changeReturned =>
      _payments.fold<double>(0, (sum, p) => sum + p.changeAmount);
  bool get _canTakePayment =>
      widget.args.allowMultiplePayments || _payments.isEmpty;
  List<String> get _targets =>
      widget.args.paymentTargets?.keys.toList(growable: false) ?? const [];

  double _targetDue(String? target) {
    if (target == null ||
        target == 'All' ||
        widget.args.paymentTargets == null) {
      return _due;
    }
    final targetTotal = widget.args.paymentTargets?[target] ?? 0;
    final paidForTarget = _payments
        .where((p) => p.target == target)
        .fold<double>(0, (sum, p) => sum + p.amount);
    final remaining = (targetTotal - paidForTarget)
        .clamp(0, targetTotal)
        .toDouble();
    return remaining;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openPaymentSheet() {
    if (!_canTakePayment || _due <= 0) {
      _showMessage(
        'This bill allows only one payment and is already recorded.',
      );
      return;
    }
    final billAmount = widget.args.grandTotal;
    final lockAmount = !widget.args.allowMultiplePayments;
    final amountController = TextEditingController(
      text: _due.toStringAsFixed(2),
    );
    final payerController = TextEditingController();
    final tenderController = TextEditingController(
      text: billAmount.toStringAsFixed(2),
    );
    String method = 'Cash';

    double _calcChange(double amount, String tenderText) {
      final tendered = double.tryParse(tenderText) ?? 0;
      return tendered > amount ? tendered - amount : 0;
    }

    double changePreview = _calcChange(billAmount, tenderController.text);
    String? selectedTarget = _targets.isNotEmpty ? _targets.first : null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                'Take Payment',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: payerController,
                decoration: const InputDecoration(
                  labelText: 'Payer (optional)',
                ),
              ),
              if (_targets.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTarget,
                  decoration: const InputDecoration(labelText: 'Paying for'),
                  items: _targets
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() {
                        selectedTarget = value;
                        changePreview = _calcChange(
                          billAmount,
                          tenderController.text,
                        );
                      });
                    }
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                readOnly: lockAmount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (Bill total)',
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tenderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tender Amount',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: Color(0xFFF1F5FF),
                ),
                onChanged: (_) => setModalState(() {
                  changePreview = _calcChange(
                    billAmount,
                    tenderController.text,
                  );
                }),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Change to return'),
                  Text(
                    _currency(changePreview),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
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
                  final tendered =
                      double.tryParse(tenderController.text) ?? amount;
                  if (amount <= 0) {
                    _showMessage('Enter a valid amount.');
                    return;
                  }
                  final target = selectedTarget;
                  final payer = payerController.text.trim().isEmpty
                      ? 'Guest'
                      : payerController.text.trim();
                  final double change = _calcChange(
                    _due,
                    tenderController.text,
                  );
                  setState(() {
                    _paid =
                        (_paid + amount).clamp(0, widget.args.grandTotal)
                            as double;
                    _payments.add(
                      _PaymentEntry(
                        payer: payer,
                        amount: amount.toDouble(),
                        tendered: tendered.toDouble(),
                        changeAmount: change,
                        method: method,
                        target: target,
                      ),
                    );
                  });
                  Navigator.pop(context);
                  _showMessage(
                    'Payment of ${_currency(amount)} via $method. Change: ${_currency(change)}',
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
    final args = widget.args;
    final paymentTaken = _payments.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Bill & Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              args.orderLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'Item',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text('Qty', textAlign: TextAlign.center),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text('Total', textAlign: TextAlign.end),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Expanded(
                        child: ListView.separated(
                          itemCount: args.items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = args.items[index];
                            return Row(
                              children: [
                                Expanded(child: Text(item.name)),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    '${item.quantity}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    '\$${item.lineTotal.toStringAsFixed(2)}',
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const Divider(height: 32),
                      _SummaryRow(label: 'Subtotal', amount: args.subtotal),
                      _SummaryRow(
                        label: 'Grand total',
                        amount: args.grandTotal,
                        isBold: true,
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(label: 'Paid', amount: _paid),
                      if (_changeReturned > 0)
                        _SummaryRow(
                          label: 'Change returned',
                          amount: _changeReturned,
                        ),
                      _SummaryRow(label: 'Due', amount: _due, isBold: true),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_payments.isNotEmpty) ...[
              const Text(
                'Payments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  itemCount: _payments.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    return ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: Text('${payment.payer} • ${payment.method}'),
                      subtitle: Text(
                        'Tendered: ${_currency(payment.tendered)} • Change: ${_currency(payment.changeAmount)}',
                      ),
                      trailing: Text(_currency(payment.amount)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _canTakePayment && _due > 0
                        ? _openPaymentSheet
                        : null,
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Take Payment'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (paymentTaken) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showMessage('Bill shared (UI only)'),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share Bill'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (paymentTaken) ...[
                  const SizedBox(height: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _showMessage('Printing bill (UI only)'),
                      icon: const Icon(Icons.print),
                      label: const Text('Print Bill'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = isBold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(_currency(amount), style: textStyle),
        ],
      ),
    );
  }
}

class _PaymentEntry {
  final String payer;
  final double amount;
  final double tendered;
  final double changeAmount;
  final String method;
  final String? target;

  const _PaymentEntry({
    required this.payer,
    required this.amount,
    required this.tendered,
    required this.changeAmount,
    required this.method,
    this.target,
  });
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';
