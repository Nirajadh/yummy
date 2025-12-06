import 'package:flutter/material.dart';

class OperationalSnapshotSection extends StatelessWidget {
  const OperationalSnapshotSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operational Snapshot',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: _TablesOverviewCard()),
            SizedBox(width: 12),
            Expanded(child: _StaffSnapshotCard()),
          ],
        ),
        const SizedBox(height: 12),
        const _KitchenLoadCard(),
      ],
    );
  }
}

class _TablesOverviewCard extends StatelessWidget {
  const _TablesOverviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                  child: Icon(
                    Icons.table_bar,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tables',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Total: 22', style: theme.textTheme.bodyMedium),
            Text('Occupied: 6', style: theme.textTheme.bodyMedium),
            Text('Free: 16', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _StaffSnapshotCard extends StatelessWidget {
  const _StaffSnapshotCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.secondary.withValues(alpha: 0.08),
                  child: Icon(
                    Icons.group_outlined,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Staff',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('On duty: 4', style: theme.textTheme.bodyMedium),
            Text('Orders served: 49', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _KitchenLoadCard extends StatelessWidget {
  const _KitchenLoadCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  theme.colorScheme.tertiary.withValues(alpha: 0.08),
              child: Icon(
                Icons.local_fire_department_outlined,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kitchen Load',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Medium • Avg prep 12 min',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
