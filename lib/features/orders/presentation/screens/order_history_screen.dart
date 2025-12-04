import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/admin/presentation/bloc/admin_dashboard/admin_dashboard_bloc.dart';
import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  void _showSummary(
    BuildContext context,
    OrderHistoryEntryEntity entry,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ${entry.id}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Type: ${entry.type}'),
            Text('Amount: \$${entry.amount.toStringAsFixed(2)}'),
            Text('Status: ${entry.status}'),
            Text('Time: ${entry.timestamp}'),
            const SizedBox(height: 16),
            const Text('Items', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('• Sample Item 1 x2\n• Sample Item 2 x1'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = context.watch<AdminDashboardBloc>().state;
    final orders = dashboardState.snapshot?.orderHistory ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: orders.isEmpty
          ? const Center(child: Text('No order history yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final entry = orders[index];
                final statusColor =
                    entry.status == 'Paid' ? Colors.green : Colors.orange;
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showSummary(context, entry),
                    title: Text(entry.id),
                    subtitle: Text('${entry.type} • ${entry.timestamp}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('\$${entry.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(entry.status, style: TextStyle(color: statusColor)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
