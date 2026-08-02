import 'package:flutter/material.dart';

/// Centralized color palette for NoteNest AI matching the reference splash screen.
class AppColors {
  AppColors._();

  // Background Gradient — vibrant deep purple/violet matching reference
  static const Color bgGradientTop    = Color(0xFF6B35D9); // bright purple top-center
  static const Color bgGradientMiddle = Color(0xFF3A1199); // mid deep purple-blue
  static const Color bgGradientBottom = Color(0xFF0D0630); // near-black dark bottom

  // Radial Ambient Glow Halo (breathing around logo)
  static const Color ambientPurpleGlow = Color(0xFF7B2FFF);
  static const Color ambientCyanGlow   = Color(0xFF00E5FF);
  static const Color glowHaloCenter    = Color(0xFF4A148C);

  // Text Colors
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFDCD7F5);
  static const Color textMuted     = Color(0xFF9E9CC3);

  // AI Gradient Accent — "AI" word and sparkle star (cyan → blue)
  static const Color cyanAccentStart = Color(0xFF00E5FF);
  static const Color cyanAccentEnd   = Color(0xFF00A3FF);

  // Orbit Rings & Accent Nodes
  static const Color orbitOuterRing  = Color(0x507B3FFF);
  static const Color orbitInnerRing  = Color(0x609050E0);
  static const Color orbitNodeCyan   = Color(0xFF00E5FF);
  static const Color orbitNodePurple = Color(0xFFB57EDC);
  static const Color orbitNodePink   = Color(0xFFFF70A6);

  // Bottom Mesh Waves
  static const Color waveLinePrimary   = Color(0x503A0088);
  static const Color waveLineSecondary = Color(0x706C2BFF);
  static const Color waveLineCyanGlow  = Color(0x3000E5FF);

  // Loading Dots
  static const Color dotActive   = Color(0xFF00E5FF);
  static const Color dotInactive = Color(0x607A78A8);
}
