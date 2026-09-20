import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/pro_subscription_service.dart';

/// Clean, responsive AdMob Banner Widget for NoteNest.
/// Automatically handles ad loading, errors, and hides gracefully when offline.
class AdBannerWidget extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final bool showBorder;

  const AdBannerWidget({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.showBorder = true,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (kIsWeb) return;
    final adUnitId = AdService.bannerAdUnitId;
    if (adUnitId.isEmpty) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdBannerWidget] Banner failed to load: ${error.message} (Code: ${error.code})');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || ProSubscriptionService.isPro || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: widget.showBorder
          ? BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
