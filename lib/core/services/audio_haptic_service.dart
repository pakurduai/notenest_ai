import 'package:flutter/services.dart';

/// Centralized Audio & Haptic Feedback Service for NoteNest
class AudioHapticService {
  /// Global Sound ON/OFF state toggle
  static bool isSoundEnabled = true;

  /// Play tactile click sound and light haptic vibration on button tap
  static void playButtonSound() {
    if (!isSoundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  /// Play notification bell alert sound and medium haptic vibration
  static void playNotificationBellSound() {
    if (!isSoundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();
  }

  /// Play page navigation sound & subtle haptic feedback
  static void playNavigationSound() {
    if (!isSoundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }
}
