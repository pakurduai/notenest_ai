import 'package:flutter/material.dart';

/// Enum representing the type of onboarding illustration to render.
enum OnboardingIllustrationType {
  aiRobotWithNotebook,
  aiBrainWithNotes,
  glowingNotebook,
}

/// Data model representing a single onboarding screen.
class OnboardingModel {
  final String title;
  final String titleHighlight;
  final String subtitle;
  final OnboardingIllustrationType illustrationType;
  final List<OnboardingFeatureItem> features;

  const OnboardingModel({
    required this.title,
    required this.titleHighlight,
    required this.subtitle,
    required this.illustrationType,
    this.features = const [],
  });
}

/// Data model for a single AI feature card shown on Screen 2.
class OnboardingFeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color gradientStart;
  final Color gradientEnd;

  const OnboardingFeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

/// Centralized data source for all three onboarding pages.
class OnboardingData {
  OnboardingData._();

  static const List<OnboardingModel> pages = [
    // Screen 1: Welcome to NoteNest AI
    OnboardingModel(
      title: 'Welcome to\n',
      titleHighlight: 'NoteNest AI',
      subtitle: 'Capture ideas instantly.\nOrganize everything effortlessly.',
      illustrationType: OnboardingIllustrationType.aiRobotWithNotebook,
    ),

    // Screen 2: Organize Your Notes Your Way
    OnboardingModel(
      title: 'Organize Your Notes\n',
      titleHighlight: 'Your Way',
      subtitle: 'Pin important notes, use categories, checklists,\nand reminders to stay perfectly organized.',
      illustrationType: OnboardingIllustrationType.aiBrainWithNotes,
    ),

    // Screen 3: Supercharge Ideas With AI
    OnboardingModel(
      title: 'Supercharge Ideas\n',
      titleHighlight: 'With AI Magic',
      subtitle: 'Summarize long text, generate ideas,\nand transcribe voice notes in seconds.',
      illustrationType: OnboardingIllustrationType.glowingNotebook,
    ),
  ];
}
