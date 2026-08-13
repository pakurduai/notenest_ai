import 'package:flutter/material.dart';

/// Ambient Soft Gradient Background Glows Widget
/// Renders moving/pulsing radial pastel purple & cyan gradient light orbs in the background.
class AmbientBackgroundGlowWidget extends StatefulWidget {
  /// Global toggle for ambient glow lights
  static bool isGlowEnabled = true;

  final Widget child;

  const AmbientBackgroundGlowWidget({
    super.key,
    required this.child,
  });

  @override
  State<AmbientBackgroundGlowWidget> createState() => _AmbientBackgroundGlowWidgetState();
}

class _AmbientBackgroundGlowWidgetState extends State<AmbientBackgroundGlowWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AmbientBackgroundGlowWidget.isGlowEnabled) {
      return Container(
        color: const Color(0xFFF6F5FA),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final animValue = _controller.value;
        return Stack(
          children: [
            // Background Base Color
            Positioned.fill(
              child: Container(
                color: const Color(0xFFF6F5FA),
              ),
            ),

            // Top Left Ambient Purple Light Orb
            Positioned(
              top: -60 + (animValue * 20),
              left: -40 + (animValue * 30),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED).withValues(alpha: 0.12 + (animValue * 0.05)),
                      const Color(0xFFC084FC).withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Top Right Ambient Cyan/Blue Light Orb
            Positioned(
              top: 100 - (animValue * 25),
              right: -50 - (animValue * 20),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00C6FF).withValues(alpha: 0.10 + (animValue * 0.04)),
                      const Color(0xFF6366F1).withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Middle Ambient Soft Glow
            Positioned(
              top: 380 + (animValue * 15),
              left: 60 - (animValue * 15),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFA855F7).withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Foreground Content
            if (child != null) child,
          ],
        );
      },
    );
  }
}
