import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../widgets/onboarding_page.dart';

/// Main Onboarding Screen controller managing 100% pixel-perfect design images
/// with smooth slide transitions, edge-to-edge layout, and interactive navigation.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<String> _onboardingImages = [
    'assets/images/onboarding_screen_1.png',
    'assets/images/onboarding_screen_2.png',
    'assets/images/onboarding_screen_3.png',
  ];

  @override
  void initState() {
    super.initState();
    // System UI overlay configuration for edge-to-edge full-screen display
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _onboardingImages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToHome();
    }
  }

  void _onSkip() {
    _navigateToHome();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070415),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _onboardingImages.length,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          return OnboardingPage(
            imagePath: _onboardingImages[index],
            pageIndex: index,
            totalPages: _onboardingImages.length,
            onNext: _onNext,
            onSkip: _onSkip,
          );
        },
      ),
    );
  }
}
