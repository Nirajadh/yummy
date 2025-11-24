import 'package:flutter/material.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  final shouldLogout =
      await showDialog<bool>(
        context: context,
        builder: (_) => const LogoutConfirmationDialog(),
      ) ??
      false;
  return shouldLogout;
}
