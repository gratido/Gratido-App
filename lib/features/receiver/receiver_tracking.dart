// lib/features/receiver/receiver_tracking.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class ReceiverTrackingPage extends StatelessWidget {
  const ReceiverTrackingPage({Key? key}) : super(key: key);

  Widget _stepTile(String time, String title, bool done) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: done ? Colors.green : Colors.grey.shade300,
              child: done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            Container(width: 2, height: 48, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: done ? Colors.black : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'time': 'Now', 'title': 'Receiver confirmed pickup', 'done': true},
      {'time': 'N minutes', 'title': 'Volunteer on the way', 'done': false},
      {'time': 'Later', 'title': 'Picked up by volunteer', 'done': false},
      {'time': 'After', 'title': 'Delivered to receiver center', 'done': false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.6,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pickup status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, i) {
                  final s = steps[i];
                  return _stepTile(
                    s['time'] as String,
                    s['title'] as String,
                    s['done'] as bool,
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This is a placeholder tracking action'),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Center(
                child: Text(
                  'Open live tracking (placeholder)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
