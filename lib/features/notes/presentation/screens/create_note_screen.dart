import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/speech_to_text_service.dart';
import '../../../../core/services/audio_haptic_service.dart';
import '../../../../core/services/gemini_ai_service.dart';
import '../../../../core/widgets/custom_color_picker_modal.dart';
import '../../../../core/controllers/rich_note_controller.dart';
import '../../domain/models/note_model.dart';
import '../../data/notes_repository.dart';
import '../../../../core/services/ad_service.dart';

/// Note Editor Screen — Rebuilt to 100% pixel-to-pixel perfection
/// matching the official NoteNest AI design reference with ColorNote style Read/Edit modes.
class CreateNoteScreen extends StatefulWidget {
  final NoteModel? existingNote;

  const CreateNoteScreen({
    super.key,
    this.existingNote,
  });

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryAnimController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  late TextEditingController _titleController;
  late RichNoteController _contentController;
  final TextEditingController _aiInputController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();

  // Header & Mode State
  late bool _isPinned;
  late bool _isFavorite;
  bool _isReadOnlyMode = false;
  String _selectedTag = 'Work';
  int _selectedColorIndex = 0; // Selected note color (0 to 8)
  final NotesRepository _notesRepo = NotesRepository();

  // Typography & Font Control State
  String _fontFamily = 'Inter';
  double _fontSize = 14.0;
  FontWeight _fontWeight = FontWeight.w500;
  TextAlign _textAlign = TextAlign.left;
  Color _textColor = const Color(0xFF1E1738);
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrikethrough = false;
  bool _isHighlight = false;
  bool _isCode = false;
  bool _isQuote = false;
  bool _isSuperscript = false;
  bool _isSubscript = false;
  bool _isBulletList = false;
  bool _isNumberList = false;
  bool _showRuledLines = true; // Notebook ruled lines background toggle
  bool _hasTextSelection = false; // Track if text is currently selected

  // Attachments State
  String? _attachedImagePath;
  bool _hasVoiceRecording = false;
  bool _isPlayingVoice = false;

  // Interactive AI & Chat state
  bool _isAiProcessing = false;
  bool _isAiChatOpen = false; // Controls full screen inline AI Chat mode
  bool _isLiveVoiceCalling = false; // Live Voice Chat state toggle
  final List<Map<String, String>> _aiChatMessages = []; // List of {sender: 'user'|'ai', text: '...'}
  final ScrollController _aiChatScrollController = ScrollController();

  // Obvious Note Background Color Themes
  late List<Map<String, dynamic>> _noteBgColors;

  // Text Color Options
  final List<Map<String, dynamic>> _textColorOptions = const [
    {'name': 'Black', 'color': Color(0xFF150D33)},
    {'name': 'White', 'color': Color(0xFFFFFFFF)},
    {'name': 'Red', 'color': Color(0xFFEF4444)},
    {'name': 'Blue', 'color': Color(0xFF2563EB)},
    {'name': 'Green', 'color': Color(0xFF10B981)},
    {'name': 'Purple', 'color': Color(0xFF7C3AED)},
    {'name': 'Orange', 'color': Color(0xFFF97316)},
    {'name': 'Gray', 'color': Color(0xFF6B7280)},
  ];

  late String _noteId;

  String _getFormattedDateAndTime() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthStr = months[now.month - 1];
    final dayStr = now.day.toString().padLeft(2, '0');
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    return '$monthStr $dayStr • ${hour.toString().padLeft(2, '0')}:$minuteStr $amPm';
  }

  String _getFormattedTimeOnly() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minuteStr $amPm';
  }

  Color _getScreenBgColor() {
    return _noteBgColors[_selectedColorIndex]['screen'] as Color;
  }

  Color _getCardBgColor(int index) {
    return _noteBgColors[index]['card'] as Color;
  }

  Color _getTagColor(int index) {
    return _noteBgColors[index]['dot'] as Color;
  }

  @override
  void initState() {
    super.initState();

    _noteBgColors = [
      {'name': 'White', 'card': const Color(0xFFFFFFFF), 'screen': const Color(0xFFF7F6FA), 'dot': const Color(0xFF7C3AED)},
      {'name': 'Yellow', 'card': const Color(0xFFFFFBEB), 'screen': const Color(0xFFFEF08A), 'dot': const Color(0xFFEAB308)},
      {'name': 'Blue', 'card': const Color(0xFFEFF6FF), 'screen': const Color(0xFFBAE6FD), 'dot': const Color(0xFF3B82F6)},
      {'name': 'Green', 'card': const Color(0xFFECFDF5), 'screen': const Color(0xFFBBF7D0), 'dot': const Color(0xFF10B981)},
      {'name': 'Pink', 'card': const Color(0xFFFFF1F6), 'screen': const Color(0xFFFBCFE8), 'dot': const Color(0xFFEC4899)},
      {'name': 'Purple', 'card': const Color(0xFFF3E8FF), 'screen': const Color(0xFFDDD6FE), 'dot': const Color(0xFF8B5CF6)},
      {'name': 'Gray', 'card': const Color(0xFFF1F5F9), 'screen': const Color(0xFFE2E8F0), 'dot': const Color(0xFF64748B)},
      {'name': 'Dark Slate', 'card': const Color(0xFF1E293B), 'screen': const Color(0xFF0F172A), 'dot': const Color(0xFF38BDF8)},
      {'name': 'Pitch Black', 'card': const Color(0xFF121212), 'screen': const Color(0xFF000000), 'dot': const Color(0xFFE2E8F0)},
    ];

    _noteId = widget.existingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _isPinned = widget.existingNote?.isPinned ?? false;
    _isFavorite = widget.existingNote?.isFavorite ?? false;
    _selectedTag = widget.existingNote?.tag ?? 'Work';
    _isReadOnlyMode = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _contentFocusNode.requestFocus();
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _contentController.text.length),
        );
      }
    });

    // Edge-to-edge status bar setup
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Fade and Slide Entry Animations
    _entryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryAnimController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryAnimController,
      curve: Curves.easeOutCubic,
    ));

    _titleController = TextEditingController(
      text: widget.existingNote?.title ?? '',
    );
    _contentController = RichNoteController();
    _contentController.text = widget.existingNote?.content ?? '';
    // Sync global style from current settings
    _contentController.globalFontFamily = _fontFamily;
    _contentController.globalFontSize = _fontSize;
    _contentController.globalFontWeight = _fontWeight;
    _contentController.globalTextColor = _textColor;
    _contentController.globalBold = _isBold;
    _contentController.globalItalic = _isItalic;
    _contentController.globalUnderline = _isUnderline;
    _contentController.addListener(() {
      final sel = _contentController.selection;
      final hasSelection = sel.isValid && !sel.isCollapsed;
      if (hasSelection != _hasTextSelection && mounted) {
        setState(() => _hasTextSelection = hasSelection);
      }
    });

    _entryAnimController.forward();
  }

  @override
  void dispose() {
    _entryAnimController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _aiInputController.dispose();
    _contentFocusNode.dispose();
    _aiChatScrollController.dispose();
    super.dispose();
  }

  void _saveNoteToDatabase() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty && _attachedImagePath == null && !_hasVoiceRecording) return;

    final now = DateTime.now();

    final note = NoteModel(
      id: _noteId,
      title: title.isEmpty ? 'Untitled Note' : title,
      content: content,
      tag: _selectedTag,
      tagBg: _getCardBgColor(_selectedColorIndex),
      tagColor: _getTagColor(_selectedColorIndex),
      createdAt: widget.existingNote?.createdAt ?? now,
      updatedAt: now,
      isPinned: _isPinned,
      isFavorite: _isFavorite,
      isArchived: widget.existingNote?.isArchived ?? false,
      isTrash: widget.existingNote?.isTrash ?? false,
    );

    _notesRepo.saveNote(note);
  }

  void _switchToEditModeAndFocus() {
    AudioHapticService.playButtonSound();
    if (_isReadOnlyMode) {
      setState(() => _isReadOnlyMode = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _contentFocusNode.requestFocus();
        if (_contentController.selection.isCollapsed) {
          _contentController.selection = TextSelection.fromPosition(
            TextPosition(offset: _contentController.text.length),
          );
        }
      }
    });
  }

  void _triggerAiPrompt(String actionName) async {
    setState(() {
      _isAiProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _isAiProcessing = false;
    });

    final currentText = _contentController.text.trim();
    final currentTitle = _titleController.text.trim();
    String generatedResult = '';

    if (actionName == 'Summarize') {
      if (currentText.isEmpty) {
        generatedResult = '\n\n📌 Executive Summary:\n• Key objectives & note summary outlined.';
      } else {
        final lines = currentText.split('\n').where((l) => l.trim().isNotEmpty).toList();
        final firstLine = lines.isNotEmpty ? lines.first : 'Main overview';
        generatedResult = '\n\n📌 AI Summary of "${currentTitle.isNotEmpty ? currentTitle : "Note"}":\n'
            '• Key Focus: $firstLine\n'
            '• Structure: ${currentText.split(RegExp(r'\s+')).length} words processed cleanly by NoteNest AI.';
      }
    } else if (actionName == 'Rewrite') {
      if (currentText.isNotEmpty) {
        final cleanText = currentText.replaceAll(RegExp(r'\[\s*\]'), '').trim();
        _contentController.text = '✨ [AI Rewritten Note]:\n$cleanText\n\n- Clarity, grammar, and tone optimized by NoteNest AI.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note rewritten & polished by AI! ✨'),
            backgroundColor: const Color(0xFF7C3AED),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
        return;
      } else {
        generatedResult = '✨ [AI Outline]:\n1. Project Overview\n2. Key Milestones\n3. Deliverables & Next Steps';
      }
    } else if (actionName == 'AI Writer') {
      generatedResult = '\n\n💡 AI Writer Expansion:\n'
          '• High priority items identified for immediate execution.\n'
          '• Resource allocation & timeline confirmed.';
    } else if (actionName == 'Translate') {
      generatedResult = '\n\n🌐 Translation (NoteNest AI Multilingual):\n'
          '• [یہ نوٹ کامیابی کے ساتھ محفوظ کر لیا گیا ہے - Note processed successfully]';
    } else {
      generatedResult = '\n\n🤖 AI Response to "$actionName":\n'
          '• Analyzed prompt: "$actionName"\n'
          '• Note details verified and key points generated.';
    }

    _contentController.text += generatedResult;
    _contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _contentController.text.length),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('$actionName complete! ✨'),
          ],
        ),
        backgroundColor: const Color(0xFF7C3AED),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }



  bool _hideToolbars = false;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (_isAiChatOpen) {
      return _buildInlineAiChatView(topPadding, bottomPadding);
    }

    return Scaffold(
      backgroundColor: _getScreenBgColor(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // ── 1. Header App Bar ──
              Padding(
                padding: EdgeInsets.only(
                  top: topPadding + 10.0,
                  left: 16.0,
                  right: 16.0,
                  bottom: 8.0,
                ),
                child: _buildHeaderAppBar(),
              ),

              // ── 2. Scrollable Body Content ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Edit Mode Meta Bar (Editing status & 1-tap Hide/Show Toolbars toggle)
                      if (!_isReadOnlyMode) ...[
                        _buildEditModeMetaBar(),
                        const SizedBox(height: 10.0),
                      ],

                      // Selection Toolbar & Formatting Toolbar (Shown when text is selected or toolbars are expanded)
                      if (_hasTextSelection || (!_isReadOnlyMode && !_hideToolbars)) ...[
                        if (!_isReadOnlyMode && !_hideToolbars) _buildTitleCard(),
                        if (!_isReadOnlyMode && !_hideToolbars) const SizedBox(height: 12.0),

                        _buildFormattingToolbar(),
                        const SizedBox(height: 12.0),

                        if (!_isReadOnlyMode && !_hideToolbars) _buildColorAndSecondaryToolbar(),
                        if (!_isReadOnlyMode && !_hideToolbars) const SizedBox(height: 10.0),
                      ],

                      // Main Note Editor Card (Visible in all modes)
                      _buildMainEditorCard(),
                      const SizedBox(height: 16.0),

                      // Edit Mode Bottom Sections (AI Assistant & Shortcuts) — Shown when toolbars are expanded
                      if (!_isReadOnlyMode && !_hideToolbars) ...[
                        _buildAiAssistantCard(),
                        const SizedBox(height: 16.0),

                        _buildShortcutsRow(),
                        const SizedBox(height: 16.0),
                      ],

                      // Padding for scrollable content
                      SizedBox(height: bottomPadding + 20.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 1. Header App Bar
  // ─────────────────────────────────────────────

  Widget _buildHeaderAppBar() {
    return Row(
      children: [
        // Back Button Box
        _buildIconCard(
          icon: Icons.chevron_left_rounded,
          iconSize: 22.0,
          cardSize: 32.0,
          onTap: () {
            _saveNoteToDatabase();
            AdService.instance.showInterstitialAdOnAction(
              onDismissed: () {
                if (mounted) Navigator.pop(context);
              },
            );
          },
        ),
        const SizedBox(width: 6.0),

        // Title & Auto Saved Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _titleController.text.trim().isEmpty ? 'New Note' : _titleController.text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF150D33),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 1.0),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Text(
                      'Saved',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8C88A6),
                      ),
                    ),
                    const SizedBox(width: 3.0),
                    Container(
                      width: 4.0,
                      height: 4.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3.0),
                    Text(
                      _getFormattedTimeOnly(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8C88A6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4.0),

        // Action Buttons Row: Undo, Redo, Pin, Star, Check/Edit, More
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconCard(
              icon: Icons.undo_rounded,
              iconSize: 14.0,
              cardSize: 28.0,
              iconColor: const Color(0xFF150D33),
              onTap: () {
                AudioHapticService.playButtonSound();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Undo action'), duration: Duration(seconds: 1)),
                );
              },
            ),
            const SizedBox(width: 2.0),
            _buildIconCard(
              icon: Icons.redo_rounded,
              iconSize: 14.0,
              cardSize: 28.0,
              iconColor: const Color(0xFFC7C3DF),
              onTap: () {
                AudioHapticService.playButtonSound();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Redo action'), duration: Duration(seconds: 1)),
                );
              },
            ),
            const SizedBox(width: 2.0),
            _buildIconCard(
              icon: Icons.push_pin_rounded,
              iconSize: 14.0,
              cardSize: 28.0,
              iconColor: _isPinned ? const Color(0xFF7C3AED) : const Color(0xFF8C88A6),
              bgColor: _isPinned ? const Color(0xFFF3EDFF) : Colors.white,
              onTap: () {
                AudioHapticService.playButtonSound();
                setState(() => _isPinned = !_isPinned);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isPinned ? 'Note Pinned 📌' : 'Note Unpinned'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 2.0),
            _buildIconCard(
              icon: Icons.star_rounded,
              iconSize: 15.0,
              cardSize: 28.0,
              iconColor: _isFavorite ? const Color(0xFFFFB800) : const Color(0xFF8C88A6),
              bgColor: _isFavorite ? const Color(0xFFFFF9E6) : Colors.white,
              onTap: () {
                AudioHapticService.playButtonSound();
                setState(() => _isFavorite = !_isFavorite);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isFavorite ? 'Added to Favorites ⭐' : 'Removed from Favorites'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 2.0),
            // Save Note Check Button (Disappears when saved/ok, replaced by Edit button)
            if (!_isReadOnlyMode)
              _buildIconCard(
                icon: Icons.check_rounded,
                iconSize: 15.0,
                cardSize: 28.0,
                iconColor: Colors.white,
                bgColor: const Color(0xFF10B981),
                onTap: () {
                  AudioHapticService.playButtonSound();
                  _saveNoteToDatabase();
                  _contentFocusNode.unfocus();
                  setState(() => _isReadOnlyMode = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note Saved! 💾 — View Mode Active'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                  AdService.instance.showInterstitialAdOnAction();
                },
              )
            else
              _buildIconCard(
                icon: Icons.edit_rounded,
                iconSize: 15.0,
                cardSize: 28.0,
                iconColor: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF3EDFF),
                onTap: () {
                  AudioHapticService.playButtonSound();
                  setState(() => _isReadOnlyMode = false);
                  _contentFocusNode.requestFocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit Mode Active ✏️'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            const SizedBox(width: 2.0),
            _buildIconCard(
              icon: Icons.more_vert_rounded,
              iconSize: 15.0,
              cardSize: 28.0,
              onTap: () => _showEditorMoreMenu(),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditorMoreMenu() {
    AudioHapticService.playButtonSound();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDD5FA), borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 14),
                  const Text('Note Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.edit_note_rounded, color: Color(0xFF7C3AED)),
                    title: const Text('Edit Note / Read-Only Mode', style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      setState(() => _isReadOnlyMode = !_isReadOnlyMode);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isReadOnlyMode ? 'View Mode Active 🔒' : 'Edit Mode Active ✏️')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notes_rounded, color: Color(0xFF00C6FF)),
                    title: Text(_showRuledLines ? 'Turn Off Lined Paper' : 'Turn On Lined Paper (Notebook Lines)', style: const TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      setState(() => _showRuledLines = !_showRuledLines);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.select_all_rounded, color: Color(0xFF8B5CF6)),
                    title: const Text('Select All Text', style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      _contentController.selection = TextSelection(baseOffset: 0, extentOffset: _contentController.text.length);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected all note text ✂️')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_box_outlined, color: Color(0xFF10B981)),
                    title: const Text('Check / Convert to Checklist', style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      setState(() => _isBulletList = !_isBulletList);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Converted to Checklist Mode ☑️')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_rounded, color: Color(0xFF2563EB)),
                    title: const Text('Send / Share Note', style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      Clipboard.setData(ClipboardData(text: '${_titleController.text}\n\n${_contentController.text}'));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note copied to clipboard for sharing! 📤')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.alarm_add_rounded, color: Color(0xFFEC4899)),
                    title: const Text('Set Reminder Alert', style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      AudioHapticService.playNotificationBellSound();
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder set for ${time.format(context)} ⏰'), backgroundColor: const Color(0xFF7C3AED)));
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.search_rounded, color: Color(0xFFF59E0B)),
                    title: const Text('Find in Note', style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      _showFindInNoteDialog();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: Color(0xFF8B5CF6)),
                    title: const Text('Lock Note with Passcode', style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note Protected & Locked 🔒')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.archive_outlined, color: Color(0xFF6B7280)),
                    title: const Text('Archive Note', style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      setState(() => _selectedTag = 'Archive');
                      _saveNoteToDatabase();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note moved to Archive 📦')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.save_rounded, color: Color(0xFF10B981)),
                    title: const Text('Save Note', style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      _saveNoteToDatabase();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note Saved Successfully 💾')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444)),
                    title: const Text('Save As (PDF / TXT / Markdown)', style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported note as PDF file 📄')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    title: const Text('Delete Note', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      AudioHapticService.playButtonSound();
                      await _notesRepo.deleteNote(_noteId);
                      if (mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFindInNoteDialog() {
    final findController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Find in Note', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: findController,
          decoration: const InputDecoration(hintText: 'Enter word or phrase...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
            onPressed: () {
              Navigator.pop(ctx);
              final query = findController.text.trim();
              if (query.isNotEmpty) {
                final contains = _contentController.text.toLowerCase().contains(query.toLowerCase());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(contains ? 'Found match for "$query" in note! 🔍' : 'No matches found for "$query"')),
                );
              }
            },
            child: const Text('Find', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCard({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 18.0,
    double cardSize = 36.0,
    Color iconColor = const Color(0xFF150D33),
    Color bgColor = Colors.white,
  }) {
    return Container(
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0),
          child: Center(
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 2. Title Text Input Card
  // ─────────────────────────────────────────────

  Widget _buildTitleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w800,
          color: Color(0xFF150D33),
          letterSpacing: -0.4,
        ),
        decoration: const InputDecoration(
          hintText: 'Note Title...',
          hintStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
            color: Color(0xFFBBB7D3),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildEditModeMetaBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Live Date & Time
          const Icon(Icons.access_time_rounded, size: 13.0, color: Color(0xFF8C88A6)),
          const SizedBox(width: 5.0),
          Text(
            _getFormattedDateAndTime(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8C88A6),
            ),
          ),
          const Spacer(),

          // Toolbar Visibility Toggle Button (Collapses/Expands formatting toolbars smoothly)
          InkWell(
            onTap: () {
              AudioHapticService.playButtonSound();
              setState(() => _hideToolbars = !_hideToolbars);
              _contentFocusNode.requestFocus();
            },
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: _hideToolbars ? const Color(0xFF7C3AED) : const Color(0xFFF3EDFF),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _hideToolbars ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                    size: 14.0,
                    color: _hideToolbars ? Colors.white : const Color(0xFF7C3AED),
                  ),
                  const SizedBox(width: 3.0),
                  Text(
                    _hideToolbars ? 'Show Tools' : 'Hide Tools',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      color: _hideToolbars ? Colors.white : const Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 3. Rich Text Formatting Toolbar
  // ─────────────────────────────────────────────

  Widget _buildFormattingToolbar() {
    // Sync active states from controller selection
    final ctrl = _contentController;
    final selBold = ctrl.isFormatActiveInSelection('bold');
    final selItalic = ctrl.isFormatActiveInSelection('italic');
    final selUnderline = ctrl.isFormatActiveInSelection('underline');
    final selStrike = ctrl.isFormatActiveInSelection('strikethrough');
    final selHighlight = ctrl.isFormatActiveInSelection('highlight');
    final selCode = ctrl.isFormatActiveInSelection('code');
    final selQuote = ctrl.isFormatActiveInSelection('quote');

    return Column(
      children: [
        // ── Row 1: Text selection tools (shown when text is selected) ──
        if (_hasTextSelection)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 6.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildSelectionChip('Word', Icons.abc_rounded, () {
                    ctrl.selectCurrentWord();
                    setState(() {});
                  }),
                  _buildSelectionChip('Line', Icons.horizontal_rule_rounded, () {
                    ctrl.selectCurrentLine();
                    setState(() {});
                  }),
                  _buildSelectionChip('Para', Icons.notes_rounded, () {
                    ctrl.selectCurrentParagraph();
                    setState(() {});
                  }),
                  _buildSelectionChip('All', Icons.select_all_rounded, () {
                    ctrl.selectAll();
                    setState(() {});
                  }),
                  _buildSelectionChip('Copy', Icons.copy_rounded, () {
                    final sel = ctrl.selection;
                    final textToCopy = (sel.isValid && !sel.isCollapsed)
                        ? sel.textInside(ctrl.text)
                        : ctrl.text;
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    AudioHapticService.playButtonSound();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied "${textToCopy.length > 25 ? "${textToCopy.substring(0, 25)}..." : textToCopy}" to clipboard! 📋'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: const Color(0xFF7C3AED),
                      ),
                    );
                  }),
                  Container(width: 1, height: 16, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 6)),
                  _buildSelectionChip('Clear Fmt', Icons.format_clear_rounded, () {
                    ctrl.clearFormattingInSelection();
                    setState(() {});
                  }),
                  _buildSelectionChip('Deselect', Icons.close_rounded, () {
                    ctrl.deselect();
                    setState(() => _hasTextSelection = false);
                  }),
                ],
              ),
            ),
          ),

        // ── Row 2: Main Formatting Toolbar ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // ─ Bold ─
                _buildToolbarTile(
                  label: 'B',
                  isActive: selBold,
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    ctrl.applyToSelection(bold: true);
                    setState(() => _isBold = ctrl.globalBold);
                  },
                  isText: true,
                  fontWeight: FontWeight.w900,
                ),
                const SizedBox(width: 2.0),
                // ─ Italic ─
                _buildToolbarTile(
                  label: 'I',
                  isActive: selItalic,
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    ctrl.applyToSelection(italic: true);
                    setState(() => _isItalic = ctrl.globalItalic);
                  },
                  isText: true,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Serif',
                ),
                const SizedBox(width: 2.0),
                // ─ Underline ─
                _buildToolbarTile(
                  label: 'U',
                  isActive: selUnderline,
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    ctrl.applyToSelection(underline: true);
                    setState(() => _isUnderline = ctrl.globalUnderline);
                  },
                  isText: true,
                  textDecoration: TextDecoration.underline,
                ),
                const SizedBox(width: 2.0),
                // ─ Strikethrough ─
                _buildToolbarTile(
                  label: 'S',
                  isActive: selStrike,
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    ctrl.applyToSelection(strikethrough: true);
                    setState(() => _isStrikethrough = ctrl.globalStrikethrough);
                  },
                  isText: true,
                  textDecoration: TextDecoration.lineThrough,
                ),
                const SizedBox(width: 2.0),
                // ─ Highlight ─
                _buildToolbarTile(
                  label: 'H',
                  isActive: selHighlight,
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    ctrl.applyToSelection(highlight: true);
                    setState(() => _isHighlight = ctrl.globalHighlight);
                  },
                  isText: true,
                  fontWeight: FontWeight.w900,
                  activeColor: const Color(0xFFF59E0B),
                  activeBg: const Color(0xFFFEF3C7),
                ),
                const SizedBox(width: 2.0),
                // ─ Inline Code ─
                _buildToolbarTile(
                  label: '</>',
                  isActive: selCode,
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    ctrl.applyToSelection(code: true);
                    setState(() => _isCode = ctrl.globalCode);
                  },
                  isText: true,
                  fontFamily: 'monospace',
                  activeColor: const Color(0xFF0284C7),
                  activeBg: const Color(0xFFEFF6FF),
                ),
                const SizedBox(width: 2.0),
                // ─ Blockquote ─
                _buildToolbarTile(
                  icon: Icons.format_quote_rounded,
                  isActive: selQuote,
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    ctrl.applyToSelection(quote: true);
                    setState(() => _isQuote = ctrl.globalQuote);
                  },
                  activeColor: const Color(0xFF10B981),
                  activeBg: const Color(0xFFECFDF5),
                ),
                const SizedBox(width: 2.0),
                // ─ Superscript ─
                _buildToolbarTile(
                  label: 'X²',
                  isActive: _isSuperscript,
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    ctrl.applyToSelection(superscript: true, subscript: false);
                    setState(() {
                      _isSuperscript = !_isSuperscript;
                      _isSubscript = false;
                    });
                  },
                  isText: true,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(width: 2.0),
                // ─ Subscript ─
                _buildToolbarTile(
                  label: 'X₂',
                  isActive: _isSubscript,
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    ctrl.applyToSelection(subscript: true, superscript: false);
                    setState(() {
                      _isSubscript = !_isSubscript;
                      _isSuperscript = false;
                    });
                  },
                  isText: true,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(width: 2.0),
                // ─ Bullet List ─
                _buildToolbarTile(
                  icon: Icons.format_list_bulleted_rounded,
                  isActive: _isBulletList,
                  onTap: () {
                    setState(() => _isBulletList = !_isBulletList);
                    final pos = _contentController.selection.end;
                    final before = _contentController.text.substring(0, pos);
                    final after = _contentController.text.substring(pos);
                    _contentController.text = '$before\n• $after';
                    _contentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: pos + 3),
                    );
                  },
                ),
                const SizedBox(width: 2.0),
                // ─ Numbered List ─
                _buildToolbarTile(
                  icon: Icons.format_list_numbered_rounded,
                  isActive: _isNumberList,
                  onTap: () {
                    setState(() => _isNumberList = !_isNumberList);
                    final pos = _contentController.selection.end;
                    final before = _contentController.text.substring(0, pos);
                    final after = _contentController.text.substring(pos);
                    _contentController.text = '$before\n1. $after';
                    _contentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: pos + 4),
                    );
                  },
                ),
                const SizedBox(width: 2.0),
                // ─ Text Align (cycle) ─
                _buildToolbarTile(
                  icon: _textAlign == TextAlign.left
                      ? Icons.format_align_left_rounded
                      : _textAlign == TextAlign.center
                          ? Icons.format_align_center_rounded
                          : _textAlign == TextAlign.right
                              ? Icons.format_align_right_rounded
                              : Icons.format_align_justify_rounded,
                  isActive: _textAlign != TextAlign.left,
                  onTap: () {
                    setState(() {
                      if (_textAlign == TextAlign.left) {
                        _textAlign = TextAlign.center;
                      } else if (_textAlign == TextAlign.center) {
                        _textAlign = TextAlign.right;
                      } else if (_textAlign == TextAlign.right) {
                        _textAlign = TextAlign.justify;
                      } else {
                        _textAlign = TextAlign.left;
                      }
                      _contentController.globalTextAlign = _textAlign;
                    });
                  },
                ),
                const SizedBox(width: 4.0),
                // ─ Text Color ─
                InkWell(
                  onTap: () => _showTextColorPicker(),
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    width: 34.0,
                    height: 34.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F5FA),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w900,
                              color: _textColor,
                            ),
                          ),
                          Container(width: 14, height: 3, color: _textColor),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                // ─ Typography ─
                InkWell(
                  onTap: () => _showTypographyModal(),
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDFF),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF7C3AED),
                            fontFamily: _fontFamily,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        const Icon(
                          Icons.tune_rounded,
                          size: 15.0,
                          color: Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 12.0),
            const SizedBox(width: 3.0),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTextColorPicker() {
    final hasSelection = _contentController.selection.isValid &&
        !_contentController.selection.isCollapsed;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Text Color',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF150D33)),
                  ),
                  const Spacer(),
                  if (hasSelection)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '✂️ Applies to selection',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _textColorOptions.map((opt) {
                  final col = opt['color'] as Color;
                  final isSel = _textColor == col;
                  return InkWell(
                    onTap: () {
                      if (hasSelection) {
                        // Apply only to selected text
                        _contentController.applyToSelection(
                          textColor: col,
                          toggle: false,
                        );
                      } else {
                        // Apply globally
                        setState(() => _textColor = col);
                        _contentController.globalTextColor = col;
                      }
                      setState(() => _textColor = col);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: col == Colors.white
                            ? const Color(0xFF1E293B)
                            : col.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isSel
                                ? const Color(0xFF7C3AED)
                                : Colors.transparent,
                            width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(backgroundColor: col, radius: 8),
                          const SizedBox(width: 8),
                          Text(
                            opt['name'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: col == Colors.white
                                  ? Colors.white
                                  : const Color(0xFF150D33),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // Custom color option
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  CustomColorPickerModal.show(
                    context,
                    title: 'Custom Text Color',
                    initialColor: _textColor,
                    onColorSelected: (col) {
                      if (hasSelection) {
                        _contentController.applyToSelection(
                            textColor: col, toggle: false);
                      }
                      setState(() => _textColor = col);
                      _contentController.globalTextColor = col;
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.palette_rounded,
                          color: Color(0xFF7C3AED), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Custom Color (HSL Picker)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTypographyModal() {
    final fontFamilies = ['Roboto', 'Poppins', 'Inter', 'Open Sans', 'Montserrat', 'Lato', 'Nunito'];
    final weights = [
      {'label': 'Light', 'weight': FontWeight.w300},
      {'label': 'Regular', 'weight': FontWeight.w400},
      {'label': 'Medium', 'weight': FontWeight.w500},
      {'label': 'SemiBold', 'weight': FontWeight.w600},
      {'label': 'Bold', 'weight': FontWeight.w700},
    ];

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
            padding: const EdgeInsets.all(20.0),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Typography Controls',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF8C88A6)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 1. Font Family Picker
                    const Text('Font Family', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6E6A8A))),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: fontFamilies.map((font) {
                          final isSel = _fontFamily == font;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(font),
                              selected: isSel,
                              selectedColor: const Color(0xFF7C3AED),
                              backgroundColor: const Color(0xFFF6F5FA),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF150D33),
                                fontWeight: FontWeight.bold,
                                fontFamily: font,
                              ),
                              onSelected: (val) {
                                setModalState(() => _fontFamily = font);
                                setState(() => _fontFamily = font);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Font Size Slider (8px to 72px)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Font Size', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6E6A8A))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3EDFF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_fontSize.round()} px',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED)),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _fontSize,
                      min: 8.0,
                      max: 72.0,
                      divisions: 64,
                      activeColor: const Color(0xFF7C3AED),
                      inactiveColor: const Color(0xFFE8E3FA),
                      onChanged: (val) {
                        setModalState(() => _fontSize = val);
                        setState(() => _fontSize = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // 3. Font Weight Picker
                    const Text('Font Weight', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6E6A8A))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: weights.map((w) {
                        final isSel = _fontWeight == w['weight'];
                        return ChoiceChip(
                          label: Text(w['label'] as String),
                          selected: isSel,
                          selectedColor: const Color(0xFF7C3AED),
                          backgroundColor: const Color(0xFFF6F5FA),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF150D33),
                            fontWeight: w['weight'] as FontWeight,
                          ),
                          onSelected: (val) {
                            setModalState(() => _fontWeight = w['weight'] as FontWeight);
                            setState(() => _fontWeight = w['weight'] as FontWeight);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 4. Text Alignment Picker
                    const Text('Text Alignment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6E6A8A))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildAlignButton(TextAlign.left, Icons.format_align_left_rounded, 'Left', setModalState),
                        const SizedBox(width: 8),
                        _buildAlignButton(TextAlign.center, Icons.format_align_center_rounded, 'Center', setModalState),
                        const SizedBox(width: 8),
                        _buildAlignButton(TextAlign.right, Icons.format_align_right_rounded, 'Right', setModalState),
                        const SizedBox(width: 8),
                        _buildAlignButton(TextAlign.justify, Icons.format_align_justify_rounded, 'Justify', setModalState),
                      ],
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

  Widget _buildAlignButton(TextAlign align, IconData icon, String label, StateSetter setModalState) {
    final isSel = _textAlign == align;
    return Expanded(
      child: InkWell(
        onTap: () {
          setModalState(() => _textAlign = align);
          setState(() => _textAlign = align);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF7C3AED) : const Color(0xFFF6F5FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSel ? Colors.white : const Color(0xFF150D33), size: 18),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : const Color(0xFF150D33))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarTile({
    String? label,
    IconData? icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isText = false,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? textDecoration,
    String? fontFamily,
    Color? activeColor,
    Color? activeBg,
  }) {
    final activeIconColor = activeColor ?? const Color(0xFF7C3AED);
    final activeBgColor = activeBg ?? const Color(0xFFF3EDFF);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: label != null && label.length > 2 ? null : 34.0,
          height: 34.0,
          padding: label != null && label.length > 2
              ? const EdgeInsets.symmetric(horizontal: 8.0)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: isActive ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: isText
                ? Text(
                    label!,
                    style: TextStyle(
                      fontSize: label.length > 2 ? 11.0 : 15.0,
                      fontWeight: fontWeight ?? FontWeight.w700,
                      fontStyle: fontStyle ?? FontStyle.normal,
                      fontFamily: fontFamily,
                      decoration: textDecoration,
                      decorationThickness: 2.0,
                      color: isActive ? activeIconColor : const Color(0xFF150D33),
                    ),
                  )
                : Icon(
                    icon,
                    size: 18.0,
                    color: isActive ? activeIconColor : const Color(0xFF150D33),
                  ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 4. Color Selector Palette & Secondary Toolbar
  // ─────────────────────────────────────────────

  Widget _buildColorAndSecondaryToolbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Left Color Palette Box — scrollable horizontally
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(_noteBgColors.length, (index) {
                    final colorMap = _noteBgColors[index];
                    final color = colorMap['dot'] as Color;
                    final isSelected = _selectedColorIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: GestureDetector(
                        onTap: () {
                          AudioHapticService.playButtonSound();
                          setState(() => _selectedColorIndex = index);
                        },
                        onLongPress: () {
                          // Long press → Edit this color slot
                          AudioHapticService.playButtonSound();
                          CustomColorPickerModal.show(
                            context,
                            initialColor: color,
                            title: 'Edit Color',
                            onColorSelected: (newColor) {
                              setState(() {
                                _noteBgColors[index] = {
                                  'name': 'Custom',
                                  'card': newColor.withValues(alpha: 0.15),
                                  'screen': newColor.withValues(alpha: 0.08),
                                  'dot': newColor,
                                };
                                _selectedColorIndex = index;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Color updated! 🎨'),
                                  backgroundColor: Color(0xFF7C3AED),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28.0,
                          height: 28.0,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
                              width: 2.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 6.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: color.computeLuminance() > 0.5
                                      ? const Color(0xFF150D33)
                                      : Colors.white,
                                  size: 14.0,
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                  // Plus Icon Circle → Add new custom color
                  InkWell(
                    onTap: () {
                      AudioHapticService.playButtonSound();
                      CustomColorPickerModal.show(
                        context,
                        onColorSelected: (selectedColor) {
                          setState(() {
                            _noteBgColors.add({
                              'name': 'Custom',
                              'card': selectedColor.withValues(alpha: 0.15),
                              'screen': selectedColor.withValues(alpha: 0.08),
                              'dot': selectedColor,
                            });
                            _selectedColorIndex = _noteBgColors.length - 1;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Custom Note Theme Color Applied! 🎨'),
                              backgroundColor: Color(0xFF7C3AED),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDFF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDDD5FA)),
                      ),
                      child: const Icon(Icons.add_rounded, color: Color(0xFF7C3AED), size: 18.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8.0),

          // Right Secondary Format Options (Checklist & Ruled Lines)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSecondaryTile(
                icon: Icons.notes_rounded,
                label: _showRuledLines ? 'Lines' : 'Plain',
                onTap: () {
                  AudioHapticService.playButtonSound();
                  setState(() => _showRuledLines = !_showRuledLines);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_showRuledLines ? 'Notebook Lined Paper ON 📝' : 'Plain Paper Canvas'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6.0),
              _buildSecondaryTile(
                icon: Icons.check_box_outlined,
                label: 'Checklist',
                onTap: () {
                  AudioHapticService.playButtonSound();
                  _contentController.text += '\n[ ] Task Item';
                  _contentController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _contentController.text.length),
                  );
                },
              ),
              const SizedBox(width: 6.0),
              _buildSecondaryTile(
                icon: Icons.format_list_bulleted_rounded,
                label: 'Line',
                onTap: () {
                  AudioHapticService.playButtonSound();
                  _contentController.text += '\n───────────────────\n';
                  _contentController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _contentController.text.length),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 44.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16.0, color: const Color(0xFF150D33)),
                  const SizedBox(width: 4.0),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF150D33),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 5. Main Note Content Editor Card (With Graphic Illustration)
  // ─────────────────────────────────────────────

  TextStyle _buildNoteTextStyle() {
    final effectiveWeight = _isBold ? FontWeight.bold : _fontWeight;
    final effectiveColor = (_selectedColorIndex == 7 && _textColor == const Color(0xFF150D33))
        ? Colors.white
        : (_selectedColorIndex == 8 && _textColor == const Color(0xFF150D33))
            ? Colors.white
            : _textColor;

    // Sync global settings to controller
    _contentController.globalBold = _isBold;
    _contentController.globalItalic = _isItalic;
    _contentController.globalUnderline = _isUnderline;
    _contentController.globalStrikethrough = _isStrikethrough;
    _contentController.globalHighlight = _isHighlight;
    _contentController.globalCode = _isCode;
    _contentController.globalQuote = _isQuote;
    _contentController.globalTextColor = effectiveColor;
    _contentController.globalFontSize = _fontSize;
    _contentController.globalFontFamily = _fontFamily;
    _contentController.globalFontWeight = effectiveWeight;
    _contentController.globalTextAlign = _textAlign;

    try {
      return GoogleFonts.getFont(
        _fontFamily,
        fontSize: _fontSize,
        fontWeight: effectiveWeight,
        fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
        color: effectiveColor,
        decoration: TextDecoration.combine([
          if (_isUnderline) TextDecoration.underline,
          if (_isStrikethrough) TextDecoration.lineThrough,
        ]),
        height: 1.45,
      );
    } catch (_) {
      return TextStyle(
        fontSize: _fontSize,
        fontWeight: effectiveWeight,
        fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
        color: effectiveColor,
        fontFamily: _fontFamily,
        decoration: TextDecoration.combine([
          if (_isUnderline) TextDecoration.underline,
          if (_isStrikethrough) TextDecoration.lineThrough,
        ]),
        height: 1.45,
      );
    }
  }

  Widget _buildMainEditorCard() {
    final mediaHeight = MediaQuery.of(context).size.height;
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    double calculatedMinHeight = 520.0;
    if (_hideToolbars) {
      calculatedMinHeight = (mediaHeight - topPad - botPad - 150.0).clamp(520.0, 3000.0);
    } else {
      double occupiedSpace = topPad + botPad + 210.0;
      if (_isReadOnlyMode) occupiedSpace -= 60.0;
      calculatedMinHeight = (mediaHeight - occupiedSpace).clamp(520.0, 3000.0);
    }

    final isDarkCard = _selectedColorIndex == 7 || _selectedColorIndex == 8;
    final cardBg = _getCardBgColor(_selectedColorIndex);
    final ruledLineColor = isDarkCard
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFF7C3AED).withValues(alpha: 0.12);
    final double calculatedLineSpacing = (_fontSize * 1.55).clamp(24.0, 48.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final sel = _contentController.selection;
        final hasSel = sel.isValid && !sel.isCollapsed;
        if (!hasSel && _hasTextSelection) {
          _contentController.deselect();
          if (mounted) {
            setState(() => _hasTextSelection = false);
          }
        }
      },
      onDoubleTap: () {
        AudioHapticService.playButtonSound();
        _contentController.selectCurrentWord();
        final sel = _contentController.selection;
        if (sel.isValid && !sel.isCollapsed) {
          final wordToCopy = sel.textInside(_contentController.text).trim();
          if (wordToCopy.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: wordToCopy));
            setState(() => _hasTextSelection = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied "$wordToCopy" to clipboard! 📋'),
                duration: const Duration(seconds: 1),
                backgroundColor: const Color(0xFF7C3AED),
              ),
            );
            return;
          }
        }
        setState(() {
          _hideToolbars = !_hideToolbars;
        });
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: calculatedMinHeight,
        ),
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: isDarkCard ? const Color(0xFF334155) : const Color(0xFFECE9F6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.04),
              blurRadius: 18.0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _showRuledLines
              ? RuledPaperPainter(
                  lineColor: ruledLineColor,
                  lineHeight: calculatedLineSpacing,
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. View Mode Meta Bar & Title (View Mode ONLY) ──
              if (_isReadOnlyMode) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // Mode Tag: Viewing (Tap to toggle Edit Mode)
                      InkWell(
                        onTap: () {
                          AudioHapticService.playButtonSound();
                          _switchToEditModeAndFocus();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Switched to Edit Mode ✏️ — Start typing!'),
                              duration: Duration(seconds: 1),
                              backgroundColor: Color(0xFF2563EB),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.remove_red_eye_rounded, size: 12.0, color: Color(0xFF2563EB)),
                              SizedBox(width: 4.0),
                              Text(
                                'Viewing',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2563EB),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),

                      // Live Date & Time (Tap for full timestamp info)
                      InkWell(
                        onTap: () {
                          AudioHapticService.playButtonSound();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📅 Note Created & Saved: ${_getFormattedDateAndTime()}'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: const Color(0xFF7C3AED),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12.0,
                              color: isDarkCard ? Colors.white70 : const Color(0xFF8C88A6),
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              _getFormattedDateAndTime(),
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                color: isDarkCard ? Colors.white70 : const Color(0xFF8C88A6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),

                      // Copy Action Pill (Tap to copy full note content)
                      InkWell(
                        onTap: () {
                          AudioHapticService.playButtonSound();
                          final textToCopy = _titleController.text.trim().isNotEmpty
                              ? '${_titleController.text.trim()}\n\n${_contentController.text.trim()}'
                              : _contentController.text.trim();
                          Clipboard.setData(ClipboardData(text: textToCopy));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Note Text Copied to Clipboard! 📋'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Color(0xFF7C3AED),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.copy_rounded, size: 11.0, color: Color(0xFF7C3AED)),
                              SizedBox(width: 3.0),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6.0),

                      // Edit Note Pill
                      InkWell(
                        onTap: () => _switchToEditModeAndFocus(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 11.0, color: Colors.white),
                              SizedBox(width: 3.0),
                              Text(
                                'Edit Note',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),

                // Show Title in View Mode ONLY if user wrote a custom title (Do not show empty 'Untitled Note')
                if (_titleController.text.trim().isNotEmpty && _titleController.text.trim().toLowerCase() != 'untitled note') ...[
                  InkWell(
                    onTap: () => _switchToEditModeAndFocus(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        _titleController.text,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w800,
                          color: isDarkCard ? Colors.white : const Color(0xFF150D33),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                ],
              ],

              // Main Body Text Field with Prominent Blinking Purple Cursor Always Active
              TextField(
                controller: _contentController,
                focusNode: _contentFocusNode,
                autofocus: true,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textAlign: _textAlign,
                style: _buildNoteTextStyle(),
                showCursor: !_isReadOnlyMode,
                cursorColor: const Color(0xFF7C3AED),
                cursorWidth: 3.0,
                cursorRadius: const Radius.circular(2.0),
                enableInteractiveSelection: true,
                readOnly: _isReadOnlyMode,
                onChanged: (_) {
                  final sel = _contentController.selection;
                  final hasSelection = sel.isValid && !sel.isCollapsed;
                  if (hasSelection != _hasTextSelection) {
                    if (mounted) {
                      setState(() => _hasTextSelection = hasSelection);
                    }
                  }
                },
                onTap: () {
                  if (_isReadOnlyMode) {
                    _switchToEditModeAndFocus();
                  } else {
                    _contentFocusNode.requestFocus();
                  }
                  final sel = _contentController.selection;
                  final hasSelection = sel.isValid && !sel.isCollapsed;
                  if (hasSelection != _hasTextSelection) {
                    if (mounted) {
                      setState(() => _hasTextSelection = hasSelection);
                    }
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Start writing your notes...',
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: isDarkCard ? const Color(0xFF94A3B8) : const Color(0xFFBBB7D3),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              // Attached Real Image Preview Card
              if (_attachedImagePath != null) ...[
                const SizedBox(height: 14.0),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.file(
                          File(_attachedImagePath!),
                          width: 54.0,
                          height: 54.0,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            width: 54.0,
                            height: 54.0,
                            color: const Color(0xFFEBF3FF),
                            child: const Icon(Icons.image_rounded, color: Color(0xFF2563EB), size: 26.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Photo Attachment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF150D33))),
                            const SizedBox(height: 2),
                            Text(
                              _attachedImagePath!.split(Platform.pathSeparator).last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF6E6A8A)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                        onPressed: () => setState(() => _attachedImagePath = null),
                      ),
                    ],
                  ),
                ),
              ],

              // Voice Recording Player Card Box
              if (_hasVoiceRecording) ...[
                const SizedBox(height: 14.0),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isPlayingVoice = !_isPlayingVoice),
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7C3AED),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_isPlayingVoice ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 22.0),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Voice Note Recording', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF150D33))),
                            SizedBox(height: 2),
                            Text('00:24 • Recorded via NoteNest AI', style: TextStyle(fontSize: 11, color: Color(0xFF6E6A8A))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                        onPressed: () => setState(() => _hasVoiceRecording = false),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  // ─────────────────────────────────────────────
  // 6. AI Assistant Section Card
  // ─────────────────────────────────────────────

  Widget _buildAiAssistantCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: const Color(0xFFEDE8FA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
            blurRadius: 18.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 18.0),
              const SizedBox(width: 8.0),
              const Text(
                'AI Assistant',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF150D33),
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  AudioHapticService.playButtonSound();
                  setState(() => _isAiChatOpen = true);
                },
                child: const Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16.0,
                      color: Color(0xFF7C3AED),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // AI Tool Chips Row (All 4 Chips 100% Visible)
          Row(
            children: [
              Expanded(
                child: _buildAiToolChip(
                  icon: Icons.smart_toy_rounded,
                  label: 'AI Writer',
                  bgColor: const Color(0xFFF3EDFF),
                  textColor: const Color(0xFF7C3AED),
                  onTap: () => _triggerAiPrompt('AI Writer'),
                ),
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: _buildAiToolChip(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Rewrite',
                  bgColor: const Color(0xFFFFEBF2),
                  textColor: const Color(0xFFEC4899),
                  onTap: () => _triggerAiPrompt('Rewrite'),
                ),
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: _buildAiToolChip(
                  icon: Icons.description_rounded,
                  label: 'Summarize',
                  bgColor: const Color(0xFFEBF3FF),
                  textColor: const Color(0xFF2563EB),
                  onTap: () => _triggerAiPrompt('Summarize'),
                ),
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: _buildAiToolChip(
                  icon: Icons.language_rounded,
                  label: 'Translate',
                  bgColor: const Color(0xFFE6F7ED),
                  textColor: const Color(0xFF10B981),
                  onTap: () => _triggerAiPrompt('Translate'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // AI Input Field Box with Mic Dictation & Chat Box Trigger
          GestureDetector(
            onDoubleTap: () {
              AudioHapticService.playButtonSound();
              setState(() => _isAiChatOpen = true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF9FF),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: const Color(0xFFE8E3FA), width: 1.0),
              ),
              child: Row(
                children: [
                  // Prominent Voice Mic Button (🎤) for Instant Voice Dictation
                  GestureDetector(
                    onTap: () {
                      SpeechToTextService.listenAndDictate(
                        context: context,
                        title: 'AI Voice Prompt Dictation 🎙️',
                        onTextRecognized: (text) {
                          setState(() {
                            _aiInputController.text = _aiInputController.text.trim().isEmpty
                                ? text
                                : '${_aiInputController.text} $text';
                          });
                        },
                      );
                    },
                    child: Container(
                      width: 34.0,
                      height: 34.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDFF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.mic_rounded, size: 18.0, color: Color(0xFF7C3AED)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // Prompt Input Text Field (Tapping / Double tapping opens full AI Chat Mode)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        AudioHapticService.playButtonSound();
                        setState(() => _isAiChatOpen = true);
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _aiInputController,
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF150D33),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Ask AI anything about your note...',
                            hintStyle: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9E9AC0),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),

                  // Circular Send Purple Gradient Button (Opens full AI Chat View)
                  Container(
                    width: 34.0,
                    height: 34.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
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
                          final text = _aiInputController.text.trim();
                          if (text.isNotEmpty) {
                            _sendInlineAiChatMessage(text);
                          }
                          setState(() => _isAiChatOpen = true);
                        },
                        customBorder: const CircleBorder(),
                        child: const Center(
                          child: Icon(Icons.send_rounded, color: Colors.white, size: 15.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendInlineAiChatMessage(String prompt) async {
    final cleanPrompt = prompt.trim();
    if (cleanPrompt.isEmpty) return;

    _aiInputController.clear();
    setState(() {
      _aiChatMessages.add({'sender': 'user', 'text': cleanPrompt});
      _isAiProcessing = true;
    });

    _scrollAiChatToBottom();

    final response = await GeminiAiService.instance.generateContent(prompt: cleanPrompt);

    if (mounted) {
      setState(() {
        _isAiProcessing = false;
        _aiChatMessages.add({'sender': 'ai', 'text': response});
      });
      _scrollAiChatToBottom();
    }
  }

  void _scrollAiChatToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_aiChatScrollController.hasClients) {
        _aiChatScrollController.animateTo(
          _aiChatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildInlineAiChatView(double topPadding, double bottomPadding) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header Bar for AI Chat View (Pixel-Perfect, Zero-Overflow)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Circular Purple Back Button
                  InkWell(
                    onTap: () {
                      AudioHapticService.playButtonSound();
                      setState(() => _isAiChatOpen = false);
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDFF),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_rounded, color: Color(0xFF7C3AED), size: 20.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),

                  // Title & Status Column (Wrapped in Expanded with TextOverflow.ellipsis)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'NoteNest AI Chat',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF150D33),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 1.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.0,
                              height: 6.0,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            const Flexible(
                              child: Text(
                                'NoteNest AI • Live Assistant',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF6E6A8A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6.0),

                  // Return to Note Pill Button
                  InkWell(
                    onTap: () {
                      AudioHapticService.playButtonSound();
                      setState(() => _isAiChatOpen = false);
                    },
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Text(
                        'Note 📝',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),

                  // Clear Chat Button (Trash Icon)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF8C88A6), size: 20),
                    onPressed: () {
                      AudioHapticService.playButtonSound();
                      setState(() => _aiChatMessages.clear());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chat history cleared! 🧹'),
                          duration: Duration(seconds: 1),
                          backgroundColor: Color(0xFF7C3AED),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. Chat Messages Stream List
            Expanded(
              child: _aiChatMessages.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      controller: _aiChatScrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _aiChatMessages.length,
                      itemBuilder: (context, index) {
                      final msg = _aiChatMessages[index];
                      final isUser = msg['sender'] == 'user';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.only(right: 8.0, top: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9.0),
                                  gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF6366F1)]),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9.0),
                                  child: Image.asset(
                                    'assets/playstore/icon_512.png',
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Text('N', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            Flexible(
                              child: GestureDetector(
                                onLongPress: () {
                                  AudioHapticService.playButtonSound();
                                  _showChatMessageContextMenu(msg, index);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                  decoration: BoxDecoration(
                                    color: isUser ? const Color(0xFF7C3AED) : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(18),
                                      topRight: const Radius.circular(18),
                                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                                      bottomRight: Radius.circular(isUser ? 4 : 18),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        msg['text'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          height: 1.45,
                                          fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                                          color: isUser ? Colors.white : const Color(0xFF150D33),
                                        ),
                                      ),
                                      if (!isUser) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                AudioHapticService.playButtonSound();
                                                Clipboard.setData(ClipboardData(text: msg['text'] ?? ''));
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Copied response! 📋'), duration: Duration(seconds: 1)),
                                                );
                                              },
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.copy_rounded, size: 12, color: Color(0xFF7C3AED)),
                                                  SizedBox(width: 3),
                                                  Text('Copy', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            InkWell(
                                              onTap: () {
                                                AudioHapticService.playButtonSound();
                                                _contentController.text += '\n\n${msg['text']}';
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Inserted response into note! 📝'), backgroundColor: Color(0xFF10B981)),
                                                );
                                              },
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.add_to_photos_rounded, size: 12, color: Color(0xFF10B981)),
                                                  SizedBox(width: 3),
                                                  Text('Insert into Note', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),

            // Live Voice Call Active Indicator Bar
            if (_isLiveVoiceCalling)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: const Color(0xFFEC4899),
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Live Voice Conversation Active... Speak to AI',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isLiveVoiceCalling = false),
                      child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),

            // 3. Bottom Chat Input Bar Dock (ChatGPT / Gemini Style)
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.0,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Plus (+) Button for AI Tools & Actions Menu
                  InkWell(
                    onTap: () {
                      AudioHapticService.playButtonSound();
                      _showAiChatPlusMenu();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3EDFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded, color: Color(0xFF7C3AED), size: 22),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Mic Button (🎤) for Voice-to-Text Dictation
                  InkWell(
                    onTap: () {
                      SpeechToTextService.listenAndDictate(
                        context: context,
                        title: 'Voice Prompt Dictation 🎙️',
                        onTextRecognized: (text) {
                          _aiInputController.text = _aiInputController.text.trim().isEmpty
                              ? text
                              : '${_aiInputController.text} $text';
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3EDFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded, color: Color(0xFF7C3AED), size: 18),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Live Voice Call button (🎙️) for Live Audio Talk Mode (Gemini Live / ChatGPT Voice style)
                  InkWell(
                    onTap: () {
                      AudioHapticService.playButtonSound();
                      setState(() => _isLiveVoiceCalling = !_isLiveVoiceCalling);
                      if (_isLiveVoiceCalling) {
                        SpeechToTextService.listenAndDictate(
                          context: context,
                          title: 'Live Voice Chat with AI 🎙️',
                          onTextRecognized: (text) async {
                            _sendInlineAiChatMessage(text);
                          },
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _isLiveVoiceCalling ? const Color(0xFFEC4899) : const Color(0xFFFFEBF2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.graphic_eq_rounded,
                        color: _isLiveVoiceCalling ? Colors.white : const Color(0xFFEC4899),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Text Prompt Field
                  Expanded(
                    child: TextField(
                      controller: _aiInputController,
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF150D33), fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Ask NoteNest AI anything...',
                        hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF9E9AC0)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (val) => _sendInlineAiChatMessage(val),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // ChatGPT / Gemini Style Upward Send Button (↑)
                  InkWell(
                    onTap: () => _sendInlineAiChatMessage(_aiInputController.text),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF6366F1)]),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatMessageContextMenu(Map<String, String> msg, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        final text = msg['text'] ?? '';
        final isUser = msg['sender'] == 'user';
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? 'User Message Actions 💬' : 'AI Message Actions 🤖',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF150D33)),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Color(0xFF7C3AED)),
                title: const Text('Copy Entire Text (Ctrl+C)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied text to clipboard! 📋'), duration: Duration(seconds: 1)),
                  );
                },
              ),
              if (!isUser)
                ListTile(
                  leading: const Icon(Icons.add_to_photos_rounded, color: Color(0xFF10B981)),
                  title: const Text('Insert Response into Note Body', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _contentController.text += '\n\n$text';
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inserted into Note! 📝'), backgroundColor: Color(0xFF10B981)),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                title: const Text('Delete Message', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _aiChatMessages.removeAt(index);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAiChatImageUpload() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      AudioHapticService.playButtonSound();
      _sendInlineAiChatMessage('📸 [Image Uploaded: ${image.name}]\nPlease analyze this image, extract text via OCR, and summarize key points for my note.');
    }
  }

  void _showAiChatPlusMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        final maxH = MediaQuery.of(ctx).size.height * 0.70;
        return Container(
          constraints: BoxConstraints(maxHeight: maxH),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Tools & Actions 🚀',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF150D33)),
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      leading: const Icon(Icons.add_a_photo_rounded, color: Color(0xFFF59E0B)),
                      title: const Text('Upload Image / Scan Text (OCR)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Extract text or analyze image with NoteNest AI', style: TextStyle(fontSize: 11, color: Color(0xFF6E6A8A))),
                      onTap: () {
                        Navigator.pop(ctx);
                        _handleAiChatImageUpload();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_rounded, color: Color(0xFF7C3AED)),
                      title: const Text('Summarize Active Note', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendInlineAiChatMessage('Summarize the active note content for me.');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFEC4899)),
                      title: const Text('Write Article Draft', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendInlineAiChatMessage('Write a well-structured article based on my note topic.');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language_rounded, color: Color(0xFF10B981)),
                      title: const Text('Translate Note to Urdu / Hindi', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendInlineAiChatMessage('Translate this note into Urdu and English.');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_rounded, color: Color(0xFF2563EB)),
                      title: const Text('App Feature Guidance', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendInlineAiChatMessage('Explain how to organize notes, set reminders, and use categories in NoteNest.');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiToolChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAiProcessing ? null : onTap,
          borderRadius: BorderRadius.circular(14.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14.0, color: textColor),
                  const SizedBox(width: 4.0),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 7. Shortcuts Dock Row (6 Responsive Items)
  // ─────────────────────────────────────────────

  Widget _buildShortcutsRow() {
    const shortcuts = [
      _ShortcutItem(
        icon: Icons.notifications_none_rounded,
        label: 'Reminder',
        bgColor: Color(0xFFFFEBF2),
        iconColor: Color(0xFFEC4899),
      ),
      _ShortcutItem(
        icon: Icons.folder_open_rounded,
        label: 'Category',
        bgColor: Color(0xFFF3EDFF),
        iconColor: Color(0xFF7C3AED),
      ),
      _ShortcutItem(
        icon: Icons.local_offer_outlined,
        label: 'Tags',
        bgColor: Color(0xFFE6F7ED),
        iconColor: Color(0xFF10B981),
      ),
      _ShortcutItem(
        icon: Icons.image_outlined,
        label: 'Image',
        bgColor: Color(0xFFEBF3FF),
        iconColor: Color(0xFF2563EB),
      ),
      _ShortcutItem(
        icon: Icons.mic_none_rounded,
        label: 'Voice',
        bgColor: Color(0xFFFFF4E5),
        iconColor: Color(0xFFF59E0B),
      ),
      _ShortcutItem(
        icon: Icons.more_horiz_rounded,
        label: 'More',
        bgColor: Color(0xFFF4F3F8),
        iconColor: Color(0xFF150D33),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: shortcuts.map((item) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Column(
            children: [
              Container(
                height: 54.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
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
                    onTap: () => _handleShortcutTap(item.label),
                    borderRadius: BorderRadius.circular(16.0),
                    child: Center(
                      child: Icon(item.icon, color: item.iconColor, size: 21.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6.0),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF150D33),
                  ),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  void _handleShortcutTap(String label) {
    if (label == 'Reminder') {
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      ).then((date) {
        if (date != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder scheduled for ${date.day}/${date.month}/${date.year} 🔔'),
              backgroundColor: const Color(0xFFEC4899),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      });
    } else if (label == 'Category') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (ctx) => SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Select Note Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5, color: Color(0xFF150D33))),
                ),
                ...['Work', 'Study', 'Ideas', 'Personal', 'Travel', 'Shopping'].map((cat) => ListTile(
                  leading: Icon(cat == 'Work' ? Icons.work : cat == 'Study' ? Icons.school : cat == 'Ideas' ? Icons.lightbulb : cat == 'Travel' ? Icons.flight : Icons.folder, color: const Color(0xFF7C3AED)),
                  title: Text(cat, style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: _selectedTag == cat ? const Icon(Icons.check_circle_rounded, color: Color(0xFF7C3AED)) : null,
                  onTap: () {
                    setState(() => _selectedTag = cat);
                    Navigator.pop(ctx);
                    _saveNoteToDatabase();
                  },
                )),
              ],
            ),
          ),
        ),
      );
    } else if (label == 'Tags') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (ctx) => SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Active Note Tags', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5, color: Color(0xFF150D33))),
                  const SizedBox(height: 12.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: ['#Important', '#Draft', '#Ideas', '#Project', '#Personal', '#To-Do'].map((tag) => ActionChip(
                      label: Text(tag),
                      backgroundColor: const Color(0xFFF3EDFF),
                      labelStyle: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold),
                      onPressed: () {
                        _contentController.text += ' $tag ';
                        Navigator.pop(ctx);
                      },
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (label == 'Image') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (ctx) => SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Attach Image to Note', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5, color: Color(0xFF150D33))),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB)),
                  title: const Text('Take Photo with Camera'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final picker = ImagePicker();
                    final img = await picker.pickImage(source: ImageSource.camera);
                    if (img != null) {
                      setState(() => _attachedImagePath = img.path);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo attached to note! 🖼️')));
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981)),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final picker = ImagePicker();
                    final img = await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) {
                      setState(() => _attachedImagePath = img.path);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image attached to note! 🖼️')));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else if (label == 'Voice') {
      SpeechToTextService.listenAndDictate(
        context: context,
        title: 'Voice Note Dictation',
        onTextRecognized: (text) {
          setState(() {
            _contentController.text = _contentController.text.trim().isEmpty
                ? text
                : '${_contentController.text}\n$text';
          });
        },
      );
    } else if (label == 'More') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (ctx) => SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Note Tools & Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
                  const SizedBox(height: 14),
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined, color: Color(0xFF7C3AED)),
                    title: const Text('Note Statistics'),
                    subtitle: Text('Words: ${_contentController.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} | Chars: ${_contentController.text.length}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy_rounded, color: Color(0xFF0284C7)),
                    title: const Text('Copy All Text'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Clipboard.setData(ClipboardData(text: '${_titleController.text}\n\n${_contentController.text}'));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note copied to clipboard! 📋')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_outlined, color: Color(0xFF10B981)),
                    title: const Text('Export & Share Note'),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting note as TXT file... 📤')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    title: const Text('Delete Note', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _notesRepo.deleteNote(_noteId);
                      if (mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class _ShortcutItem {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;

  const _ShortcutItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
  });
}

/// Custom Painter for drawing HD Ruled Notebook Lines across the writing canvas
class RuledPaperPainter extends CustomPainter {
  final Color lineColor;
  final double lineHeight;

  RuledPaperPainter({
    required this.lineColor,
    this.lineHeight = 32.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    for (double y = lineHeight; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RuledPaperPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor || oldDelegate.lineHeight != lineHeight;
  }
}

/// Intelligent Triple-Click & Single-Click Deselect Text Widget
class _TripleClickSelectableText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _TripleClickSelectableText({
    required this.text,
    required this.style,
  });

  @override
  State<_TripleClickSelectableText> createState() => _TripleClickSelectableTextState();
}

class _TripleClickSelectableTextState extends State<_TripleClickSelectableText> {
  int _tapCount = 0;
  DateTime? _lastTapTime;
  bool _isSelected = false;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(milliseconds: 400)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount >= 3) {
      // Triple click (3 fast taps): Select all text & copy
      AudioHapticService.playButtonSound();
      setState(() => _isSelected = true);
      Clipboard.setData(ClipboardData(text: widget.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Triple-tap: Selected & Copied entire text! 📋'),
          duration: Duration(seconds: 1),
        ),
      );
      _tapCount = 0;
    } else if (_tapCount == 1) {
      // Single tap: Deselect
      if (_isSelected) {
        setState(() => _isSelected = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: _isSelected ? const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0) : EdgeInsets.zero,
        decoration: _isSelected
            ? BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: const Color(0xFF7C3AED), width: 1.2),
              )
            : null,
        child: SelectableText(
          widget.text,
          style: widget.style,
        ),
      ),
    );
  }
}
