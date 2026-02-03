// lib/features/donor/profile.dart
// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gratido_sample/features/donor/donation_repo.dart';
import 'package:gratido_sample/features/donor/pages/notifications_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mydonations.dart';
import 'pages/about_provider.dart';
import 'pages/feedback_provider.dart';
import 'pages/faq_provider.dart';
import 'pages/edit_profile_provider.dart';
import 'package:gratido_sample/features/selection_interface/selection.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _name = '';
  String _phone = '';
  String _address = '';
  String? _photoPath;
  String _email = '';

  static const Color primary = Color(0xFF6E5CD6);
  static const Color bgSoft = Color(0xFFF7F3FF);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('donor_name') ?? '';
      _phone = prefs.getString('donor_phone') ?? '';
      _address = prefs.getString('donor_address') ?? '';
      _photoPath = prefs.getString('donor_photo');
      _email = prefs.getString('donor_email') ?? '';
    });
  }

  Future<void> _openEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileProviderPage(
          name: _name,
          email: _email,
          phone: _phone,
          address: _address,
          photoPath: _photoPath,
        ),
      ),
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('donor_name', result['name'] ?? '');
      await prefs.setString('donor_phone', result['phone'] ?? '');
      await prefs.setString('donor_address', result['address'] ?? '');
      await prefs.setString('donor_email', result['email'] ?? '');

      if ((result['photo'] ?? '').isNotEmpty) {
        await prefs.setString('donor_photo', result['photo']);
      }
      _load();
    }
  }

  Future<void> _signOutAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    DonationRepo.instance.clearAll();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SelectionScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,

        // ✅ ensures icons (back + notification) are visible
        iconTheme: const IconThemeData(color: Colors.black),

        // ✅ THIS is the key line (Material 3 safe)
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 78, 62, 171), // primary purple
          fontSize: 20,
          //fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w900,
        ),

        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
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
                  builder: (_) => const NotificationsPage(),
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
              const SizedBox(height: 28),
              _sectionTitle('Service Controls'),
              _card([
                _item(
                  icon: Icons.list_alt,
                  title: 'My Donations',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyDonations()),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Support'),
              _card([
                _item(
                  icon: Icons.chat_bubble_outline,
                  title: 'Share feedback',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackFormPage()),
                  ),
                ),
                _item(
                  icon: Icons.info_outline,
                  title: 'About us',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AboutProviderPage()),
                  ),
                ),
                _item(
                  icon: Icons.help_outline,
                  title: 'Frequently asked questions',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FAQProviderPage()),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('More'),
              _card([
                _item(
                  icon: Icons.logout,
                  title: 'Sign out',
                  onTap: () => showSignOutDialog(
                    context,
                    onConfirmed: _signOutAndNavigate,
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

  Widget _profileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: const Color(0xFFE9D5FF),
          backgroundImage: FileImageFromPath(_photoPath),
          child: FileImageFromPath(_photoPath) == null
              ? Text(
                  _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Color(0xFF7E22CE),
                    fontWeight: FontWeight.w600,
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
                _name.isNotEmpty ? _name : 'No name saved',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _email.isNotEmpty ? _email : 'example@gmail.com',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _openEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: const StadiumBorder(),
                  elevation: 3,
                ),
                child: const Text(
                  'Edit profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Color(0xFF2E1065),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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

  Widget _item({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Icon(icon, color: primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// ---------------- IMAGE HELPER ----------------

ImageProvider? FileImageFromPath(String? path) {
  if (path == null || path.isEmpty) return null;
  try {
    if (kIsWeb) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    return FileImage(file);
  } catch (_) {
    return null;
  }
}

// ---------------- SIGN OUT DIALOG (UNCHANGED) ----------------

Future<void> showSignOutDialog(
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
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Stay'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
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
      );
    },
  );
}

// ---------------- DELETE ACCOUNT DIALOG (ONLY BUTTONS UPDATED) ----------------

// ---------------- DELETE ACCOUNT DIALOG (TYPOGRAPHY & SIZE SYNCED) ----------------

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
                                  DonationRepo.instance.clearAll();
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
