// lib/features/receiver/receiver_detail.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'receiver_tracking.dart';

// ✅ NEW IMPORT
import 'models/food_item.dart';

/// GRATIDO THEME
const Color primary = Color(0xFF6E5CD6);
const Color softBg = Color(0xFFF7F3FF);

class ReceiverDetailPage extends StatelessWidget {
  final FoodItem item;
  final VoidCallback? onConfirmPickup;

  const ReceiverDetailPage({
    Key? key,
    required this.item,
    this.onConfirmPickup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ SAME DATA, JUST FROM MODEL
    final title = item.title;
    final category = item.category;
    final location = item.location;
    final quantity = item.quantity;
    final prepared = item.pickupTime;
    final expiry = item.expiry;
    final List<String> images = item.images;

    final String donorNotes =
        'Weekend Food Pack – contains various items suitable for a family meal. '
        'Please bring your own containers if possible.';

    return Scaffold(
      backgroundColor: softBg,

      // ✅ TOP BAR (UNCHANGED)
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          'Donation Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            /// IMAGE (TAP → FULLSCREEN)
            GestureDetector(
              onTap: images.isNotEmpty
                  ? () => _openImagePreview(context, images.first)
                  : null,
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: images.isNotEmpty
                    ? Image.asset(
                        images.first,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFEDE9FE),
                              Color(0xFFDCD6FF),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 80,
                            color: primary,
                          ),
                        ),
                      ),
              ),
            ),

            Container(
              transform: Matrix4.translationValues(0, -28, 0),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE CARD
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 13,
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// FOOD INFORMATION
                  _infoSection(
                    icon: Icons.restaurant_menu,
                    title: 'Food Information',
                    children: [
                      _row('Category', category),
                      _row('Quantity', quantity),
                      _row('Prepared', prepared),
                      _expiryRow(expiry),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// PICKUP INFORMATION
                  _infoSection(
                    icon: Icons.location_on,
                    title: 'Pickup Information',
                    children: [
                      _row('Location', location),
                      _row('Pickup Window', 'Within 30 mins'),
                      const SizedBox(height: 12),
                      _contactDonorButton(),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// DONOR NOTES
                  _donorNotesCard(donorNotes),

                  const SizedBox(height: 24),

                  /// REQUEST PICKUP
                  _requestPickupButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FULLSCREEN IMAGE =================

  void _openImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.asset(imagePath),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= UI HELPERS (UNCHANGED) =================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: primary.withOpacity(0.15),
                child: Icon(icon, size: 18, color: primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _expiryRow(String value) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Expiry',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.red.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _contactDonorButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withOpacity(0.15),
              primary.withOpacity(0.25),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.call, color: primary),
          label: const Text(
            'Contact Donor',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _donorNotesCard(String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donor Notes',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$notes"',
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestPickupButton(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primary, Color(0xFF8A79E8)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            if (onConfirmPickup != null) onConfirmPickup!();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReceiverTrackingPage(),
              ),
            );
          },
          icon: const Icon(Icons.volunteer_activism),
          label: const Text(
            'Request Pickup',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
    );
  }
}
