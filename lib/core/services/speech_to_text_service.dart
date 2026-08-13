import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'audio_haptic_service.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/notes/presentation/screens/create_note_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/trash_screen.dart';

/// Unified Speech-to-Text & Voice Command Navigation Service for NoteNest AI
class SpeechToTextService {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  factory SpeechToTextService() => _instance;
  SpeechToTextService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Launch voice recognition modal and send recognized/edited text to callback
  static Future<void> listenAndDictate({
    required BuildContext context,
    required Function(String text) onTextRecognized,
    String title = 'Voice Command & Dictation',
  }) async {
    AudioHapticService.playButtonSound();

    // On web, skip permission_handler (not supported) and go straight to STT
    if (!kIsWeb) {
      final status = await Permission.microphone.request();
      if (!status.isGranted && context.mounted) {
        _showFallbackTextInput(
          context,
          onTextRecognized,
          title: title,
          message: 'Microphone permission was not granted. Type or speak command below:',
        );
        return;
      }
    }

    final instance = SpeechToTextService();
    try {
      if (!instance._isInitialized) {
        instance._isInitialized = await instance._speech.initialize(
          onError: (val) {},
          onStatus: (val) {},
        );
      }
    } catch (_) {
      instance._isInitialized = false;
    }

    if (!context.mounted) return;

    if (!instance._isInitialized) {
      // On web or when STT not available, show manual text input
      _showFallbackTextInput(
        context,
        onTextRecognized,
        title: title,
        message: kIsWeb
            ? 'Voice typing: type your prompt or command below:'
            : 'Voice engine ready. Enter or dictate command below:',
      );
      return;
    }

    // Launch speech listening bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SpeechListeningBottomSheet(
        speech: instance._speech,
        title: title,
        onTextRecognized: onTextRecognized,
      ),
    );
  }

  static void _showFallbackTextInput(
    BuildContext context,
    Function(String text) onTextRecognized, {
    required String title,
    required String message,
  }) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.mic_rounded, color: Color(0xFF7C3AED), size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF6E6A8A))),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: Color(0xFF150D33)),
              decoration: InputDecoration(
                hintText: 'Speak or type command (e.g. "home page open karo", "create note")...',
                hintStyle: const TextStyle(color: Color(0xFF9E9AC0)),
                fillColor: const Color(0xFFF7F6FA),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFECE9F6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF8C88A6))),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                  label: const Text('Execute Command', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      onTextRecognized(text);
                      performVoiceNavigation(context, text);
                    }
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Global Multilingual Voice Navigation Handler
  /// Matches voice commands in English, Urdu, Roman Urdu, Hindi, Spanish etc.
  static bool performVoiceNavigation(BuildContext context, String text) {
    final lower = text.toLowerCase().trim();

    if (lower.contains('home') || lower.contains('main') || lower.contains('ہوم') || lower.contains('home page')) {
      AudioHapticService.playNavigationSound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Home Screen... 🎙️'), backgroundColor: Color(0xFF7C3AED), duration: Duration(seconds: 1)),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      return true;
    } else if (lower.contains('create') || lower.contains('new note') || lower.contains('write') || lower.contains('likho') || lower.contains('banao') || lower.contains('نیا نوٹ') || lower.contains('نوٹ')) {
      AudioHapticService.playNavigationSound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening New Note Editor... 🎙️'), backgroundColor: Color(0xFF7C3AED), duration: Duration(seconds: 1)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNoteScreen()));
      return true;
    } else if (lower.contains('search') || lower.contains('find') || lower.contains('dhoondo') || lower.contains('تلاش') || lower.contains('سرچ')) {
      AudioHapticService.playNavigationSound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Search Screen... 🎙️'), backgroundColor: Color(0xFF7C3AED), duration: Duration(seconds: 1)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
      return true;
    } else if (lower.contains('ai') || lower.contains('assistant') || lower.contains('robot') || lower.contains('gemini') || lower.contains('ای آئی') || lower.contains('اسسٹنٹ')) {
      AudioHapticService.playNavigationSound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening AI Assistant... 🎙️'), backgroundColor: Color(0xFF7C3AED), duration: Duration(seconds: 1)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
      return true;
    } else if (lower.contains('category') || lower.contains('categories') || lower.contains('folder') || lower.contains('اقسام') || lower.contains('کیٹیگری')) {
      AudioHapticService.playNavigationSound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Categories... 🎙️'), backgroundColor: Color(0xFF7C3AED), duration: Duration(seconds: 1)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
      return true;
    } else if (lower.contains('setting') || lower.contains('settings') || lower.contains('tarseem') || lower.contains('سیٹنگز')) {
      AudioHapticService.playNavigationSound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Settings... 🎙️'), backgroundColor: Color(0xFF7C3AED), duration: Duration(seconds: 1)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
      return true;
    } else if (lower.contains('trash') || lower.contains('deleted') || lower.contains('bin') || lower.contains('تریاش') || lower.contains('ڈیلیٹ')) {
      AudioHapticService.playNavigationSound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Trash... 🎙️'), backgroundColor: Color(0xFF7C3AED), duration: Duration(seconds: 1)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TrashScreen()));
      return true;
    }

    return false;
  }
}

class _SpeechListeningBottomSheet extends StatefulWidget {
  final stt.SpeechToText speech;
  final String title;
  final Function(String text) onTextRecognized;

  const _SpeechListeningBottomSheet({
    required this.speech,
    required this.title,
    required this.onTextRecognized,
  });

  @override
  State<_SpeechListeningBottomSheet> createState() => _SpeechListeningBottomSheetState();
}

class _SpeechListeningBottomSheetState extends State<_SpeechListeningBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late TextEditingController _textController;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _startListening();
  }

  void _startListening() async {
    AudioHapticService.playButtonSound();
    if (mounted) setState(() => _isListening = true);
    await widget.speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _textController.text = result.recognizedWords;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        });
      },
    );
  }

  void _stopListening() async {
    await widget.speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _animController.dispose();
    _textController.dispose();
    widget.speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 20.0 + bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar Handle Indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDD5FA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF150D33),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isListening
                    ? 'Listening... Speak in any language 🎙️'
                    : 'Tap Mic to speak or edit text below',
                style: const TextStyle(fontSize: 13.0, color: Color(0xFF6E6A8A), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // Interactive Pulsing Mic Graphic Button
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isListening) ...[
                        Container(
                          width: 86 + (_animController.value * 20),
                          height: 86 + (_animController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.15 - (_animController.value * 0.1)),
                          ),
                        ),
                        Container(
                          width: 72 + (_animController.value * 10),
                          height: 72 + (_animController.value * 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.3 - (_animController.value * 0.15)),
                          ),
                        ),
                      ],
                      GestureDetector(
                        onTap: () {
                          AudioHapticService.playButtonSound();
                          if (_isListening) {
                            _stopListening();
                          } else {
                            _startListening();
                          }
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Live Editable Text Field (User can both speak AND edit/type directly!)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6FA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFECE9F6)),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    color: Color(0xFF150D33),
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Spoken command or text will appear here. You can also edit or type manually...',
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF9E9AC0),
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Action Buttons Row: Cancel, Clear, Done
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      side: const BorderSide(color: Color(0xFFDDD5FA)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      AudioHapticService.playButtonSound();
                      _stopListening();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E6A8A), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: Color(0xFFDDD5FA)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      AudioHapticService.playButtonSound();
                      setState(() {
                        _textController.clear();
                      });
                    },
                    child: const Text('Clear', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF7C3AED),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      onPressed: () {
                        AudioHapticService.playButtonSound();
                        _stopListening();
                        final text = _textController.text.trim();
                        if (text.isNotEmpty) {
                          widget.onTextRecognized(text);
                          final handled = SpeechToTextService.performVoiceNavigation(context, text);
                          if (!handled) {
                            Navigator.pop(context);
                          }
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
