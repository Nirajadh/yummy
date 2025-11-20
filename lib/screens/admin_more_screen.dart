import 'package:flutter/material.dart';

import '../widgets/logout_confirmation_dialog.dart';

class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem(
        title: 'Staff',
        subtitle: 'Manage staff and payroll',
        icon: Icons.badge_outlined,
        route: '/staff-management',
      ),
      _MoreItem(
        title: 'Expenses',
        subtitle: 'Track spending and payouts',
        icon: Icons.attach_money_outlined,
        route: '/expenses',
      ),
      _MoreItem(
        title: 'Menu Management',
        subtitle: 'Edit and organize menu',
        icon: Icons.restaurant_menu,
        route: '/menu-management',
      ),
      _MoreItem(
        title: 'Purchases',
        subtitle: 'Track vendor bills',
        icon: Icons.shopping_cart_outlined,
        route: '/purchase',
      ),
      _MoreItem(
        title: 'Income',
        subtitle: 'Monitor incoming payments',
        icon: Icons.account_balance_wallet_outlined,
        route: '/income',
      ),
      _MoreItem(
        title: 'Reports',
        subtitle: 'View performance insights',
        icon: Icons.bar_chart_outlined,
        route: '/reports',
      ),
      _MoreItem(
        title: 'Settings',
        subtitle: 'Preferences and account',
        icon: Icons.settings_outlined,
        route: '/settings',
      ),
      _MoreItem(
        title: 'Logout',
        subtitle: 'Sign out of MyRestro',
        icon: Icons.logout,
        onTap: () async {
          final shouldLogout = await showLogoutConfirmationDialog(context);
          if (shouldLogout && context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child: Icon(item.icon, color: Colors.grey.shade800),
              ),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (item.onTap != null) {
                  item.onTap!();
                } else if (item.route != null) {
                  Navigator.pushNamed(context, item.route!);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _MoreItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;

  const _MoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.route,
    this.onTap,
  });
}
