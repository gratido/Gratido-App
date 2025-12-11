// lib/features/donor/pages/sign_out_provider.dart
import 'package:flutter/material.dart';

/// showSignOutDialog(context, onConfirmed: callback)
/// - The dialog uses a dim (not fully black) barrier so the profile behind is visible.
/// - onConfirmed is called if the user taps Yes.
Future<void> showSignOutDialog(
  BuildContext context, {
  required VoidCallback onConfirmed,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    // dim but not black
    barrierColor: Colors.black26,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm logout'),
        content: const Text('Are you sure you want to logout?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );

  if (confirmed == true) onConfirmed();
}
