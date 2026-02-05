// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import '../donor/auth/donor_registration.dart';
import '../receiver/auth/receiver_registration.dart';

/// --------------------------------------------------------
/// DONOR LOCATION POPUP (UPDATED UI + COPY ONLY)
/// --------------------------------------------------------
/// --------------------------------------------------------
/// DONOR LOCATION POPUP — FINAL VERSION
/// --------------------------------------------------------
/// --------------------------------------------------------
/// DONOR LOCATION POPUP — COMPACT VERSION
/// --------------------------------------------------------
Future<Object?> showAnimatedLocationPopup(BuildContext context) async {
  const Color primaryPurple = Color(0xFF7C3AED);
  const Color secondaryGrey = Color(0xFF6B7280);

  final double dialogWidth = MediaQuery.of(context).size.width * 0.82;

  return await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (context, anim, __, ___) {
      return Transform.scale(
        scale: 0.96 + (anim.value * 0.04),
        child: Opacity(
          opacity: anim.value,
          child: Center(
            child: Container(
              width: dialogWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.22),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// ICON WITH WIDER, SOFTER GLOW
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPurple
                                        .withOpacity(0.34), // ⬅️ +5%
                                    blurRadius: 70, // ⬅️ wider fade
                                    spreadRadius: 20, // ⬅️ reaches sides
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryPurple.withOpacity(0.14),
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              size: 30,
                              color: primaryPurple,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Enable Location',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Allow location so nearby receivers\n'
                        'can find your donation.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              height: 1.35,
                              color: secondaryGrey,
                            ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            'Enable Location',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Maybe Later',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: secondaryGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  // 🎨 COLORS
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color wordPurple = Color(0xFF5B49C1);
  static const Color softBlack = Color.fromARGB(255, 34, 34, 36);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F3FF),
              Color(0xFFE9D5FF),
              Color(0xFFDDD0FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// TITLE
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(
                            text: 'Pick Your Way to\n',
                            style: TextStyle(color: softBlack),
                          ),
                          TextSpan(
                            text: 'Contribute',
                            style: TextStyle(color: primaryPurple),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      '"Start your journey of kindness"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14, // ⬅️ slightly smaller
                        fontStyle: FontStyle.italic, // ⬅️ italic
                        color: Color.fromARGB(255, 67, 72, 81), // ⬅️ dark grey
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// SHARE
                    _buildGlassCard(
                      icon: Icons.volunteer_activism_outlined,
                      isShare: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DonorRegistration(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    /// RECEIVE
                    _buildGlassCard(
                      icon: Icons.inventory_2_outlined,
                      isShare: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReceiverRegistration(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------------------------------------
  /// GLASS CARD (UNCHANGED)
  /// -------------------------------------------------
  Widget _buildGlassCard({
    required IconData icon,
    required bool isShare,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: primaryPurple.withOpacity(0.30),
                blurRadius: 40,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Color(0xFFF3E8FF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.40),
                            blurRadius: 26,
                            spreadRadius: 2,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 34,
                        color: primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 18),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: isShare ? 'Share ' : 'Receive ',
                            style: const TextStyle(color: wordPurple),
                          ),
                          const TextSpan(
                            text: 'Kindness',
                            style: TextStyle(color: softBlack),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isShare
                          ? 'Offer food to those in need'
                          : 'Collect food for your organization',
                      textAlign: TextAlign.center,
                      maxLines: 1, // ⬅️ force single line
                      overflow: TextOverflow.ellipsis, // ⬅️ safety net
                      style: const TextStyle(
                        fontSize: 12, // ⬅️ same size as before

                        color: Color.fromARGB(255, 67, 72, 81), // ⬅️ dark grey
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
