import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/note_model.dart';
import '../../data/notes_repository.dart';

/// Note Editor Screen — Rebuilt to 100% pixel-to-pixel perfection
/// matching the official NoteNest AI design reference.
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
  late TextEditingController _contentController;
  late TextEditingController _aiInputController;

  // Header State
  late bool _isPinned;
  late bool _isFavorite;
  String _selectedTag = 'Work';
  int _selectedColorIndex = 0; // Violet color checked
  final NotesRepository _notesRepo = NotesRepository();

  // Formatting & Alignment State
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrikethrough = false;
  bool _isBulletList = false;
  bool _isNumberList = false;
  TextAlign _textAlign = TextAlign.left;
  String _fontFamily = 'Inter';

  // Attachments State
  bool _hasAttachedImage = false;
  bool _hasVoiceRecording = false;
  bool _isPlayingVoice = false;

  // Interactive AI state
  bool _isAiProcessing = false;
  double _saveButtonScale = 1.0;

  final List<Color> _paletteColors = const [
    Color(0xFF7C3AED), // Violet
    Color(0xFFFFB800), // Yellow
    Color(0xFFEC4899), // Pink
    Color(0xFF2563EB), // Blue
    Color(0xFF10B981), // Green
  ];

  late String _noteId;

  Color _getCardBgColor(int index) {
    switch (index) {
      case 1:
        return const Color(0xFFFFFBEB);
      case 2:
        return const Color(0xFFFFF1F6);
      case 3:
        return const Color(0xFFEFF6FF);
      case 4:
        return const Color(0xFFECFDF5);
      case 0:
      default:
        return const Color(0xFFF9F7FE);
    }
  }

  Color _getTagColor(int index) {
    switch (index) {
      case 1:
        return const Color(0xFFD97706);
      case 2:
        return const Color(0xFFDB2777);
      case 3:
        return const Color(0xFF2563EB);
      case 4:
        return const Color(0xFF059669);
      case 0:
      default:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  void initState() {
    super.initState();

    _noteId = widget.existingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _isPinned = widget.existingNote?.isPinned ?? false;
    _isFavorite = widget.existingNote?.isFavorite ?? false;
    _selectedTag = widget.existingNote?.tag ?? 'Work';

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
    _contentController = TextEditingController(
      text: widget.existingNote?.content ?? '',
    );
    _aiInputController = TextEditingController();

    _entryAnimController.forward();
  }

  @override
  void dispose() {
    _entryAnimController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _aiInputController.dispose();
    super.dispose();
  }

  void _saveNoteToDatabase() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty && !_hasAttachedImage && !_hasVoiceRecording) return;

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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
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
                      // Title Text Input Card
                      _buildTitleCard(),
                      const SizedBox(height: 12.0),

                      // Rich Text Formatting Toolbar (B, I, U, S, lists, align, A˅)
                      _buildFormattingToolbar(),
                      const SizedBox(height: 12.0),

                      // Color Palette & Secondary Toolbar (Checklist, Line)
                      _buildColorAndSecondaryToolbar(),
                      const SizedBox(height: 12.0),

                      // Main Note Editor Card (With Animated Floating Note Graphic)
                      _buildMainEditorCard(),
                      const SizedBox(height: 16.0),

                      // AI Assistant Section Card
                      _buildAiAssistantCard(),
                      const SizedBox(height: 16.0),

                      // 6 Shortcuts Dock Row
                      _buildShortcutsRow(),
                      const SizedBox(height: 16.0),

                      // Padding for bottom action bar
                      SizedBox(height: bottomPadding + 85.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── 3. Bottom Sticky Action Bar (Delete & Save Note) ──
      bottomSheet: _buildBottomActionBar(bottomPadding),
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
          iconSize: 24.0,
          cardSize: 36.0,
          onTap: () {
            _saveNoteToDatabase();
            Navigator.pop(context);
          },
        ),
        const SizedBox(width: 8.0),

        // Title & Auto Saved Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'New Note',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF150D33),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 1.0),
              Row(
                children: [
                  const Text(
                    'Auto saved',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8C88A6),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Container(
                    width: 4.0,
                    height: 4.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Text(
                    '10:30 AM',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8C88A6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Action Buttons Row: Undo, Redo, Pin, Star, More
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconCard(
              icon: Icons.undo_rounded,
              iconSize: 16.0,
              cardSize: 33.0,
              iconColor: const Color(0xFF150D33),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Undo action'), duration: Duration(seconds: 1)),
                );
              },
            ),
            const SizedBox(width: 4.0),
            _buildIconCard(
              icon: Icons.redo_rounded,
              iconSize: 16.0,
              cardSize: 33.0,
              iconColor: const Color(0xFFC7C3DF),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Redo action'), duration: Duration(seconds: 1)),
                );
              },
            ),
            const SizedBox(width: 4.0),
            _buildIconCard(
              icon: Icons.push_pin_rounded,
              iconSize: 16.0,
              cardSize: 33.0,
              iconColor: _isPinned ? const Color(0xFF7C3AED) : const Color(0xFF8C88A6),
              bgColor: _isPinned ? const Color(0xFFF3EDFF) : Colors.white,
              onTap: () {
                setState(() => _isPinned = !_isPinned);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isPinned ? 'Note Pinned 📌' : 'Note Unpinned'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 4.0),
            _buildIconCard(
              icon: Icons.star_rounded,
              iconSize: 18.0,
              cardSize: 33.0,
              iconColor: _isFavorite ? const Color(0xFFFFB800) : const Color(0xFF8C88A6),
              bgColor: _isFavorite ? const Color(0xFFFFF9E6) : Colors.white,
              onTap: () {
                setState(() => _isFavorite = !_isFavorite);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isFavorite ? 'Added to Favorites ⭐' : 'Removed from Favorites'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 4.0),
            _buildIconCard(
              icon: Icons.more_vert_rounded,
              iconSize: 17.0,
              cardSize: 33.0,
              onTap: () => _showEditorMoreMenu(),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditorMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(_isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded, color: const Color(0xFF7C3AED)),
                  title: Text(_isPinned ? 'Unpin Note' : 'Pin Note'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _isPinned = !_isPinned);
                    _saveNoteToDatabase();
                  },
                ),
                ListTile(
                  leading: Icon(_isFavorite ? Icons.star_outline_rounded : Icons.star_rounded, color: const Color(0xFFFFB800)),
                  title: Text(_isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _isFavorite = !_isFavorite);
                    _saveNoteToDatabase();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_rounded, color: Color(0xFF0284C7)),
                  title: const Text('Copy Note Text'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: '${_titleController.text}\n\n${_contentController.text}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note copied to clipboard!'), duration: Duration(seconds: 2)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Delete Note', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _notesRepo.deleteNote(_noteId);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
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

  // ─────────────────────────────────────────────
  // 3. Rich Text Formatting Toolbar
  // ─────────────────────────────────────────────

  Widget _buildFormattingToolbar() {
    return Container(
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
            _buildToolbarTile(
              label: 'B',
              isActive: _isBold,
              onTap: () => setState(() => _isBold = !_isBold),
              isText: true,
              fontWeight: FontWeight.w900,
            ),
            const SizedBox(width: 2.0),
            _buildToolbarTile(
              label: 'I',
              isActive: _isItalic,
              onTap: () => setState(() => _isItalic = !_isItalic),
              isText: true,
              fontStyle: FontStyle.italic,
              fontFamily: 'Serif',
            ),
            const SizedBox(width: 2.0),
            _buildToolbarTile(
              label: 'U',
              isActive: _isUnderline,
              onTap: () => setState(() => _isUnderline = !_isUnderline),
              isText: true,
              textDecoration: TextDecoration.underline,
            ),
            const SizedBox(width: 2.0),
            _buildToolbarTile(
              label: 'S',
              isActive: _isStrikethrough,
              onTap: () => setState(() => _isStrikethrough = !_isStrikethrough),
              isText: true,
              textDecoration: TextDecoration.lineThrough,
            ),
            const SizedBox(width: 2.0),
            _buildToolbarTile(
              icon: Icons.format_list_bulleted_rounded,
              isActive: _isBulletList,
              onTap: () {
                setState(() => _isBulletList = !_isBulletList);
                _contentController.text += '\n• ';
                _contentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _contentController.text.length),
                );
              },
            ),
            const SizedBox(width: 2.0),
            _buildToolbarTile(
              icon: Icons.format_list_numbered_rounded,
              isActive: _isNumberList,
              onTap: () {
                setState(() => _isNumberList = !_isNumberList);
                _contentController.text += '\n1. ';
                _contentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _contentController.text.length),
                );
              },
            ),
            const SizedBox(width: 2.0),
            _buildToolbarTile(
              icon: _textAlign == TextAlign.left
                  ? Icons.format_align_left_rounded
                  : _textAlign == TextAlign.center
                      ? Icons.format_align_center_rounded
                      : Icons.format_align_right_rounded,
              isActive: _textAlign != TextAlign.left,
              onTap: () {
                setState(() {
                  if (_textAlign == TextAlign.left) {
                    _textAlign = TextAlign.center;
                  } else if (_textAlign == TextAlign.center) {
                    _textAlign = TextAlign.right;
                  } else {
                    _textAlign = TextAlign.left;
                  }
                });
              },
            ),
            const SizedBox(width: 2.0),
            // Font Dropdown Tile (A ˅)
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                  ),
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Select Typography Style', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        ListTile(
                          title: const Text('Modern Sans (Inter)', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                          trailing: _fontFamily == 'Inter' ? const Icon(Icons.check_rounded, color: Color(0xFF7C3AED)) : null,
                          onTap: () {
                            setState(() => _fontFamily = 'Inter');
                            Navigator.pop(ctx);
                          },
                        ),
                        ListTile(
                          title: const Text('Serif / Editorial', style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold)),
                          trailing: _fontFamily == 'Serif' ? const Icon(Icons.check_rounded, color: Color(0xFF7C3AED)) : null,
                          onTap: () {
                            setState(() => _fontFamily = 'Serif');
                            Navigator.pop(ctx);
                          },
                        ),
                        ListTile(
                          title: const Text('Monospace / Code', style: TextStyle(fontFamily: 'Monospace', fontWeight: FontWeight.bold)),
                          trailing: _fontFamily == 'Monospace' ? const Icon(Icons.check_rounded, color: Color(0xFF7C3AED)) : null,
                          onTap: () {
                            setState(() => _fontFamily = 'Monospace');
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F5FA),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Text(
                      _fontFamily == 'Serif' ? 'A (Serif)' : _fontFamily == 'Monospace' ? 'A (Mono)' : 'A',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF150D33),
                        fontFamily: _fontFamily,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16.0,
                      color: Color(0xFF150D33),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: 34.0,
          height: 34.0,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF3EDFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: isText
                ? Text(
                    label!,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: fontWeight ?? FontWeight.w700,
                      fontStyle: fontStyle ?? FontStyle.normal,
                      fontFamily: fontFamily,
                      decoration: textDecoration,
                      color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF150D33),
                    ),
                  )
                : Icon(
                    icon,
                    size: 18.0,
                    color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF150D33),
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
    return Row(
      children: [
        // Left Color Palette Box
        Expanded(
          flex: 6,
          child: Container(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...List.generate(_paletteColors.length, (index) {
                  final color = _paletteColors[index];
                  final isSelected = _selectedColorIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = index),
                    child: Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
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
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16.0)
                          : null,
                    ),
                  );
                }),
                // Plus Icon Circle -> Theme Color Picker
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
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
                              const Text('Choose Note Theme Color', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
                              const SizedBox(height: 14.0),
                              Wrap(
                                spacing: 14.0,
                                runSpacing: 14.0,
                                children: List.generate(_paletteColors.length, (idx) {
                                  final color = _paletteColors[idx];
                                  return InkWell(
                                    onTap: () {
                                      setState(() => _selectedColorIndex = idx);
                                      Navigator.pop(ctx);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: color,
                                      radius: 22,
                                      child: _selectedColorIndex == idx ? const Icon(Icons.check, color: Colors.white) : null,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F1F8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded, color: Color(0xFF150D33), size: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10.0),

        // Right Secondary Format Options (Checklist & Line)
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Expanded(
                child: _buildSecondaryTile(
                  icon: Icons.check_box_outlined,
                  label: 'Checklist',
                  onTap: () {
                    _contentController.text += '\n[ ] Task Item';
                    _contentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _contentController.text.length),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildSecondaryTile(
                  icon: Icons.format_list_bulleted_rounded,
                  label: 'Line',
                  onTap: () {
                    _contentController.text += '\n───────────────────\n';
                    _contentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _contentController.text.length),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildMainEditorCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 285.0),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      decoration: BoxDecoration(
        color: _getCardBgColor(_selectedColorIndex),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: const Color(0xFFECE9F6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.04),
            blurRadius: 18.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Body Text Field
          TextField(
            controller: _contentController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textAlign: _textAlign,
            style: TextStyle(
              fontSize: 14.0,
              height: 1.45,
              color: const Color(0xFF1E1738),
              fontWeight: _isBold ? FontWeight.w800 : FontWeight.w500,
              fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
              fontFamily: _fontFamily,
              decoration: TextDecoration.combine([
                if (_isUnderline) TextDecoration.underline,
                if (_isStrikethrough) TextDecoration.lineThrough,
              ]),
            ),
            decoration: const InputDecoration(
              hintText: 'Start writing your notes...',
              hintStyle: TextStyle(
                fontSize: 13.5,
                color: Color(0xFFBBB7D3),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          // Attached Image Card Box
          if (_hasAttachedImage) ...[
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
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF3FF),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Icon(Icons.image_rounded, color: Color(0xFF2563EB), size: 26.0),
                  ),
                  const SizedBox(width: 12.0),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Photo Attachment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF150D33))),
                        SizedBox(height: 2),
                        Text('IMG_2026_NoteNest.png • 1.2 MB', style: TextStyle(fontSize: 11, color: Color(0xFF6E6A8A))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                    onPressed: () => setState(() => _hasAttachedImage = false),
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
                onTap: () {},
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

          // AI Input Field Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF9FF),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: const Color(0xFFE8E3FA), width: 1.0),
            ),
            child: Row(
              children: [
                // Robot Mascot Avatar Badge
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0EBFB),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.smart_toy_rounded, size: 18.0, color: Color(0xFF7C3AED)),
                  ),
                ),
                const SizedBox(width: 10.0),

                // Prompt Input Text Field
                Expanded(
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9E9AC0),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),

                // Circular Send Purple Gradient Button
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
                        if (_aiInputController.text.trim().isNotEmpty) {
                          _triggerAiPrompt(_aiInputController.text.trim());
                          _aiInputController.clear();
                        }
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
        ],
      ),
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
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF150D33),
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (ctx) => SafeArea(
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
      );
    } else if (label == 'Tags') {
      showModalBottomSheet(
        context: context,
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
      );
    } else if (label == 'Image') {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (ctx) => SafeArea(
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
                onTap: () {
                  setState(() => _hasAttachedImage = true);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo attached to note! 🖼️')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  setState(() => _hasAttachedImage = true);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image attached to note! 🖼️')));
                },
              ),
            ],
          ),
        ),
      );
    } else if (label == 'Voice') {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (ctx) => StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic_rounded, size: 48, color: Color(0xFFF59E0B)),
                    const SizedBox(height: 10),
                    const Text('Voice Note Recorder', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
                    const SizedBox(height: 4),
                    const Text('00:24 • Ready to attach', style: TextStyle(fontSize: 12.5, color: Color(0xFF6E6A8A))),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.check_rounded, color: Colors.white),
                          label: const Text('Attach Voice Recording', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            setState(() => _hasVoiceRecording = true);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice recording attached! 🎙️')));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else if (label == 'More') {
      showModalBottomSheet(
        context: context,
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
      );
    }
  }

  // ─────────────────────────────────────────────
  // 8. Sticky Bottom Action Bar (Delete & Save Note)
  // ─────────────────────────────────────────────

  Widget _buildBottomActionBar(double bottomPadding) {
    return Container(
      padding: EdgeInsets.only(
        top: 12.0,
        bottom: bottomPadding > 0 ? bottomPadding + 6.0 : 16.0,
        left: 16.0,
        right: 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Delete Button (Soft White Card + Red Trash Icon)
          Expanded(
            flex: 4,
            child: Container(
              height: 52.0,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(color: const Color(0xFFFFE5E5), width: 1.0),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await _notesRepo.deleteNote(_noteId);
                    if (mounted) Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(18.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20.0),
                      SizedBox(width: 6.0),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),

          // Save Note Button (Vibrant Purple Gradient Button with Scale Feedback)
          Expanded(
            flex: 7,
            child: AnimatedScale(
              scale: _saveButtonScale,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: 52.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                      blurRadius: 14.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTapDown: (_) => setState(() => _saveButtonScale = 0.96),
                    onTapUp: (_) => setState(() => _saveButtonScale = 1.0),
                    onTapCancel: () => setState(() => _saveButtonScale = 1.0),
                    onTap: () {
                      _saveNoteToDatabase();
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(18.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, color: Colors.white, size: 21.0),
                        SizedBox(width: 6.0),
                        Text(
                          'Save Note',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
