import 'package:flutter/material.dart';

/// Data model representing an AI tool feature card in NoteNest AI.
class AiToolModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const AiToolModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

/// Data model representing a recent AI interaction history item.
class AiHistoryModel {
  final String id;
  final String title;
  final String timeStr;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const AiHistoryModel({
    required this.id,
    required this.title,
    required this.timeStr,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}
