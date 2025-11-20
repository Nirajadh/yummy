import 'package:flutter/material.dart';

import '../data/dummy_data.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = dummyIncome.fold<double>(0, (sum, inc) => sum + inc.amount);
    final average = dummyIncome.isEmpty ? 0.0 : total / dummyIncome.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSnack(context, 'Income entry coming soon'),
        icon: const Icon(Icons.add_chart_outlined),
        label: const Text('Add Income'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _Stat(label: 'Total', value: _currency(total)),
                  const SizedBox(width: 16),
                  _Stat(label: 'Average', value: _currency(average)),
                  const SizedBox(width: 16),
                  _Stat(label: 'Entries', value: '${dummyIncome.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...dummyIncome
              .map(
                (income) => Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(.12),
                      child: const Icon(Icons.trending_up, color: Colors.green),
                    ),
                    title: Text(income.source),
                    subtitle: Text('${income.type} • ${income.date}\n${income.note}'),
                    isThreeLine: true,
                    trailing: Text(
                      _currency(income.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';
