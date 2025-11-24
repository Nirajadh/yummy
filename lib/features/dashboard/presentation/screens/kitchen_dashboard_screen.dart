import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/auth/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:yummy/features/kot/presentation/bloc/kot/kot_bloc.dart';

class KitchenDashboardScreen extends StatelessWidget {
  const KitchenDashboardScreen({super.key});

  void _handleStatus(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kitchen KOT'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final shouldLogout = await showLogoutConfirmationDialog(
                  context,
                );
                if (shouldLogout && context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: BlocBuilder<KotBloc, KotState>(
          builder: (context, state) {
            if (state.status == KotStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final tickets = state.tickets;
            if (tickets.isEmpty) {
              return const Center(child: Text('No KOT tickets right now.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticket.id,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ticket.time,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${ticket.type} • ${ticket.reference}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        ...ticket.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.deepOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(item)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: () => _handleStatus(
                                  context,
                                  '${ticket.id} marked Preparing',
                                ),
                                child: const Text('Preparing'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => _handleStatus(
                                  context,
                                  '${ticket.id} marked Ready',
                                ),
                                child: const Text('Ready'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
