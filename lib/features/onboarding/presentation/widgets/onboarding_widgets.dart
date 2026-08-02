import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Page Indicator Dots (● ○ ○)
// ─────────────────────────────────────────────

/// Animated page indicator dots matching reference design pixel-perfect.
class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          width: isActive ? 12.0 : 10.0,
          height: isActive ? 12.0 : 10.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF8B2DF0), Color(0xFF00C6FF)],
                  )
                : null,
            color: isActive ? null : Colors.transparent,
            border: isActive
                ? null
                : Border.all(color: const Color(0xFF382363), width: 1.5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B2DF0).withValues(alpha: 0.6),
                      blurRadius: 10.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF00C6FF).withValues(alpha: 0.4),
                      blurRadius: 8.0,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Sparkle Line Divider
// ─────────────────────────────────────────────

/// Glowing horizontal divider with a center 4-point sparkle star ✦.
class OnboardingSparkleDivider extends StatelessWidget {
  const OnboardingSparkleDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 1.2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xFF6B4DBA)],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 14.0,
              color: Color(0xFF8B2DF0),
            ),
          ),
          Expanded(
            child: Container(
              height: 1.2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B4DBA), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Primary Gradient Button (Next ->)
// ─────────────────────────────────────────────

/// Primary gradient pill button ("Next →" / "Get Started →").
class OnboardingPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(27.0),
        child: Container(
          height: 54.0,
          constraints: const BoxConstraints(minWidth: 155.0),
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27.0),
            gradient: const LinearGradient(
              colors: [Color(0xFF8A2BE2), Color(0xFF00C6FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C6FF).withValues(alpha: 0.4),
                blurRadius: 20.0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFF8A2BE2).withValues(alpha: 0.45),
                blurRadius: 16.0,
                offset: const Offset(-2, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 10.0),
                Icon(icon, color: Colors.white, size: 20.0),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Secondary Outline Button (Skip)
// ─────────────────────────────────────────────

/// Secondary outline pill button ("Skip").
class OnboardingSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const OnboardingSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(27.0),
        child: Container(
          height: 54.0,
          constraints: const BoxConstraints(minWidth: 130.0),
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27.0),
            border: Border.all(color: const Color(0xFF2E1C59), width: 1.5),
            color: const Color(0xFF0F0827).withValues(alpha: 0.5),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB8B4DB),
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Title Widget with Highlight
// ─────────────────────────────────────────────

/// Title text matching reference design.
class OnboardingTitleWidget extends StatelessWidget {
  final String prefix;
  final String highlight;

  const OnboardingTitleWidget({
    super.key,
    required this.prefix,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          prefix.trimRight(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.15,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4.0),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF9D4EDD), Color(0xFF38BDF8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            highlight,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 38.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -0.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Screen 1 3D Illustration Widget (Notebook + Pen + Floating Cards)
// ─────────────────────────────────────────────

class RobotIllustrationWidget extends StatelessWidget {
  const RobotIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 330,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background Sparkle Stars ✦
          const Positioned(top: 15, left: 40, child: _SparkleStar(size: 14, color: Color(0xFF9D4EDD))),
          const Positioned(top: 30, right: 50, child: _SparkleStar(size: 16, color: Color(0xFF38BDF8))),
          const Positioned(bottom: 60, left: 15, child: _SparkleStar(size: 12, color: Color(0xFF38BDF8))),
          const Positioned(bottom: 80, right: 20, child: _SparkleStar(size: 14, color: Color(0xFF9D4EDD))),

          // Neon Glow Base at bottom of Notebook
          Positioned(
            bottom: 30,
            child: Container(
              width: 250,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B2DF0).withValues(alpha: 0.75),
                    blurRadius: 70,
                    spreadRadius: 25,
                  ),
                  BoxShadow(
                    color: const Color(0xFF00C6FF).withValues(alpha: 0.5),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
            ),
          ),

          // 3D Notebook Back Page Shadow Layer
          Positioned(
            top: 32,
            child: Container(
              width: 205,
              height: 245,
              decoration: BoxDecoration(
                color: const Color(0xFFDCD8ED),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          // Main 3D Notebook Front Cover
          Positioned(
            top: 28,
            child: Container(
              width: 202,
              height: 242,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F8FC),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: const Color(0xFF8B2DF0).withValues(alpha: 0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Left Edge Spiral Ring Bindings
                  Positioned(
                    left: -2,
                    top: 18,
                    bottom: 18,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(9, (index) {
                        return Container(
                          width: 16,
                          height: 9,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2D264A), Color(0xFF140F2D)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(4.5),
                              bottomRight: Radius.circular(4.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  // Top Right Bookmark Ribbon
                  Positioned(
                    top: 0,
                    right: 22,
                    child: Container(
                      width: 24,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8A2BE2),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8A2BE2).withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Notebook Cover Branding & Content
                  Positioned.fill(
                    left: 28,
                    right: 18,
                    top: 38,
                    bottom: 24,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Official Monogram Logo
                        Image.asset(
                          'assets/branding/monogram.png',
                          width: 54,
                          height: 54,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.eco_rounded,
                            size: 44,
                            color: Color(0xFF8A2BE2),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'NoteNest',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1139),
                            letterSpacing: -0.4,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF8A2BE2), Color(0xFF00C6FF)],
                          ).createShader(bounds),
                          child: const Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Horizontal text line placeholders
                        Container(
                          width: 110,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4DFEE),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 85,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4DFEE),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fountain Pen resting next to notebook
          Positioned(
            right: 48,
            top: 75,
            child: Transform.rotate(
              angle: 0.32,
              child: Container(
                width: 18,
                height: 125,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF261356), Color(0xFF0C0521)],
                  ),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1D1EA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(9),
                          topRight: Radius.circular(9),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 18,
                      width: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E5F8),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4.5),
                          bottomRight: Radius.circular(4.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Card Top Left: Purple Speech Bubble (...)
          Positioned(
            left: 25,
            top: 45,
            child: _buildFloating3DCard(
              icon: Icons.more_horiz_rounded,
              gradientColors: const [Color(0xFF9D4EDD), Color(0xFF6C5CE7)],
              size: 46,
            ),
          ),

          // Floating Card Top Right: Purple AI Badge
          Positioned(
            right: 25,
            top: 40,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8A2BE2), Color(0xFF6C5CE7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A2BE2).withValues(alpha: 0.55),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'AI ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),

          // Floating Card Mid Left: Blue Document Icon Card
          Positioned(
            left: 8,
            top: 115,
            child: _buildFloating3DCard(
              icon: Icons.article_rounded,
              gradientColors: const [Color(0xFF2563EB), Color(0xFF3B82F6)],
              size: 48,
            ),
          ),

          // Floating Card Mid Right: Blue Mic Recording Card
          Positioned(
            right: 8,
            top: 120,
            child: _buildFloating3DCard(
              icon: Icons.mic_rounded,
              gradientColors: const [Color(0xFF2563EB), Color(0xFF00C6FF)],
              size: 46,
            ),
          ),

          // Floating Plant Pot Bottom Left
          Positioned(
            left: 18,
            bottom: 25,
            child: Column(
              children: [
                const Icon(Icons.eco_rounded, size: 32, color: Color(0xFF9D4EDD)),
                Container(
                  width: 36,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAE7F8),
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Checklist Card Bottom Right
          Positioned(
            right: 12,
            bottom: 30,
            child: Container(
              width: 115,
              height: 82,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFFC),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(3, (index) {
                  return Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(4.5),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        width: 60,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCDC6E8),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFloating3DCard({
    required IconData icon,
    required List<Color> gradientColors,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.5),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }
}

// ─────────────────────────────────────────────
// Sparkle Star Shape Helper
// ─────────────────────────────────────────────

class _SparkleStar extends StatelessWidget {
  final double size;
  final Color color;

  const _SparkleStar({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.auto_awesome_rounded, size: size, color: color);
  }
}

// ─────────────────────────────────────────────
// Screen 2 3D Illustration Widget (Phone + Categories + Checklist)
// ─────────────────────────────────────────────

class BrainIllustrationWidget extends StatelessWidget {
  const BrainIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 330,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background Sparkles
          const Positioned(top: 20, left: 35, child: _SparkleStar(size: 14, color: Color(0xFF38BDF8))),
          const Positioned(top: 40, right: 40, child: _SparkleStar(size: 16, color: Color(0xFF9D4EDD))),

          // Neon Glow Base
          Positioned(
            bottom: 30,
            child: Container(
              width: 250,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B2DF0).withValues(alpha: 0.75),
                    blurRadius: 70,
                    spreadRadius: 25,
                  ),
                  BoxShadow(
                    color: const Color(0xFF00C6FF).withValues(alpha: 0.5),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
            ),
          ),

          // Main 3D Phone Screen
          Positioned(
            top: 25,
            child: Container(
              width: 185,
              height: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF130A2A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF4C368D).withValues(alpha: 0.7),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF271A4D),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded, size: 15, color: Color(0xFFB8B4DB)),
                        SizedBox(width: 6),
                        Text(
                          'Search',
                          style: TextStyle(color: Color(0xFFB8B4DB), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'All Notes',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),

                  // Category 1: Purple
                  Container(
                    height: 40,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF8A2BE2), Color(0xFF6C5CE7)]),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 65,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                        const Icon(Icons.push_pin_rounded, size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),

                  // Category 2: Cyan Checklist
                  Container(
                    height: 40,
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(2, (i) {
                        return Row(
                          children: [
                            const Icon(Icons.check_rounded, size: 11, color: Colors.white),
                            const SizedBox(width: 5),
                            Container(
                              width: 55,
                              height: 3.5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 7),

                  // Category 3: Pink
                  Container(
                    height: 32,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFD946EF), Color(0xFFA855F7)]),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  const SizedBox(height: 7),

                  // Category 4: Orange
                  Container(
                    height: 26,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFFBBF24)]),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Cards Around Phone
          Positioned(
            left: 15,
            top: 50,
            child: RobotIllustrationWidget._buildFloating3DCard(
              icon: Icons.folder_rounded,
              gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              size: 46,
            ),
          ),
          Positioned(
            right: 18,
            top: 45,
            child: RobotIllustrationWidget._buildFloating3DCard(
              icon: Icons.notifications_rounded,
              gradientColors: const [Color(0xFF8A2BE2), Color(0xFFA855F7)],
              size: 44,
            ),
          ),
          Positioned(
            left: 12,
            bottom: 65,
            child: RobotIllustrationWidget._buildFloating3DCard(
              icon: Icons.search_rounded,
              gradientColors: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
              size: 46,
            ),
          ),

          // Floating Checklist Card Bottom Right
          Positioned(
            right: 10,
            bottom: 40,
            child: Container(
              width: 115,
              height: 105,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF4EFFC),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) {
                  return Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A2BE2),
                          borderRadius: BorderRadius.circular(4.5),
                        ),
                        child: const Icon(Icons.check_rounded, size: 11, color: Colors.white),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        width: 56,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCDC6E8),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Screen 3 3D Illustration Widget (Glowing Magic Notebook)
// ─────────────────────────────────────────────

class NotebookIllustrationWidget extends StatelessWidget {
  const NotebookIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 330,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [

          // Neon Glow Base
          Positioned(
            bottom: 30,
            child: Container(
              width: 250,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B2DF0).withValues(alpha: 0.8),
                    blurRadius: 75,
                    spreadRadius: 25,
                  ),
                  BoxShadow(
                    color: const Color(0xFF00C6FF).withValues(alpha: 0.55),
                    blurRadius: 55,
                    spreadRadius: 15,
                  ),
                ],
              ),
            ),
          ),

          // Central 3D AI Card
          Positioned(
            top: 25,
            child: Container(
              width: 200,
              height: 240,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8A2BE2), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/branding/monogram.png',
                    width: 64,
                    height: 64,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.auto_awesome_rounded,
                      size: 55,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'AI Magic Notes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Smart & Instant',
                    style: TextStyle(
                      color: Color(0xFFE9D5FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Badges
          Positioned(
            left: 15,
            top: 45,
            child: RobotIllustrationWidget._buildFloating3DCard(
              icon: Icons.psychology_rounded,
              gradientColors: const [Color(0xFF00C6FF), Color(0xFF0072FF)],
              size: 48,
            ),
          ),
          Positioned(
            right: 15,
            top: 45,
            child: RobotIllustrationWidget._buildFloating3DCard(
              icon: Icons.bolt_rounded,
              gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
              size: 48,
            ),
          ),
          Positioned(
            left: 18,
            bottom: 45,
            child: RobotIllustrationWidget._buildFloating3DCard(
              icon: Icons.auto_awesome_rounded,
              gradientColors: const [Color(0xFFEC4899), Color(0xFF8B5CF6)],
              size: 48,
            ),
          ),
          Positioned(
            right: 18,
            bottom: 45,
            child: RobotIllustrationWidget._buildFloating3DCard(
              icon: Icons.verified_rounded,
              gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}
