/// Application configuration and asset path constants.
class AppConstants {
  AppConstants._();

  // Asset Paths
  static const String appIconPath        = 'assets/branding/app_icon.png';
  static const String fullLogoPath       = 'assets/branding/full_logo.png';
  static const String monogramPath       = 'assets/branding/monogram.png';
  static const String splashV2Path = 'assets/images/splash_screen_v2.png';

  // Timings — exact 1.5s (1500ms) splash duration requirement
  static const Duration splashDuration = Duration(milliseconds: 1500);
}

