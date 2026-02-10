// lib/features/receiver/pages/history_page.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  static const Color primaryPurple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final historyItems = [
      HistoryItem(
        title: 'Bakery - Fresh Croissants',
        time: '2h ago',
        status: HistoryStatus.completed,
      ),
      HistoryItem(
        title: 'Greens - Mixed Salads',
        time: '5h ago',
        status: HistoryStatus.completed,
      ),
      HistoryItem(
        title: 'Village Bread - Baguettes',
        time: 'Yesterday',
        status: HistoryStatus.completed,
      ),
      HistoryItem(
        title: 'Fruit Stand - Assorted',
        time: '2 days ago',
        status: HistoryStatus.canceled,
      ),
      HistoryItem(
        title: 'Deli House - Roast Chicken',
        time: '3 days ago',
        status: HistoryStatus.completed,
      ),
      HistoryItem(
        title: 'Curry Express - Samosas',
        time: '4 days ago',
        status: HistoryStatus.canceledMuted,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFE),
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...historyItems.map((item) => _HistoryCard(item: item)),
            const SizedBox(height: 32),

            /// End of history
            Column(
              children: const [
                SizedBox(
                  width: 36,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'END OF HISTORY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// History Card
/// ------------------------------------------------------------
class _HistoryCard extends StatelessWidget {
  final HistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isCompleted = item.status == HistoryStatus.completed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
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
                /// Icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: item.iconColor,
                  ),
                ),
                const SizedBox(width: 12),

                /// Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: item.statusDotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.statusLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isCompleted
                                  ? Colors.grey
                                  : item.statusTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Models & Enums
/// ------------------------------------------------------------
enum HistoryStatus {
  completed,
  canceled,
  canceledMuted,
}

class HistoryItem {
  final String title;
  final String time;
  final HistoryStatus status;

  HistoryItem({
    required this.title,
    required this.time,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case HistoryStatus.completed:
        return 'Completed';
      case HistoryStatus.canceled:
      case HistoryStatus.canceledMuted:
        return 'Canceled';
    }
  }

  Color get statusDotColor {
    switch (status) {
      case HistoryStatus.completed:
        return Colors.green;
      case HistoryStatus.canceled:
        return Colors.red;
      case HistoryStatus.canceledMuted:
        return Colors.grey;
    }
  }

  Color get statusTextColor {
    switch (status) {
      case HistoryStatus.completed:
        return Colors.grey;
      case HistoryStatus.canceled:
        return Colors.red;
      case HistoryStatus.canceledMuted:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (status) {
      case HistoryStatus.completed:
        return Icons.restaurant;
      case HistoryStatus.canceled:
      case HistoryStatus.canceledMuted:
        return Icons.block;
    }
  }

  Color get iconBg {
    switch (status) {
      case HistoryStatus.completed:
        return const Color(0xFFEDE9FE);
      case HistoryStatus.canceled:
      case HistoryStatus.canceledMuted:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get iconColor {
    switch (status) {
      case HistoryStatus.completed:
        return HistoryPage.primaryPurple;
      case HistoryStatus.canceled:
      case HistoryStatus.canceledMuted:
        return Colors.grey;
    }
  }
}
