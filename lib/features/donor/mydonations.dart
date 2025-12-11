// lib/features/donor/mydonations.dart
// Final corrected version: fixes analyzer warnings about null checks,
// computes quantity safely for both nullable and non-nullable models,
// shows Food name, "Category: <type>", "Quantity: <persons>" and
// "Expiry date: <expiryTime>" (if present).
// NEW badge logic: latest donation (by createdAt) for this donor shows NEW.
// Keeps 2 cards per row, rounded modern cards, and live updates via DonationRepo listener.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'donation_repo.dart';
import 'donation_detail.dart';

class MyDonations extends StatefulWidget {
  const MyDonations({super.key});

  @override
  State<MyDonations> createState() => _MyDonationsState();
}

class _MyDonationsState extends State<MyDonations> {
  String _myName = '';

  @override
  void initState() {
    super.initState();
    _loadDonorName();
    DonationRepo.instance.addListener(_onRepoUpdated);
  }

  @override
  void dispose() {
    DonationRepo.instance.removeListener(_onRepoUpdated);
    super.dispose();
  }

  void _onRepoUpdated() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadDonorName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _myName = prefs.getString('donor_name') ?? '';
    });
  }

  // small helper to safely get trimmed strings whether field is nullable or not
  String _safe(String? s) => s?.trim() ?? '';

  Widget _imageWidget(String? firstPhoto) {
    if (_safe(firstPhoto).isEmpty) {
      return Container(
        height: 110,
        color: Colors.grey.shade100,
        child: const Center(child: Icon(Icons.image_not_supported)),
      );
    }
    try {
      if (firstPhoto!.startsWith('assets/')) {
        return Image.asset(
          firstPhoto,
          height: 110,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
      final f = File(firstPhoto);
      if (!f.existsSync()) {
        return Container(
          height: 110,
          color: Colors.grey.shade100,
          child: const Center(child: Icon(Icons.image_not_supported)),
        );
      }
      return Image.file(
        f,
        height: 110,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (_) {
      return Container(
        height: 110,
        color: Colors.grey.shade100,
        child: const Center(child: Icon(Icons.image_not_supported)),
      );
    }
  }

  // Determines which donation is the latest for this donor (by createdAt)
  DateTime? _latestCreatedAtForDonor(List<Donation> list) {
    if (list.isEmpty) return null;
    DateTime latest = list.first.createdAt;
    for (final d in list) {
      if (d.createdAt.isAfter(latest)) latest = d.createdAt;
    }
    return latest;
  }

  // safe conversion of quantity to string for analyzer-friendly code
  String _quantityToString(dynamic quantity) {
    try {
      // if it's null or an empty string, return a dash
      if (quantity == null) return '—';
      // numbers -> toString, strings -> trimmed string
      if (quantity is num) return quantity.toString();
      if (quantity is String) {
        final s = quantity.trim();
        return s.isEmpty ? '—' : s;
      }
      // fallback: call toString and hope for best
      final s = quantity.toString();
      return s.isEmpty ? '—' : s;
    } catch (_) {
      return '—';
    }
  }

  Widget _buildCard(
    BuildContext context,
    Donation donation, {
    required bool isLatest,
  }) {
    final bool hasPhoto = donation.photoPaths.isNotEmpty;
    final String? firstPhoto = hasPhoto ? donation.photoPaths.first : null;

    final titleText = (_safe(donation.foodName).isNotEmpty)
        ? _safe(donation.foodName)
        : _safe(donation.category);

    // expiry formatted (if available) — use only expiryTime string from model (safe)
    final expiryTextRaw = _safe(donation.expiryTime);
    final String expiryText = expiryTextRaw.isNotEmpty ? expiryTextRaw : '';

    // quantity: safe conversion (works whether quantity is int, int?, String, etc.)
    final String quantityText = _quantityToString(donation.quantity);

    final String categoryText = _safe(donation.category);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DonationDetail(donation: donation)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: _imageWidget(firstPhoto),
                ),

                // content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food name (main title)
                      Text(
                        titleText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Category: type
                      Row(
                        children: [
                          const Text(
                            'Category: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              categoryText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Quantity : persons
                      Row(
                        children: [
                          const Text(
                            'Quantity: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$quantityText persons',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Expiry date: use expiryTime string if available
                      if (expiryText.isNotEmpty)
                        Row(
                          children: [
                            const Text(
                              'Expiry date: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                expiryText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // NEW badge top-right (only the latest donation for this donor will have it)
          if (isLatest)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // filtered list for this donor
    final List<Donation> donorList = DonationRepo.instance.items
        .where(
          (d) =>
              d.donorName.trim().toLowerCase() == _myName.trim().toLowerCase(),
        )
        .toList();

    // compute the latest createdAt for this donor (so we know which item is NEW)
    final DateTime? latest = _latestCreatedAtForDonor(donorList);

    // show newest-first
    final List<Donation> list = donorList.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: list.isEmpty
            ? const Center(
                child: Text(
                  'No donations yet. Tap + to add one.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : GridView.builder(
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  // aspect ratio tuned to avoid overflow and give card breathing room
                  childAspectRatio: 0.66,
                ),
                itemBuilder: (context, index) {
                  final d = list[index];
                  final bool isLatestForDonor =
                      latest != null && d.createdAt == latest;
                  return _buildCard(context, d, isLatest: isLatestForDonor);
                },
              ),
      ),
    );
  }
}
