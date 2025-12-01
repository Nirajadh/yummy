import 'package:flutter/material.dart';

/// Hub page for restaurant-level management links.
class RestaurantHubScreen extends StatelessWidget {
  const RestaurantHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_RestaurantItem>[
      _RestaurantItem(
        title: 'Restaurant Profile',
        subtitle: 'Name, address, contact, description',
        icon: Icons.storefront_outlined,
        route: '/restaurant-setup',
      ),
      _RestaurantItem(
        title: 'Staff',
        subtitle: 'Manage staff and payroll',
        icon: Icons.badge_outlined,
        route: '/staff-management',
      ),
      _RestaurantItem(
        title: 'Menu Management',
        subtitle: 'Products, pricing, availability',
        icon: Icons.restaurant_menu,
        route: '/menu-management',
      ),
      _RestaurantItem(
        title: 'Item Categories',
        subtitle: 'Organize menu by categories',
        icon: Icons.category_outlined,
        route: '/item-categories',
      ),
      _RestaurantItem(
        title: 'Manage Tables',
        subtitle: 'Create and organize table layouts',
        icon: Icons.table_bar_outlined,
        route: '/tables-manage',
      ),
      _RestaurantItem(
        title: 'Expenses',
        subtitle: 'Track spending and payouts',
        icon: Icons.attach_money_outlined,
        route: '/expenses',
      ),
      _RestaurantItem(
        title: 'Purchases',
        subtitle: 'Vendor bills and inventory',
        icon: Icons.shopping_cart_outlined,
        route: '/purchase',
      ),
      _RestaurantItem(
        title: 'Income',
        subtitle: 'Incoming payments overview',
        icon: Icons.account_balance_wallet_outlined,
        route: '/income',
      ),
      _RestaurantItem(
        title: 'Reports',
        subtitle: 'Performance and sales insights',
        icon: Icons.bar_chart_outlined,
        route: '/reports',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Your Restaurant')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                child: Icon(item.icon, color: theme.colorScheme.primary),
              ),
              title: Text(
                item.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(item.subtitle, style: theme.textTheme.bodySmall),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, item.route),
            ),
          );
        },
      ),
    );
  }
}

class _RestaurantItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const _RestaurantItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}
