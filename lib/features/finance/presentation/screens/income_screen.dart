import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/finance/domain/entities/income_entry_entity.dart';
import 'package:yummy/features/finance/domain/usecases/get_income_usecase.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late final Future<List<IncomeEntryEntity>> _incomeFuture;

  @override
  void initState() {
    super.initState();
    final repository = context.read<RestaurantRepository>();
    final usecase = GetIncomeUseCase(repository);
    _incomeFuture = usecase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IncomeEntryEntity>>(
      future: _incomeFuture,
      builder: (context, snapshot) {
        final income = snapshot.data ?? const <IncomeEntryEntity>[];
        final total = income.fold<double>(0, (sum, inc) => sum + inc.amount);
        final average = income.isEmpty ? 0.0 : total / income.length;

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
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            _Stat(label: 'Total', value: _currency(total)),
                            const SizedBox(width: 16),
                            _Stat(label: 'Average', value: _currency(average)),
                            const SizedBox(width: 16),
                            _Stat(label: 'Entries', value: '${income.length}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (income.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No income entries yet.'),
                        ),
                      )
                    else
                      ...income.map(
                        (inc) => Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withValues(
                                alpha: .12,
                              ),
                              child: const Icon(
                                Icons.trending_up,
                                color: Colors.green,
                              ),
                            ),
                            title: Text(inc.source),
                            subtitle: Text(
                              '${inc.type} • ${inc.date}\n${inc.note}',
                            ),
                            isThreeLine: true,
                            trailing: Text(
                              _currency(inc.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';
