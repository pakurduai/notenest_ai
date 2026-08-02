import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/notes/domain/models/note_model.dart';

/// Central Database Service managing Hive local storage boxes
class HiveDatabaseService {
  static const String notesBoxName = 'notes_box';
  static const String settingsBoxName = 'settings_box';

  static Box? _notesBox;
  static Box? _settingsBox;

  /// Initializes Hive database and opens boxes (supports optional AES encryption cipher)
  static Future<void> init({HiveCipher? encryptionCipher}) async {
    await Hive.initFlutter();

    _notesBox = await Hive.openBox(notesBoxName, encryptionCipher: encryptionCipher);
    _settingsBox = await Hive.openBox(settingsBoxName, encryptionCipher: encryptionCipher);

    // Initial database seed for sample notes on first launch
    if (_notesBox!.isEmpty) {
      await _seedInitialNotes();
    }
  }

  static Box get notesBox {
    if (_notesBox == null || !_notesBox!.isOpen) {
      throw Exception('Notes box is not initialized');
    }
    return _notesBox!;
  }

  static Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box is not initialized');
    }
    return _settingsBox!;
  }

  /// Seeds initial sample notes into Hive on first launch
  static Future<void> _seedInitialNotes() async {
    final now = DateTime.now();
    final sampleNotes = [
      NoteModel(
        id: 'note_1',
        title: 'Project Brainstorm',
        content: 'Ideas for the new mobile app project:\n1. Smooth animations\n2. Dark theme support\n3. Local database persistence.',
        tag: 'Work',
        tagBg: const Color(0xFFF0ECFF),
        tagColor: const Color(0xFF7C3AED),
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        isPinned: true,
        isFavorite: true,
      ),
      NoteModel(
        id: 'note_2',
        title: 'Study Notes - Chapter 5',
        content: 'Important concepts and formulas:\n- Key architecture principles\n- Clean separation of concerns\n- State management best practices.',
        tag: 'Study',
        tagBg: const Color(0xFFDCFCE7),
        tagColor: const Color(0xFF10B981),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isPinned: false,
        isFavorite: false,
      ),
      NoteModel(
        id: 'note_3',
        title: 'Daily Goals',
        content: '1. Morning workout & meditation\n2. Read 20 pages of technical book\n3. Complete NoteNest AI database integration.',
        tag: 'Personal',
        tagBg: const Color(0xFFFFEDD5),
        tagColor: const Color(0xFFF97316),
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 3)),
        isPinned: false,
        isFavorite: true,
      ),
      NoteModel(
        id: 'note_4',
        title: 'Travel Plan - Dubai Trip',
        content: 'Flight details, hotel reservations, places to visit:\n- Burj Khalifa\n- Desert Safari\n- Dubai Mall',
        tag: 'Travel',
        tagBg: const Color(0xFFE0F2FE),
        tagColor: const Color(0xFF0284C7),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        isPinned: false,
        isFavorite: false,
      ),
    ];

    for (final note in sampleNotes) {
      await _notesBox!.put(note.id, note.toMap());
    }
  }
}
