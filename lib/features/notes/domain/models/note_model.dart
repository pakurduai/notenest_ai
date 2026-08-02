import 'package:flutter/material.dart';

/// Note data model representing a note entry in NoteNest AI.
class NoteModel {
  final String id;
  final String title;
  final String content;
  final String tag;
  final Color tagBg;
  final Color tagColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isFavorite;
  final bool isArchived;
  final bool isTrash;
  final String? aiSummary;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.tag = 'Work',
    this.tagBg = const Color(0xFFF0ECFF),
    this.tagColor = const Color(0xFF7C3AED),
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.isTrash = false,
    this.aiSummary,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? tag,
    Color? tagBg,
    Color? tagColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    bool? isTrash,
    String? aiSummary,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      tagBg: tagBg ?? this.tagBg,
      tagColor: tagColor ?? this.tagColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isTrash: isTrash ?? this.isTrash,
      aiSummary: aiSummary ?? this.aiSummary,
    );
  }

  /// Converts model to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tag': tag,
      'tagBg': tagBg.toARGB32(),
      'tagColor': tagColor.toARGB32(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'isTrash': isTrash,
      'aiSummary': aiSummary,
    };
  }

  /// Creates model from Hive Map
  factory NoteModel.fromMap(Map<dynamic, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      tag: map['tag'] as String? ?? 'Work',
      tagBg: map['tagBg'] != null
          ? Color(map['tagBg'] as int)
          : const Color(0xFFF0ECFF),
      tagColor: map['tagColor'] != null
          ? Color(map['tagColor'] as int)
          : const Color(0xFF7C3AED),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
      isPinned: map['isPinned'] as bool? ?? false,
      isFavorite: map['isFavorite'] as bool? ?? false,
      isArchived: map['isArchived'] as bool? ?? false,
      isTrash: map['isTrash'] as bool? ?? false,
      aiSummary: map['aiSummary'] as String?,
    );
  }
}
