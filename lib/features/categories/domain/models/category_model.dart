import 'package:flutter/material.dart';

/// Category model for category grid items
class CategoryModel {
  final String id;
  final String title;
  final int noteCount;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color indicatorColor;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.noteCount,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.indicatorColor,
  });
}

/// Note model for category detail note items
class CategoryNoteModel {
  final String id;
  final String title;
  final String preview;
  final String dateStr;
  final String tag;
  final Color tagBg;
  final Color tagColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isPinned;
  final bool isFavorite;

  const CategoryNoteModel({
    required this.id,
    required this.title,
    required this.preview,
    required this.dateStr,
    required this.tag,
    required this.tagBg,
    required this.tagColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isPinned = false,
    this.isFavorite = false,
  });
}
