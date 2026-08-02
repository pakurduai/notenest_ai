import 'package:flutter/material.dart';

/// Data model representing a search result entry in NoteNest AI.
class SearchResultModel {
  final String id;
  final String title;
  final String preview;
  final String dateStr;
  final String categoryTag;
  final Color tagBg;
  final Color tagColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isPinned;
  final bool isFavorite;

  const SearchResultModel({
    required this.id,
    required this.title,
    required this.preview,
    required this.dateStr,
    required this.categoryTag,
    required this.tagBg,
    required this.tagColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isPinned = false,
    this.isFavorite = false,
  });
}
