
// lib/features/receiver/sign_out_page.dart
import 'package:flutter/material.dart';

// Use the same import path you provided earlier — adjust if SelectionScreen is elsewhere.
import 'package:gratido_sample/features/selection_interface/selection.dart';

/// Final corrected logout helper.
/// CALL THIS from your Profile/Settings page (where the profile UI is visible):
///    await showSignOutDialog(context);
///
/// Do NOT push a SignOutPage route. Show the dialog directly using the current
/// profile page context so the profile UI remains visible behind the dialog.
Future<void> showSignOutDialog(BuildContext context) async {
  // showDialog returns when Navigator.pop is called inside the dialog builder
  final bool? confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(
      0.25,
    ), // subtle dim, profile visible behind
    builder: (dialogCtx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Confirm logout',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to logout?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop(false); // return false (cancel)
            },
            child: const Text(
              'No',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop(true); // return true (confirm)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    },
  );

  // If user didn't confirm, just return (stay on profile)
  if (confirmed != true) return;

  // Ensure the original context is still mounted before navigating
  if (!context.mounted) return;

  // OPTIONAL: add sign-out cleanup here (clear tokens, shared prefs, etc.)
  // await AuthService.signOut();
  // await SharedPreferences.getInstance().then((p) => p.clear());

  // Navigate to SelectionScreen and clear the navigation stack
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const SelectionScreen()),
    (route) => false,
  );
}
