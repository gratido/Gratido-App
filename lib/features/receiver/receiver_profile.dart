// ignore_for_file: use_super_parameters

import 'dart:io';
import 'package:flutter/material.dart';
import 'pages/about_page.dart';
import 'pages/edit_profile_page.dart';
import 'pages/feedback_form.dart';
import 'pages/faq_page.dart';
import 'pages/history_page.dart';
import 'pages/sign_out_page.dart';
import 'pages/providers_closeby.dart';
import 'pages/pickup_status_page.dart';

class ReceiverProfilePage extends StatefulWidget {
  const ReceiverProfilePage({Key? key}) : super(key: key);

  @override
  State<ReceiverProfilePage> createState() => _ReceiverProfilePageState();
}

class _ReceiverProfilePageState extends State<ReceiverProfilePage> {
  final Color _accent = const Color(0xFFFF7A18);

  String receiverName = 'Name of Receiver';
  String receiverEmail = 'receiver@example.com';
  String? receiverPhotoPath;

  @override
  Widget build(BuildContext context) {
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
              // Profile Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: receiverPhotoPath != null
                        ? FileImage(File(receiverPhotoPath!))
                        : null,
                    child: receiverPhotoPath == null
                        ? const Icon(Icons.person, size: 44, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receiverName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          receiverEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        /// SMALLER EDIT BUTTON — UPDATED
                        InkWell(
                          onTap: () async {
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
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ), // smaller
                            decoration: BoxDecoration(
                              color: _accent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withOpacity(0.18),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Edit profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13, // small text
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

              const SizedBox(height: 20),

              // Accepted Listings
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Accepted Listings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '12',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Service Controls',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              _buildSectionCard(
                context,
                items: [
                  _SectionItem(
                    title: 'History',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    ),
                  ),
                  _SectionItem(
                    title: 'Pickup Status',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PickupStatusPage(),
                      ),
                    ),
                  ),
                  _SectionItem(
                    title: 'Nearby Providers',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProvidersCloseByPage(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Text(
                'Support',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              _buildSectionCard(
                context,
                items: [
                  _SectionItem(
                    title: 'Share feedback',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FeedbackFormPage(),
                      ),
                    ),
                  ),
                  _SectionItem(
                    title: 'About us',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    ),
                  ),
                  _SectionItem(
                    title: 'Frequently asked questions',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ModernFaqPage()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'More',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              _buildSectionCard(
                context,
                items: [
                  _SectionItem(
                    title: 'Logout',
                    leading: const Icon(Icons.logout),
                    onTap: () async {
                      await showSignOutDialog(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  /// UPDATED → ARROW ICON ADDED
  Widget _buildSectionCard(
    BuildContext context, {
    required List<_SectionItem> items,
  }) {
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

                /// → Added Arrow Icon Here
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),

                onTap: item.onTap,
              ),
              if (!isLast) Divider(height: 0, color: Colors.grey.shade200),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionItem {
  final String title;
  final Widget? leading;
  final VoidCallback? onTap;

  const _SectionItem({required this.title, this.leading, this.onTap});
}
