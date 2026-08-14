import 'package:flutter/material.dart';
import '../../notes/data/notes_repository.dart';
import '../../notes/domain/models/note_model.dart';

/// Repository handling real-time search queries across database notes.
class SearchRepository {
  final NotesRepository _notesRepo;

  SearchRepository(this._notesRepo);

  /// Performs live query search across note titles, contents, tags, categories, and colors
  List<NoteModel> searchNotes({
    required String query,
    String categoryFilter = 'All Notes',
    String tagFilter = 'All',
    Color? colorFilter,
    String sortOrder = 'Newest',
  }) {
    final activeNotes = _notesRepo.getAllActiveNotes();
    final cleanQuery = query.trim().toLowerCase();

    final filtered = activeNotes.where((note) {
      // 1. Text Query Filter
      final matchesQuery = cleanQuery.isEmpty ||
          note.title.toLowerCase().contains(cleanQuery) ||
          note.content.toLowerCase().contains(cleanQuery) ||
          note.tag.toLowerCase().contains(cleanQuery);

      if (!matchesQuery) return false;

      // 2. Main Category Filter Chips
      if (categoryFilter.contains('Favorites') || categoryFilter.contains('⭐')) {
        if (!note.isFavorite) return false;
      } else if (categoryFilter.contains('Pinned') || categoryFilter.contains('📌')) {
        if (!note.isPinned) return false;
      } else if (categoryFilter.contains('Checklists') || categoryFilter.contains('☑')) {
        final lowerContent = note.content.toLowerCase();
        final isChecklist = lowerContent.contains('[ ]') || lowerContent.contains('[x]') || note.tag.toLowerCase().contains('checklist');
        if (!isChecklist) return false;
      } else if (categoryFilter.contains('Attachments') || categoryFilter.contains('📎')) {
        final lowerContent = note.content.toLowerCase();
        final hasAttachment = lowerContent.contains('http') || lowerContent.contains('assets') || lowerContent.contains('.png') || lowerContent.contains('.jpg') || lowerContent.contains('.mp3');
        if (!hasAttachment) return false;
      } else if (categoryFilter != 'All Notes' && !categoryFilter.startsWith('📄')) {
        // Specific named category (e.g. Work, Personal, Study)
        if (note.tag.toLowerCase() != categoryFilter.toLowerCase()) return false;
      }

      // 3. Tag Filter
      if (tagFilter != 'All' && tagFilter.isNotEmpty) {
        if (note.tag.toLowerCase() != tagFilter.toLowerCase()) return false;
      }

      // 4. Color Filter
      if (colorFilter != null) {
        final noteColorVal = note.tagBg.toARGB32();
        final targetColorVal = colorFilter.toARGB32();
        if ((noteColorVal & 0x00FFFFFF) != (targetColorVal & 0x00FFFFFF)) {
          return false;
        }
      }


      return true;
    }).toList();

    // 5. Apply Sorting
    if (sortOrder.contains('Oldest')) {
      filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    } else if (sortOrder.contains('A-Z')) {
      filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (sortOrder.contains('Z-A')) {
      filtered.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    } else {
      // Default: Newest first
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    return filtered;
  }
}

