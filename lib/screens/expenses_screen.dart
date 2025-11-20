import 'package:flutter/material.dart';

import '../data/dummy_data.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = dummyExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final average = dummyExpenses.isEmpty ? 0.0 : total / dummyExpenses.length;
    final categories = _categoryTotals();

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'expenses-fab',
        onPressed: () => _showLogExpenseDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Spend', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(total),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ExpenseStat(
                          label: 'Avg Expense',
                          value: _formatCurrency(average),
                        ),
                      ),
                      Expanded(
                        child: _ExpenseStat(
                          label: 'Categories',
                          value: '${categories.length}',
                        ),
                      ),
                      Expanded(
                        child: _ExpenseStat(
                          label: 'Entries',
                          value: '${dummyExpenses.length}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Spending by Category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.entries
                .map(
                  (entry) => Chip(
                    avatar: const Icon(Icons.wallet_outlined, size: 18),
                    label: Text('${entry.key}: ${_formatCurrency(entry.value)}'),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text('Recent Expenses', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dummyExpenses.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final expense = dummyExpenses[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(.1),
                    child: const Icon(Icons.receipt_long, color: Colors.orange),
                  ),
                  title: Text(expense.vendor),
                  subtitle: Text('${expense.category} • ${expense.paymentMode}\n${expense.date}'),
                  isThreeLine: true,
                  trailing: Text(
                    _formatCurrency(expense.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          if (dummyExpenses.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Notes: ${dummyExpenses.first.notes}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  void _showLogExpenseDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Expense'),
        content: const Text('Expense logging will sync with your accounting system in the next sprint.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ExpenseStat extends StatelessWidget {
  final String label;
  final String value;

  const _ExpenseStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

Map<String, double> _categoryTotals() {
  final totals = <String, double>{};
  for (final expense in dummyExpenses) {
    totals.update(expense.category, (current) => current + expense.amount, ifAbsent: () => expense.amount);
  }
  return totals;
}
