// lib/features/donor/donor_pickup_status_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DonorPickupStatusPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  const DonorPickupStatusPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  static const Color primary = Color(0xFF7642F0);
  static const Color bgLight = Color(0xFFF6F6F8);

  @override
  Widget build(BuildContext context) {
    final LatLng donorLocation = LatLng(latitude, longitude);

    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          /// MAP
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: donorLocation,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: donorLocation,
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.location_on,
                        color: primary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// HEADER
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    "Pickup Progress",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),

          /// BOTTOM SHEET
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.40,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: const [
                  Text(
                    "RECEIVER EN ROUTE",
                    style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "10–15 Minutes",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(8),
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon),
      ),
    );
  }
}
