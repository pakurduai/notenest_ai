import 'package:flutter/material.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../widgets/onboarding_page.dart';
import '../../../../core/services/audio_haptic_service.dart';

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
    AudioHapticService.playNavigationSound();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    AudioHapticService.playButtonSound();
    if (_currentPage < _onboardingImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _onSkip() {
    AudioHapticService.playButtonSound();
    _navigateToHome();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
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
          if (mounted) {
            AudioHapticService.playButtonSound();
            setState(() => _currentPage = index);
          }
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
