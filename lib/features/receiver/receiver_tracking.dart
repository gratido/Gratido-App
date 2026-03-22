// lib/features/receiver/receiver_tracking.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'models/food_item.dart';

class ReceiverTrackingPage extends StatelessWidget {
  final FoodItem item;

  const ReceiverTrackingPage({super.key, required this.item});

  static const Color primary = Color(0xFF7642F0);
  static const Color bgLight = Color(0xFFF6F6F8);

  @override
  Widget build(BuildContext context) {
    final LatLng donationLocation = LatLng(item.latitude, item.longitude);

    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          /// ================= MAP SECTION =================
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: donationLocation,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.gratido.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: donationLocation,
                      width: 60,
                      height: 60,
                      child: _PulsingPin(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// ================= HEADER =================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Track Donation",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),

          /// ================= BOTTOM SHEET =================
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.40,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ETA
                    const Text(
                      "ESTIMATED ARRIVAL",
                      style: TextStyle(
                        fontSize: 12,
                        color: primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "15 Minutes",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// STATUS STEPPER
                    _StatusStepper(),

                    const SizedBox(height: 30),

                    /// DONATION DETAILS
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "DONATION DETAILS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.store, color: primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Divider(height: 24),
                          _detailRow(item.category, item.quantity),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String name, String qty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name),
        Text(
          "x$qty",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// ================= STATUS STEPPER =================

class _StatusStepper extends StatelessWidget {
  const _StatusStepper();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _StepRow(
          title: "Donation Accepted",
          subtitle: "Receiver has accepted",
          active: true,
        ),
        _StepRow(
          title: "On the Way",
          subtitle: "Heading to pickup",
        ),
        _StepRow(
          title: "Picked Up",
          subtitle: "Donation completed",
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool active;

  const _StepRow({
    required this.title,
    required this.subtitle,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 10,
        backgroundColor:
            active ? ReceiverTrackingPage.primary : Colors.grey.shade300,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: active ? ReceiverTrackingPage.primary : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _PulsingPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: ReceiverTrackingPage.primary.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: CircleAvatar(
          radius: 6,
          backgroundColor: ReceiverTrackingPage.primary,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon),
      ),
    );
  }
}
