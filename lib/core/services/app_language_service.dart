import 'package:flutter/material.dart';
import '../../features/settings/data/settings_repository.dart';

/// Centralized Language & Localization Service for NoteNest
class AppLanguageService {
  static SettingsRepository get _repository => SettingsRepository();

  /// ValueNotifier for app language state
  static final ValueNotifier<String> currentLanguageNotifier =
      ValueNotifier<String>('English (US)');

  /// Initializes persisted language preference safely after Hive database init
  static void init() {
    try {
      final savedLang = _repository.language;
      if (savedLang.isNotEmpty && savedLang != 'en') {
        currentLanguageNotifier.value = savedLang;
      }
    } catch (_) {}
  }

  static String get currentLanguage => currentLanguageNotifier.value;

  /// Set and persist selected language code/name
  static Future<void> setLanguage(String lang) async {
    await _repository.setLanguage(lang);
    currentLanguageNotifier.value = lang;
  }

  /// Supported Languages list
  static const List<String> supportedLanguages = [
    'English (US)',
    'Urdu (اردو)',
    'Hindi (हिंदी)',
    'Spanish (Español)',
    'French (Français)',
    'German (Deutsch)',
    'Arabic (العربية)',
    'Chinese (中文)',
  ];

  /// Get translation string for a given key based on current language
  static String tr(String key) {
    final lang = currentLanguageNotifier.value;
    return _translations[lang]?[key] ?? _translations['English (US)']?[key] ?? key;
  }

  /// Translations map for common app strings
  static final Map<String, Map<String, String>> _translations = {
    'English (US)': {
      'app_name': 'NoteNest',
      'settings': 'Settings',
      'language': 'App Language',
      'select_language': 'Select App Language',
      'search': 'Search Notes...',
      'categories': 'Categories',
      'ai_assistant': 'AI Assistant',
      'create_note': 'Create Note',
      'sound': 'Sound Effects',
      'theme': 'Theme Mode',
      'storage': 'Storage & Data',
      'about': 'About NoteNest',
    },
    'Urdu (اردو)': {
      'app_name': 'نوٹ نیسٹ',
      'settings': 'سیٹنگز',
      'language': 'ایپ کی زبان',
      'select_language': 'ایپ کی زبان منتخب کریں',
      'search': 'نوٹس تلاش کریں...',
      'categories': 'کیٹیگریز',
      'ai_assistant': 'اے آئی اسسٹنٹ',
      'create_note': 'نیا نوٹ بنائیں',
      'sound': 'آواز کے اثرات',
      'theme': 'تھیم موڈ',
      'storage': 'اسٹوریج اور ڈیٹا',
      'about': 'نوٹ نیسٹ کے بارے میں',
    },
    'Hindi (हिंदी)': {
      'app_name': 'नोटनेस्ट',
      'settings': 'सेटिंग्स',
      'language': 'ऐप भाषा',
      'select_language': 'ऐप भाषा चुनें',
      'search': 'नोट्स खोजें...',
      'categories': 'श्रेणियां',
      'ai_assistant': 'एआई सहायक',
      'create_note': 'नया नोट बनाएं',
      'sound': 'ध्वनि प्रभाव',
      'theme': 'थीम मोड',
      'storage': 'संग्रहण और डेटा',
      'about': 'नोटनेस्ट के बारे में',
    },
    'Spanish (Español)': {
      'app_name': 'NoteNest',
      'settings': 'Ajustes',
      'language': 'Idioma de la app',
      'select_language': 'Seleccionar idioma',
      'search': 'Buscar notas...',
      'categories': 'Categorías',
      'ai_assistant': 'Asistente IA',
      'create_note': 'Crear nota',
      'sound': 'Efectos de sonido',
      'theme': 'Modo de tema',
      'storage': 'Almacenamiento y datos',
      'about': 'Acerca de NoteNest',
    },
    'French (Français)': {
      'app_name': 'NoteNest',
      'settings': 'Paramètres',
      'language': 'Langue de l\'application',
      'select_language': 'Sélectionner la langue',
      'search': 'Rechercher des notes...',
      'categories': 'Catégories',
      'ai_assistant': 'Assistant IA',
      'create_note': 'Créer une note',
      'sound': 'Effets sonores',
      'theme': 'Mode de thème',
      'storage': 'Stockage et données',
      'about': 'À propos de NoteNest',
    },
    'German (Deutsch)': {
      'app_name': 'NoteNest',
      'settings': 'Einstellungen',
      'language': 'App-Sprache',
      'select_language': 'Sprache auswählen',
      'search': 'Notizen suchen...',
      'categories': 'Kategorien',
      'ai_assistant': 'KI-Assistent',
      'create_note': 'Notiz erstellen',
      'sound': 'Soundeffekte',
      'theme': 'Design-Modus',
      'storage': 'Speicher & Daten',
      'about': 'Über NoteNest',
    },
    'Arabic (العربية)': {
      'app_name': 'نوت نيست',
      'settings': 'الإعدادات',
      'language': 'لغة التطبيق',
      'select_language': 'اختر لغة التطبيق',
      'search': 'البحث في الملاحظات...',
      'categories': 'الفئات',
      'ai_assistant': 'مساعد الذكاء الاصطناعي',
      'create_note': 'إنشاء ملاحظة',
      'sound': 'المؤثرات الصوتية',
      'theme': 'وضع المظهر',
      'storage': 'التخزين والبيانات',
      'about': 'حول نوت نيست',
    },
    'Chinese (中文)': {
      'app_name': 'NoteNest 笔记',
      'settings': '设置',
      'language': '应用语言',
      'select_language': '选择应用语言',
      'search': '搜索笔记...',
      'categories': '分类',
      'ai_assistant': 'AI 助手',
      'create_note': '新建笔记',
      'sound': '音效',
      'theme': '主题模式',
      'storage': '存储与数据',
      'about': '关于 NoteNest',
    },
  };
}
