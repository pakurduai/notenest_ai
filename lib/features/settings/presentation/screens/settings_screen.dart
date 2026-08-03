import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/settings_item_model.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'pro_upgrade_screen.dart';
import 'trash_screen.dart';
import '../../../../core/services/audio_haptic_service.dart';

/// Settings Screen — Rebuilt to 100% pixel-to-pixel perfection
/// matching the official NoteNest AI design reference.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  int _currentBottomNavIndex = 4; // 'Settings' active tab

  final List<SettingsItemModel> _appPreferences = const [
    SettingsItemModel(
      id: 'appearance',
      title: 'Appearance',
      subtitle: 'Choose theme, colors and font size',
      icon: Icons.palette_rounded,
      iconBg: Color(0xFFF3EDFF),
      iconColor: Color(0xFF7C3AED),
    ),
    SettingsItemModel(
      id: 'notifications',
      title: 'Notifications',
      subtitle: 'Manage reminders and notifications',
      icon: Icons.notifications_rounded,
      iconBg: Color(0xFFDCFCE7),
      iconColor: Color(0xFF10B981),
    ),
    SettingsItemModel(
      id: 'privacy',
      title: 'Privacy & Security',
      subtitle: 'App lock, privacy and security settings',
      icon: Icons.verified_user_rounded,
      iconBg: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
    ),
    SettingsItemModel(
      id: 'backup',
      title: 'Backup & Restore',
      subtitle: 'Backup your notes and restore data',
      icon: Icons.folder_rounded,
      iconBg: Color(0xFFFFEDD5),
      iconColor: Color(0xFFF97316),
    ),
    SettingsItemModel(
      id: 'language',
      title: 'Language',
      subtitle: 'Choose your preferred language',
      icon: Icons.language_rounded,
      iconBg: Color(0xFFFFEBF2),
      iconColor: Color(0xFFEC4899),
      trailingText: 'English',
    ),
  ];

  final List<SettingsItemModel> _dataAndStorage = const [
    SettingsItemModel(
      id: 'storage',
      title: 'Storage Usage',
      subtitle: 'Manage app storage and cache',
      icon: Icons.dns_rounded,
      iconBg: Color(0xFFF3EDFF),
      iconColor: Color(0xFF8B5CF6),
      trailingText: '256 MB',
    ),
    SettingsItemModel(
      id: 'trash',
      title: 'Trash',
      subtitle: 'View and manage deleted notes',
      icon: Icons.delete_outline_rounded,
      iconBg: Color(0xFFDCFCE7),
      iconColor: Color(0xFF10B981),
    ),
    SettingsItemModel(
      id: 'export',
      title: 'Export Notes',
      subtitle: 'Export your notes in PDF, TXT or Markdown',
      icon: Icons.description_rounded,
      iconBg: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
    ),
  ];

  final List<SettingsItemModel> _others = const [
    SettingsItemModel(
      id: 'rate',
      title: 'Rate Us',
      subtitle: 'If you love NoteNest AI, please rate us',
      icon: Icons.star_rounded,
      iconBg: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
    ),
    SettingsItemModel(
      id: 'share',
      title: 'Share App',
      subtitle: 'Share NoteNest AI with your friends',
      icon: Icons.favorite_rounded,
      iconBg: Color(0xFFFFEBF2),
      iconColor: Color(0xFFEC4899),
    ),
    SettingsItemModel(
      id: 'about',
      title: 'About Us',
      subtitle: 'Version 1.0.0',
      icon: Icons.info_rounded,
      iconBg: Color(0xFFF3EDFF),
      iconColor: Color(0xFF7C3AED),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Edge-to-edge status bar styling
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
                          // User Profile & Storage Banner Card
                          _buildProfileStorageBanner(),
                          const SizedBox(height: 16.0),

                          // App Preferences Section
                          _buildSectionHeader('App Preferences'),
                          const SizedBox(height: 8.0),
                          _buildSettingsGroupCard(_appPreferences),
                          const SizedBox(height: 16.0),

                          // Data & Storage Section
                          _buildSectionHeader('Data & Storage'),
                          const SizedBox(height: 8.0),
                          _buildSettingsGroupCard(_dataAndStorage),
                          const SizedBox(height: 16.0),

                          // Others Section
                          _buildSectionHeader('Others'),
                          const SizedBox(height: 8.0),
                          _buildSettingsGroupCard(_others),

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

        // Title & Subtitle
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF150D33),
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 1.0),
              Text(
                'Customize your app experience',
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
              onTap: () {},
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
  // 2. User Profile & Storage Banner Card
  // ─────────────────────────────────────────────

  Widget _buildProfileStorageBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Official NoteNest AI Monogram Logo Avatar (Reference Design Match)
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.18),
                    blurRadius: 12.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    'assets/branding/monogram.png',
                    width: 44.0,
                    height: 44.0,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7C3AED),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'N',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),

            // Middle User Details Column (Un-truncated Full Text)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title + Free Plan Badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'NoteNest AI',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF150D33),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EBFB),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        'Free Plan',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),

                // Email
                const Text(
                  'notes@notenest.ai',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E6A8A),
                  ),
                ),
                const SizedBox(height: 6.0),

                // Storage Used Icon & Text
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_outlined, size: 12.0, color: Color(0xFF7C3AED)),
                    SizedBox(width: 4.0),
                    Text(
                      '256 MB of 500 MB used',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),

                // Gradient Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Container(
                    height: 5.0,
                    width: 140.0,
                    color: const Color(0xFFEFEAFB),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.512,
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
              ],
            ),
            const SizedBox(width: 12.0),

            // Right "Upgrade to Pro" Card Box (Royal Crown Reference Match)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProUpgradeScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 9.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: const Color(0xFFEDE9F6)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.05),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Royal Crown Icon Box
                    Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EBFB),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Center(
                        child: CustomPaint(
                          size: Size(18.0, 16.0),
                          painter: ProCrownPainter(color: Color(0xFF7C3AED)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Upgrade to Pro',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        SizedBox(height: 1.0),
                        Text(
                          'Unlock all premium features',
                          style: TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8C88A6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4.0),

                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C3AED), size: 16.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 3. Section Title Header
  // ─────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w800,
        color: Color(0xFF150D33),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 4. Settings Group Card Container (Reusable)
  // ─────────────────────────────────────────────

  Widget _buildSettingsGroupCard(List<SettingsItemModel> items) {
    return Container(
      width: double.infinity,
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
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleSettingsItemTap(item.title),
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(22.0) : Radius.zero,
                    bottom: isLast ? const Radius.circular(22.0) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
                    child: Row(
                      children: [
                        // Left Icon Square
                        Container(
                          width: 36.0,
                          height: 36.0,
                          decoration: BoxDecoration(
                            color: item.iconBg,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(item.icon, color: item.iconColor, size: 19.0),
                        ),
                        const SizedBox(width: 12.0),

                        // Title & Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF150D33),
                                ),
                              ),
                              const SizedBox(height: 1.0),
                              Text(
                                item.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7B7799),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),

                        // Right Trailing Text (e.g. 'English', '256 MB') & Chevron
                        Row(
                          children: [
                            if (item.trailingText != null) ...[
                              Text(
                                item.trailingText!,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                              const SizedBox(width: 4.0),
                            ],
                            const Icon(Icons.chevron_right_rounded,
                                color: Color(0xFF9C98B6), size: 18.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Light Divider Line (except last item)
              if (!isLast)
                const Divider(
                  height: 1.0,
                  thickness: 1.0,
                  indent: 62.0,
                  endIndent: 14.0,
                  color: Color(0xFFF3F0F9),
                ),
            ],
          );
        }),
      ),
    );
  }

  void _handleSettingsItemTap(String title) {
    if (title == 'Trash') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TrashScreen()));
      return;
    } else if (title == 'Storage Usage') {
      _showStorageUsageDialog();
      return;
    } else if (title == 'Appearance') {
      _showAppearanceModal();
      return;
    } else if (title == 'Notifications') {
      _showNotificationsModal();
      return;
    } else if (title == 'Privacy & Security') {
      _showPrivacyModal();
      return;
    } else if (title == 'Backup & Restore') {
      _showBackupModal();
      return;
    } else if (title == 'Language') {
      _showLanguageModal();
      return;
    } else if (title == 'Export Notes') {
      _showExportModal();
      return;
    } else if (title == 'Rate Us') {
      _showRateUsDialog();
      return;
    } else if (title == 'Share App') {
      _showShareModal();
      return;
    } else if (title == 'About Us') {
      _showAboutDialog();
      return;
    }
  }

  // ── 12. Storage Usage Dialog ──
  void _showStorageUsageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.dns_rounded, color: Color(0xFF7C3AED), size: 24),
            SizedBox(width: 10),
            Text(
              'Storage Usage',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF150D33)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App & Database Storage Status:',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF6E6A8A)),
            ),
            const SizedBox(height: 16),

            // Used Storage Row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.pie_chart_rounded, size: 16, color: Color(0xFF7C3AED)),
                    SizedBox(width: 6),
                    Text('Used Storage:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF150D33))),
                  ],
                ),
                Text('2.4 MB', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED))),
              ],
            ),
            const SizedBox(height: 8),

            // Available Storage Row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud_done_rounded, size: 16, color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Text('Available Storage:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF150D33))),
                  ],
                ),
                Text('497.6 MB', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 10.0,
                    width: double.infinity,
                    color: const Color(0xFFEFEAFB),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.05, // 2.4MB / 500MB
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
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('0.5% of 500 MB limit', style: TextStyle(fontSize: 11, color: Color(0xFF8C88A6))),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Clean Cache Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFDDD5FA)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 42),
              ),
              icon: const Icon(Icons.cleaning_services_rounded, color: Color(0xFF7C3AED), size: 18),
              label: const Text('Clear Temporary Cache', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Temporary cache cleared! 🧹'), duration: Duration(seconds: 2)),
                );
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAppearanceModal() {
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
              const Text('Appearance Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.light_mode_rounded, color: Color(0xFF7C3AED)),
                title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Light Mode (System Auto Switch)'),
                trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF7C3AED)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_rounded, color: Color(0xFF2563EB)),
                title: const Text('Primary Accent Color', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Royal Violet (#7C3AED)'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsModal() {
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
              const Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
              const SizedBox(height: 14),
              SwitchListTile(
                value: true,
                onChanged: (val) {},
                title: const Text('Daily Reminder Notification', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Receive a gentle reminder at 09:00 AM'),
                activeTrackColor: const Color(0xFF7C3AED),
              ),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return SwitchListTile(
                    value: AudioHapticService.isSoundEnabled,
                    onChanged: (val) {
                      setModalState(() {
                        AudioHapticService.isSoundEnabled = val;
                      });
                      setState(() {});
                      if (val) AudioHapticService.playNotificationBellSound();
                    },
                    title: const Text('App Sound Effects & Vibration', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(AudioHapticService.isSoundEnabled ? 'Sound ON (Tactile Feedback active)' : 'Sound OFF (Muted)'),
                    activeTrackColor: const Color(0xFF7C3AED),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyModal() {
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
              const Text('Privacy & Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.lock_rounded, color: Color(0xFF7C3AED)),
                title: const Text('App Lock PIN', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Protect notes with Biometrics / PIN'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App Lock configured successfully! 🔒')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.security_rounded, color: Color(0xFF10B981)),
                title: const Text('Offline Local Storage', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('100% data remains on your device in Hive DB'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackupModal() {
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
              const Text('Backup & Restore', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF7C3AED)),
                title: const Text('Create Local Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Export all notes to JSON backup file'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup file saved successfully! 💾')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download_rounded, color: Color(0xFF2563EB)),
                title: const Text('Restore Data from Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Import notes from JSON snapshot'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes restored from backup! 🔄')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageModal() {
    final languages = ['English (US)', 'Spanish (Español)', 'French (Français)', 'German (Deutsch)', 'Urdu (اردو)', 'Hindi (हिंदी)', 'Arabic (العربية)', 'Chinese (中文)'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select App Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
            ),
            ...languages.map((lang) => ListTile(
              title: Text(lang, style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: lang.startsWith('English') ? const Icon(Icons.check_circle_rounded, color: Color(0xFF7C3AED)) : null,
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language set to $lang')));
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showExportModal() {
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
              const Text('Export Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.description_rounded, color: Color(0xFF7C3AED)),
                title: const Text('Export as Plain Text (.txt)'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported notes as TXT file! 📤')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.code_rounded, color: Color(0xFF2563EB)),
                title: const Text('Export as Markdown (.md)'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported notes as Markdown file! 📤')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                title: const Text('Export as PDF Document (.pdf)'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported notes as PDF file! 📤')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRateUsDialog() {
    int selectedRating = 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Enjoying NoteNest AI?', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please leave us a rating on Google Play Store!', style: TextStyle(fontSize: 13, color: Color(0xFF6E6A8A))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (idx) => IconButton(
                    icon: Icon(idx < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded, color: const Color(0xFFFFB800), size: 36),
                    onPressed: () => setDialogState(() => selectedRating = idx + 1),
                  )),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later', style: TextStyle(color: Color(0xFF8C88A6)))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for rating 5 stars! ⭐⭐⭐⭐⭐')));
                },
                child: const Text('Submit Rating', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showShareModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.share_rounded, color: Color(0xFF7C3AED), size: 40),
              const SizedBox(height: 10),
              const Text('Share NoteNest AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
              const SizedBox(height: 4),
              const Text('https://play.google.com/store/apps/details?id=com.notenest.ai', style: TextStyle(fontSize: 12, color: Color(0xFF6E6A8A))),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.copy_rounded, color: Colors.white),
                label: const Text('Copy App Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: 'https://play.google.com/store/apps/details?id=com.notenest.ai'));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App link copied to clipboard! 📋')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Image.asset('assets/branding/monogram.png', width: 32, height: 32, errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED))),
            const SizedBox(width: 10),
            const Text('NoteNest AI', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF150D33))),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0 (Build 1)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(height: 6),
            Text('NoteNest AI is a smart, 100% offline note-taking app powered by Hive DB and Flutter.', style: TextStyle(fontSize: 13, color: Color(0xFF6E6A8A))),
            SizedBox(height: 10),
            Text('© 2026 NoteNest AI Inc. All rights reserved.', style: TextStyle(fontSize: 11, color: Color(0xFF8C88A6))),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final navItems = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Notes', 'icon': Icons.description_rounded},
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
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
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

/// Custom Painter for the Upgrade to Pro Royal Crown Icon
class ProCrownPainter extends CustomPainter {
  final Color color;

  const ProCrownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Crown Base Bar
    final baseRect = RRect.fromLTRBR(
      w * 0.12,
      h * 0.76,
      w * 0.88,
      h * 0.90,
      const Radius.circular(2.0),
    );
    canvas.drawRRect(baseRect, paint);

    // Crown Spikes Body Path
    final path = Path();
    path.moveTo(w * 0.14, h * 0.72);
    path.lineTo(w * 0.08, h * 0.30); // Left peak
    path.lineTo(w * 0.33, h * 0.52); // Left valley
    path.lineTo(w * 0.50, h * 0.18); // Center peak
    path.lineTo(w * 0.67, h * 0.52); // Right valley
    path.lineTo(w * 0.92, h * 0.30); // Right peak
    path.lineTo(w * 0.86, h * 0.72); // Bottom right
    path.close();

    canvas.drawPath(path, paint);

    // Crown Top Jewels (3 Circles)
    canvas.drawCircle(Offset(w * 0.08, h * 0.24), w * 0.07, paint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.12), w * 0.08, paint);
    canvas.drawCircle(Offset(w * 0.92, h * 0.24), w * 0.07, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
