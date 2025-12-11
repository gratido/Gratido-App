// lib/features/donor/pages/about_provider.dart
import 'package:flutter/material.dart';

class AboutProviderPage extends StatelessWidget {
  const AboutProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFFF7A18);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          children: [
            // Hero block
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(48),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade100,
                      child: const Icon(
                        Icons.fastfood,
                        size: 36,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Give food. Save waste.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'A simple platform connecting providers to local receivers — fast, safe and community-driven.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // hero image placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image, size: 38, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
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
                    'Gratido helps local kitchens, bakeries and organisations redistribute surplus food to nearby receivers quickly and safely. Our mission is to reduce food waste and support community programs.',
                    style: TextStyle(color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      _StatChip(label: 'Providers', value: '120+'),
                      SizedBox(width: 8),
                      _StatChip(label: 'Pickups/day', value: '340+'),
                      SizedBox(width: 8),
                      _StatChip(label: 'Communities', value: '24'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How it works',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  const _HowStep(
                    index: 1,
                    title: 'Post donation',
                    subtitle: 'Add details, photos and pickup window.',
                  ),
                  const _HowStep(
                    index: 2,
                    title: 'Confirm pickup',
                    subtitle: 'Track confirmations and volunteers.',
                  ),
                  const _HowStep(
                    index: 3,
                    title: 'Complete',
                    subtitle: 'Mark as picked up once collected.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
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
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SizedBox()),
                          ),
                          child: const Text('Send feedback'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
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
            const Text(
              'Version 1.0 • © Gratido 2025',
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

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
    final accent = const Color(0xFFFF7A18);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
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
