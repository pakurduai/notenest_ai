import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/hive_database_service.dart';

/// Repository class for persisting user settings, preferences, recent searches, and view state.
class SettingsRepository {
  Box get _box => HiveDatabaseService.settingsBox;

  ValueListenable<Box> get settingsListenable => _box.listenable();

  // Dark Theme Mode
  bool get isDarkMode => _box.get('isDarkMode', defaultValue: false) as bool;
  Future<void> setDarkMode(bool value) async => await _box.put('isDarkMode', value);

  // Font Size
  double get fontSize => _box.get('fontSize', defaultValue: 14.0) as double;
  Future<void> setFontSize(double size) async => await _box.put('fontSize', size);

  // Language
  String get language => _box.get('language', defaultValue: 'en') as String;
  Future<void> setLanguage(String lang) async => await _box.put('language', lang);

  // Last Opened Screen
  String get lastOpenedScreen => _box.get('lastOpenedScreen', defaultValue: 'home') as String;
  Future<void> setLastOpenedScreen(String screen) async => await _box.put('lastOpenedScreen', screen);

  // Recent Searches List
  List<String> getRecentSearches() {
    final raw = _box.get('recentSearches', defaultValue: [
      'project ideas',
      'study notes',
      'meeting',
      'todo list',
      'travel plan',
    ]);
    if (raw is List) {
      return raw.cast<String>();
    }
    return [];
  }

  Future<void> addRecentSearch(String query) async {
    final list = getRecentSearches();
    if (query.trim().isNotEmpty && !list.contains(query.trim())) {
      list.insert(0, query.trim());
      if (list.length > 10) list.removeLast();
      await _box.put('recentSearches', list);
    }
  }

  Future<void> clearRecentSearches() async {
    await _box.put('recentSearches', <String>[]);
  }

  // Sort Preference ('Newest', 'Oldest', 'Title')
  String get sortPreference => _box.get('sortPreference', defaultValue: 'Newest') as String;
  Future<void> setSortPreference(String sort) async => await _box.put('sortPreference', sort);

  // View Preference ('list', 'grid')
  bool get isGridView => _box.get('isGridView', defaultValue: false) as bool;
  Future<void> setGridView(bool value) async => await _box.put('isGridView', value);

  // Enabled AI Tools Preference List
  List<String> getEnabledAiTools() {
    final raw = _box.get('enabledAiTools', defaultValue: [
      'ai_writer', 'rewrite', 'summarize', 'translate', 'grammar', 'tone', 'idea_gen', 'title_gen', 'ocr'
    ]);
    if (raw is List) {
      return raw.cast<String>();
    }
    return ['ai_writer', 'rewrite', 'summarize', 'translate', 'grammar', 'tone', 'idea_gen', 'title_gen', 'ocr'];
  }

  Future<void> setEnabledAiTools(List<String> tools) async {
    await _box.put('enabledAiTools', tools);
  }
}
