// lib/features/receiver/pages/providers_closeby.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class ProvidersCloseByPage extends StatelessWidget {
  const ProvidersCloseByPage({Key? key}) : super(key: key);

  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color bgLight = Color(0xFFFDFCFE);

  @override
  Widget build(BuildContext context) {
    final providers = [
      ProviderItem('Green Earth Pantry', '~500 m away'),
      ProviderItem('Harvest Community', '~850 m away'),
      ProviderItem('Sunshine Kitchen', '~1.2 km away'),
      ProviderItem('Unity Food Bank', '~1.5 km away'),
      ProviderItem('Local Heroes Cafe', '~2.1 km away'),
    ];

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nearby Providers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(139, 92, 246, 0.08),
              Color.fromRGBO(139, 92, 246, 0.02),
            ],
          ),
        ),
        child: Column(
          children: [
            /// Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Showing 12 providers near you',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(Icons.tune, color: primaryPurple),
                ],
              ),
            ),

            /// Provider list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: providers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = providers[index];
                  return _ProviderCard(item: item);
                },
              ),
            ),

            /// View More button
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryPurple,
                  side: BorderSide(color: primaryPurple.withOpacity(0.25)),
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                onPressed: () {},
                icon: const Icon(Icons.expand_more),
                label: const Text(
                  'View More',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------------
/// Provider Card Widget
/// ----------------------------
class _ProviderCard extends StatelessWidget {
  final ProviderItem item;

  const _ProviderCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1.2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              /// Text section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.distance,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Location icon pill
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ProvidersCloseByPage.primaryPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: ProvidersCloseByPage.primaryPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Model
class ProviderItem {
  final String name;
  final String distance;

  ProviderItem(this.name, this.distance);
}
