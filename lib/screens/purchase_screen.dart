import 'package:flutter/material.dart';

import '../data/dummy_data.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = dummyPurchases.fold<double>(0, (sum, p) => sum + p.amount);
    final average = dummyPurchases.isEmpty ? 0.0 : total / dummyPurchases.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSnack(context, 'New purchase flow coming soon'),
        icon: const Icon(Icons.add_shopping_cart_outlined),
        label: const Text('Add Purchase'),
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
                  _Stat(label: 'Entries', value: '${dummyPurchases.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...dummyPurchases
              .map(
                (purchase) => Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.withOpacity(.12),
                      child: const Icon(Icons.shopping_bag_outlined, color: Colors.indigo),
                    ),
                    title: Text(purchase.vendor),
                    subtitle: Text('${purchase.category} • ${purchase.reference}\n${purchase.date}'),
                    isThreeLine: true,
                    trailing: Text(
                      _currency(purchase.amount),
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
