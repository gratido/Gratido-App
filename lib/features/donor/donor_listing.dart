// lib/features/donor/donor_listing.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'donation_repo.dart';
import 'donation_detail.dart';

class DonorListing extends StatefulWidget {
  const DonorListing({super.key});

  @override
  State<DonorListing> createState() => _DonorListingState();
}

class _DonorListingState extends State<DonorListing> {
  @override
  void initState() {
    super.initState();
    DonationRepo.instance.seedDemo(); // seeds once
    DonationRepo.instance.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    DonationRepo.instance.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() => setState(() {});

  // ---------- IMAGE ----------
  Widget _image(String? path) {
    if (path == null) return Container(color: Colors.grey.shade200);
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    final file = File(path);
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : Container(color: Colors.grey.shade200);
  }

  // ---------- QTY COLOR CYCLE ----------
  Color _qtyBg(int index) {
    const colors = [
      Color(0xFFE8F1FF),
      Color(0xFFEAF7EE),
      Color(0xFFFFF2E5),
      Color(0xFFEFEAFF),
    ];
    return colors[index % 4];
  }

  Color _qtyFg(int index) {
    const colors = [
      Color(0xFF3B6FD8),
      Color(0xFF2E7D32),
      Color(0xFFF57C00),
      Color(0xFF6E5CD6),
    ];
    return colors[index % 4];
  }

  //Helper widget
  Widget _newBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6E5CD6),
// red NEW tag
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = DonationRepo.instance.items.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Donation Listings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E8FF),
              Color(0xFFF9FAFB),
            ],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 215, // 🔒 unchanged
          ),
          itemBuilder: (context, index) {
            final d = items[index];

            final title = (d.foodName != null && d.foodName!.trim().isNotEmpty)
                ? d.foodName!
                : d.category;

            final imagePath =
                d.photoPaths.isNotEmpty ? d.photoPaths.first : null;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DonationDetail(donation: d),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 100,
                              width: double.infinity,
                              child: _image(imagePath),
                            ),
                          ),

                          // ✅ NEW TAG — only for latest donation
                          if (index == 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: _newBadge(),
                            ),
                        ],
                      ),
                    ),

                    // TEXT
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Category: ${d.category}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black38,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ✅ FIXED, COMPACT BOTTOM ROW
                          SizedBox(
                            height: 22,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _qtyBg(index),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Qty: ${d.quantity}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _qtyFg(index),
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    d.pickupWindow,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      height: 1.1,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
