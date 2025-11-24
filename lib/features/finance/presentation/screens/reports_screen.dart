import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      _ReportCard(title: 'Daily Sales', value: '\$1,250', icon: Icons.today),
      _ReportCard(
        title: 'Weekly Sales',
        value: '\$8,750',
        icon: Icons.calendar_view_week,
      ),
      _ReportCard(
        title: 'Monthly Sales',
        value: '\$36,400',
        icon: Icons.calendar_month,
      ),
      _ReportCard(
        title: 'Most Sold Items',
        value: 'Margherita Pizza',
        icon: Icons.star,
      ),
      _ReportCard(
        title: 'Top Tables',
        value: 'T5, T2, T9',
        icon: Icons.table_bar,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.15,
          children: reports
              .map((card) => _ReportCardWidget(card: card))
              .toList(),
        ),
      ),
    );
  }
}

class _ReportCard {
  final String title;
  final String value;
  final IconData icon;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _ReportCardWidget extends StatelessWidget {
  final _ReportCard card;

  const _ReportCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepOrange.withValues(alpha: .12),
              child: Icon(card.icon, color: Colors.deepOrange),
            ),
            const Spacer(),
            Text(
              card.title,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.grey,

                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              card.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
