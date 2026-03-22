// lib/features/receiver/receiver_detail.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'receiver_tracking.dart';
import 'models/food_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

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
    final title = item.title;
    final category = item.category;
    final location = item.location;
    final quantity = item.quantity;
    final prepared = item.pickupTime;
    final expiry = item.expiry;
    final List<String> images = item.images;

    final notes = item.notes;
    return Scaffold(
      backgroundColor: softBg,
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
            /// IMAGE
            GestureDetector(
              onTap: images.isNotEmpty
                  ? () => _openImagePreview(context, images.first)
                  : null,
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: images.isNotEmpty
                    ? _buildImage(images.first)
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
                      _contactDonorButton(context),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// DONOR NOTES
                  if (notes.trim().isNotEmpty) ...[
                    _donorNotesCard(notes),
                  ],

                  const SizedBox(height: 24),

                  /// CONFIRM PICKUP BUTTON
                  _requestPickupButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    final bool isWeb =
        path.startsWith('http://') || path.startsWith('https://');

    if (isWeb) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image,
              size: 60,
              color: Colors.grey,
            ),
          );
        },
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
    );
  }

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
                  child: imagePath.startsWith('http')
                      ? Image.network(imagePath)
                      : Image.asset(imagePath),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
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

  Future<void> _callDonor(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Widget _contactDonorButton(BuildContext context) {
    final String donorPhone = item.phone; // MUST match your FoodItem model

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
          onPressed: () => _callDonor(donorPhone),
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
      child: ElevatedButton.icon(
        onPressed: () async {
          const String laptopIp = "192.168.0.5";

          try {
            final token = await FirebaseAuth.instance.currentUser?.getIdToken();

            final response = await http.post(
              Uri.parse('http://$laptopIp:5227/api/Donation/accept/${item.id}'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            );

            if (response.statusCode == 200) {
              if (onConfirmPickup != null) {
                onConfirmPickup!();
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReceiverTrackingPage(item: item),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Pickup failed: ${response.statusCode}")),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
        },
        icon: const Icon(Icons.volunteer_activism),
        label: const Text(
          'Confirm Pickup',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
