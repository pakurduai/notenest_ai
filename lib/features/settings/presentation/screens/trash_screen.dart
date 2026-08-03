import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../notes/data/notes_repository.dart';
import '../../../notes/domain/models/note_model.dart';

/// Trash Screen — Manages deleted notes in NoteNest AI
class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final NotesRepository _notesRepo = NotesRepository();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: EdgeInsets.only(
                top: topPadding + 10.0,
                left: 16.0,
                right: 16.0,
                bottom: 12.0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8.0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12.0),
                        child: const Center(
                          child: Icon(Icons.arrow_back_rounded, color: Color(0xFF150D33), size: 20.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trash Bin',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF150D33),
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 1.0),
                        Text(
                          'Deleted notes can be restored or removed',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B7799),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Empty Trash Button
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 24),
                    onPressed: () {
                      _showEmptyTrashConfirmation();
                    },
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _notesRepo.notesListenable,
                builder: (context, box, child) {
                  final trashNotes = _notesRepo.getTrashNotes();

                  if (trashNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3EDFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete_outline_rounded, size: 40, color: Color(0xFF7C3AED)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Trash is empty',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'No deleted notes in trash bin.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF6E6A8A)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: bottomPadding + 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: trashNotes.length,
                    itemBuilder: (context, index) {
                      final note = trashNotes[index];
                      return _buildTrashNoteTile(note);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrashNoteTile(NoteModel note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.description_rounded, color: Color(0xFFEC4899), size: 22),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title.isNotEmpty ? note.title : 'Untitled Note',
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF150D33)),
                ),
                const SizedBox(height: 2),
                Text(
                  note.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6E6A8A)),
                ),
              ],
            ),
          ),

          // Restore Button
          IconButton(
            icon: const Icon(Icons.restore_rounded, color: Color(0xFF7C3AED)),
            onPressed: () async {
              final restoredNote = note.copyWith(isTrash: false);
              await _notesRepo.saveNote(restoredNote);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note restored from trash! 🔄')),
                );
              }
            },
          ),

          // Permanent Delete Button
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            onPressed: () async {
              await _notesRepo.deleteNote(note.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note permanently deleted.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEmptyTrashConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Empty Trash?', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
        content: const Text('All items in the trash will be permanently deleted. This action cannot be undone.', style: TextStyle(fontSize: 13, color: Color(0xFF6E6A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8C88A6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final trashNotes = _notesRepo.getTrashNotes();
              for (final note in trashNotes) {
                await _notesRepo.deleteNote(note.id);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trash emptied permanently.')),
                );
              }
            },
            child: const Text('Empty Trash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
