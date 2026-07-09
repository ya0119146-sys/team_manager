import 'package:flutter/material.dart';
import 'package:team_manager/core/widgets/glass_button.dart';

Future<void> showLogoutDialog(BuildContext context, VoidCallback onConfirm) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final theme = Theme.of(context);
      
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: theme.textTheme.bodyMedium),
          ),
          GlassButton(
            width: 100,
            height: 40,
            gradient: LinearGradient(
              colors: [theme.colorScheme.error, theme.colorScheme.error],
            ),
            label: 'Logout',
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
          ),
        ],
      );
    },
  );
}
