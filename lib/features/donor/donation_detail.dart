// lib/features/donor/donation_detail.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'donation_repo.dart';

class DonationDetail extends StatelessWidget {
  final Donation donation;

  const DonationDetail({super.key, required this.donation});

  Widget _buildPhoto(String path) {
    if (path.startsWith('assets/images')) {
      return Image.asset(path, fit: BoxFit.cover);
    } else {
      final f = File(path);
      if (!f.existsSync()) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        );
      }
      return Image.file(f, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// TITLE LOGIC: foodName > category
    final title =
        (donation.foodName != null && donation.foodName!.trim().isNotEmpty)
        ? donation.foodName!.trim()
        : donation.category;

    return Scaffold(
      appBar: AppBar(title: const Text("Donation Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// MAIN TITLE (food name shown here)
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: donation.photoPaths.length,
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildPhoto(donation.photoPaths[i]),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Food Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _infoRow("Category", donation.category),
            _infoRow("Quantity", "${donation.quantity} persons"),
            _infoRow("Prepared", donation.preparedTime ?? "Not given"),
            _infoRow("Expiry", donation.expiryTime ?? "Not specified"),
            const SizedBox(height: 20),

            const Text(
              "Pickup Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _infoRow("Location", donation.pickupLocation),
            _infoRow(
              "Pickup Window",
              donation.pickupWindow == "Other" &&
                      (donation.pickupWindowOther?.isNotEmpty ?? false)
                  ? donation.pickupWindowOther!
                  : donation.pickupWindow,
            ),
            _infoRow("Phone", donation.phone),

            const SizedBox(height: 20),

            if (donation.notes != null && donation.notes!.trim().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(donation.notes!, style: const TextStyle(fontSize: 14)),
                ],
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
