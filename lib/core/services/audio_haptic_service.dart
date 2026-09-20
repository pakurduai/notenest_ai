import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'web_audio.dart';

/// Centralized Audio & Haptic Feedback Service for NoteNest
class AudioHapticService {
  /// Global Sound ON/OFF state toggle (Default: ON for notifications)
  static bool isSoundEnabled = true;

  /// Play subtle haptic feedback on button tap
  static void playButtonSound() {
    try {
      SystemSound.play(SystemSoundType.click);
      if (!kIsWeb) {
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  /// Play notification bell chime sound & haptic vibration (Synthesized Bell Chime for Web & Native)
  static void playNotificationBellSound() {
    if (!isSoundEnabled) return;
    try {
      if (kIsWeb) {
        playWebBellChimeSynth();
      } else {
        SystemSound.play(SystemSoundType.alert);
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }

  /// Play soft screen navigation haptic feedback
  static void playNavigationSound() {
    try {
      SystemSound.play(SystemSoundType.click);
      if (!kIsWeb) {
        HapticFeedback.selectionClick();
      }
    } catch (_) {}
  }

  /// Play gentle home welcome haptic feedback
  static void playHomeWelcomeSound() {
    try {
      if (!kIsWeb) {
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  /// App Launch haptic pulse
  static void playAppLaunchSound() {
    try {
      if (!kIsWeb) {
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }
}
