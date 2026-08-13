import 'package:flutter/foundation.dart';

/// Centralized AdMob Ad Service (Ads currently disabled per user preference).
/// Can be easily re-enabled when ready for production release.
class AdService {
  static final AdService instance = AdService._internal();
  factory AdService() => instance;
  AdService._internal();

  /// Live AdMob Banner Ad Unit IDs (Saved for future re-activation)
  static const String bannerAdUnitIdAndroid = 'ca-app-pub-9647688316681781/4147006403';
  static const String bannerAdUnitIdIos = 'ca-app-pub-3940256099942544/2934735716';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes Google Mobile Ads SDK (Disabled)
  Future<void> init() async {
    // Ads disabled for development & user request
    _isInitialized = false;
  }

  /// Helper to get platform-specific Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return bannerAdUnitIdAndroid;
    } else {
      return bannerAdUnitIdIos;
    }
  }

  void showInterstitialAdOnAction() {
    // No-op while ads are disabled
  }
}

