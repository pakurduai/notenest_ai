import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/hive_database_service.dart';
import '../domain/models/note_model.dart';

/// Repository class providing CRUD & state operations for Notes stored in Hive database.
class NotesRepository {
  final Box _box = HiveDatabaseService.notesBox;

  /// Exposes Box listenable for reactive UI updates
  ValueListenable<Box> get notesListenable => _box.listenable();

  /// Retrieves all active, non-archived, non-trash notes sorted by newest first
  List<NoteModel> getAllActiveNotes() {
    final List<NoteModel> list = [];
    for (var key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        final note = NoteModel.fromMap(raw);
        if (!note.isTrash && !note.isArchived) {
          list.add(note);
        }
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Retrieves all pinned notes
  List<NoteModel> getPinnedNotes() {
    return getAllActiveNotes().where((note) => note.isPinned).toList();
  }

  /// Retrieves all favorite notes
  List<NoteModel> getFavoriteNotes() {
    return getAllActiveNotes().where((note) => note.isFavorite).toList();
  }

  /// Retrieves archived notes
  List<NoteModel> getArchivedNotes() {
    final List<NoteModel> list = [];
    for (var key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        final note = NoteModel.fromMap(raw);
        if (note.isArchived && !note.isTrash) {
          list.add(note);
        }
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Retrieves trash notes
  List<NoteModel> getTrashNotes() {
    final List<NoteModel> list = [];
    for (var key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        final note = NoteModel.fromMap(raw);
        if (note.isTrash) {
          list.add(note);
        }
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Retrieves notes filtered by category name
  List<NoteModel> getNotesByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      return getAllActiveNotes();
    } else if (category.toLowerCase() == 'favorites') {
      return getFavoriteNotes();
    } else if (category.toLowerCase() == 'archive') {
      return getArchivedNotes();
    }
    return getAllActiveNotes()
        .where((n) => n.tag.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Gets single note by ID
  NoteModel? getNoteById(String id) {
    final raw = _box.get(id);
    if (raw is Map) {
      return NoteModel.fromMap(raw);
    }
    return null;
  }

  /// Saves (creates or updates) a note in Hive
  Future<void> saveNote(NoteModel note) async {
    await _box.put(note.id, note.toMap());
  }

  /// Toggles Pin status
  Future<void> togglePin(String id) async {
    final note = getNoteById(id);
    if (note != null) {
      final updated = note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      );
      await saveNote(updated);
    }
  }

  /// Toggles Favorite status
  Future<void> toggleFavorite(String id) async {
    final note = getNoteById(id);
    if (note != null) {
      final updated = note.copyWith(
        isFavorite: !note.isFavorite,
        updatedAt: DateTime.now(),
      );
      await saveNote(updated);
    }
  }

  /// Toggles Archive status
  Future<void> toggleArchive(String id) async {
    final note = getNoteById(id);
    if (note != null) {
      final updated = note.copyWith(
        isArchived: !note.isArchived,
        updatedAt: DateTime.now(),
      );
      await saveNote(updated);
    }
  }

  /// Permanently deletes a note from Hive
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  /// Restores note from trash or archive
  Future<void> restoreNote(String id) async {
    final note = getNoteById(id);
    if (note != null) {
      final updated = note.copyWith(
        isTrash: false,
        isArchived: false,
        updatedAt: DateTime.now(),
      );
      await saveNote(updated);
    }
  }
}
