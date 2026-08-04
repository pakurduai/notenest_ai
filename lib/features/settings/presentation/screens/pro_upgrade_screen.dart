import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pro Upgrade Screen — Matching NoteNest AI design aesthetic
class ProUpgradeScreen extends StatefulWidget {
  const ProUpgradeScreen({super.key});

  @override
  State<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends State<ProUpgradeScreen> {
  int _selectedPlanIndex = 1; // Default to Yearly Plan (Best Value)

  final List<Map<String, dynamic>> _features = const [
    {
      'icon': Icons.auto_awesome_rounded,
      'title': 'Unlimited AI Assistant',
      'desc': 'Generate, rewrite, summarize and translate notes with zero limits.',
    },
    {
      'icon': Icons.cloud_done_rounded,
      'title': 'Cloud Sync & Backups',
      'desc': 'Automatic multi-device sync and encrypted cloud backups.',
    },
    {
      'icon': Icons.document_scanner_rounded,
      'title': 'Advanced OCR Scanner',
      'desc': 'Extract text instantly from photos, documents, and handwritten notes.',
    },
    {
      'icon': Icons.folder_special_rounded,
      'title': 'Unlimited Notes & Folders',
      'desc': 'Organize your ideas without any storage restrictions.',
    },
    {
      'icon': Icons.block_rounded,
      'title': '100% Ad-Free Experience',
      'desc': 'Enjoy clean, distraction-free productivity.',
    },
    {
      'icon': Icons.palette_rounded,
      'title': 'Exclusive Pro Themes & Fonts',
      'desc': 'Unlock custom typography and premium color palettes.',
    },
  ];

  final List<Map<String, String>> _plans = const [
    {
      'id': 'monthly',
      'title': 'Monthly Plan',
      'price': '\$9.99',
      'subtitle': 'Billed monthly. Cancel anytime.',
      'badge': '',
    },
    {
      'id': 'yearly',
      'title': 'Yearly Plan',
      'price': '\$49.99',
      'subtitle': '\$4.16/mo • Billed annually',
      'badge': 'BEST VALUE • 60% OFF',
    },
    {
      'id': 'lifetime',
      'title': 'Lifetime Access',
      'price': '\$99.99',
      'subtitle': 'One-time payment • Forever access',
      'badge': 'PAY ONCE',
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0A21),
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(height: topPadding + 10),

                  // Header with Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'PRO UNLOCKED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Royalty Crown Badge & Title
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF00C6FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Upgrade to NoteNest Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Unlock the full power of AI note taking & organization',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFFB0A9D0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Premium Features List
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      children: _features.map((feat) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(feat['icon'] as IconData, color: const Color(0xFF00C6FF), size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feat['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      feat['desc'] as String,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF9E96C5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Select Plan Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose Your Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Plan Selection Cards
                  Column(
                    children: List.generate(_plans.length, (index) {
                      final plan = _plans[index];
                      final isSelected = _selectedPlanIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedPlanIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF7C3AED).withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00C6FF)
                                  : Colors.white.withValues(alpha: 0.1),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              // Radio Indicator
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF00C6FF) : const Color(0xFF7B7799),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF00C6FF),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),

                              // Title & Subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          plan['title']!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (plan['badge']!.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF00C6FF),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              plan['badge']!,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF0F0A21),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      plan['subtitle']!,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF9E96C5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Price
                              Text(
                                plan['price']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Subscribe Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF00C6FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final selected = _plans[_selectedPlanIndex];
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Subscribed to ${selected['title']}! Welcome to NoteNest Pro ✨'),
                              backgroundColor: const Color(0xFF7C3AED),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Subscribe Now',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Restore Purchase & Terms
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Purchases restored successfully! 🔄'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text(
                          'Restore Purchase',
                          style: TextStyle(color: Color(0xFFB0A9D0), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Text('•', style: TextStyle(color: Color(0xFF7B7799))),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Terms & Privacy Policy'), duration: Duration(seconds: 2)),
                          );
                        },
                        child: const Text(
                          'Terms & Privacy',
                          style: TextStyle(color: Color(0xFFB0A9D0), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: bottomPadding + 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
