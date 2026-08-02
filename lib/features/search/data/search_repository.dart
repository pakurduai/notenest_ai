import '../../notes/data/notes_repository.dart';
import '../../notes/domain/models/note_model.dart';

/// Repository handling real-time search queries across database notes.
class SearchRepository {
  final NotesRepository _notesRepo;

  SearchRepository(this._notesRepo);

  /// Performs live query search across note titles, contents, and tags
  List<NoteModel> searchNotes({
    required String query,
    String categoryFilter = 'All Notes',
  }) {
    final activeNotes = _notesRepo.getAllActiveNotes();
    final cleanQuery = query.trim().toLowerCase();

    return activeNotes.where((note) {
      final matchesQuery = cleanQuery.isEmpty ||
          note.title.toLowerCase().contains(cleanQuery) ||
          note.content.toLowerCase().contains(cleanQuery) ||
          note.tag.toLowerCase().contains(cleanQuery);

      if (!matchesQuery) return false;

      if (categoryFilter == '⭐ Favorites') {
        return note.isFavorite;
      } else if (categoryFilter == '📌 Pinned') {
        return note.isPinned;
      }

      return true;
    }).toList();
  }
}
