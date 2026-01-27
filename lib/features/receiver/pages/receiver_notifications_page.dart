import 'package:flutter/material.dart';

const Color primary = Color(0xFF6E5CD6);

class ReceiverNotificationsPage extends StatelessWidget {
  const ReceiverNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: const [
          _NotificationTile(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            title: "Pickup confirmed",
            message:
                "Your request for Vegetable Biryani has been accepted. Pickup is scheduled for today at 9:00 PM.",
            time: "2 min ago",
          ),
          _NotificationTile(
            icon: Icons.access_time,
            iconColor: primary,
            title: "Pickup reminder",
            message:
                "Reminder: Please reach the pickup location within the next 30 minutes.",
            time: "30 min ago",
          ),
          _NotificationTile(
            icon: Icons.info_outline,
            iconColor: Colors.orange,
            title: "New food available nearby",
            message:
                "A donor near Downtown Seattle has listed fresh food items.",
            time: "1 hr ago",
          ),
          _NotificationTile(
            icon: Icons.cancel_outlined,
            iconColor: Colors.redAccent,
            title: "Request declined",
            message:
                "Unfortunately, your request for Evening Snacks was declined.",
            time: "Yesterday",
          ),
        ],
      ),
    );
  }
}

// ================= TILE =================

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
