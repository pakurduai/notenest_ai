import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/speech_to_text_service.dart';
import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../../notes/data/notes_repository.dart';
import '../../data/search_repository.dart';
import '../../../settings/data/settings_repository.dart';
import '../../../notes/domain/models/note_model.dart';
import '../../../notes/presentation/screens/create_note_screen.dart';
import '../../../../core/widgets/custom_color_picker_modal.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
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

                          // AI Smart Search Card
                          _buildAiSmartSearchCard(),
                          const SizedBox(height: 16.0),

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

          // Floating Bottom Navigation Bar (Consistent across all screens)
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
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF150D33),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search notes, tags, categories...',
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
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => _searchController.clear(),
                    child: const Icon(Icons.cancel_rounded, color: Color(0xFF8C88A6), size: 18.0),
                  )
                else
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
                _buildFilterDropdownTile(icon: Icons.folder_open_rounded, label: 'Categories'),
                const SizedBox(width: 5.0),
                _buildFilterDropdownTile(icon: Icons.local_offer_outlined, label: 'Tags'),
                const SizedBox(width: 5.0),
                _buildFilterDropdownTile(icon: Icons.color_lens_outlined, label: 'Colors'),
                const SizedBox(width: 5.0),
                _buildFilterDropdownTile(icon: Icons.tune_rounded, label: 'Sort by: Newest'),
              ],
            ),
          ),
          const SizedBox(height: 12.0),

          // Color Palette Selection Row (Evenly Spaced Circles Across Card Width)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 'All' Circle
              GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = 0),
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

              // Solid Color Circles (Evenly spaced across card)
              ...List.generate(_filterColors.length, (index) {
                final color = _filterColors[index];
                final isSelected = _selectedColorIndex == index + 1;
                return GestureDetector(
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
        ],
      ),
    );
  }

  Widget _buildFilterDropdownTile({required IconData icon, required String label}) {
    return Container(
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
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 6. AI Smart Search Featured Card
  // ─────────────────────────────────────────────

  Widget _buildAiSmartSearchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.0),
        gradient: const LinearGradient(
          colors: [Color(0xFFF3EDFF), Color(0xFFEBF3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFDDD5FA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
            blurRadius: 16.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Seamless Transparent 3D Robot Mascot Asset
          Container(
            width: 54.0,
            height: 54.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
                  blurRadius: 12.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/home_robot.png',
                width: 48.0,
                height: 48.0,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.smart_toy_rounded,
                  size: 28.0,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),

          // Content Column
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AI Smart Search',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF150D33),
                      ),
                    ),
                    SizedBox(width: 3.0),
                    Icon(Icons.auto_awesome, size: 13.0, color: Color(0xFF7C3AED)),
                  ],
                ),
                SizedBox(height: 2.0),
                Text(
                  'Try natural language search',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6E6A8A),
                  ),
                ),
                Text(
                  '"Show my work notes from last week"',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF8C88A6),
                  ),
                ),
              ],
            ),
          ),

          // Try Now Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 12.0),
                    SizedBox(width: 3.0),
                    Text(
                      'Try Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 7. Search Results Header & Cards List
  // ─────────────────────────────────────────────

  Widget _buildSearchResultsHeader() {
    const categories = ['📄 All Notes', '⭐ Favorites', '📌 Pinned', '☑ Checklists', '📎 Attachments'];
    final categoryFilter = categories[_activeCategoryIndex < categories.length ? _activeCategoryIndex : 0];
    final realResults = _searchRepo.searchNotes(query: _searchQuery, categoryFilter: categoryFilter);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
              onTap: () => setState(() => _isGridView = false),
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
              onTap: () => setState(() => _isGridView = true),
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
    const categories = ['📄 All Notes', '⭐ Favorites', '📌 Pinned', '☑ Checklists', '📎 Attachments'];
    final categoryFilter = categories[_activeCategoryIndex < categories.length ? _activeCategoryIndex : 0];
    final realResults = _searchRepo.searchNotes(query: _searchQuery, categoryFilter: categoryFilter);

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
      {'label': 'AI Tools', 'icon': Icons.auto_awesome_rounded},
      {'label': 'Categories', 'icon': Icons.folder_rounded},
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = index == 1; // Search tab is selected
          final item = navItems[index];

          if (isSelected) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDFF),
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Row(
                children: [
                  Icon(item['icon'] as IconData, size: 20.0, color: const Color(0xFF7C3AED)),
                  const SizedBox(width: 6.0),
                  Text(
                    item['label'] as String,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
            );
          }

          return InkWell(
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
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              } else if (index == 4) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }
            },
            borderRadius: BorderRadius.circular(16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 20.0,
                    color: const Color(0xFF9C98B6),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    item['label'] as String,
                    style: const TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9C98B6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
