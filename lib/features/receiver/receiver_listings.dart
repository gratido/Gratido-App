// lib/features/receiver/receiver_listings.dart
// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'receiver_detail.dart';

class ReceiverListingsPage extends StatefulWidget {
  const ReceiverListingsPage({Key? key}) : super(key: key);

  @override
  State<ReceiverListingsPage> createState() => _ReceiverListingsPageState();
}

class _ReceiverListingsPageState extends State<ReceiverListingsPage> {
  // sample dataset — each item is a Map to match ReceiverDetailPage expectations
  final List<Map<String, dynamic>> _items = List.generate(8, (i) {
    // only the first item has multiple images (carousel); others have one image
    final List<String> imagesForItem = (i == 0)
        ? [
            'https://images.unsplash.com/photo-1542831371-d531d36971e6?w=1200',
            'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=1200',
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200',
          ]
        : ['https://picsum.photos/seed/item$i/800/450'];

    return {
      'id': 'list_$i',
      'title': i % 2 == 0 ? 'Bakery - Croissants' : 'Prepared - Veg Curry',
      'provider': 'Provider ${i + 1}',
      'phone': '+91 98765432${10 + i}',
      'location': 'City Center',
      'time': i % 2 == 0 ? '10:00 - 12:00' : '15:00 - 17:00',
      'quantity': '${5 + i} persons',
      'notes': i % 2 == 0 ? 'Freshly baked items' : 'Serve chilled',
      'prepared_time': '${1 + i} hours ago',
      'expiry': 'Today',
      'status': 'open', // open / accepted / declined
      'images': imagesForItem,
    };
  });

  void _setStatus(int index, String status) {
    setState(() {
      _items[index]['status'] = status;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(status == 'accepted' ? 'Accepted' : 'Declined')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const acceptGradient = [
      Color(0xFFD1C4E9),
      Color(0xFF9575CD),
      Color(0xFF512DA8),
    ];
    const declineGradient = [
      Color(0xFFFFE0B2),
      Color(0xFFFFA726),
      Color(0xFFF57C00),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All listings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.6,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 20, 20),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = _items[i];
          final status = item['status'] as String;
          final images = List<String>.from(item['images'] ?? []);

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // image area (if multiple images we show first image as preview; detail page has full carousel)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: images.isNotEmpty
                          ? Image.network(
                              images[0],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (ctx, child, prog) => prog == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.fastfood,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.fastfood,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // title / provider / pickup time
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['provider'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pickup window: ${item['time'] ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),

                  // accepted/declined indicator or action buttons
                  if (status != 'open')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: status == 'accepted'
                            ? Colors.green.shade600
                            : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status == 'accepted' ? 'Accepted' : 'Declined',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _GradientPillButton(
                            label: 'Decline',
                            gradient: declineGradient,
                            onTap: () => _setStatus(i, 'declined'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GradientPillButton(
                            label: 'Accept',
                            gradient: acceptGradient,
                            onTap: () {
                              // Only Accept navigates to details now
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ReceiverDetailPage(
                                    item: item,
                                    onConfirmPickup: () {
                                      _setStatus(i, 'accepted');
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GradientPillButton extends StatelessWidget {
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _GradientPillButton({
    Key? key,
    required this.label,
    required this.gradient,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.22),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
