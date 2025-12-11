// lib/features/donor/profile.dart
// ignore_for_file: use_super_parameters, use_build_context_synchronously, non_constant_identifier_names

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mydonations.dart';
import 'pages/about_provider.dart';
import 'pages/feedback_provider.dart';
import 'pages/faq_provider.dart';
import 'pages/edit_profile_provider.dart';
import 'pages/sign_out_provider.dart';

// If your selection screen path differs, change this import accordingly:
import 'package:gratido_sample/features/selection_interface/selection.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _name = '';
  String _phone = '';
  String _address = '';
  String? _photoPath;

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
    });
  }

  Future<void> _signOutAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('donor_name');
    await prefs.remove('donor_phone');
    await prefs.remove('donor_address');
    await prefs.remove('donor_photo');
    // navigate to SelectionScreen clearing history
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SelectionScreen()),
      (route) => false,
    );
  }

  Future<void> _openEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileProviderPage(
          name: _name,
          email: '', // pass what you have
          phone: _phone,
          address: _address,
          photoPath: _photoPath,
        ),
      ),
    );
    if (result != null) {
      // apply the returned map — same pattern as receiver.
    }

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('donor_name', result['name'] ?? '');
      await prefs.setString('donor_phone', result['phone'] ?? '');
      await prefs.setString('donor_address', result['address'] ?? '');
      if ((result['photo'] ?? '').isNotEmpty) {
        await prefs.setString('donor_photo', result['photo']!);
      }
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF7A18);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'gratido',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE HEADER ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: FileImageFromPath(_photoPath),
                    child: FileImageFromPath(_photoPath) == null
                        ? Text(
                            _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.black54,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name.isNotEmpty ? _name : 'No name saved',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _phone.isNotEmpty ? '+91 $_phone' : 'No phone saved',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _address.isNotEmpty ? _address : 'No address saved',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // smaller edit button
                        InkWell(
                          onTap: _openEdit,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ), // reduced size
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.14),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Edit profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Service Controls (My Donations appears here — removed large card)
              const Text(
                'Service Controls',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                context,
                items: [
                  _SectionItem(
                    title: 'My Donations',
                    leading: const Icon(Icons.list_alt_outlined),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyDonations()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Support
              const Text(
                'Support',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                context,
                items: [
                  _SectionItem(
                    title: 'Share feedback',
                    leading: const Icon(Icons.feedback_outlined),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FeedbackFormPage(),
                      ),
                    ),
                  ),
                  _SectionItem(
                    title: 'About us',
                    leading: const Icon(Icons.info_outline),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AboutProviderPage(),
                      ),
                    ),
                  ),
                  _SectionItem(
                    title: 'Frequently asked questions',
                    leading: const Icon(Icons.help_outline),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FAQProviderPage(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // More (Sign out)
              const Text(
                'More',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                context,
                items: [
                  _SectionItem(
                    title: 'Sign out',
                    leading: const Icon(Icons.logout_outlined),
                    onTap: () => showSignOutDialog(
                      context,
                      onConfirmed: _signOutAndNavigate,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Delete account - LEFT aligned (as requested)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Delete account'),
                        content: const Text(
                          'Are you sure you want to permanently delete your account?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(c).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(c).pop();
                              // deletion logic
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Delete account',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper: safe FileImage loader (works on mobile/desktop; returns null on web)
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

// Section card builder (same look as receiver)
Widget _sectionCard(BuildContext context, {required List<_SectionItem> items}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isLast = index == items.length - 1;
        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: item.leading,
              title: Text(item.title, style: const TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.chevron_right),
              onTap: item.onTap,
            ),
            if (!isLast)
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          ],
        );
      }),
    ),
  );
}

class _SectionItem {
  final String title;
  final Widget? leading;
  final VoidCallback? onTap;
  const _SectionItem({required this.title, this.leading, this.onTap});
}
