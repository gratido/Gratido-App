import 'package:flutter/material.dart';
import 'onboarding_widgets.dart';

class IntroCard1 extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const IntroCard1({
    super.key,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌈 Background (same as before)
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.8,
              colors: [
                Color.fromARGB(255, 224, 205, 245),
                Color(0xFFF3F4F6),
              ],
            ),
          ),
        ),

        // ⏭ Skip (UNCHANGED)
        Positioned(
          top: 36,
          right: 24,
          child: TextButton(
            onPressed: onSkip,
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ),

        // 🔹 CONTENT (EXACT SAME STRUCTURE AS INTROCARD1)
        Column(
          children: [
            const SizedBox(height: 120), // ⬅ pushes content down from Skip

            // 📸 Polaroid image (NO glow)
            polaroidImage('assets/images/intro1.png'),

            const SizedBox(height: 32),

            // 🔵 Circle icons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(0, 18),
                  child: circleIcon(Icons.map, Colors.green, 56),
                ),
                const SizedBox(width: 20),
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: circleIcon(
                    Icons.recycling,
                    Colors.orange,
                    72,
                    glow: true,
                  ),
                ),
                const SizedBox(width: 20),
                Transform.translate(
                  offset: const Offset(0, 18),
                  child: circleIcon(
                    Icons.volunteer_activism,
                    const Color(0xFF8B5CF6),
                    56,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 📝 Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Reduce Waste,\n',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                        color: Color(0xFF111827),
                      ),
                    ),
                    TextSpan(
                      text: 'Share Food',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // 📝 Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Connect with those in need and make a positive impact on your community by donating surplus food.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),

            const Spacer(),

            // 🔘 Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSkip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Start Exploring',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: onNext,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF8B5CF6),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: Color(0x668B5CF6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 72),
          ],
        ),
      ],
    );
  }
}
