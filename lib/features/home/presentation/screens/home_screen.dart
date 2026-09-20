import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notenest_ai/features/notes/presentation/screens/create_note_screen.dart';
import 'package:notenest_ai/features/search/presentation/screens/search_screen.dart';
import 'package:notenest_ai/features/categories/presentation/screens/categories_screen.dart';
import 'package:notenest_ai/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:notenest_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:notenest_ai/features/settings/presentation/screens/pro_upgrade_screen.dart';
import 'package:notenest_ai/features/notes/data/notes_repository.dart';
import 'package:notenest_ai/features/notes/domain/models/note_model.dart';
import 'package:notenest_ai/core/database/hive_database_service.dart';
import 'package:notenest_ai/core/services/audio_haptic_service.dart';
import 'package:notenest_ai/core/services/notification_service.dart';
import 'package:notenest_ai/core/widgets/ambient_background_glow_widget.dart';
import 'package:notenest_ai/core/widgets/ad_banner_widget.dart';

/// Pixel-Perfect, Ultra-HD, Material 3 Home Screen for NoteNest AI
/// Rebuilt 100% using pure Flutter widgets matching the reference UI design.
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentNavIndex = 0;
  bool _isGridView = false;
  String _selectedCategory = 'All';
  String _selectedSortBy = 'modified';

  final NotesRepository _notesRepo = NotesRepository();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.addListener(_onNotificationStateChanged);
    _notesRepo.seedInitialNotesIfEmpty();
    AudioHapticService.playHomeWelcomeSound();
    try {
      _isGridView = HiveDatabaseService.settingsBox.get('is_grid_view', defaultValue: false);
    } catch (_) {}
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
      duration: const Duration(milliseconds: 500),
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

  void _onNotificationStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationStateChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F5FA),
      drawer: _buildNavigationDrawer(),
      body: AmbientBackgroundGlowWidget(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── 1. Top App Bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: topPadding > 15 ? topPadding + 8.0 : 22.0,
                      left: 18.0,
                      right: 18.0,
                      bottom: 8.0,
                    ),
                    child: _buildAppBar(),
                  ),
                ),

                // ── 2. Header Section (Title + Subtitle + View Toggle) ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0, bottom: 14.0),
                    child: _buildHeaderSection(),
                  ),
                ),

                // ── 3. Main Notes Content Area ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
                    child: _buildNotesSection(),
                  ),
                ),

                // Bottom Spacing for Ad Banner, Floating Nav & FAB
                SliverToBoxAdapter(
                  child: SizedBox(height: bottomPadding + 145.0),
                ),
              ],
            ),
          ),
        ),
      ),

      // ── Floating Action Button ──
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ── Ad Banner + Floating Bottom Navigation Bar ──
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerWidget(
            margin: EdgeInsets.only(bottom: 6.0),
            showBorder: true,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, bottomPadding + 8.0),
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 1. App Bar
  // ─────────────────────────────────────────────

  Widget _buildAppBar() {
    return Row(
      children: [
        // Drawer Menu Button (☰)
        _buildCircleIconButton(
          icon: Icons.menu_rounded,
          onTap: () {
            AudioHapticService.playButtonSound();
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        const SizedBox(width: 6.0),

        // Brand Logo + Title: NoteNest
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBrandLogoBadge(),
              const SizedBox(width: 6.0),
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'NoteNest',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF150D33),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4.0),

        // Search Action Button
        _buildCircleIconButton(
          icon: Icons.search_rounded,
          onTap: () {
            AudioHapticService.playButtonSound();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
        ),
        const SizedBox(width: 5.0),

        // Bell Notification Button (🔔)
        _buildNotificationBellButton(),
        const SizedBox(width: 5.0),

        // More Options Button (⋮)
        _buildCircleIconButton(
          icon: Icons.more_vert_rounded,
          onTap: () => _showMoreOptionsMenu(context),
        ),
      ],
    );
  }

  Widget _buildBrandLogoBadge() {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/playstore/icon_512.png',
            width: 32.0,
            height: 32.0,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFFFD700),
                    size: 8.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 34.0,
      height: 34.0,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: const Color(0xFF150D33), size: 18.0),
        onPressed: onTap,
        splashRadius: 16.0,
      ),
    );
  }

  Widget _buildNotificationBellButton() {
    final unreadCount = _notificationService.unreadCount;
    return GestureDetector(
      onTap: () {
        AudioHapticService.playNotificationBellSound();
        _showNotificationCenterModal(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34.0,
        height: 34.0,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              unreadCount > 0
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_outlined,
              color: unreadCount > 0
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFF150D33),
              size: 18.0,
            ),
            if (unreadCount > 0)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 15.0,
                    minHeight: 15.0,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.0,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationCenterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final notifications = _notificationService.notifications;
            final unreadCount = _notificationService.unreadCount;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20.0,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12.0),
                  Container(
                    width: 38.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Header Title Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Color(0xFF7C3AED),
                            size: 20.0,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 19.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF150D33),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              '$unreadCount New',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 16.0, thickness: 1.0),

                  // Action Bar (Test Sound, Mark Read, Clear)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _notificationService.triggerTestNotification();
                              setModalState(() {});
                            },
                            icon: const Icon(Icons.volume_up_rounded, size: 16.0),
                            label: const Text('Test Sound 🔔',
                                style: TextStyle(
                                    fontSize: 12.0, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          if (notifications.isNotEmpty) ...[
                            TextButton.icon(
                              onPressed: () {
                                _notificationService.markAllAsRead();
                                setModalState(() {});
                              },
                              icon: const Icon(Icons.done_all_rounded,
                                  size: 15.0, color: Color(0xFF7C3AED)),
                              label: const Text('Mark Read',
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: Color(0xFF7C3AED),
                                      fontWeight: FontWeight.w600)),
                            ),
                            TextButton(
                              onPressed: () {
                                _notificationService.clearAll();
                                setModalState(() {});
                              },
                              child: const Text('Clear',
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 6.0),

                  // Notification List
                  Flexible(
                    child: notifications.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.notifications_none_rounded,
                                    size: 48.0, color: Colors.grey.shade400),
                                const SizedBox(height: 10.0),
                                Text(
                                  'No notifications right now',
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            itemCount: notifications.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10.0),
                            itemBuilder: (context, index) {
                              final item = notifications[index];
                              return Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: item.isRead
                                      ? const Color(0xFFF9FAFB)
                                      : const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: item.isRead
                                        ? Colors.grey.shade200
                                        : const Color(0xFFDDD6FE),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: item.isRead
                                            ? Colors.grey.shade200
                                            : const Color(0xFF7C3AED),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        item.icon,
                                        color: item.isRead
                                            ? Colors.grey.shade700
                                            : Colors.white,
                                        size: 18.0,
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: item.isRead
                                                        ? FontWeight.w600
                                                        : FontWeight.w800,
                                                    color:
                                                        const Color(0xFF150D33),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                item.timeFormatted,
                                                style: TextStyle(
                                                  fontSize: 11.0,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            item.body,
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              color: Colors.grey.shade700,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // 2. Header Section (Title + Subtitle + View Toggle)
  // ─────────────────────────────────────────────

  void _toggleLayoutView(bool isGrid) {
    AudioHapticService.playButtonSound();
    setState(() => _isGridView = isGrid);
    try {
      HiveDatabaseService.settingsBox.put('is_grid_view', isGrid);
    } catch (_) {}
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Title & Subtitle Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCategory == 'All' ? 'All Notes' : '$_selectedCategory Notes',
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF150D33),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  const Text(
                    'Your ideas, organized ✨',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6E6A8A),
                    ),
                  ),
                ],
              ),
            ),

            // 1. List / Grid View Toggle Segmented Pill
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // List View Button
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showColorSortViewModal(context, initialTabIndex: 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: !_isGridView ? const Color(0xFF7C3AED) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: !_isGridView
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                                  blurRadius: 6.0,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        Icons.format_list_bulleted_rounded,
                        size: 19.0,
                        color: !_isGridView ? Colors.white : const Color(0xFF9C98B6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),

                  // Grid View Button
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showColorSortViewModal(context, initialTabIndex: 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _isGridView ? const Color(0xFF7C3AED) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: _isGridView
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                                  blurRadius: 6.0,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 19.0,
                        color: _isGridView ? Colors.white : const Color(0xFF9C98B6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),

            // 2. Color / Sort / View Modal Trigger Button
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showColorSortViewModal(context, initialTabIndex: 0),
              child: Container(
                padding: const EdgeInsets.all(11.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.palette_outlined, size: 20.0, color: Color(0xFF7C3AED)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),

        // Sort by Dropdown Pill Bar
        _buildSortBarPill(),
      ],
    );
  }

  Widget _buildSortBarPill() {
    String sortLabel = 'Sort by modified time';
    if (_selectedSortBy == 'created') sortLabel = 'Sort by created time';
    if (_selectedSortBy == 'alphabetical') sortLabel = 'Sort alphabetically';
    if (_selectedSortBy == 'color') sortLabel = 'Sort by color / tag';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showColorSortViewModal(context, initialTabIndex: 1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFECE9F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 16.0, color: Color(0xFF7C3AED)),
            const SizedBox(width: 6.0),
            Text(
              sortLabel,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFF150D33),
              ),
            ),
            const SizedBox(width: 4.0),
            const Icon(Icons.arrow_drop_down_rounded, size: 18.0, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }

  void _showColorSortViewModal(BuildContext context, {int initialTabIndex = 0}) {
    AudioHapticService.playButtonSound();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DefaultTabController(
              length: 3,
              initialIndex: initialTabIndex,
              child: Container(
                height: 420,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 25.0,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top Handle Drag Bar & Title Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 32),
                          Container(
                            width: 44.0,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14.0),

                      // Premium Segmented TabBar
                      Container(
                        height: 42.0,
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: TabBar(
                          isScrollable: false,
                          labelPadding: EdgeInsets.zero,
                          indicator: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                            ),
                            borderRadius: BorderRadius.circular(11.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                                blurRadius: 8.0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF64748B),
                          tabs: const [
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.palette_outlined, size: 14),
                                      SizedBox(width: 3),
                                      Text('Color / Tag', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.sort_rounded, size: 14),
                                      SizedBox(width: 3),
                                      Text('Sort Order', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.grid_view_rounded, size: 14),
                                      SizedBox(width: 3),
                                      Text('View Layout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // TabBar Content Views
                      Expanded(
                        child: TabBarView(
                          children: [
                            // ── Tab 1: Color / Category Filter Cards ──
                            GridView(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 2.7,
                              ),
                              children: [
                                _buildCategoryFilterChip(ctx, setModalState, 'All', Icons.dashboard_rounded, const Color(0xFF7C3AED), const Color(0xFFF3EDFF)),
                                _buildCategoryFilterChip(ctx, setModalState, 'Work', Icons.work_rounded, const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                                _buildCategoryFilterChip(ctx, setModalState, 'Study', Icons.school_rounded, const Color(0xFF8B5CF6), const Color(0xFFF3E8FF)),
                                _buildCategoryFilterChip(ctx, setModalState, 'Ideas', Icons.lightbulb_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                                _buildCategoryFilterChip(ctx, setModalState, 'Personal', Icons.person_rounded, const Color(0xFF10B981), const Color(0xFFE6F7ED)),
                                _buildCategoryFilterChip(ctx, setModalState, 'Reference', Icons.bookmark_rounded, const Color(0xFFDB2777), const Color(0xFFFFF1F6)),
                              ],
                            ),

                            // ── Tab 2: Sort Radio Tiles List ──
                            ListView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildSortRadioTile(ctx, setModalState, 'modified', 'by modified time', 'Order by latest edited date & time', Icons.access_time_filled_rounded),
                                _buildSortRadioTile(ctx, setModalState, 'created', 'by created time', 'Order by initial note creation date', Icons.calendar_month_rounded),
                                _buildSortRadioTile(ctx, setModalState, 'alphabetical', 'alphabetically', 'Sort notes from A to Z by title', Icons.sort_by_alpha_rounded),
                                _buildSortRadioTile(ctx, setModalState, 'color', 'by color / tag', 'Group notes together by category color', Icons.palette_rounded),
                              ],
                            ),

                            // ── Tab 3: View Layout Mode Options ──
                            Row(
                              children: [
                                Expanded(
                                  child: _buildViewOptionCard(ctx, setModalState, false, 'List View', 'Single column detailed cards', Icons.format_list_bulleted_rounded),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildViewOptionCard(ctx, setModalState, true, 'Grid View', '2-column compact grid layout', Icons.grid_view_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryFilterChip(
    BuildContext ctx,
    StateSetter setModalState,
    String name,
    IconData icon,
    Color color,
    Color bg,
  ) {
    final isSelected = _selectedCategory == name;
    return InkWell(
      onTap: () {
        AudioHapticService.playButtonSound();
        setState(() => _selectedCategory = name);
        setModalState(() {});
        Navigator.pop(ctx);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? color : bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.0,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4.0),
              const Icon(Icons.check_circle_rounded, size: 14.0, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortRadioTile(
    BuildContext ctx,
    StateSetter setModalState,
    String key,
    String label,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedSortBy == key;
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF3EDFF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
          width: isSelected ? 1.8 : 1.0,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19, color: isSelected ? Colors.white : const Color(0xFF64748B)),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 14.0,
            color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF150D33),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF64748B),
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.radio_button_checked_rounded, color: Color(0xFF7C3AED), size: 22)
            : const Icon(Icons.radio_button_off_rounded, color: Color(0xFFCBD5E1), size: 22),
        onTap: () {
          AudioHapticService.playButtonSound();
          setState(() => _selectedSortBy = key);
          setModalState(() {});
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _buildViewOptionCard(
    BuildContext ctx,
    StateSetter setModalState,
    bool isGrid,
    String label,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _isGridView == isGrid;
    return InkWell(
      onTap: () {
        _toggleLayoutView(isGrid);
        setModalState(() {});
        Navigator.pop(ctx);
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3EDFF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.0,
                  color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF150D33),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.0,
                color: Color(0xFF64748B),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 3. Notes Section (List View & Grid View)
  // ─────────────────────────────────────────────

  Widget _buildNotesSection() {
    return ValueListenableBuilder(
      valueListenable: _notesRepo.notesListenable,
      builder: (context, box, child) {
        final filteredNotes = _notesRepo.getFilteredAndSortedNotes(
          category: _selectedCategory,
          sortBy: _selectedSortBy,
        );

        final pinnedNotes = filteredNotes.where((n) => n.isPinned).toList();
        final recentNotes = filteredNotes.where((n) => !n.isPinned).toList();
        final hasNotes = filteredNotes.isNotEmpty;

        if (!hasNotes) {
          return _buildPureFlutterEmptyState(isCompact: false);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ColorNote Style "Tap to Create Note" Button ──
            _buildColorNoteCreateButton(),

            const SizedBox(height: 14.0),

            // Pinned Notes (if any)
            if (pinnedNotes.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(left: 4.0, bottom: 10.0, top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.push_pin_rounded, size: 14.0, color: Color(0xFF7C3AED)),
                    SizedBox(width: 6.0),
                    Text(
                      'PINNED NOTES',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C3AED),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isGridView)
                _buildNotesGrid(pinnedNotes)
              else
                ...pinnedNotes.map((note) => _buildNoteCard(note)),
              const SizedBox(height: 14.0),
            ],

            // All Notes (no RECENT NOTES header — clean ColorNote style)
            if (recentNotes.isNotEmpty)
              if (_isGridView)
                _buildNotesGrid(recentNotes)
              else
                ...recentNotes.map((note) => _buildNoteCard(note)),
          ],
        );
      },
    );
  }

  // Grid View Layout
  Widget _buildNotesGrid(List<NoteModel> notes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.88,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(notes[index], isGridMode: true);
      },
    );
  }

  // Single Note Card Widget matching reference design pixel-by-pixel
  Widget _buildNoteCard(NoteModel note, {bool isGridMode = false}) {
    final isChecklist = note.content.contains('[ ]') || note.content.contains('☐') || note.title.toLowerCase().contains('list');
    final isLinkNote = note.content.contains('http') || note.content.contains('www.');
    final isVoiceNote = note.content.contains('🎙️') || note.content.contains('Voice Note');

    // Theme Color Setup per Card Type
    Color accentColor = const Color(0xFF7C3AED); // Default Purple
    Color iconBg = const Color(0xFFF3EDFF);
    IconData cardIcon = Icons.article_outlined;

    if (isChecklist) {
      accentColor = const Color(0xFF8B5CF6);
      iconBg = const Color(0xFFF3E8FF);
      cardIcon = Icons.assignment_outlined;
    } else if (isLinkNote) {
      accentColor = const Color(0xFFEC4899);
      iconBg = const Color(0xFFFFF1F6);
      cardIcon = Icons.link_rounded;
    } else if (isVoiceNote) {
      accentColor = const Color(0xFF2563EB);
      iconBg = const Color(0xFFEFF6FF);
      cardIcon = Icons.mic_none_rounded;
    } else if (note.tag.toLowerCase() == 'work') {
      accentColor = const Color(0xFFEAB308);
      iconBg = const Color(0xFFFFFBEB);
      cardIcon = Icons.sticky_note_2_outlined;
    }

    if (isGridMode) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 4.0,
                  color: accentColor,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateNoteScreen(existingNote: note),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 34.0,
                              height: 34.0,
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Icon(cardIcon, color: accentColor, size: 18.0),
                            ),
                            InkWell(
                              onTap: () {
                                AudioHapticService.playButtonSound();
                                _notesRepo.togglePin(note.id);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                                  size: 16.0,
                                  color: note.isPinned ? const Color(0xFF7C3AED) : const Color(0xFFB0ACC8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          note.title.isNotEmpty ? note.title : 'Untitled Note',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF150D33),
                            letterSpacing: -0.2,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            note.content.replaceAll('\n', ' ').trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF6E6A8A),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: _buildTagPill(note.tag, isVoiceNote: isVoiceNote)),
                            InkWell(
                              onTap: () => _showNoteCardOptions(context, note),
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(
                                Icons.more_vert_rounded,
                                size: 16.0,
                                color: Color(0xFF9C98B6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.0),
          child: Stack(
            children: [
              // Left Vertical Color Bar Accent Line
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4.5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22.0),
                      bottomLeft: Radius.circular(22.0),
                    ),
                  ),
                ),
              ),

              // Main Card Interactive Area
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    AudioHapticService.playButtonSound();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateNoteScreen(existingNote: note),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 14.0, 14.0, 14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Card Header Row: Icon Container + Title + Pin Icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Soft Colored Icon Container Box
                            Container(
                              width: 46.0,
                              height: 46.0,
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Icon(cardIcon, color: accentColor, size: 23.0),
                            ),
                            const SizedBox(width: 12.0),

                            // Note Title & Top Right Pin Button
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.title.isNotEmpty ? note.title : 'Untitled Note',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF150D33),
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          AudioHapticService.playButtonSound();
                                          _notesRepo.togglePin(note.id);
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(
                                            note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                                            size: 18.0,
                                            color: note.isPinned ? const Color(0xFF7C3AED) : const Color(0xFFB0ACC8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),

                                  // Body Snippet Preview Content
                                  _buildCardBodyPreview(note, isChecklist, isLinkNote, isVoiceNote),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12.0),

                        // Card Footer Row: Tag Badge + More Options Button (⋮)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Tag Badge Pill
                            _buildTagPill(note.tag, isVoiceNote: isVoiceNote),

                            // More Options Button (⋮)
                            InkWell(
                              onTap: () => _showNoteCardOptions(context, note),
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.more_vert_rounded,
                                  size: 18.0,
                                  color: Color(0xFF9C98B6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBodyPreview(NoteModel note, bool isChecklist, bool isLinkNote, bool isVoiceNote) {
    if (isChecklist) {
      final items = note.content.split('\n').where((l) => l.trim().isNotEmpty).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_box_outline_blank_rounded, size: 14.0, color: Color(0xFF9C98B6)),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: Text(
                        item.replaceAll(RegExp(r'^\[\s*\]\s*'), '').replaceAll(RegExp(r'^☐\s*'), ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF6E6A8A), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )),
          if (items.length > 3)
            const Text('...', style: TextStyle(fontSize: 12, color: Color(0xFF9C98B6), fontWeight: FontWeight.bold)),
        ],
      );
    } else if (isLinkNote) {
      final links = note.content.split('\n').where((l) => l.contains('http') || l.contains('www.')).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: links.take(2).map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Row(
            children: [
              const Icon(Icons.link_rounded, size: 14.0, color: Color(0xFFEC4899)),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  link.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      );
    } else if (isVoiceNote) {
      return const Row(
        children: [
          Icon(Icons.mic_rounded, size: 14.0, color: Color(0xFF2563EB)),
          SizedBox(width: 4.0),
          Text(
            '02:35 • Voice Note',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return Text(
      note.content.isEmpty ? 'No text preview...' : note.content,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 13.0,
        color: Color(0xFF6E6A8A),
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
    );
  }

  Widget _buildTagPill(String tag, {bool isVoiceNote = false}) {
    Color bg = const Color(0xFFE6F7ED);
    Color fg = const Color(0xFF10B981);

    if (isVoiceNote && tag.toLowerCase() == 'personal') {
      bg = const Color(0xFFEBF3FF);
      fg = const Color(0xFF2563EB);
    } else if (tag.toLowerCase() == 'work') {
      bg = const Color(0xFFFFFBEB);
      fg = const Color(0xFFD97706);
    } else if (tag.toLowerCase() == 'reference') {
      bg = const Color(0xFFFFF1F6);
      fg = const Color(0xFFDB2777);
    } else if (tag.toLowerCase() == 'study') {
      bg = const Color(0xFFF3E8FF);
      fg = const Color(0xFF8B5CF6);
    } else if (tag.toLowerCase() == 'ideas') {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ColorNote Style Simple "Create Note" Button
  // ─────────────────────────────────────────────

  Widget _buildColorNoteCreateButton() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFECE9F6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            AudioHapticService.playButtonSound();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
            child: Row(
              children: [
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDFF),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Icon(Icons.add_rounded, color: Color(0xFF7C3AED), size: 24.0),
                ),
                const SizedBox(width: 12.0),
                const Expanded(
                  child: Text(
                    '+ Add Note / Take a note...',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6E6A8A),
                    ),
                  ),
                ),
                // Checklist Quick Action
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () {
                      AudioHapticService.playButtonSound();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateNoteScreen(
                            existingNote: NoteModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: 'To-Do Checklist',
                              content: '[ ] Item 1\n[ ] Item 2\n[ ] Item 3\n',
                              tag: 'Personal',
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7.0),
                      child: const Icon(Icons.check_box_outlined, color: Color(0xFF10B981), size: 21.0),
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                // AI Note Quick Action
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () {
                      AudioHapticService.playButtonSound();
                      _showCreateOptionsBottomSheet(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7.0),
                      child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF7C3AED), size: 20.0),
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

  // ─────────────────────────────────────────────
  // Pure Flutter Empty State Illustration Widget
  // ─────────────────────────────────────────────

  Widget _buildPureFlutterEmptyState({bool isCompact = false}) {
    final dynamicMinHeight = isCompact
        ? 220.0
        : (MediaQuery.of(context).size.height > 550
            ? MediaQuery.of(context).size.height - 330.0
            : 340.0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioHapticService.playButtonSound();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
          );
        },
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: dynamicMinHeight),
          padding: EdgeInsets.symmetric(vertical: isCompact ? 24.0 : 40.0, horizontal: 22.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: const Color(0xFFECE9F6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
                blurRadius: 16.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stacked Pure Flutter Vector Cards Widget
            SizedBox(
              width: 100,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -0.15,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: 0.12,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.note_alt_rounded, color: Color(0xFF7C3AED), size: 36),
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    right: 4,
                    child: Icon(Icons.auto_awesome, color: Color(0xFFFFB800), size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18.0),

            const Text(
              'Create Your First Note 📝',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFF150D33),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6.0),
            const Text(
              'Tap anywhere on this card or the + button below to start writing your ideas!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6E6A8A),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ─────────────────────────────────────────────
  // 4. Floating Action Button & Bottom Sheet
  // ─────────────────────────────────────────────

  Widget _buildFab() {
    return Container(
      width: 58.0,
      height: 58.0,
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
            blurRadius: 16.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCreateOptionsBottomSheet(context),
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


  // Material Bottom Sheet Options: Text Note, Checklist, Voice Note, Scan Document, AI Note, Premium
  void _showCreateOptionsBottomSheet(BuildContext context) {
    AudioHapticService.playButtonSound();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Handle Bar
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                const Text(
                  'Create New',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF150D33),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16.0),

                // 6 Option Tiles Grid
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.75,
                  ),
                  children: [
                    _buildOptionTile(
                      icon: Icons.edit_note_rounded,
                      title: 'Text Note',
                      subtitle: 'Type ideas',
                      color: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFFF3EDFF),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNoteScreen()));
                      },
                    ),
                    _buildOptionTile(
                      icon: Icons.check_box_outlined,
                      title: 'Checklist',
                      subtitle: 'To-do items',
                      color: const Color(0xFF10B981),
                      bgColor: const Color(0xFFE6F7ED),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateNoteScreen(
                          existingNote: NoteModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: 'Shopping List',
                            content: '[ ] Milk\n[ ] Eggs\n[ ] Bread\n',
                            tag: 'Personal',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        )));
                      },
                    ),
                    _buildOptionTile(
                      icon: Icons.mic_rounded,
                      title: 'Voice Note',
                      subtitle: 'Audio dictation',
                      color: const Color(0xFF2563EB),
                      bgColor: const Color(0xFFEBF3FF),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateNoteScreen(
                          existingNote: NoteModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: 'Voice Note',
                            content: '🎙️ [Voice Recording Saved]\n',
                            tag: 'Personal',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        )));
                      },
                    ),
                    _buildOptionTile(
                      icon: Icons.document_scanner_rounded,
                      title: 'Scan Document',
                      subtitle: 'OCR extract',
                      color: const Color(0xFFF59E0B),
                      bgColor: const Color(0xFFFFF4E5),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateNoteScreen(
                          existingNote: NoteModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: 'Scanned Document',
                            content: '📄 [Extracted Document Text]\n',
                            tag: 'Work',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        )));
                      },
                    ),
                    _buildOptionTile(
                      icon: Icons.auto_awesome_rounded,
                      title: 'AI Note',
                      subtitle: 'Smart Assistant',
                      color: const Color(0xFFEC4899),
                      bgColor: const Color(0xFFFFF1F6),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
                      },
                    ),
                    _buildOptionTile(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Premium',
                      subtitle: 'Pro Features',
                      color: const Color(0xFF8B5CF6),
                      bgColor: const Color(0xFFF3E8FF),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProUpgradeScreen()));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20.0),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6E6A8A),
                        ),
                      ),
                    ],
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
  // 5. Floating Bottom Navigation Bar
  // ─────────────────────────────────────────────

  Widget _buildBottomNavigationBar() {
    final navItems = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Categories', 'icon': Icons.folder_rounded},
      {'label': 'AI Assistant', 'icon': Icons.auto_awesome_rounded},
      {'label': 'Settings', 'icon': Icons.settings_rounded},
    ];

    return Container(
      height: 64.0,
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.0),
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
          final isSelected = _currentNavIndex == index;
          final item = navItems[index];

          return Expanded(
            child: InkWell(
              onTap: () {
                AudioHapticService.playButtonSound();
                if (index == 0) {
                  setState(() => _currentNavIndex = 0);
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                }
              },
              borderRadius: BorderRadius.circular(20.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF3EDFF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 21.0,
                        color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF9C98B6),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item['label'] as String,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF9C98B6),
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

  // ─────────────────────────────────────────────
  // 6. Navigation Drawer
  // ─────────────────────────────────────────────

  Widget _buildNavigationDrawer() {
    final categories = [
      {'name': 'All Notes', 'icon': Icons.note_alt_rounded, 'color': const Color(0xFF7C3AED)},
      {'name': 'Work', 'icon': Icons.work_rounded, 'color': const Color(0xFFD97706)},
      {'name': 'Study', 'icon': Icons.school_rounded, 'color': const Color(0xFF8B5CF6)},
      {'name': 'Ideas', 'icon': Icons.lightbulb_rounded, 'color': const Color(0xFF2563EB)},
      {'name': 'Personal', 'icon': Icons.person_rounded, 'color': const Color(0xFF10B981)},
      {'name': 'Favorites', 'icon': Icons.star_rounded, 'color': const Color(0xFFFFB800)},
      {'name': 'Archive', 'icon': Icons.archive_rounded, 'color': const Color(0xFF64748B)},
      {'name': 'Settings', 'icon': Icons.settings_rounded, 'color': const Color(0xFF6E6A8A)},
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  _buildBrandLogoBadge(),
                  const SizedBox(width: 12.0),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NoteNest',
                        style: TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF150D33),
                        ),
                      ),
                      Text(
                        'Smart Notes. Smarter Ideas.',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Color(0xFF6E6A8A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFECE9F6)),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == (cat['name'] as String == 'All Notes' ? 'All' : cat['name'] as String);
                  final name = cat['name'] as String;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context);
                      AudioHapticService.playButtonSound();
                      if (name == 'Settings') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      } else {
                        setState(() {
                          _selectedCategory = name == 'All Notes' ? 'All' : name;
                        });
                      }
                    },
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      selected: isSelected,
                      selectedTileColor: const Color(0xFFF3EDFF),
                      leading: Icon(cat['icon'] as IconData, color: cat['color'] as Color),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF150D33),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 7. More Options Bottom Sheet (⋮)
  // ─────────────────────────────────────────────

  void _showMoreOptionsMenu(BuildContext context) {
    AudioHapticService.playButtonSound();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.0)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.search_rounded, color: Color(0xFF7C3AED)),
              title: const Text('Search Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_rounded, color: Color(0xFF2563EB)),
              title: const Text('Categories & Tags', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded, color: Color(0xFF10B981)),
              title: const Text('Settings & Backup', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteCardOptions(BuildContext context, NoteModel note) {
    AudioHapticService.playButtonSound();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.push_pin_rounded, color: Color(0xFF7C3AED)),
              title: Text(note.isPinned ? 'Unpin Note' : 'Pin to Top', style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                _notesRepo.togglePin(note.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text('Delete Note', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                _notesRepo.deleteNote(note.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
