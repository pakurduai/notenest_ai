import 'package:flutter/material.dart';

/// Pixel-perfect Onboarding Page rendering the official design image edge-to-edge
/// with interactive tap areas for Skip and Next navigation.
class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final int pageIndex;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.pageIndex,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070415),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Official 3D Design Image (Pixel-Perfect 100% Match)
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    'Image asset missing: $imagePath',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),

            // 2. Interactive Bottom Tap Areas for Skip & Next
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      // Left Tap Area: Skip -> Home Screen
                      Expanded(
                        flex: 4,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onSkip,
                          child: const SizedBox.expand(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right Tap Area: Next -> Screen 2 / Home Screen
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onNext,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ],
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
