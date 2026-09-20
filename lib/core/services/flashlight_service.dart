import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:torch_light/torch_light.dart';

/// Flashlight & Reading Light Service for NoteNest
class FlashlightService {
  static final FlashlightService instance = FlashlightService._internal();
  factory FlashlightService() => instance;
  FlashlightService._internal();

  /// Flashlight ON/OFF state
  static bool isFlashlightOn = false;

  /// Toggle flashlight / reading light ON/OFF
  static Future<bool> toggleFlashlight(BuildContext context) async {
    isFlashlightOn = !isFlashlightOn;
    HapticFeedback.mediumImpact();

    try {
      if (isFlashlightOn) {
        final isAvailable = await TorchLight.isTorchAvailable();
        if (isAvailable) {
          await TorchLight.enableTorch();
        }
      } else {
        await TorchLight.disableTorch();
      }
    } catch (e) {
      debugPrint('Torch control error: $e');
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isFlashlightOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                isFlashlightOn ? 'Flashlight / Reading Light Turned ON 🔦' : 'Flashlight Turned OFF',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: isFlashlightOn ? const Color(0xFF7C3AED) : const Color(0xFF374151),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }

    return isFlashlightOn;
  }
}

