import 'package:flutter/material.dart';
import 'package:gratido_sample/features/selection_interface/selection.dart';
import 'introcard1.dart';
import 'introcard2.dart';
import 'introcard3.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int page = 0;

  void _skip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SelectionScreen()),
      (_) => false,
    );
  }

  void _next() {
    if (page == 2) {
      _skip();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => page = i),
            children: [
              IntroCard1(onSkip: _skip, onNext: _next),
              IntroCard2(onSkip: _skip, onNext: _next),
              IntroCard3(onSkip: _skip, onNext: _next),
            ],
          ),

          // 🔵 DOTS
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: page == i
                        ? const Color(0xFF8B5CF6)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
