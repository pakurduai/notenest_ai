import 'package:flutter/services.dart';

/// Centralized Audio & Haptic Feedback Service for NoteNest
class AudioHapticService {
  /// Global Sound ON/OFF state toggle
  static bool isSoundEnabled = true;

  /// Play tactile click sound and haptic vibration on button tap
  static void playButtonSound() {
    if (!isSoundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  /// Play notification bell alert sound and heavy haptic vibration
  static void playNotificationBellSound() {
    if (!isSoundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }

  /// Play page navigation sound & tactile haptic feedback on screen open / button tap
  static void playNavigationSound() {
    if (!isSoundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.selectionClick();
  }
}
