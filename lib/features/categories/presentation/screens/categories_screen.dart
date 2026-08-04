import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/category_model.dart';
import '../../../notes/presentation/screens/create_note_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../notes/data/notes_repository.dart';
import '../../data/categories_repository.dart';
import '../../../notes/domain/models/note_model.dart';
import '../../../../core/services/audio_haptic_service.dart';

/// Categories Screen — Rebuilt to 100% pixel-to-pixel perfection
/// matching the official NoteNest AI design reference.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  int _selectedCategoryIndex = 0; // 'Work' selected by default
  int _currentBottomNavIndex = 3; // 'Categories' active tab

  final NotesRepository _notesRepo = NotesRepository();
  late final CategoriesRepository _categoriesRepo;

  final List<CategoryModel> _categories = const [
    CategoryModel(
      id: 'work',
      title: 'Work',
      noteCount: 24,
      icon: Icons.work_rounded,
      iconBg: Color(0xFFF3EDFF),
      iconColor: Color(0xFF7C3AED),
      indicatorColor: Color(0xFF7C3AED),
    ),
    CategoryModel(
      id: 'study',
      title: 'Study',
      noteCount: 18,
      icon: Icons.school_rounded,
      iconBg: Color(0xFFDCFCE7),
      iconColor: Color(0xFF10B981),
      indicatorColor: Color(0xFF10B981),
    ),
    CategoryModel(
      id: 'ideas',
      title: 'Ideas',
      noteCount: 15,
      icon: Icons.lightbulb_rounded,
      iconBg: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
      indicatorColor: Color(0xFFD97706),
    ),
    CategoryModel(
      id: 'personal',
      title: 'Personal',
      noteCount: 32,
      icon: Icons.calendar_today_rounded,
      iconBg: Color(0xFFFFEBF2),
      iconColor: Color(0xFFEC4899),
      indicatorColor: Color(0xFFEC4899),
    ),
    CategoryModel(
      id: 'travel',
      title: 'Travel',
      noteCount: 12,
      icon: Icons.flight_takeoff_rounded,
      iconBg: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
      indicatorColor: Color(0xFF0284C7),
    ),
    CategoryModel(
      id: 'shopping',
      title: 'Shopping',
      noteCount: 8,
      icon: Icons.shopping_cart_rounded,
      iconBg: Color(0xFFFFEDD5),
      iconColor: Color(0xFFF97316),
      indicatorColor: Color(0xFFF97316),
    ),
    CategoryModel(
      id: 'favorites',
      title: 'Favorites',
      noteCount: 10,
      icon: Icons.star_rounded,
      iconBg: Color(0xFFCCFBF1),
      iconColor: Color(0xFF0D9488),
      indicatorColor: Color(0xFF0D9488),
    ),
    CategoryModel(
      id: 'archive',
      title: 'Archive',
      noteCount: 9,
      icon: Icons.inventory_2_rounded,
      iconBg: Color(0xFFF1F5F9),
      iconColor: Color(0xFF64748B),
      indicatorColor: Color(0xFF64748B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    AudioHapticService.playNavigationSound();
    _categoriesRepo = CategoriesRepository(_notesRepo);

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final activeCategory = _categories[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
      body: Stack(
        children: [
          // ── Main Scrollable Body ──
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

                  // 2. Scrollable Content Area
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Statistics Summary Card
                          _buildStatisticsSummaryCard(),
                          const SizedBox(height: 14.0),

                          // 8 Category Grid Cards (4 columns x 2 rows)
                          _buildCategoriesGrid(),
                          const SizedBox(height: 16.0),

                          // "Notes in Work" Header Row
                          _buildCategoryNotesHeader(activeCategory),
                          const SizedBox(height: 10.0),

                          // Notes List under Selected Category
                          _buildCategoryNotesList(),

                          SizedBox(height: bottomPadding + 110.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Floating Action Button ──
          Positioned(
            right: 20.0,
            bottom: bottomPadding + 82.0,
            child: _buildFloatingActionButton(),
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

        // Title & Subtitle
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF150D33),
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 1.0),
              Text(
                'Organize your notes by categories',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7B7799),
                ),
              ),
            ],
          ),
        ),

        // Search Action Circular Icon
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              customBorder: const CircleBorder(),
              child: const Center(
                child: Icon(Icons.search_rounded, color: Color(0xFF150D33), size: 20.0),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category options menu'), duration: Duration(seconds: 1)),
                );
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
  // 2. Statistics Summary Card
  // ─────────────────────────────────────────────

  Widget _buildStatisticsSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Column: Folder Icon & Total Categories
          Expanded(
            flex: 4,
            child: Row(
              children: [
                // Folder Icon Tile
                Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBFB),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: const Center(
                    child: Icon(Icons.folder_rounded, color: Color(0xFF7C3AED), size: 28.0),
                  ),
                ),
                const SizedBox(width: 12.0),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Categories',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6E6A8A),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    const Text(
                      '8',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7C3AED),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '${_notesRepo.getAllActiveNotes().length} Notes',
                      style: const TextStyle(
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

          // Vertical Divider Line
          Container(
            width: 1.0,
            height: 54.0,
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            color: const Color(0xFFECE9F6),
          ),

          // Right Column: Storage Used & Progress Bar
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Storage Used',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6E6A8A),
                      ),
                    ),
                    Text(
                      '65%',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),

                // Gradient Progress Bar Track
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Container(
                    height: 8.0,
                    width: double.infinity,
                    color: const Color(0xFFEFEAFB),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.65,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),

                const Text(
                  '256 MB / 500 MB',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8C88A6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 3. 8 Category Grid Cards (4 columns x 2 rows)
  // ─────────────────────────────────────────────

  Widget _buildCategoriesGrid() {
    final categories = _categoriesRepo.getDynamicCategories();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.78,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategoryIndex == index;
        return _buildCategoryGridCard(category, index, isSelected);
      },
    );
  }

  Widget _buildCategoryGridCard(CategoryModel category, int index, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF7C3AED).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isSelected ? 10.0 : 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategoryIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(18.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon Badge & 3-dots Menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        color: category.iconBg,
                        borderRadius: BorderRadius.circular(11.0),
                      ),
                      child: Icon(category.icon, color: category.iconColor, size: 17.0),
                    ),
                    const Icon(Icons.more_vert_rounded, color: Color(0xFF9C98B6), size: 14.0),
                  ],
                ),

                // Title & Notes Count
                Column(
                  children: [
                    Text(
                      category.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF150D33),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '${category.noteCount} Notes',
                      style: const TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8C88A6),
                      ),
                    ),
                  ],
                ),

                // Bottom Colored Indicator Bar
                Container(
                  height: 3.0,
                  width: 36.0,
                  decoration: BoxDecoration(
                    color: category.indicatorColor,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 4. "Notes in Work" Header Row
  // ─────────────────────────────────────────────

  Widget _buildCategoryNotesHeader(CategoryModel activeCategory) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Notes in ',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF150D33),
              ),
            ),
            Text(
              activeCategory.title,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              '${activeCategory.noteCount} Notes',
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8C88A6),
              ),
            ),
            const SizedBox(width: 8.0),
            InkWell(
              onTap: () {
                AudioHapticService.playButtonSound();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              child: const Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 15.0,
                    color: Color(0xFF7C3AED),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 5. Notes List under Selected Category
  // ─────────────────────────────────────────────

  Widget _buildCategoryNotesList() {
    return ValueListenableBuilder(
      valueListenable: _notesRepo.notesListenable,
      builder: (context, box, child) {
        final categories = _categoriesRepo.getDynamicCategories();
        final activeCategory = categories[_selectedCategoryIndex < categories.length ? _selectedCategoryIndex : 0];
        final notes = _notesRepo.getNotesByCategory(activeCategory.title);

        if (notes.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            alignment: Alignment.center,
            child: Text(
              'No notes in ${activeCategory.title}',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF8C88A6)),
            ),
          );
        }

        return Column(
          children: notes.map((note) {
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
                child: _buildRealCategoryNoteCard(note),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRealCategoryNoteCard(NoteModel note) {
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
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF150D33),
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  note.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6A8A),
                  ),
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
                      decoration: BoxDecoration(
                        color: note.tagBg,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        note.tag,
                        style: TextStyle(color: note.tagColor, fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
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
  // 6. Floating Action Button (FAB)
  // ─────────────────────────────────────────────

  Widget _buildFloatingActionButton() {
    return Container(
      width: 52.0,
      height: 52.0,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
            blurRadius: 14.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
            );
          },
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(Icons.add_rounded, color: Colors.white, size: 28.0),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 7. Bottom Navigation Bar
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = _currentBottomNavIndex == index;
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
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
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
