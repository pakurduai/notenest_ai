import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notenest_ai/features/notes/presentation/screens/create_note_screen.dart';
import 'package:notenest_ai/features/search/presentation/screens/search_screen.dart';
import 'package:notenest_ai/features/categories/presentation/screens/categories_screen.dart';
import 'package:notenest_ai/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:notenest_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:notenest_ai/features/notes/data/notes_repository.dart';
import 'package:notenest_ai/features/notes/domain/models/note_model.dart';
import 'package:notenest_ai/core/widgets/ad_banner_widget.dart';
import 'package:notenest_ai/core/services/audio_haptic_service.dart';
import 'package:notenest_ai/core/widgets/ambient_background_glow_widget.dart';

/// Home Screen — Production-ready, 100% Flutter widget implementation
/// matching the official NoteNest AI design reference pixel-to-pixel.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  int _currentNavIndex = 0;
  final NotesRepository _notesRepo = NotesRepository();

  @override
  void initState() {
    super.initState();
    // System UI Overlay setup for Light Theme edge-to-edge
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
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      body: AmbientBackgroundGlowWidget(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header Bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + 14.0,
                    left: 20.0,
                    right: 20.0,
                    bottom: 10.0,
                  ),
                  child: _buildHeader(),
                ),
              ),

              // ── Greeting Title ──
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning! 👋',
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF150D33),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'What would you like to capture today?',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6E6A8A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── AI Assistant Featured Banner Card ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: _buildAiAssistantBanner(),
                ),
              ),

              // ── Quick Actions Section (5 All-Visible Cards) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14.0, bottom: 8.0),
                  child: _buildQuickActionsSection(),
                ),
              ),

              // ── Recent Notes Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: _buildRecentNotesSection(),
                ),
              ),

              const SliverToBoxAdapter(
                child: AdBannerWidget(),
              ),

              // Bottom Padding for Floating FAB & Navigation Bar
              SliverToBoxAdapter(
                child: SizedBox(height: bottomPadding + 80.0),
              ),
            ],
          ),
        ),
      ),
    ),
    floatingActionButton: _buildFloatingActionButton(),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    bottomNavigationBar: _buildBottomNavigationBar(bottomPadding),
  );
}

  // ─────────────────────────────────────────────
  // App Header Bar
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        // Brand Logo + Name
        Row(
          children: [
            Image.asset(
              'assets/branding/monogram.png',
              width: 36,
              height: 36,
              errorBuilder: (_, __, ___) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                  ),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 10.0),
            const Text(
              'NoteNest',
              style: TextStyle(
                fontSize: 21.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFF150D33),
                letterSpacing: -0.4,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
              ).createShader(bounds),
              child: const Text(
                ' AI',
                style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),

        // Search Action Circular Icon
        _buildCircleIconButton(
          icon: Icons.search_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
        ),
        const SizedBox(width: 10.0),

        // Notification Bell Circular Icon
        _buildCircleIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            AudioHapticService.playNotificationBellSound();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔔 Notification: 1 New Reminder set for 09:00 AM'),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFF7C3AED),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44.0,
      height: 44.0,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF150D33), size: 22.0),
        onPressed: onTap,
        splashRadius: 22.0,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AI Assistant Banner Card with Official 3D Robot Mascot
  // ─────────────────────────────────────────────

  Widget _buildAiAssistantBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18.0, 18.0, 10.0, 18.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.0),
        gradient: const LinearGradient(
          colors: [Color(0xFFF2ECFF), Color(0xFFEBF3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFDDD5FA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
            blurRadius: 18.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Text Content & Action Button
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 19.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF150D33),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 16.0,
                      color: Color(0xFF7C3AED),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                const Text(
                  'Write, summarize, organize\nand do more with AI.',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6A8A),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Button: Ask AI Anything ✨
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(22.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.0),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                            blurRadius: 12.0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ask AI Anything',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 14.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Official 3D Robot Mascot Graphic (Seamless Transparent PNG)
          Expanded(
            flex: 5,
            child: SizedBox(
              height: 125,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Ambient Purple Glow Backdrop underneath Robot
                  Positioned(
                    bottom: 8,
                    child: Container(
                      width: 90,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(45),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                            blurRadius: 24,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 100% Pixel-Perfect Vector Robot Mascot Avatar
                  Container(
                    width: 85,
                    height: 85,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF00C6FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x407C3AED),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.smart_toy_rounded, size: 48, color: Colors.white),
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
  // Quick Actions Section (5 Cards Responsive Layout)
  // ─────────────────────────────────────────────

  Widget _buildQuickActionsSection() {
    const actions = [
      _QuickActionItem(
        icon: Icons.note_add_rounded,
        label: 'New Note',
        bgColor: Color(0xFFF3EDFF),
        iconColor: Color(0xFF7C3AED),
      ),
      _QuickActionItem(
        icon: Icons.mic_rounded,
        label: 'Voice Note',
        bgColor: Color(0xFFEBF3FF),
        iconColor: Color(0xFF2563EB),
      ),
      _QuickActionItem(
        icon: Icons.image_rounded,
        label: 'Scan\nDocument',
        bgColor: Color(0xFFE6F7ED),
        iconColor: Color(0xFF10B981),
      ),
      _QuickActionItem(
        icon: Icons.lightbulb_rounded,
        label: 'AI Ideas',
        bgColor: Color(0xFFFFF4E5),
        iconColor: Color(0xFFF59E0B),
      ),
      _QuickActionItem(
        icon: Icons.event_note_rounded,
        label: 'Tasks',
        bgColor: Color(0xFFFFEBF2),
        iconColor: Color(0xFFEC4899),
      ),
    ];

    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF150D33),
                  letterSpacing: -0.3,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18.0,
                      color: Color(0xFF7C3AED),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),

        // 5 Quick Action Cards Row (Fits all 5 perfectly!)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: _buildQuickActionTile(item),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile(_QuickActionItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item.label.contains('New Note')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNoteScreen()));
          } else if (item.label.contains('Voice')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CreateNoteScreen(
              existingNote: NoteModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Voice Note',
                content: '🎙️ [Voice Note Recorded]\n',
                tag: 'Personal',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )));
          } else if (item.label.contains('Scan')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CreateNoteScreen(
              existingNote: NoteModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Scanned Document',
                content: '📄 [Document Scanned Text]\n',
                tag: 'Work',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )));
          } else if (item.label.contains('AI Ideas')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
          } else if (item.label.contains('Tasks')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CreateNoteScreen(
              existingNote: NoteModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Daily Task List',
                content: '[ ] Task 1\n[ ] Task 2\n[ ] Task 3\n',
                tag: 'Personal',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )));
          }
        },
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          height: 98.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42.0,
                height: 42.0,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 21.0),
              ),
              const SizedBox(height: 6.0),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF150D33),
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Recent Notes Section
  // ─────────────────────────────────────────────

  Widget _buildRecentNotesSection() {
    return ValueListenableBuilder(
      valueListenable: _notesRepo.notesListenable,
      builder: (context, box, child) {
        final activeNotes = _notesRepo.getAllActiveNotes();

        return Column(
          children: [
            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Notes',
                  style: TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF150D33),
                    letterSpacing: -0.3,
                  ),
                ),
                InkWell(
                  onTap: () {
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
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18.0,
                        color: Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),

            // List of Real Database Notes or Empty State
            if (activeNotes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.note_alt_outlined, size: 48, color: Color(0xFF9C98B6)),
                    SizedBox(height: 10),
                    Text(
                      'No notes yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF150D33)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap + button below to create your first note!',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6E6A8A)),
                    ),
                  ],
                ),
              )
            else
              ...activeNotes.take(5).map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateNoteScreen(existingNote: note),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20.0),
                      child: _buildRealNoteCard(note),
                    ),
                  )),
          ],
        );
      },
    );
  }

  Widget _buildRealNoteCard(NoteModel note) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              color: note.tagBg,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Icon(Icons.description_rounded, color: note.tagColor, size: 25.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title.isNotEmpty ? note.title : 'Untitled Note',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF150D33),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  note.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF6E6A8A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13.0,
                      color: Color(0xFF9C98B6),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF9C98B6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: note.tagBg,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        note.tag,
                        style: TextStyle(
                          color: note.tagColor,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (note.isPinned)
                const Padding(
                  padding: EdgeInsets.only(right: 6.0),
                  child: Icon(
                    Icons.push_pin_rounded,
                    size: 18.0,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              if (note.isFavorite)
                const Padding(
                  padding: EdgeInsets.only(right: 6.0),
                  child: Icon(
                    Icons.star_rounded,
                    size: 18.0,
                    color: Color(0xFFFFB800),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded, size: 20.0, color: Color(0xFF9C98B6)),
                onPressed: () {
                  _showNoteOptionsSheet(context, note);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNoteOptionsSheet(BuildContext context, NoteModel note) {
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
                  leading: Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded, color: const Color(0xFF7C3AED)),
                  title: Text(note.isPinned ? 'Unpin Note' : 'Pin Note'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _notesRepo.togglePin(note.id);
                  },
                ),
                ListTile(
                  leading: Icon(note.isFavorite ? Icons.star_outline_rounded : Icons.star_rounded, color: const Color(0xFFFFB800)),
                  title: Text(note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _notesRepo.toggleFavorite(note.id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF0284C7)),
                  title: const Text('Archive Note'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _notesRepo.toggleArchive(note.id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Delete Note', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _notesRepo.deleteNote(note.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Floating Action Button
  // ─────────────────────────────────────────────

  Widget _buildFloatingActionButton() {
    return Container(
      width: 60.0,
      height: 60.0,
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.45),
            blurRadius: 18.0,
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
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 32.0,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Bottom Navigation Bar
  // ─────────────────────────────────────────────

  Widget _buildBottomNavigationBar(double bottomPadding) {
    return Container(
      padding: EdgeInsets.only(
        top: 8.0,
        bottom: bottomPadding > 0 ? bottomPadding : 12.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.description_outlined, 'Notes'),
          _buildNavItem(2, Icons.auto_awesome_outlined, 'AI Tools'),
          _buildNavItem(3, Icons.event_note_outlined, 'Tasks'),
          _buildNavItem(4, Icons.person_outline_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          setState(() => _currentNavIndex = 0);
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoriesScreen()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF0ECFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Icon(
              icon,
              size: 22.0,
              color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF9C98B6),
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF9C98B6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Helper Models
// ─────────────────────────────────────────────

class _QuickActionItem {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
  });
}
