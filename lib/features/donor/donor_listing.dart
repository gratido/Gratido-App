// lib/features/donor/donor_listing.dart
// ignore_for_file: dead_code
//
// Minimal update:
// - Title: Food name (if present) else category.
// - Second line: "Category: <category>" (placeholder + actual).
// - Bottom row keeps Qty and pickup/time.
// - Items shown newest-first (createdAt desc).
// - Keeps NEW badge and pixel-safe layout.

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
    DonationRepo.instance.seedDemo();
    DonationRepo.instance.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    DonationRepo.instance.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() => setState(() {});

  Widget _buildThumb(String? path) {
    if (path == null) return _placeholderImage();
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    final file = File(path);
    if (!file.existsSync()) return _placeholderImage();
    return Image.file(file, fit: BoxFit.cover);
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.fastfood_outlined, size: 44, color: Colors.grey),
      ),
    );
  }

  bool _isNewByTime(Donation d) =>
      DateTime.now().difference(d.createdAt).inHours < 4;

  @override
  Widget build(BuildContext context) {
    // copy and sort newest-first by createdAt
    final items = DonationRepo.instance.items.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Donation Listings"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: items.isEmpty
          ? const Center(child: Text("No listings yet."))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final d = items[index];

                  // topTitle: Food name if present else category (both trimmed)
                  final String topTitle =
                      (d.foodName?.trim().isNotEmpty ?? false)
                          ? d.foodName!.trim()
                          : d.category.trim();

                  // Category line (placeholder + selected category)
                  final String categoryLine = 'Category: ${d.category.trim()}';

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DonationDetail(donation: d),
                      ),
                    ),
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGE AREA
                          Expanded(
                            flex: 6,
                            child: Stack(
                              children: [
                                SizedBox.expand(
                                  child: _buildThumb(
                                    d.photoPaths.isNotEmpty
                                        ? d.photoPaths.first
                                        : null,
                                  ),
                                ),
                                if (_isNewByTime(d))
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "NEW",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // TEXT AREA
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // FOOD NAME (main title)
                                  Text(
                                    topTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // CATEGORY placeholder + selected category
                                  Text(
                                    categoryLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),

                                  const Spacer(),

                                  // BOTTOM ROW: Qty (left) and pickup/time (right)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Qty: ${d.quantity}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          d.pickupWindow == 'Other' &&
                                                  (d.pickupWindowOther
                                                          ?.isNotEmpty ??
                                                      false)
                                              ? d.pickupWindowOther!
                                              : (d.pickupWindow),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
