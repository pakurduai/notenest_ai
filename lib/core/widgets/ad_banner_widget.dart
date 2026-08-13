import 'package:flutter/material.dart';

/// AdBannerWidget — Ads completely removed per user request.
/// Renders an empty SizedBox.shrink() so zero ad banners appear in the app.
class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
