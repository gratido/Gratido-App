// ignore_for_file: use_super_parameters, deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ REQUIRED IMPORT (THIS FIXES YOUR ERROR)
import 'package:gratido_sample/features/selection_interface/selection.dart';

// ---------- PAGES ----------
import 'pages/about_page.dart';
import 'pages/receiver_notifications_page.dart';
import 'pages/edit_profile_page.dart';
import 'pages/feedback_form.dart';
import 'pages/faq_page.dart';
import 'pages/history_page.dart';
import 'pages/providers_closeby.dart';
import 'pages/pickup_status_page.dart';

class ReceiverProfilePage extends StatefulWidget {
  const ReceiverProfilePage({Key? key}) : super(key: key);

  @override
  State<ReceiverProfilePage> createState() => _ReceiverProfilePageState();
}

class _ReceiverProfilePageState extends State<ReceiverProfilePage> {
  static const Color primary = Color(0xFF6E5CD6);
  static const Color bgSoft = Color(0xFFF7F3FF);

  String receiverName = '';
  String receiverEmail = 'receiver@example.com';
  String? receiverPhotoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,

        // ✅ ensures back + notification icons stay visible
        iconTheme: const IconThemeData(color: Colors.black),

        // ✅ Material 2 + Material 3 safe (this is the key)
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 78, 62, 171), // primary purple
          fontSize: 20,
          //fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w900,
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),

        title: const Text('Gratido'),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReceiverNotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileHeader(),
              const SizedBox(height: 24),
              _sectionTitle('Service Controls'),
              _card([
                _item(
                  title: 'History',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  ),
                ),
                _item(
                  title: 'Pickup Status',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PickupStatusPage()),
                  ),
                ),
                _item(
                  title: 'Nearby Providers',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProvidersCloseByPage()),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Support'),
              _card([
                _item(
                  title: 'Share feedback',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackFormPage()),
                  ),
                ),
                _item(
                  title: 'About us',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  ),
                ),
                _item(
                  title: 'Frequently asked questions',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ModernFaqPage()),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('More'),
              _card([
                _item(
                  title: 'Logout',
                  onTap: () => showReceiverSignOutDialog(
                    context,
                    onConfirmed: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => showDeleteAccountDialog(context),
                child: const Text(
                  'Delete account',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _profileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: const Color(0xFFE9D5FF),
          backgroundImage: receiverPhotoPath != null
              ? FileImage(File(receiverPhotoPath!))
              : null,
          child: receiverPhotoPath == null
              ? Text(
                  receiverName.isNotEmpty ? receiverName[0].toUpperCase() : 'R',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                receiverName.isNotEmpty ? receiverName : 'No name saved',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                receiverEmail,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(
                        name: receiverName,
                        email: receiverEmail,
                        phone: '',
                        address: '',
                      ),
                    ),
                  );

                  if (updated != null) {
                    setState(() {
                      receiverName = updated['name'];
                      receiverEmail = updated['email'];
                      receiverPhotoPath = updated['photo'];
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Edit profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= HELPERS =================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _item({required String title, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// ===================================================================
// SIGN OUT DIALOG
// ===================================================================

Future<void> showReceiverSignOutDialog(
  BuildContext context, {
  required VoidCallback onConfirmed,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (context) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.82,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 120,
                  child: SvgPicture.asset(
                    'assets/images/logout.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Leaving already?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We’ll be here when you come back',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Stay'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirmed();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6E5CD6),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ===================================================================
// DELETE ACCOUNT DIALOG (FINAL & WORKING)
// ===================================================================

Future<void> showDeleteAccountDialog(BuildContext context) async {
  const Color primaryPurple = Color(0xFF7C3AED);
  const Color dangerRed = Color(0xFFDC2626);
  const Color secondaryGrey = Color(0xFF6B7280);

  final double dialogWidth = MediaQuery.of(context).size.width * 0.86;

  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (context, anim, __, ___) {
      return Transform.scale(
        scale: 0.96 + (anim.value * 0.04),
        child: Opacity(
          opacity: anim.value,
          child: Center(
            child: Container(
              width: dialogWidth, // ✅ SAME AS LOCATION POPUP
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22), // ✅ SAME
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.22),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18), // compact
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ICON + GLOW (UNCHANGED FROM DELETE POPUP)
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPurple.withOpacity(0.34),
                                    blurRadius: 70,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryPurple.withOpacity(0.14),
                              ),
                            ),
                            const Icon(
                              Icons.delete_forever_rounded,
                              size: 30,
                              color: primaryPurple,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ✅ TITLE — EXACT SAME SYSTEM AS LOCATION POPUP
                      Text(
                        'Delete your account?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 6),

                      // ✅ SUBTEXT — SAME BASE, SIZE −1
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12, // ⬅ reduced from 13
                                    height: 1.35,
                                    color: secondaryGrey,
                                  ),
                          children: const [
                            TextSpan(
                              text:
                                  'Your generosity has meant a lot. This action will ',
                            ),
                            TextSpan(
                              text: 'permanently remove ',
                              style: TextStyle(
                                color: dangerRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: 'your account and history.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // BUTTONS — UNCHANGED STRUCTURE FROM DELETE POPUP
                      // ✅ BUTTONS — EXACTLY MATCH OLD DELETE POPUP
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryPurple,
                                  side: BorderSide(
                                    color: primaryPurple.withOpacity(0.35),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Keep Account',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.clear();

                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const SelectionScreen(),
                                    ),
                                    (_) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryPurple,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Yes, Delete',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
