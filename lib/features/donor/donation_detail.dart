import 'dart:io';
import 'package:flutter/material.dart';
import 'donation_repo.dart';

class DonationDetail extends StatefulWidget {
  final Donation donation;
  const DonationDetail({super.key, required this.donation});

  @override
  State<DonationDetail> createState() => _DonationDetailState();
}

class _DonationDetailState extends State<DonationDetail> {
  int _imageIndex = 0;

  static const Color primary = Color(0xFF6E5CD6);
  static const Color softBg = Color(0xFFF7F3FF);

  //bool get _isPackedFood => widget.donation.category == 'Packed Food';

  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    final file = File(path);
    if (!file.existsSync()) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      );
    }
    return Image.file(file, fit: BoxFit.cover);
  }

  void _openFullscreen(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FullscreenImage(path: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.donation;
    final images = d.photoPaths;

    final title = (d.foodName != null && d.foodName!.trim().isNotEmpty)
        ? d.foodName!
        : d.category;

    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Donation Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            if (images.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (i) => setState(() => _imageIndex = i),
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => _openFullscreen(images[i]),
                            child: _buildImage(images[i]),
                          ),
                        ),
                      ),

                      // ✅ Carousel dots (only when multiple images)
                      if (images.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: _imageIndex == i ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _imageIndex == i
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            /// FIRST CARD — FOOD TITLE
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18, // 🔽 reduced
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.category,
                    style: const TextStyle(
                      color: primary,
                      fontSize: 13, // 🔽 smaller than title
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          d.pickupLocation,
                          style: const TextStyle(
                            fontSize: 13, // 🔽 smaller
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
            /// ✅ EXCITED UPDATE: "TYPE" IS GONE! REAL PREPARED TIME & PHONE LABELS!
            _infoSection(
              icon: Icons.restaurant_menu,
              title: 'Food Information',
              children: [
                _row('Category', d.category),
                _row('Quantity',
                    '${d.quantity} persons'), // ✅ Show '10' persons!
                _row(
                    'Prepared Time',
                    d.preparedTime ??
                        'Not specified'), // ✅ CHANGED LABEL TO PREPARED TIME!
                _expiryRow(d.expiryTime ?? 'N/A'), // ✅ SHOWS JUNE 6!
              ],
            ),

            const SizedBox(height: 16),

            /// PICKUP INFORMATION
            _infoSection(
              icon: Icons.location_on,
              title: 'Pickup Information',
              children: [
                _row('Location',
                    d.pickupLocation), // ✅ SHOWS REAL HYDERABAD ADDRESS!
                _row('Pickup Window', d.pickupWindow),
                _phoneRow(d.phone), // ✅ SHOWS REAL MANUAL PHONE!
              ],
            ),

            if (d.notes != null && d.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _notesCard(d.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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
                  fontWeight: FontWeight.w700,
                  fontSize: 16, // 🔼 slightly bigger
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
            flex: 4, // label space
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 6, // value space — pushes content visually right
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
              color: Colors.red.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _phoneRow(String phone) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Phone',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            phone,
            style: const TextStyle(
              fontSize: 13,
              color: primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _notesCard(String notes) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donor Notes',
            style: TextStyle(
              fontSize: 14,
              color: primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$notes"',
            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  final String path;
  const _FullscreenImage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: path.startsWith('assets/')
                  ? Image.asset(path)
                  : Image.file(File(path)),
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
  }
}
