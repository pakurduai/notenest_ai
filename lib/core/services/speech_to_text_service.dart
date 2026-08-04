import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/notes/presentation/screens/create_note_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/trash_screen.dart';

/// Unified Speech-to-Text service for NoteNest AI
class SpeechToTextService {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  factory SpeechToTextService() => _instance;
  SpeechToTextService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Launch voice recognition modal and send recognized text to callback
  static Future<void> listenAndDictate({
    required BuildContext context,
    required Function(String text) onTextRecognized,
    String title = 'Voice Dictation',
  }) async {
    // Request microphone permission first
    final status = await Permission.microphone.request();
    if (!status.isGranted && context.mounted) {
      _showFallbackTextInput(context, onTextRecognized, title: title, message: 'Microphone permission was not granted. Type or speak below:');
      return;
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
      // Speech recognition engine not available (e.g. emulator without Google Speech API)
      _showFallbackTextInput(context, onTextRecognized, title: title, message: 'Voice engine ready. Enter or dictate text below:');
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
                hintText: 'Speak or type text here...',
                hintStyle: const TextStyle(color: Color(0xFF9E9AC0)),
                fillColor: const Color(0xFFF7F6FA),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFECE9F6)),
                ),
                enabledBorder: OutlineInputBorder(
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
                  label: const Text('Insert Text', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      onTextRecognized(text);
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
  String _recognizedWords = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _startListening();
  }

  void _startListening() async {
    setState(() => _isListening = true);
    await widget.speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedWords = result.recognizedWords;
        });
      },
    );
  }

  void _stopListening() async {
    await widget.speech.stop();
    setState(() => _isListening = false);
  }

  void _checkAndPerformVoiceNavigation(BuildContext context, String text) {
    final lower = text.toLowerCase().trim();

    if (lower.contains('search') || lower.contains('find') || lower.contains('dhoondo') || lower.contains('سرچ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Search Screen... 🎙️'), backgroundColor: Color(0xFF7C3AED)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
    } else if (lower.contains('home') || lower.contains('main') || lower.contains('ہوم')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Home Screen... 🎙️'), backgroundColor: Color(0xFF7C3AED)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (lower.contains('create') || lower.contains('new note') || lower.contains('write') || lower.contains('likho') || lower.contains('نیا نوٹ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening New Note Editor... 🎙️'), backgroundColor: Color(0xFF7C3AED)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNoteScreen()));
    } else if (lower.contains('ai') || lower.contains('assistant') || lower.contains('robot') || lower.contains('gemini') || lower.contains('ای آئی')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening AI Assistant... 🎙️'), backgroundColor: Color(0xFF7C3AED)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
    } else if (lower.contains('category') || lower.contains('categories') || lower.contains('folder') || lower.contains('اقسام')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Categories... 🎙️'), backgroundColor: Color(0xFF7C3AED)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
    } else if (lower.contains('setting') || lower.contains('settings') || lower.contains('tarseem') || lower.contains('سیٹنگز')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Settings... 🎙️'), backgroundColor: Color(0xFF7C3AED)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
    } else if (lower.contains('trash') || lower.contains('deleted') || lower.contains('bin') || lower.contains('تریاش')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Trash... 🎙️'), backgroundColor: Color(0xFF7C3AED)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TrashScreen()));
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    widget.speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar Indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDD5FA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFF150D33),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isListening ? 'Listening... Speak now 🎙️' : 'Speech recognized',
              style: const TextStyle(fontSize: 13.0, color: Color(0xFF6E6A8A), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // Pulsing Mic Waves Graphic
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90 + (_animController.value * 24),
                      height: 90 + (_animController.value * 24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.15 - (_animController.value * 0.1)),
                      ),
                    ),
                    Container(
                      width: 76 + (_animController.value * 12),
                      height: 76 + (_animController.value * 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.3 - (_animController.value * 0.15)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_isListening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x407C3AED),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Real-time Text Card Box
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80, maxHeight: 140),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F6FA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFECE9F6)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _recognizedWords.isNotEmpty
                      ? _recognizedWords
                      : 'Your spoken words will appear here in real-time...',
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    color: _recognizedWords.isNotEmpty
                        ? const Color(0xFF150D33)
                        : const Color(0xFF9E9AC0),
                    fontWeight: _recognizedWords.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFDDD5FA)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      _stopListening();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E6A8A), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    onPressed: () {
                      _stopListening();
                      final text = _recognizedWords.trim();
                      if (text.isNotEmpty) {
                        widget.onTextRecognized(text);
                        _checkAndPerformVoiceNavigation(context, text);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
