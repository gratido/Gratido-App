// lib/features/receiver/pages/about_page.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  // Replace these with your actual asset paths / network urls
  static const String _logoAsset = 'assets/images/team_grid.svg';
  static const String _heroAsset = 'assets/images/logo.svg';

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF6A4CFF); // use your app accent if different
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'About',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          children: [
            // Hero block (logo + tagline)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // logo circle
                  ClipRRect(
                    borderRadius: BorderRadius.circular(48),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade100,
                      child: Image.asset(
                        _logoAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fastfood,
                          size: 36,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Receive kindness. Deliver hope.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'A community-driven platform connecting surplus food providers to organisations in need.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Hero image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                _heroAsset,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 36),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Main white content card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Gratido',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Gratido connects volunteers, local kitchens, bakeries and organisations with receivers through a fast and simple app. Our focus is reducing waste and feeding communities — quickly matching available food with organisations that can use it.',
                    style: TextStyle(color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 12),

                  // Stats row (optional)
                  Row(
                    children: [
                      _StatChip(label: 'Providers', value: '120+'),
                      const SizedBox(width: 8),
                      _StatChip(label: 'Pickups/day', value: '340+'),
                      const SizedBox(width: 8),
                      _StatChip(label: 'Communities', value: '24'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mission & Vision row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Mission',
                    text:
                        'Make surplus food accessible to local organisations and communities via a dependable platform for timely redistribution.',
                    icon: Icons.flag,
                    accent: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    title: 'Vision',
                    text:
                        'A future where surplus food never goes to waste and local networks thrive.',
                    icon: Icons.visibility,
                    accent: accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Values
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Our values',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _ValueChip(label: 'Safety'),
                      _ValueChip(label: 'Freshness'),
                      _ValueChip(label: 'Fairness'),
                      _ValueChip(label: 'Community'),
                      _ValueChip(label: 'Transparency'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // How it works (3 steps)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'How it works',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 12),
                  _HowStep(
                    index: 1,
                    title: 'Browse listings',
                    subtitle: 'See nearby food items posted by providers.',
                  ),
                  _HowStep(
                    index: 2,
                    title: 'Accept what you can pick',
                    subtitle: 'Tap Accept to reserve the item.',
                  ),
                  _HowStep(
                    index: 3,
                    title: 'Confirm pickup',
                    subtitle: 'Track and confirm pickup in-app.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Contact / CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get in touch',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text('Need help or want to partner with us?'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // open feedback form
                            Navigator.of(
                              context,
                            ).pushNamed('/feedback'); // adjust route
                          },
                          child: const Text('Send feedback'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          // open mail or contact page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                        ),
                        child: const Text(
                          'Contact us',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Footer small text
            const Text(
              'Version 1.0 • © Gratido 2025',
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// small stat chip widget
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// info card used for mission/vision
class _InfoCard extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;
  final Color accent;
  const _InfoCard({
    required this.title,
    required this.text,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// simple value chip
class _ValueChip extends StatelessWidget {
  final String label;
  const _ValueChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade100,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// how it works step
class _HowStep extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  const _HowStep({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF6A4CFF);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accent.withOpacity(0.14),
            child: Text(
              '$index',
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
