import 'package:flutter/material.dart';
import '../../notes/data/notes_repository.dart';
import '../domain/models/category_model.dart';

/// Repository dynamically calculating category statistics and filtering notes.
class CategoriesRepository {
  final NotesRepository _notesRepo;

  CategoriesRepository(this._notesRepo);

  /// Returns 8 categories with real dynamic note counts calculated from database
  List<CategoryModel> getDynamicCategories() {
    final activeNotes = _notesRepo.getAllActiveNotes();
    final favoriteNotes = _notesRepo.getFavoriteNotes();
    final archivedNotes = _notesRepo.getArchivedNotes();

    int countTag(String tag) =>
        activeNotes.where((n) => n.tag.toLowerCase() == tag.toLowerCase()).length;

    return [
      CategoryModel(
        id: 'work',
        title: 'Work',
        noteCount: countTag('Work'),
        icon: Icons.work_rounded,
        iconBg: const Color(0xFFF3EDFF),
        iconColor: const Color(0xFF7C3AED),
        indicatorColor: const Color(0xFF7C3AED),
      ),
      CategoryModel(
        id: 'study',
        title: 'Study',
        noteCount: countTag('Study'),
        icon: Icons.school_rounded,
        iconBg: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF10B981),
        indicatorColor: const Color(0xFF10B981),
      ),
      CategoryModel(
        id: 'ideas',
        title: 'Ideas',
        noteCount: countTag('Ideas'),
        icon: Icons.lightbulb_rounded,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFD97706),
        indicatorColor: const Color(0xFFD97706),
      ),
      CategoryModel(
        id: 'personal',
        title: 'Personal',
        noteCount: countTag('Personal'),
        icon: Icons.calendar_today_rounded,
        iconBg: const Color(0xFFFFEBF2),
        iconColor: const Color(0xFFEC4899),
        indicatorColor: const Color(0xFFEC4899),
      ),
      CategoryModel(
        id: 'travel',
        title: 'Travel',
        noteCount: countTag('Travel'),
        icon: Icons.flight_takeoff_rounded,
        iconBg: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0284C7),
        indicatorColor: const Color(0xFF0284C7),
      ),
      CategoryModel(
        id: 'shopping',
        title: 'Shopping',
        noteCount: countTag('Shopping'),
        icon: Icons.shopping_cart_rounded,
        iconBg: const Color(0xFFFFEDD5),
        iconColor: const Color(0xFFF97316),
        indicatorColor: const Color(0xFFF97316),
      ),
      CategoryModel(
        id: 'favorites',
        title: 'Favorites',
        noteCount: favoriteNotes.length,
        icon: Icons.star_rounded,
        iconBg: const Color(0xFFCCFBF1),
        iconColor: const Color(0xFF0D9488),
        indicatorColor: const Color(0xFF0D9488),
      ),
      CategoryModel(
        id: 'archive',
        title: 'Archive',
        noteCount: archivedNotes.length,
        icon: Icons.inventory_2_rounded,
        iconBg: const Color(0xFFF1F5F9),
        iconColor: const Color(0xFF64748B),
        indicatorColor: const Color(0xFF64748B),
      ),
    ];
  }
}
