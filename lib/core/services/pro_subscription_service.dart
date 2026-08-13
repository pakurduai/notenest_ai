import 'package:flutter/material.dart';
import '../database/hive_database_service.dart';
import 'audio_haptic_service.dart';

/// Central Pro Subscription Service managing persistent subscription state & Google Play IAP simulation
class ProSubscriptionService {
  static const String _proKey = 'is_pro_user';
  static const String _planKey = 'active_pro_plan';
  static const String _planDateKey = 'pro_activated_date';

  /// Value Notifier for live UI updates across the entire app
  static final ValueNotifier<bool> isProNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<String> activePlanNotifier = ValueNotifier<String>('Free Tier');

  /// Initializes subscription state safely after database setup
  static void init() {
    try {
      isProNotifier.value = isPro;
      activePlanNotifier.value = activePlanTitle;
    } catch (_) {}
  }

  /// Returns true if the user has an active Pro subscription
  static bool get isPro {
    try {
      return HiveDatabaseService.settingsBox.get(_proKey, defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  /// Returns active plan title (e.g. 'Yearly Plan', 'Monthly Plan', 'Lifetime Access')
  static String get activePlanTitle {
    try {
      return HiveDatabaseService.settingsBox.get(_planKey, defaultValue: 'Free Tier') as String;
    } catch (_) {
      return 'Free Tier';
    }
  }

  /// Activates Pro Plan membership persistently in Hive
  static Future<void> activatePlan({
    required String planId,
    required String planTitle,
    required String planPrice,
  }) async {
    final box = HiveDatabaseService.settingsBox;
    await box.put(_proKey, true);
    await box.put(_planKey, planTitle);
    await box.put(_planDateKey, DateTime.now().toIso8601String());

    // Update live listeners
    isProNotifier.value = true;
    activePlanNotifier.value = planTitle;

    AudioHapticService.playButtonSound();
  }

  /// Cancels subscription (resets to Free Tier)
  static Future<void> cancelSubscription() async {
    final box = HiveDatabaseService.settingsBox;
    await box.put(_proKey, false);
    await box.put(_planKey, 'Free Tier');

    isProNotifier.value = false;
    activePlanNotifier.value = 'Free Tier';
  }

  /// Restores previous Play Store purchases
  static Future<bool> restorePurchases() async {
    AudioHapticService.playNavigationSound();
    await Future.delayed(const Duration(milliseconds: 600));
    final box = HiveDatabaseService.settingsBox;
    final hasStoredPro = box.get(_proKey, defaultValue: false) as bool;
    if (hasStoredPro) {
      isProNotifier.value = true;
      activePlanNotifier.value = box.get(_planKey, defaultValue: 'Pro Member') as String;
    }
    return hasStoredPro;
  }
}
