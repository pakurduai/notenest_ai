import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/speech_to_text_service.dart';
import '../../../../core/services/gemini_ai_service.dart';
import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../../notes/data/notes_repository.dart';
import '../../data/search_repository.dart';
import '../../../settings/data/settings_repository.dart';
import '../../../notes/domain/models/note_model.dart';
import '../../../notes/presentation/screens/create_note_screen.dart';
import '../../../../core/widgets/custom_color_picker_modal.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../../core/services/audio_haptic_service.dart';


/// Search Screen — Rebuilt to 100% pixel-to-pixel perfection
/// matching the official NoteNest AI design reference.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isGridView = false;
  bool _showAdvancedFilters = true;

  late final TextEditingController _searchController;
  String _searchQuery = '';
  int _activeCategoryIndex = 0;
  int _selectedColorIndex = 0;

  String _selectedCategory = 'All';
  String _selectedTag = 'All';
  String _selectedSortOrder = 'Newest';

  bool _isAiLoading = false;
  String? _aiResponseText;
  String? _aiLastQuery;

  final NotesRepository _notesRepo = NotesRepository();
  late final SearchRepository _searchRepo;
  final SettingsRepository _settingsRepo = SettingsRepository();


  final List<String> _recentSearches = [
    'project ideas',
    'study notes',
    'meeting',
    'todo list',
    'travel plan',
  ];

  final List<Color> _filterColors = [
    const Color(0xFFFFD56B), // Yellow
    const Color(0xFFFF94B8), // Pink
    const Color(0xFF70C5FF), // Blue
    const Color(0xFF6EE7B7), // Teal
    const Color(0xFFC084FC), // Purple
    const Color(0xFFFB923C), // Orange
    const Color(0xFFCBD5E1), // Grey
  ];

  @override
  void initState() {
    super.initState();
    _searchRepo = SearchRepository(_notesRepo);
    _isGridView = _settingsRepo.isGridView;

    // Edge-to-edge status bar configuration
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

    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
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
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // ── 1. Top App Header Bar ──
                  Padding(
                    padding: EdgeInsets.only(
                      top: topPadding + 10.0,
                      left: 16.0,
                      right: 16.0,
                      bottom: 8.0,
                    ),
                    child: _buildTopHeader(),
                  ),

                  // ── 2. Scrollable Search Content ──
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Input Field & Filter Toggle Button
                          _buildSearchInputFieldRow(),
                          const SizedBox(height: 12.0),

                          // AI Answer & Instant Response Section
                          _buildAiAnswerSection(),
                          if (_isAiLoading || _aiResponseText != null || _searchQuery.isNotEmpty)
                            const SizedBox(height: 12.0),

                          // Category Filter Chips Row (All Notes, Favorites, Pinned, Checklists, Attachments)
                          _buildCategoryChipsRow(),
                          const SizedBox(height: 12.0),

                          // Advanced Filters Section Box (Categories, Tags, Colors, Sort + Color Circles)
                          if (_showAdvancedFilters) ...[
                            _buildAdvancedFiltersCard(),
                            const SizedBox(height: 14.0),
                          ],

                          // Recent Searches Section (Chips + Clear All)
                          if (_recentSearches.isNotEmpty) ...[
                            _buildRecentSearchesSection(),
                            const SizedBox(height: 14.0),
                          ],

                          // Search Results Section (Header + List/Grid View Cards)
                          _buildSearchResultsHeader(),
                          const SizedBox(height: 10.0),
                          _buildSearchResultsList(),

                          SizedBox(height: bottomPadding + 80.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding + 8.0),
            child: const SizedBox(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, bottomPadding + 8.0),
        child: _buildBottomNavigationBar(),
      ),
    );
  }

  void _askAiForQuery(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    AudioHapticService.playButtonSound();
    setState(() {
      _isAiLoading = true;
      _aiLastQuery = clean;
      _aiResponseText = null;
    });

    try {
      final response = await GeminiAiService.instance.generateContent(prompt: clean);
      if (mounted) {
        setState(() {
          _isAiLoading = false;
          _aiResponseText = response;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAiLoading = false;
          _aiResponseText = 'Hello! 👋 I am NoteNest AI.\n\nHow can I help you today? You can ask me to write articles, summarize text, translate, or organize your notes!';
        });
      }
    }
  }

  Widget _buildAiAnswerSection() {
    if (_isAiLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDFF),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: const Color(0xFFDDD5FA)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                'Thinking & generating answer for "${_aiLastQuery ?? _searchQuery}"...',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_aiResponseText != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.0),
          border: Border.all(color: const Color(0xFFDDD5FA), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
              blurRadius: 16.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDFF),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF7C3AED), size: 18.0),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NoteNest AI Answer',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF150D33),
                        ),
                      ),
                      Text(
                        'Query: "${_aiLastQuery ?? ''}"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7B7799),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _aiResponseText = null;
                      _aiLastQuery = null;
                    });
                  },
                  child: const Icon(Icons.close_rounded, color: Color(0xFF8C88A6), size: 18.0),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            const Divider(height: 1, color: Color(0xFFF0ECF8)),
            const SizedBox(height: 12.0),

            // AI Response Body
            SelectableText(
              _aiResponseText!,
              style: const TextStyle(
                fontSize: 13.0,
                height: 1.55,
                fontWeight: FontWeight.w500,
                color: Color(0xFF150D33),
              ),
            ),
            const SizedBox(height: 14.0),

            // Interactive Action Buttons Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Full AI Chat Button
                  ElevatedButton.icon(
                    onPressed: () {
                      AudioHapticService.playButtonSound();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14.0),
                    label: const Text('Open AI Chat 💬'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // Copy Answer Button
                  OutlinedButton.icon(
                    onPressed: () {
                      AudioHapticService.playButtonSound();
                      Clipboard.setData(ClipboardData(text: _aiResponseText!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied AI Answer to clipboard! 📋'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Color(0xFF7C3AED),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 14.0),
                    label: const Text('Copy 📋'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF150D33),
                      side: const BorderSide(color: Color(0xFFDDD5FA)),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // Save as Note Button
                  OutlinedButton.icon(
                    onPressed: () async {
                      AudioHapticService.playButtonSound();
                      final newNote = NoteModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'AI Note: ${_aiLastQuery ?? "Saved Answer"}',
                        content: _aiResponseText!,
                        tag: 'AI',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        aiSummary: _aiResponseText,
                      );
                      await _notesRepo.saveNote(newNote);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Saved AI Answer as new Note! 💾'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      }

                    },
                    icon: const Icon(Icons.bookmark_add_outlined, size: 14.0),
                    label: const Text('Save as Note 💾'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFFA7F3D0)),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default Banner when query typed (e.g. "hi") but AI answer not yet generated
    if (_searchQuery.isNotEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.0),
          gradient: const LinearGradient(
            colors: [Color(0xFFF3EDFF), Color(0xFFEBF3FF)],
          ),
          border: Border.all(color: const Color(0xFFDDD5FA)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _askAiForQuery(_searchQuery),
            borderRadius: BorderRadius.circular(18.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 16.0),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ask NoteNest AI for "$_searchQuery"',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF150D33),
                          ),
                        ),
                        const SizedBox(height: 1.0),
                        const Text(
                          'Tap to get instant AI answer & chat response →',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6E6A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Text(
                      'Ask AI ✨',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }


  List<NoteModel> _getFilteredResults() {
    const categories = ['All Notes', 'Favorites', 'Pinned', 'Checklists', 'Attachments'];
    final mainCategoryFilter = categories[_activeCategoryIndex < categories.length ? _activeCategoryIndex : 0];
    final Color? activeColorFilter = (_selectedColorIndex > 0 && _selectedColorIndex <= _filterColors.length)
        ? _filterColors[_selectedColorIndex - 1]
        : null;

    return _searchRepo.searchNotes(
      query: _searchQuery,
      categoryFilter: _selectedCategory != 'All' ? _selectedCategory : mainCategoryFilter,
      tagFilter: _selectedTag,
      colorFilter: activeColorFilter,
      sortOrder: _selectedSortOrder,
    );
  }

  void _showCategoryPickerSheet() {
    AudioHapticService.playButtonSound();
    final categories = ['All', 'General', 'Work', 'Personal', 'Study', 'Ideas', 'Journal', 'Finance'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Category Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      selectedColor: const Color(0xFF7C3AED),
                      backgroundColor: const Color(0xFFF7F6FA),
                      labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF150D33), fontWeight: FontWeight.bold),
                      onSelected: (_) {
                        AudioHapticService.playButtonSound();
                        setState(() => _selectedCategory = cat);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTagPickerSheet() {
    AudioHapticService.playButtonSound();
    final tags = ['All', 'Important', 'Draft', 'Todo', 'Recipe', 'Meeting', 'Project', 'Personal'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Tag Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((t) {
                    final isSel = _selectedTag == t;
                    return ChoiceChip(
                      label: Text(t == 'All' ? 'All Tags' : '#$t'),
                      selected: isSel,
                      selectedColor: const Color(0xFF7C3AED),
                      backgroundColor: const Color(0xFFF7F6FA),
                      labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF150D33), fontWeight: FontWeight.bold),
                      onSelected: (_) {
                        AudioHapticService.playButtonSound();
                        setState(() => _selectedTag = t);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortPickerSheet() {
    AudioHapticService.playButtonSound();
    final sortOptions = ['Newest', 'Oldest', 'Title (A-Z)', 'Title (Z-A)'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Sort Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
                const SizedBox(height: 12),
                ...sortOptions.map((opt) {
                  final isSel = _selectedSortOrder == opt;
                  return ListTile(
                    title: Text(opt, style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? const Color(0xFF7C3AED) : const Color(0xFF150D33))),
                    trailing: isSel ? const Icon(Icons.check_circle_rounded, color: Color(0xFF7C3AED)) : null,
                    onTap: () {
                      AudioHapticService.playButtonSound();
                      setState(() => _selectedSortOrder = opt);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // 1. Top App Header Bar
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

        // Search Title & Subtitle
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF150D33),
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 1.0),
              Text(
                'Find your notes quickly and easily',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7B7799),
                ),
              ),
            ],
          ),
        ),

        // AI Search Button & Text (Top Right)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38.0,
              height: 38.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDFF),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF7C3AED),
                      size: 19.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3.0),
            const Text(
              'AI Search',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 2. Search Input Field & Filter Toggle Button
  // ─────────────────────────────────────────────

  Widget _buildSearchInputFieldRow() {
    return Row(
      children: [
        // Main Search Bar Box
        Expanded(
          child: Container(
            height: 48.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
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
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF8C88A6), size: 20.0),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _askAiForQuery(text);
                      }
                    },
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF150D33),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search notes or ask AI...',
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
                if (_searchQuery.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => _askAiForQuery(_searchQuery),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDFF),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF7C3AED), size: 16.0),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _aiResponseText = null;
                        _aiLastQuery = null;
                        _isAiLoading = false;
                      });
                    },
                    child: const Icon(Icons.cancel_rounded, color: Color(0xFF8C88A6), size: 18.0),
                  ),
                ] else
                  GestureDetector(
                    onTap: () {
                      SpeechToTextService.listenAndDictate(
                        context: context,
                        title: 'Voice Search',
                        onTextRecognized: (text) {
                          setState(() {
                            _searchController.text = text;
                            _searchQuery = text.toLowerCase().trim();
                          });
                          _askAiForQuery(text);
                        },
                      );
                    },
                    child: const Icon(Icons.mic_rounded, color: Color(0xFF7C3AED), size: 20.0),
                  ),

              ],
            ),
          ),
        ),
        const SizedBox(width: 10.0),

        // Filter Funnel Toggle Button Box
        Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: _showAdvancedFilters ? const Color(0xFFF3EDFF) : Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: _showAdvancedFilters ? const Color(0xFFDDD5FA) : Colors.transparent,
            ),
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
              onTap: () {
                setState(() {
                  _showAdvancedFilters = !_showAdvancedFilters;
                });
              },
              borderRadius: BorderRadius.circular(16.0),
              child: Center(
                child: Icon(
                  Icons.tune_rounded,
                  color: _showAdvancedFilters ? const Color(0xFF7C3AED) : const Color(0xFF150D33),
                  size: 20.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 3. Category Filter Chips Row
  // ─────────────────────────────────────────────

  Widget _buildCategoryChipsRow() {
    final categories = [
      {'label': 'All Notes', 'icon': Icons.description_rounded},
      {'label': 'Favorites', 'icon': Icons.star_rounded},
      {'label': 'Pinned', 'icon': Icons.push_pin_rounded},
      {'label': 'Checklists', 'icon': Icons.check_box_rounded},
      {'label': 'Attachments', 'icon': Icons.attach_file_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(categories.length, (index) {
          final isSelected = _activeCategoryIndex == index;
          final item = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _activeCategoryIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(14.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7C3AED) : Colors.white,
                    borderRadius: BorderRadius.circular(14.0),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF7C3AED).withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: isSelected ? 6.0 : 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 13.0,
                        color: isSelected ? Colors.white : const Color(0xFF150D33),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF150D33),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 4. Advanced Filters Section Box
  // ─────────────────────────────────────────────

  Widget _buildAdvancedFiltersCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF150D33),
            ),
          ),
          const SizedBox(height: 8.0),

          // Dropdowns Single Row: Categories, Tags, Colors, Sort by: Newest
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterDropdownTile(
                  icon: Icons.folder_open_rounded,
                  label: _selectedCategory == 'All' ? 'Categories' : _selectedCategory,
                  onTap: _showCategoryPickerSheet,
                ),
                const SizedBox(width: 5.0),
                _buildFilterDropdownTile(
                  icon: Icons.local_offer_outlined,
                  label: _selectedTag == 'All' ? 'Tags' : '#$_selectedTag',
                  onTap: _showTagPickerSheet,
                ),
                const SizedBox(width: 5.0),
                _buildFilterDropdownTile(
                  icon: Icons.color_lens_outlined,
                  label: _selectedColorIndex == 0 ? 'Colors' : 'Color Active',
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    setState(() => _selectedColorIndex = (_selectedColorIndex + 1) % (_filterColors.length + 1));
                  },
                ),
                const SizedBox(width: 5.0),
                _buildFilterDropdownTile(
                  icon: Icons.tune_rounded,
                  label: 'Sort: $_selectedSortOrder',
                  onTap: _showSortPickerSheet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),

          // Color Palette Selection Row (Scrollable Horizontal Circles)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // 'All' Circle
                GestureDetector(
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    setState(() => _selectedColorIndex = 0);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      children: [
                        Container(
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF7C3AED),
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 12.0,
                              height: 12.0,
                              decoration: BoxDecoration(
                                color: _selectedColorIndex == 0
                                    ? const Color(0xFF7C3AED)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        const Text(
                          'All',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Solid Color Circles (Scrollable)
                ...List.generate(_filterColors.length, (index) {
                  final color = _filterColors[index];
                  final isSelected = _selectedColorIndex == index + 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        AudioHapticService.playButtonSound();
                        setState(() => _selectedColorIndex = index + 1);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 30.0,
                        height: 30.0,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: const Color(0xFF7C3AED), width: 2.5)
                              : Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: isSelected ? 8.0 : 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Custom Color Creator Plus Button (+)
                GestureDetector(
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    CustomColorPickerModal.show(
                      context,
                      onColorSelected: (newColor) {
                        setState(() {
                          _filterColors.add(newColor);
                          _selectedColorIndex = _filterColors.length;
                        });
                      },
                    );
                  },
                  child: Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF7C3AED), size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdownTile({required IconData icon, required String label, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.5),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6FA),
            borderRadius: BorderRadius.circular(11.0),
            border: Border.all(color: const Color(0xFFE8E5F4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12.0, color: const Color(0xFF150D33)),
              const SizedBox(width: 3.5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF150D33),
                ),
              ),
              const SizedBox(width: 3.0),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 13.0, color: Color(0xFF150D33)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 5. Recent Searches Section
  // ─────────────────────────────────────────────

  Widget _buildRecentSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF150D33),
              ),
            ),
            InkWell(
              onTap: () {
                AudioHapticService.playButtonSound();
                setState(() {
                  _recentSearches.clear();
                });
              },
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),

        // Single Horizontal Row for all 5 recent search terms (including travel plan)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _recentSearches.map((term) {
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      AudioHapticService.playButtonSound();
                      setState(() {
                        _searchController.text = term;
                        _searchQuery = term.toLowerCase().trim();
                      });
                    },
                    borderRadius: BorderRadius.circular(14.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 5.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.0),
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
                          const Icon(Icons.access_time_rounded, size: 12.0, color: Color(0xFF8C88A6)),
                          const SizedBox(width: 4.0),
                          Text(
                            term,
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
  // ─────────────────────────────────────────────
  // 6. Search Results Header & Cards List
  // ─────────────────────────────────────────────

  Widget _buildSearchResultsHeader() {
    final realResults = _getFilteredResults();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Text(
                  'Search Results',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF150D33),
                  ),
                ),
                const SizedBox(width: 6.0),
                Text(
                  '(${realResults.length} found)',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8C88A6),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8.0),

        // View Mode Toggle (List vs Grid)
        Row(
          children: [
            const Text(
              'View as',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8C88A6),
              ),
            ),
            const SizedBox(width: 6.0),
            GestureDetector(
              onTap: () {
                AudioHapticService.playButtonSound();
                setState(() => _isGridView = false);
              },
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  color: !_isGridView ? const Color(0xFFF3EDFF) : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.format_list_bulleted_rounded,
                  size: 16.0,
                  color: !_isGridView ? const Color(0xFF7C3AED) : const Color(0xFF8C88A6),
                ),
              ),
            ),
            const SizedBox(width: 4.0),
            GestureDetector(
              onTap: () {
                AudioHapticService.playButtonSound();
                setState(() => _isGridView = true);
              },
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  color: _isGridView ? const Color(0xFFF3EDFF) : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  size: 16.0,
                  color: _isGridView ? const Color(0xFF7C3AED) : const Color(0xFF8C88A6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchResultsList() {
    final realResults = _getFilteredResults();

    if (realResults.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: const Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48.0, color: Color(0xFFCBD5E1)),
            SizedBox(height: 10.0),
            Text(
              'No notes found matching your search',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8C88A6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: realResults.map((note) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateNoteScreen(existingNote: note)),
              );
            },
            borderRadius: BorderRadius.circular(20.0),
            child: _buildRealSearchResultCard(note),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRealSearchResultCard(NoteModel note) {
    return Container(
      padding: const EdgeInsets.all(14.0),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: note.tagBg,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Icon(Icons.description_rounded, color: note.tagColor, size: 22.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title.isNotEmpty ? note.title : 'Untitled Note',
                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w800, color: Color(0xFF150D33)),
                ),
                const SizedBox(height: 3.0),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color(0xFF6E6A8A)),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12.0, color: Color(0xFF9C98B6)),
                    const SizedBox(width: 4.0),
                    Text(
                      '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
                      style: const TextStyle(fontSize: 11.0, color: Color(0xFF9C98B6), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 10.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(color: note.tagBg, borderRadius: BorderRadius.circular(8.0)),
                      child: Text(note.tag, style: TextStyle(color: note.tagColor, fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 7. Floating Bottom Navigation Bar
  // ─────────────────────────────────────────────

  Widget _buildBottomNavigationBar() {
    const navItems = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Search', 'icon': Icons.search_rounded},
      {'label': 'AI Assistant', 'icon': Icons.auto_awesome_rounded},
      {'label': 'Settings', 'icon': Icons.settings_rounded},
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
          final isSelected = index == 1; // Search tab is selected
          final item = navItems[index];

          if (isSelected) {
            return Expanded(
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item['label'] as String,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                AudioHapticService.playButtonSound();
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                  );
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
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
}
