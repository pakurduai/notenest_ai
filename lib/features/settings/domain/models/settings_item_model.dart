import 'package:flutter/material.dart';

/// Data model representing a single setting tile item in NoteNest AI.
class SettingsItemModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String? trailingText;
  final VoidCallback? onTap;

  const SettingsItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.trailingText,
    this.onTap,
  });
}
