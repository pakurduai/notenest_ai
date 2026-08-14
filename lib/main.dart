import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'core/database/hive_database_service.dart';
import 'core/services/app_language_service.dart';
import 'core/services/pro_subscription_service.dart';
import 'core/services/play_billing_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive Database for persistent local storage
  try {
    await HiveDatabaseService.init();
    AppLanguageService.init();
    ProSubscriptionService.init();
  } catch (e) {
    debugPrint('Hive init exception: $e');
  }

  // Initialize Google Play Billing API service
  if (!kIsWeb) {
    try {
      await PlayBillingService.init();
    } catch (_) {}
  }

  if (!kIsWeb) {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    } catch (_) {}
  }

  runApp(const NoteNestApp());
}

/// Root Application Widget for NoteNest AI
class NoteNestApp extends StatelessWidget {
  const NoteNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguageService.currentLanguageNotifier,
      builder: (context, currentLang, child) {
        return MaterialApp(
          title: 'NoteNest AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
