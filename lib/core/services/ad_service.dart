import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralized AdMob Ad Management Service for NoteNest
class AdService {
  static final AdService instance = AdService._internal();
  factory AdService() => instance;
  AdService._internal();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  int _actionCounter = 0;

  // --------------------------------------------------------------------------
  // Ad Unit IDs
  // Note: Using official Google Test IDs by default. Replace test IDs with
  // your real AdMob Ad Unit IDs from your AdMob Dashboard (pub-9647688316681781).
  // --------------------------------------------------------------------------
  static const String _bannerAdUnitIdAndroid = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // Test Banner ID
      : 'ca-app-pub-3940256099942544/6300978111'; // Replace with real Banner Unit ID

  static const String _interstitialAdUnitIdAndroid = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Test Interstitial ID
      : 'ca-app-pub-3940256099942544/1033173712'; // Replace with real Interstitial Unit ID

  /// Initialize Google Mobile Ads SDK
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadInterstitialAd();
    } catch (e) {
      debugPrint('AdService Init Error: $e');
    }
  }

  /// Create and load a BannerAd for UI components
  BannerAd createBannerAd({required Function(Ad ad) onAdLoaded}) {
    final banner = BannerAd(
      adUnitId: Platform.isAndroid ? _bannerAdUnitIdAndroid : 'ca-app-pub-3940256099942544/2934735716',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );
    banner.load();
    return banner;
  }

  /// Preload Interstitial Ad in background
  void preloadInterstitialAd() {
    if (_interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: Platform.isAndroid ? _interstitialAdUnitIdAndroid : 'ca-app-pub-3940256099942544/4411468910',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              preloadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              preloadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isInterstitialLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Show Interstitial Ad periodically (e.g. after every 3 note saves)
  void showInterstitialAdOnAction({int triggerEveryCount = 2}) {
    _actionCounter++;
    if (_actionCounter % triggerEveryCount == 0) {
      if (_interstitialAd != null) {
        _interstitialAd!.show();
        _interstitialAd = null;
      } else {
        preloadInterstitialAd();
      }
    }
  }
}
