import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'pro_subscription_service.dart';

/// Centralized AdMob Ad Service for NoteNest: Offline Notes.
/// Safely manages Banner and Interstitial Ads with offline resilience & frequency capping.
class AdService {
  static final AdService instance = AdService._internal();
  factory AdService() => instance;
  AdService._internal();

  /// Official NoteNest AdMob App ID
  static const String appId = 'ca-app-pub-9647688316681781~6451972635';

  /// Official Live Banner Ad Unit ID
  static const String liveBannerAdUnitIdAndroid = 'ca-app-pub-9647688316681781/3843110845';

  /// Google Official Test Banner Ad Unit ID (Used in debug/testing to protect AdMob account)
  static const String testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';

  /// Official NoteNest Live Interstitial Ad Unit ID
  static const String liveInterstitialAdUnitIdAndroid = 'ca-app-pub-9647688316681781/5056361417';

  /// Google Official Test Interstitial Ad Unit ID
  static const String testInterstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  DateTime? _lastInterstitialShownTime;
  int _noteActionCounter = 0;

  /// Initializes Google Mobile Ads SDK on supported platforms and preloads ads
  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('[AdService] Google Mobile Ads initialized successfully');
      loadInterstitialAd();
    } catch (e) {
      debugPrint('[AdService] AdMob initialization error: $e');
    }
  }

  /// Helper to get the active Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    // Use test ads during debug development to protect AdMob account from policy flags
    if (kDebugMode) {
      return testBannerAdUnitIdAndroid;
    }
    return liveBannerAdUnitIdAndroid;
  }

  /// Preloads an Interstitial Ad in the background
  void loadInterstitialAd() {
    if (kIsWeb) return;
    if (ProSubscriptionService.isPro) return;

    final adUnitId = kDebugMode || liveInterstitialAdUnitIdAndroid.contains('1234567890')
        ? testInterstitialAdUnitIdAndroid
        : liveInterstitialAdUnitIdAndroid;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('[AdService] Interstitial Ad loaded and ready');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          debugPrint('[AdService] Interstitial Ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Shows full-screen Interstitial Ad with intelligent frequency capping
  /// (Shows on milestone note saves with minimum 40s interval)
  void showInterstitialAdOnAction({VoidCallback? onDismissed}) {
    if (kIsWeb || ProSubscriptionService.isPro) {
      onDismissed?.call();
      return;
    }

    _noteActionCounter++;
    final now = DateTime.now();
    final timeSinceLastAd = _lastInterstitialShownTime == null
        ? 999
        : now.difference(_lastInterstitialShownTime!).inSeconds;

    // Show every 2nd note action with a safe 40-second cooldown
    final shouldShow = (_noteActionCounter % 2 == 0) && (timeSinceLastAd >= 40);

    if (shouldShow && _isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          _lastInterstitialShownTime = DateTime.now();
          loadInterstitialAd(); // Preload next ad
          onDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          loadInterstitialAd(); // Preload next ad
          onDismissed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      if (!_isInterstitialAdLoaded) {
        loadInterstitialAd();
      }
      onDismissed?.call();
    }
  }
}
