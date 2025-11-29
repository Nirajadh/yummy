import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yummy/features/auth/presentation/widgets/logout_confirmation_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushAlerts = true;
  bool _emailSummaries = false;
  bool _autoBackup = true;
  bool _kitchenSound = true;
  final String _language = 'English';

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(title: 'General'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Push Alerts'),
            subtitle: const Text('Orders, payments, table updates'),
            value: _pushAlerts,
            onChanged: (value) => setState(() => _pushAlerts = value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.mail_outline),
            title: const Text('Email Summaries'),
            subtitle: const Text('Daily performance snapshot'),
            value: _emailSummaries,
            onChanged: (value) => setState(() => _emailSummaries = value),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSnack(context, 'Language picker coming soon'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: const Text('Restaurant Details'),
            subtitle: const Text('Name, address, phone, description'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(
              context,
              '/restaurant-setup',
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                _showSnack(context, 'Theme settings tapped (UI only).'),
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'Operations'),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('Kitchen Sounds'),
            subtitle: const Text('Play alert sounds for new KOT'),
            value: _kitchenSound,
            onChanged: (value) => setState(() => _kitchenSound = value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.cloud_sync_outlined),
            title: const Text('Auto Backup'),
            subtitle: const Text('Sync data to cloud every night'),
            value: _autoBackup,
            onChanged: (value) => setState(() => _autoBackup = value),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Data Export'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSnack(context, 'Export started in background'),
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'Support'),
          ListTile(
            leading: const Icon(Icons.headset_mic_outlined),
            title: const Text('Contact Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSnack(context, 'Support chat opening soon'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Guides & Tutorials'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSnack(context, 'Knowledge base coming soon'),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final shouldLogout = await showLogoutConfirmationDialog(context);
              if (shouldLogout && context.mounted) {
                context.read<AuthBloc>().add(const LogoutRequested());
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
