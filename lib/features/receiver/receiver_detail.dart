// lib/features/receiver/receiver_detail.dart
// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'receiver_tracking.dart';

class ReceiverDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onConfirmPickup;

  const ReceiverDetailPage({Key? key, required this.item, this.onConfirmPickup})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? 'Other - Cooked meals';
    final provider = item['provider'] ?? 'Provider name';
    final phone = item['phone'] ?? '+91 9876543210';
    final location = item['location'] ?? 'City Center';
    final time = item['time'] ?? '10:00 - 12:00';
    final quantity = item['quantity'] ?? '10 persons';
    final prepared = item['prepared_time'] ?? 'Just now';
    final expiry = item['expiry'] ?? 'Today';
    final notes =
        item['notes'] ?? 'Posted: ${DateTime.now().toLocal().toString()}';

    final images =
        (item['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        <String>[];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // top image carousel (main + dots inside image)
                  _ImageCarouselWithDots(images: images),

                  // curved white card overlapping image
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(34),
                          topRight: Radius.circular(34),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              location,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // pickup & quantity row
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_outlined,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Pickup',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            time,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 46,
                                  color: Colors.grey.shade300,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Quantity',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            quantity,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              'Expiry time:',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              expiry,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),

                            const Text(
                              'Prepared time:',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              prepared,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),

                            const Text(
                              'Description:',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notes,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // contact box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.08),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Phone:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        phone,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Name:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        provider,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 18,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Address:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              location,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),
                            Text(
                              'Added: ${DateTime.now().toLocal().toIso8601String()}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Confirm pickup button anchored
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (onConfirmPickup != null) onConfirmPickup!();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReceiverTrackingPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A4CFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Confirm pickup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Image carousel that shows PageView for images and dots indicator inside the image area.
/// Tapping the image opens a centered gallery dialog with swipe + pinch/zoom.
class _ImageCarouselWithDots extends StatefulWidget {
  final List<String> images;
  const _ImageCarouselWithDots({Key? key, required this.images})
    : super(key: key);

  @override
  State<_ImageCarouselWithDots> createState() => _ImageCarouselWithDotsState();
}

class _ImageCarouselWithDotsState extends State<_ImageCarouselWithDots> {
  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openDialogGallery(int initialIndex) async {
    final images = widget.images;
    final mq = MediaQuery.of(context).size;
    final dialogWidth = mq.width * 0.90;
    final dialogHeight = mq.height * 0.72;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final pageCtrl = PageController(initialPage: initialIndex);
        int dialogPage = initialIndex; // now used inside StatefulBuilder

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: dialogWidth,
                    maxHeight: dialogHeight,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          color: Colors.black,
                          child: PageView.builder(
                            controller: pageCtrl,
                            itemCount: images.length,
                            onPageChanged: (p) =>
                                setStateDialog(() => dialogPage = p),
                            itemBuilder: (context, index) {
                              final url = images[index];
                              return InteractiveViewer(
                                panEnabled: true,
                                scaleEnabled: true,
                                minScale: 1,
                                maxScale: 5,
                                child: Image.network(
                                  url,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                  loadingBuilder: (ctx, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // small page counter top-right (optional)
                      Positioned(
                        right: 16,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${dialogPage + 1} / ${images.length}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      // close button
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Material(
                          color: Colors.white.withOpacity(0.95),
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: Colors.black87,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    // If no images, render single placeholder large area (no dots)
    if (images.isEmpty) {
      return GestureDetector(
        onTap: () => _openDialogGallery(0),
        child: Container(
          width: double.infinity,
          height: 280,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.fastfood, size: 92, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (context, index) {
              final url = images[index];
              return GestureDetector(
                onTap: () => _openDialogGallery(_page),
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (ctx, child, progress) => progress == null
                        ? child
                        : Container(color: Colors.grey.shade200),
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.broken_image,
                        size: 72,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // dots indicator positioned inside the bottom of the image,
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(images.length, (i) {
                    final isCurrent = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isCurrent ? 14 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
