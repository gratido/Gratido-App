// lib/features/receiver/receiver_tracking.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class ReceiverTrackingPage extends StatelessWidget {
  const ReceiverTrackingPage({Key? key}) : super(key: key);

  static const Color primary = Color(0xFF7642F0);
  static const Color bgLight = Color(0xFFF6F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          /// MAP SECTION
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: Stack(
              children: [
                /// Map image (replace later with GoogleMap)
                Image.network(
                  'https://maps.googleapis.com/maps/api/staticmap'
                  '?center=San+Francisco&zoom=12&size=800x800',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),

                /// Gradient overlay
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

                /// Header
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

                /// Pulsing pin
                Positioned(
                  bottom: 50,
                  left: MediaQuery.of(context).size.width / 2 - 32,
                  child: _PulsingPin(),
                ),
              ],
            ),
          ),

          /// BOTTOM SHEET
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
                  children: [
                    /// Drag handle
                    Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    /// ETA
                    const Text(
                      'ESTIMATED ARRIVAL',
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '15 Minutes',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// STATUS STEPPER
                    const _StatusStepper(),

                    const SizedBox(height: 24),

                    /// DRIVER CARD
                    _DriverCard(),

                    const SizedBox(height: 24),

                    /// DONATION DETAILS
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

/// ------------------------------------------------------------
/// STATUS STEPPER
/// ------------------------------------------------------------
class _StatusStepper extends StatelessWidget {
  const _StatusStepper();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _stepCompleted(
          title: 'Donation Accepted',
          subtitle: '10:30 AM • Restaurant confirmed',
        ),
        _stepActive(
          title: 'On the Way',
          subtitle: 'Driver is heading to destination',
        ),
        _stepPending(
          title: 'Picked Up',
          subtitle: 'Estimated 10:55 AM',
        ),
      ],
    );
  }

  Widget _stepCompleted({required String title, required String subtitle}) {
    return _StepRow(
      indicator: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: ReceiverTrackingPage.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      ),
      lineColor: ReceiverTrackingPage.primary,
      title: title,
      subtitle: subtitle,
      faded: true,
    );
  }

  Widget _stepActive({required String title, required String subtitle}) {
    return _StepRow(
      indicator: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ReceiverTrackingPage.primary, width: 2),
        ),
        child: const Center(
          child: CircleAvatar(
            radius: 4,
            backgroundColor: ReceiverTrackingPage.primary,
          ),
        ),
      ),
      lineColor: Colors.grey.shade300,
      title: title,
      subtitle: subtitle,
      active: true,
    );
  }

  Widget _stepPending({required String title, required String subtitle}) {
    return _StepRow(
      indicator: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
      ),
      showLine: false,
      title: title,
      subtitle: subtitle,
      faded: true,
    );
  }
}

class _StepRow extends StatelessWidget {
  final Widget indicator;
  final Color? lineColor;
  final String title;
  final String subtitle;
  final bool faded;
  final bool active;
  final bool showLine;

  const _StepRow({
    required this.indicator,
    this.lineColor,
    required this.title,
    required this.subtitle,
    this.faded = false,
    this.active = false,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            indicator,
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: lineColor ?? Colors.transparent,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Opacity(
            opacity: faded ? 0.6 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: active ? 18 : 15,
                    fontWeight: FontWeight.bold,
                    color: active ? ReceiverTrackingPage.primary : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// DRIVER CARD
/// ------------------------------------------------------------
class _DriverCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/women/44.jpg',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sarah J.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '⭐ 4.9 • Toyota Prius',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ReceiverTrackingPage.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.call, color: ReceiverTrackingPage.primary),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// DONATION DETAILS
/// ------------------------------------------------------------
class _DonationDetails extends StatelessWidget {
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
          child: Column(
            children: const [
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
        Text(name, style: const TextStyle(fontSize: 14)),
        Text(qty, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// MAP PIN
/// ------------------------------------------------------------
class _PulsingPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
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

/// ------------------------------------------------------------
/// HEADER BUTTON
/// ------------------------------------------------------------
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
