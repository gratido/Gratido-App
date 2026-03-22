// lib/features/receiver/pages/pickup_status_page.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class PickupStatusPage extends StatelessWidget {
  const PickupStatusPage({Key? key}) : super(key: key);

  static const Color primary = Color(0xFF7642F0);
  static const Color bgLight = Color(0xFFF6F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: Stack(
              children: [
                Image.network(
                  'https://maps.googleapis.com/maps/api/staticmap'
                  '?center=San+Francisco&zoom=12&size=800x800',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(246, 246, 248, 0.1),
                        Color.fromRGBO(246, 246, 248, 1),
                      ],
                    ),
                  ),
                ),
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
                          'Track Donation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: MediaQuery.of(context).size.width / 2 - 32,
                  child: const _PulsingPin(),
                ),
              ],
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.40,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    SizedBox(height: 16),
                    Text(
                      'ESTIMATED ARRIVAL',
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '15 Minutes',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 28),
                    _StatusStepper(),
                    SizedBox(height: 24),
                    _DriverCard(),
                    SizedBox(height: 24),
                    _DonationDetails(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// STATUS STEPPER
class _StatusStepper extends StatelessWidget {
  const _StatusStepper();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _step(true, 'Donation Accepted', '10:30 AM • Restaurant confirmed',
            isLast: false),
        _step(true, 'On the Way', 'Driver is heading to destination',
            isLast: false, isActive: true),
        _step(false, 'Picked Up', 'Estimated 10:55 AM', isLast: true),
      ],
    );
  }

  Widget _step(
    bool done,
    String title,
    String sub, {
    required bool isLast,
    bool isActive = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? PickupStatusPage.primary : Colors.white,
                border: Border.all(
                  color: done ? PickupStatusPage.primary : Colors.grey.shade300,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: done ? PickupStatusPage.primary : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isActive ? 18 : 15,
                  color: isActive ? PickupStatusPage.primary : Colors.black87,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        )
      ],
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/women/44.jpg',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sarah J.', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('⭐ 4.9 • Toyota Prius',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationDetails extends StatelessWidget {
  const _DonationDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DONATION DETAILS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              _DetailRow('Assorted Pastries (Box)', 'x2'),
              SizedBox(height: 8),
              _DetailRow('Sandwich Platter', 'x1'),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String name;
  final String qty;

  const _DetailRow(this.name, this.qty);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name),
        Text(qty, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _PulsingPin extends StatelessWidget {
  const _PulsingPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: PickupStatusPage.primary.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: CircleAvatar(
          radius: 6,
          backgroundColor: PickupStatusPage.primary,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
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
