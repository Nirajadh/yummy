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

  double get _due => (widget.args.grandTotal - _paid).clamp(0, widget.args.grandTotal);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openPaymentSheet() {
    final amountController = TextEditingController(text: _due.toStringAsFixed(2));
    final payerController = TextEditingController();
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
            Text('Take Payment', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: payerController,
              decoration: const InputDecoration(labelText: 'Payer (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
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
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) {
                  _showMessage('Enter a valid amount.');
                  return;
                }
                final payer = payerController.text.trim().isEmpty ? 'Guest' : payerController.text.trim();
                setState(() {
                  _paid = (_paid + amount).clamp(0, widget.args.grandTotal);
                  _payments.add(_PaymentEntry(payer: payer, amount: amount, method: method));
                });
                Navigator.pop(context);
                _showMessage('Payment of ${_currency(amount)} recorded via $method');
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
    final args = widget.args;
    return Scaffold(
      appBar: AppBar(title: const Text('Bill & Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(args.orderLabel, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Expanded(child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 60, child: Text('Qty', textAlign: TextAlign.center)),
                          SizedBox(width: 100, child: Text('Total', textAlign: TextAlign.end)),
                        ],
                      ),
                      const Divider(height: 24),
                      Expanded(
                        child: ListView.separated(
                          itemCount: args.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = args.items[index];
                            return Row(
                              children: [
                                Expanded(child: Text(item.name)),
                                SizedBox(width: 60, child: Text('${item.quantity}', textAlign: TextAlign.center)),
                                SizedBox(
                                  width: 100,
                                  child: Text('\$${item.lineTotal.toStringAsFixed(2)}', textAlign: TextAlign.end),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const Divider(height: 32),
                      _SummaryRow(label: 'Subtotal', amount: args.subtotal),
                      _SummaryRow(label: 'Tax', amount: args.tax),
                      _SummaryRow(label: 'Service charge', amount: args.serviceCharge),
                      const Divider(height: 32),
                      _SummaryRow(label: 'Grand total', amount: args.grandTotal, isBold: true),
                      const SizedBox(height: 8),
                      _SummaryRow(label: 'Paid', amount: _paid),
                      _SummaryRow(label: 'Due', amount: _due, isBold: true),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_payments.isNotEmpty) ...[
              const Text('Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  child: OutlinedButton.icon(
                    onPressed: () => _showMessage('Bill shared (UI only)'),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share Bill'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _openPaymentSheet,
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Take Payment'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () => _showMessage('Printing bill (UI only)'),
              icon: const Icon(Icons.print),
              label: const Text('Print Bill'),
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
    final textStyle = isBold ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.bodyMedium;
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
  final String method;

  const _PaymentEntry({
    required this.payer,
    required this.amount,
    required this.method,
  });
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';
