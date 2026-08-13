import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/speech_to_text_service.dart';
import '../../../notes/domain/models/note_model.dart';
import '../../../notes/presentation/screens/create_note_screen.dart';
import '../../domain/models/ai_tool_model.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../settings/data/settings_repository.dart';
import '../../../../core/services/gemini_ai_service.dart';
import '../../../../core/services/audio_haptic_service.dart';

/// AI Assistant Screen — Rebuilt to 100% pixel-to-pixel perfection
/// matching the official NoteNest AI design reference.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final TextEditingController _promptController = TextEditingController();
  final SettingsRepository _settingsRepo = SettingsRepository();
  late Set<String> _enabledToolIds;
  int _activeSegmentIndex = 0; // 0: 'Ask AI', 1: 'Paste Text'
  int _currentBottomNavIndex = 2; // 'AI Tools' active tab

  final List<AiToolModel> _aiTools = const [
    AiToolModel(
      id: 'ai_writer',
      title: 'AI Writer',
      subtitle: 'Write anything with AI',
      icon: Icons.auto_awesome_rounded,
      iconBg: Color(0xFF7C3AED),
      iconColor: Colors.white,
    ),
    AiToolModel(
      id: 'rewrite',
      title: 'Rewrite',
      subtitle: 'Improve and rewrite text',
      icon: Icons.edit_note_rounded,
      iconBg: Color(0xFF60A5FA),
      iconColor: Colors.white,
    ),
    AiToolModel(
      id: 'summarize',
      title: 'Summarize',
      subtitle: 'Summarize long text',
      icon: Icons.description_rounded,
      iconBg: Color(0xFF4ADE80),
      iconColor: Colors.white,
    ),
    AiToolModel(
      id: 'translate',
      title: 'Translate',
      subtitle: 'Translate to any language',
      icon: Icons.language_rounded,
      iconBg: Color(0xFFFB923C),
      iconColor: Colors.white,
    ),
    AiToolModel(
      id: 'grammar',
      title: 'Grammar Fix',
      subtitle: 'Fix grammar and spelling',
      icon: Icons.spellcheck_rounded,
      iconBg: Color(0xFFF472B6),
      iconColor: Colors.white,
    ),
    AiToolModel(
      id: 'tone',
      title: 'Tone Change',
      subtitle: 'Change tone of your text',
      icon: Icons.sentiment_satisfied_alt_rounded,
      iconBg: Color(0xFFA78BFA),
      iconColor: Colors.white,
    ),
    AiToolModel(
      id: 'idea_gen',
      title: 'Idea Generator',
      subtitle: 'Generate creative ideas',
      icon: Icons.lightbulb_rounded,
      iconBg: Color(0xFF14B8A6),
      iconColor: Colors.white,
    ),
    AiToolModel(
      id: 'title_gen',
      title: 'Title Generator',
      subtitle: 'Generate catchy titles',
      icon: Icons.label_rounded,
      iconBg: Color(0xFFFBBF24),
      iconColor: Colors.white,
    ),
    AiToolModel(
      id: 'ocr',
      title: 'OCR',
      subtitle: 'Extract text from image',
      icon: Icons.document_scanner_rounded,
      iconBg: Color(0xFF38BDF8),
      iconColor: Colors.white,
    ),
  ];

  final List<Map<String, dynamic>> _examplePrompts = const [
    {
      'icon': Icons.description_rounded,
      'label': 'Write a meeting summary',
      'bgColor': Color(0xFFF3EDFF),
      'iconColor': Color(0xFF7C3AED),
    },
    {
      'icon': Icons.auto_awesome_rounded,
      'label': 'Rewrite this in professional tone',
      'bgColor': Color(0xFFEBF3FF),
      'iconColor': Color(0xFF2563EB),
    },
    {
      'icon': Icons.article_rounded,
      'label': 'Summarize this long note',
      'bgColor': Color(0xFFE6F7ED),
      'iconColor': Color(0xFF10B981),
    },
    {
      'icon': Icons.language_rounded,
      'label': 'Translate to Urdu',
      'bgColor': Color(0xFFFFEDD5),
      'iconColor': Color(0xFFF97316),
    },
  ];

  final List<AiHistoryModel> _recentHistory = const [
    AiHistoryModel(
      id: 'h1',
      title: 'Summarize the note "Project Ideas for NoteNest AI"',
      timeStr: '10:30 AM',
      icon: Icons.description_rounded,
      iconBg: Color(0xFFDCFCE7),
      iconColor: Color(0xFF10B981),
    ),
    AiHistoryModel(
      id: 'h2',
      title: 'Rewrite the note in a better way',
      timeStr: 'Yesterday',
      icon: Icons.edit_note_rounded,
      iconBg: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
    ),
    AiHistoryModel(
      id: 'h3',
      title: 'Translate the note to Urdu',
      timeStr: 'Jul 28, 2024',
      icon: Icons.language_rounded,
      iconBg: Color(0xFFFFEDD5),
      iconColor: Color(0xFFF97316),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _enabledToolIds = _settingsRepo.getEnabledAiTools().toSet();

    // Edge-to-edge system UI styling
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
      body: Stack(
        children: [
          // ── Main Scrollable Content ──
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // 1. Top Header Bar
                  Padding(
                    padding: EdgeInsets.only(
                      top: topPadding + 10.0,
                      left: 16.0,
                      right: 16.0,
                      bottom: 8.0,
                    ),
                    child: _buildTopHeader(),
                  ),

                  // 2. Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome AI Mascot Banner Card
                          _buildWelcomeAiBanner(),
                          const SizedBox(height: 16.0),

                          // AI Tools Section Header
                          _buildAiToolsSectionHeader(),
                          const SizedBox(height: 10.0),

                          // 9 AI Tools Grid Cards (3 columns x 3 rows)
                          _buildAiToolsGrid(),
                          const SizedBox(height: 18.0),

                          // "Try these examples" Section
                          _buildExamplePromptsSection(),
                          const SizedBox(height: 18.0),

                          // Ask AI / Paste Text Segmented Input Card
                          _buildAiChatInputCard(),
                          const SizedBox(height: 20.0),

                          // Recent AI History Section
                          _buildRecentAiHistorySection(),

                          SizedBox(height: bottomPadding + 110.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Navigation Bar ──
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: bottomPadding + 12.0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 1. Top Header Bar
  // ─────────────────────────────────────────────

  Widget _buildTopHeader() {
    return Row(
      children: [
        // Back Button
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

        // Title with Sparkle Icon & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'AI Assistant ',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF150D33),
                      letterSpacing: -0.4,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1.0),
              const Text(
                'Your smart note assistant',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7B7799),
                ),
              ),
            ],
          ),
        ),

        // History Circular Icon
        Container(
          width: 38.0,
          height: 38.0,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
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
              onTap: () {
                AudioHapticService.playButtonSound();
                _showAiHistoryModal();
              },
              customBorder: const CircleBorder(),
              child: const Center(
                child: Icon(Icons.access_time_rounded, color: Color(0xFF150D33), size: 20.0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),

        // More Action Circular Icon
        Container(
          width: 38.0,
          height: 38.0,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
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
              onTap: () {
                AudioHapticService.playButtonSound();
                _showAiOptionsMenu();
              },
              customBorder: const CircleBorder(),
              child: const Center(
                child: Icon(Icons.more_vert_rounded, color: Color(0xFF150D33), size: 20.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 2. Welcome AI Mascot Banner Card
  // ─────────────────────────────────────────────

  Widget _buildWelcomeAiBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: const LinearGradient(
          colors: [Color(0xFFF3EDFF), Color(0xFFEBF3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFDDD5FA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
            blurRadius: 18.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top-Right Sparkle Icon
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18.0,
              color: const Color(0xFF7C3AED).withValues(alpha: 0.5),
            ),
          ),

          Row(
            children: [
              // Left Seamless Transparent 3D Robot Mascot Asset
              SizedBox(
                width: 88.0,
                height: 88.0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ambient Purple Glow Shadow
                    Container(
                      width: 68.0,
                      height: 68.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                            blurRadius: 20.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/energetic_robot_clean.png',
                      width: 84.0,
                      height: 84.0,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/ai_card_robot_clean.png',
                        width: 84.0,
                        height: 84.0,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/home_robot.png',
                          width: 84.0,
                          height: 84.0,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            width: 74.0,
                            height: 74.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF00C6FF)],
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.smart_toy_rounded, size: 40.0, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14.0),

              // Right Text & Capsule Button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hello! I'm NoteNest AI 👋",
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF150D33),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      'I can help you write, rewrite, summarize, translate, and much more.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6E6A8A),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    // Example prompt pill capsule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded,
                              size: 13.0, color: Color(0xFF7C3AED)),
                          SizedBox(width: 4.0),
                          Flexible(
                            child: Text(
                              'Try an example below or ask me anything',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 3. AI Tools Section Header
  // ─────────────────────────────────────────────

  Widget _buildAiToolsSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'AI Tools',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF150D33),
          ),
        ),
        InkWell(
          onTap: () {
            AudioHapticService.playButtonSound();
            _showCustomizeAiToolsModal();
          },
          child: const Row(
            children: [
              Text(
                'Customize',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C3AED),
                ),
              ),
              SizedBox(width: 4.0),
              Icon(Icons.tune_rounded, size: 14.0, color: Color(0xFF7C3AED)),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 4. 9 AI Tools Grid Cards (3 columns x 3 rows)
  // ─────────────────────────────────────────────

  Widget _buildAiToolsGrid() {
    final visibleTools = _aiTools.where((t) => _enabledToolIds.contains(t.id)).toList();
    if (visibleTools.isEmpty) {
      return const SizedBox.shrink();
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1.10,
      ),
      itemCount: visibleTools.length,
      itemBuilder: (context, index) {
        final tool = visibleTools[index];
        return _buildAiToolGridCard(tool);
      },
    );
  }

  Widget _buildAiToolGridCard(AiToolModel tool) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openAiToolModal(tool),
          borderRadius: BorderRadius.circular(18.0),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 80.0,
                height: 65.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Icon Badge & Chevron
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 28.0,
                          height: 28.0,
                          decoration: BoxDecoration(
                            color: tool.iconBg,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Icon(tool.icon, color: tool.iconColor, size: 15.0),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF9C98B6), size: 14.0),
                      ],
                    ),

                    // Title & Subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tool.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF150D33),
                          ),
                        ),
                        Text(
                          tool.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8C88A6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openAiToolModal(AiToolModel tool) {
    final inputController = TextEditingController();
    String generatedResult = '';
    bool isGenerating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 28.0,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tool.iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(tool.icon, color: tool.iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tool.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33)),
                        ),
                        Text(
                          tool.subtitle,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6E6A8A)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF8C88A6)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Input Field
                TextField(
                  controller: inputController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF150D33)),
                  decoration: InputDecoration(
                    hintText: 'Enter text or prompt for ${tool.title}...',
                    hintStyle: const TextStyle(color: Color(0xFF9E9AC0), fontSize: 13),
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
                  ),
                ),
                const SizedBox(height: 12),

                // Action / Generate Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: isGenerating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    label: Text(
                      isGenerating ? 'Processing with AI...' : 'Generate with ${tool.title}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: isGenerating
                        ? null
                        : () async {
                            AudioHapticService.playButtonSound();
                            setModalState(() => isGenerating = true);
                            
                            final text = inputController.text.trim();
                            final prompt = 'Perform ${tool.title} task on text: "${text.isNotEmpty ? text : tool.subtitle}"';
                            final res = await GeminiAiService.instance.generateContent(prompt: prompt);

                            setModalState(() {
                              generatedResult = res;
                              isGenerating = false;
                            });
                          },
                  ),
                ),

                // Generated Result Box
                if (generatedResult.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDDD5FA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Color(0xFF7C3AED), size: 16),
                            SizedBox(width: 6),
                            Text('AI Generated Output:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF7C3AED))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          generatedResult,
                          style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF150D33), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF7C3AED)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF7C3AED)),
                              label: const Text('Copy', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 12)),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: generatedResult));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Result copied to clipboard! 📋')));
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.note_add_rounded, size: 14, color: Colors.white),
                              label: const Text('Save to Note', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CreateNoteScreen(
                                      existingNote: NoteModel(
                                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                                        title: '${tool.title} Result',
                                        content: generatedResult,
                                        tag: 'Ideas',
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ── 5. "Try these examples" Section ──

  Widget _buildExamplePromptsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Try these examples',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFF150D33),
              ),
            ),
            InkWell(
              onTap: () {},
              child: const Text(
                'View all',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),

        // Horizontal Scrollable Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _examplePrompts.map((prompt) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _promptController.text = prompt['label'] as String;
                    },
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24.0,
                            height: 24.0,
                            decoration: BoxDecoration(
                              color: prompt['bgColor'] as Color,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              prompt['icon'] as IconData,
                              size: 13.0,
                              color: prompt['iconColor'] as Color,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            prompt['label'] as String,
                            style: const TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF150D33),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 6. Segmented Control & AI Chat Input Card
  // ─────────────────────────────────────────────

  Widget _buildAiChatInputCard() {
    return Column(
      children: [
        // Top Segmented Control (Ask AI vs Paste Text)
        Container(
          height: 42.0,
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9F6),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            children: [
              // Segment 1: Ask AI
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeSegmentIndex = 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _activeSegmentIndex == 0 ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(13.0),
                      boxShadow: _activeSegmentIndex == 0
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 14.0,
                          color: _activeSegmentIndex == 0
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF8C88A6),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          'Ask AI',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: _activeSegmentIndex == 0
                                ? const Color(0xFF7C3AED)
                                : const Color(0xFF8C88A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Segment 2: Paste Text
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeSegmentIndex = 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _activeSegmentIndex == 1 ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(13.0),
                      boxShadow: _activeSegmentIndex == 1
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 14.0,
                          color: _activeSegmentIndex == 1
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF8C88A6),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          'Paste Text',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: _activeSegmentIndex == 1
                                ? const Color(0xFF7C3AED)
                                : const Color(0xFF8C88A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),

        // Main Chat Input Box Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFECE9F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prompt TextField Row with Left Mic Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Mic Button for Voice Dictation
                  GestureDetector(
                    onTap: () {
                      SpeechToTextService.listenAndDictate(
                        context: context,
                        title: 'AI Prompt Dictation',
                        onTextRecognized: (text) {
                          setState(() {
                            _promptController.text = _promptController.text.trim().isEmpty
                                ? text
                                : '${_promptController.text} $text';
                          });
                        },
                      );
                    },
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      margin: const EdgeInsets.only(top: 2.0, right: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDFF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.mic_rounded, size: 19.0, color: Color(0xFF7C3AED)),
                      ),
                    ),
                  ),

                  // Text Area
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      maxLines: 3,
                      minLines: 1,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF150D33),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ask AI anything or tap mic to speak...',
                        hintStyle: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFA8A4C6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),

              // Bottom Action Dock Row: Clip & Gallery Attachments + Send Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Clip Attachment Icon
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                            builder: (ctx) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Attach File to Prompt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
                                    const SizedBox(height: 14),
                                    ListTile(
                                      leading: const Icon(Icons.description_rounded, color: Color(0xFF7C3AED)),
                                      title: const Text('Attach Note Document'),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        setState(() => _promptController.text += ' [Attached Note: Project Ideas] ');
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                                      title: const Text('Attach PDF Document'),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        setState(() => _promptController.text += ' [Attached File: Document.pdf] ');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.attach_file_rounded,
                            size: 20.0, color: Color(0xFF7C3AED)),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6.0),
                      ),
                      const SizedBox(width: 4.0),
                      // Gallery Image Icon
                      IconButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              _promptController.text += ' [Image Attached: ${image.name}] ';
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Image attached: ${image.name} 🖼️')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.image_outlined,
                            size: 20.0, color: Color(0xFF7C3AED)),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6.0),
                      ),
                    ],
                  ),

                  // Send FAB Button (Gradient Purple Circular)
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                          blurRadius: 10.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (_promptController.text.isNotEmpty) {
                            _promptController.clear();
                          }
                        },
                        customBorder: const CircleBorder(),
                        child: const Center(
                          child: Icon(Icons.send_rounded, color: Colors.white, size: 18.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 7. Recent AI History Section
  // ─────────────────────────────────────────────

  Widget _buildRecentAiHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent AI History',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFF150D33),
              ),
            ),
            InkWell(
              onTap: () {},
              child: const Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),

        Column(
          children: _recentHistory.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: item.iconBg,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 16.0),
                    ),
                    const SizedBox(width: 10.0),

                    // Title
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF150D33),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),

                    // Time String
                    Text(
                      item.timeStr,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9C98B6),
                      ),
                    ),
                    const SizedBox(width: 6.0),

                    // Overflow menu icon
                    const Icon(Icons.more_horiz_rounded, size: 16.0, color: Color(0xFF9C98B6)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 8. Bottom Navigation Bar
  // ─────────────────────────────────────────────

  Widget _buildBottomNavigationBar() {
    final navItems = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Notes', 'icon': Icons.description_rounded},
      {'label': 'AI Tools', 'icon': Icons.auto_awesome_rounded},
      {'label': 'Categories', 'icon': Icons.folder_rounded},
      {'label': 'Profile', 'icon': Icons.person_rounded},
    ];

    return Container(
      height: 64.0,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navItems.length, (index) {
          final isSelected = _currentBottomNavIndex == index;
          final item = navItems[index];

          if (isSelected) {
            return Flexible(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EDFF),
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'] as IconData, size: 20.0, color: const Color(0xFF7C3AED)),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        item['label'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Flexible(
            flex: 2,
            child: InkWell(
              onTap: () {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                } else if (index == 1 || index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  );
                } else if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                } else {
                  setState(() {
                    _currentBottomNavIndex = index;
                  });
                }
              },
              borderRadius: BorderRadius.circular(16.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 20.0,
                      color: const Color(0xFF9C98B6),
                    ),
                    const SizedBox(height: 2.0),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item['label'] as String,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9C98B6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showAiHistoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history_rounded, color: Color(0xFF7C3AED), size: 22),
                      SizedBox(width: 8),
                      Text('AI Prompt History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF8C88A6)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._recentHistory.map((h) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: h.iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(h.icon, color: h.iconColor, size: 18),
                ),
                title: Text(h.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF150D33))),
                subtitle: Text(h.timeStr, style: const TextStyle(fontSize: 11, color: Color(0xFF8C88A6))),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _promptController.text = h.title);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showAiOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDD5FA), borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 16),
              const Text('AI Assistant Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.tune_rounded, color: Color(0xFF7C3AED)),
                title: const Text('Customize AI Tools', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Pin & arrange your favorite AI tools'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCustomizeAiToolsModal();
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
                title: const Text('Clear AI History', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                subtitle: const Text('Remove all stored prompt history'),
                onTap: () {
                  Navigator.pop(ctx);
                  AudioHapticService.playButtonSound();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI History cleared cleanly! 🧹')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomizeAiToolsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Customize AI Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
                        IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Toggle & pin your favorite AI tools on the Home & AI screens:', style: TextStyle(fontSize: 12, color: Color(0xFF6E6A8A))),
                    const SizedBox(height: 14),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _aiTools.length,
                        itemBuilder: (context, index) {
                          final tool = _aiTools[index];
                          final isEnabled = _enabledToolIds.contains(tool.id);
                          return CheckboxListTile(
                            value: isEnabled,
                            activeColor: const Color(0xFF7C3AED),
                            title: Text(tool.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(tool.subtitle, style: const TextStyle(fontSize: 11)),
                            onChanged: (bool? val) {
                              AudioHapticService.playButtonSound();
                              setModalState(() {
                                if (val == true) {
                                  _enabledToolIds.add(tool.id);
                                } else {
                                  if (_enabledToolIds.length > 1) {
                                    _enabledToolIds.remove(tool.id);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('At least 1 AI tool must remain enabled!')),
                                    );
                                  }
                                }
                              });
                              setState(() {});
                              _settingsRepo.setEnabledAiTools(_enabledToolIds.toList());
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
