import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/audio_haptic_service.dart';
import '../../../home/presentation/screens/home_screen.dart';

/// Clean App Launch Screen for NoteNest AI
/// Displays white background with centered official NoteNest AI logo badge for 1.5s
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _navigationTimer;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    AudioHapticService.playAppLaunchSound();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _navigateToHomeScreen();
      }
    });
  }

  void _navigateToHomeScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo Badge Icon Container
                Container(
                  width: 90.0,
                  height: 90.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                        blurRadius: 20.0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: Image.asset(
                      'assets/playstore/icon_512.png',
                      width: 90.0,
                      height: 90.0,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'N',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(
                              Icons.auto_awesome,
                              color: Color(0xFFFFD700),
                              size: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // App Title: NoteNest
                const Text(
                  'NoteNest',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF150D33),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6.0),
                const Text(
                  'Smart Notes. Smarter Ideas.',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6A8A),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

