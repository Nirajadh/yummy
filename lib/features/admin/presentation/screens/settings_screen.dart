import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/admin/presentation/bloc/settings/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAppearancePicker(BuildContext context, ThemeMode current) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: current,
                onChanged: (_) {
                  Navigator.pop(sheetContext);
                  context.read<SettingsBloc>().add(
                        const AppearanceChanged(ThemeMode.light),
                      );
                },
              ),
            ),
            ListTile(
              title: const Text('Dark'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: current,
                onChanged: (_) {
                  Navigator.pop(sheetContext);
                  context.read<SettingsBloc>().add(
                        const AppearanceChanged(ThemeMode.dark),
                      );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final appearanceLabel =
              state.appearance == ThemeMode.dark ? 'Dark' : 'Light';
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SectionHeader(title: 'Personalize'),
              _SettingTile(
                icon: Icons.favorite_border,
                title: 'Appearance',
                subtitle: 'Theme: $appearanceLabel',
                onTap: () => _showAppearancePicker(context, state.appearance),
              ),
              _SettingTile(
                icon: Icons.storefront_outlined,
                title: 'Your Restaurant',
                subtitle: 'Manage staff, menu, finance, and more',
                highlight: false,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/restaurant'),
              ),
              const SizedBox(height: 12),
              _SectionHeader(title: 'Notifications & Operations'),
              _SettingSwitch(
                icon: Icons.notifications_active_outlined,
                title: 'Push Alerts',
                subtitle: 'Orders, payments, table updates',
                value: state.pushAlerts,
                onChanged: (value) =>
                    context.read<SettingsBloc>().add(PushAlertsToggled(value)),
              ),
              _SettingSwitch(
                icon: Icons.mail_outline,
                title: 'Email Summaries',
                subtitle: 'Daily performance snapshot',
                value: state.emailSummaries,
                onChanged: (value) => context.read<SettingsBloc>().add(
                  EmailSummariesToggled(value),
                ),
              ),
              _SettingSwitch(
                icon: Icons.volume_up_outlined,
                title: 'Kitchen Sounds',
                subtitle: 'Play alert sounds for new KOT',
                value: state.kitchenSound,
                onChanged: (value) => context.read<SettingsBloc>().add(
                  KitchenSoundToggled(value),
                ),
              ),
              _SettingSwitch(
                icon: Icons.cloud_sync_outlined,
                title: 'Auto Backup',
                subtitle: 'Sync data to cloud every night',
                value: state.autoBackup,
                onChanged: (value) =>
                    context.read<SettingsBloc>().add(AutoBackupToggled(value)),
              ),
              _SettingTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack(context, 'Language picker coming soon'),
              ),
              _SettingTile(
                icon: Icons.download_outlined,
                title: 'Data Export',
                subtitle: 'Export reports and billing',
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _showSnack(context, 'Export started in background'),
              ),
              const SizedBox(height: 12),
              _SectionHeader(title: 'Security & Support'),
              _SettingTile(
                icon: Icons.lock_outline,
                title: 'Security',
                subtitle: 'Configure password, PIN, etc.',
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _showSnack(context, 'Security settings coming soon'),
              ),
              _SettingTile(
                icon: Icons.headset_mic_outlined,
                title: 'Contact Support',
                subtitle: 'Chat with our support team',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack(context, 'Support chat opening soon'),
              ),
              _SettingTile(
                icon: Icons.book_outlined,
                title: 'Guides & Tutorials',
                subtitle: 'Learn how to use the app',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack(context, 'Knowledge base coming soon'),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
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

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool highlight;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = highlight
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : theme.cardColor;
    final fg =
        theme.textTheme.bodyLarge?.color ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: fg.withValues(alpha: 0.12),
          child: Icon(icon, color: fg),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      child: SwitchListTile(
        secondary: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }
}
