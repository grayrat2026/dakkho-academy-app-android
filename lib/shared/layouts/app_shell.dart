import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../data/stores/auth_store.dart';
import '../../data/stores/stores.dart';

/// AppShell — EXACT match to web AppShell.tsx + TopBar.tsx + Sidebar.tsx + BottomNav.tsx
///
/// TopBar: Logo LEFT → Search CENTER → Bell + Avatar + Hamburger RIGHT
/// Sidebar: Slides from RIGHT (endDrawer), collapsible sections
/// BottomNav: 5 tabs with active indicator pill
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _destinations = [
    (icon: LucideIcons.home, label: 'Home', path: '/app/home'),
    (icon: LucideIcons.compass, label: 'Explore', path: '/app/explore'),
    (icon: LucideIcons.bookOpen, label: 'Courses', path: '/app/my-courses'),
    (icon: LucideIcons.clock, label: 'History', path: '/app/history'),
    (icon: LucideIcons.user, label: 'Profile', path: '/app/profile'),
  ];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = AppShell._destinations.indexWhere((d) => location.startsWith(d.path));
    final user = ref.watch(authProvider).user;
    final notifications = ref.watch(notificationProvider).notifications;
    final unreadCount = notifications.where((n) => !n.read).length;
    final searchQuery = ref.watch(searchProvider).query;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xD90F172A) : const Color(0xD9FFFFFF);
    final borderColor = isDark ? const Color(0x0DFFFFFF) : const Color(0x4DFFFFFF);
    final mutedBg = isDark ? const Color(0x4D1E293B) : const Color(0x80F1F5F9);
    final mutedText = isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight;
    final primaryText = isDark ? DakkhoColors.textPrimary : DakkhoColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      endDrawer: _AppDrawer(),  // endDrawer = slides from RIGHT (matches web app)
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              children: [
                // ─── TopBar (matches web TopBar.tsx) ───
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border(bottom: BorderSide(color: borderColor, width: 1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // LEFT: Logo (click → home)
                        GestureDetector(
                          onTap: () => context.go('/app/home'),
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              gradient: DakkhoColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 18),
                          ),
                        ).animate().fadeIn(),
                        const SizedBox(width: 12),

                        // CENTER: Search bar
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.go('/app/search'),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: mutedBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Icon(LucideIcons.search, size: 16, color: mutedText),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      searchQuery.isNotEmpty ? searchQuery : 'Search courses, instructors...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: searchQuery.isNotEmpty ? primaryText : mutedText,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (searchQuery.isNotEmpty)
                                    GestureDetector(
                                      onTap: () => ref.read(searchProvider.notifier).setQuery(''),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Container(
                                          width: 24, height: 24,
                                          decoration: BoxDecoration(
                                            color: mutedBg,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(LucideIcons.x, size: 12, color: mutedText),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // RIGHT: Notification bell with badge
                        GestureDetector(
                          onTap: () => context.go('/app/notifications'),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: mutedBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Center(child: Icon(LucideIcons.bell, size: 20, color: mutedText)),
                                if (unreadCount > 0)
                                  Positioned(
                                    top: 8, right: 8,
                                    child: Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        color: DakkhoColors.danger,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: bgColor, width: 2),
                                      ),
                                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                                      begin: const Offset(1, 1),
                                      end: const Offset(1.8, 1.8),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // RIGHT: User avatar
                        GestureDetector(
                          onTap: () => context.go('/app/profile'),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              gradient: DakkhoColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: DakkhoColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: user?.avatarUrl?.isNotEmpty == true
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(user!.avatarUrl!, fit: BoxFit.cover),
                                  )
                                : Center(
                                    child: Text(
                                      (user?.name ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // RIGHT: Hamburger (mobile only — opens endDrawer from RIGHT)
                        GestureDetector(
                          onTap: () => Scaffold.of(context).openEndDrawer(),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: mutedBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(LucideIcons.menu, size: 20, color: mutedText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Expanded(child: widget.child),
              ],
            ),
          ),

          // ─── BottomNav (matches web BottomNav.tsx) ───
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(AppShell._destinations.length, (i) {
                      final d = AppShell._destinations[i];
                      final isActive = i == currentIndex.clamp(0, AppShell._destinations.length - 1);
                      return GestureDetector(
                        onTap: () => context.go(d.path),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 64, height: 64,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                d.icon,
                                size: 20,
                                color: isActive ? DakkhoColors.primary : mutedText,
                                fill: isActive ? 1.0 : 0.0,
                              ).animate(target: isActive ? 1 : 0).slideY(
                                begin: 0, end: isActive ? -0.1 : 0,
                                duration: const Duration(milliseconds: 200),
                              ),
                              if (isActive) ...[
                                const SizedBox(height: 2),
                                Text(d.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: DakkhoColors.primary)),
                                const SizedBox(height: 2),
                                Container(
                                  width: 24, height: 3,
                                  decoration: BoxDecoration(
                                    gradient: DakkhoColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
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

// ─── Sidebar/Drawer (slides from RIGHT — matches web Sidebar.tsx) ───
class _AppDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF);
    final primaryText = isDark ? DakkhoColors.textPrimary : DakkhoColors.textPrimaryLight;
    final mutedText = isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight;
    final user = ref.watch(authProvider).user;
    final expanded = <String>{'dept', 'semester', 'exam', 'social'};

    final mainItems = [
      (LucideIcons.home, 'Home', '/app/home'),
      (LucideIcons.compass, 'Explore', '/app/explore'),
      (LucideIcons.bookOpen, 'My Courses', '/app/my-courses'),
      (LucideIcons.bookmark, 'Bookmarks', '/app/bookmarks'),
      (LucideIcons.grid3x3, 'Categories', '/app/category/cse'),
      (LucideIcons.graduationCap, 'Instructors', '/app/instructors'),
      (LucideIcons.clock, 'Watch History', '/app/history'),
      (LucideIcons.download, 'Downloads', '/app/downloads'),
      (LucideIcons.award, 'Certificates', '/app/certificates'),
      (LucideIcons.radio, 'Live Sessions', '/app/live-sessions'),
      (LucideIcons.trophy, 'Achievements', '/app/achievements'),
    ];

    final deptItems = [
      (LucideIcons.monitor, 'Computer Science', '/app/department/cse'),
      (LucideIcons.cpu, 'Electronics & Telecom', '/app/department/ete'),
      (LucideIcons.zap, 'Electrical Eng.', '/app/department/eee'),
      (LucideIcons.wrench, 'Mechanical Eng.', '/app/department/me'),
      (LucideIcons.building, 'Civil Eng.', '/app/department/ce'),
      (LucideIcons.ruler, 'Architecture', '/app/department/architecture'),
      (LucideIcons.scissors, 'Textile Eng.', '/app/department/textile'),
      (LucideIcons.flaskConical, 'Chemical Eng.', '/app/department/chemical'),
      (LucideIcons.car, 'Automobile Eng.', '/app/department/automobile'),
      (LucideIcons.snowflake, 'RAC', '/app/department/rac'),
    ];

    final semesterItems = [
      for (var i = 1; i <= 8; i++) (LucideIcons.bookMarked, 'Semester $i', '/app/semester/$i'),
    ];

    final examItems = [
      (LucideIcons.clipboardList, 'Exam Prep', '/app/exam/prep'),
      (LucideIcons.calendarDays, 'Exam Schedule', '/app/exam/schedule'),
      (LucideIcons.award, 'Exam Results', '/app/exam/results'),
      (LucideIcons.helpCircle, 'Practice', '/app/exam/practice'),
      (LucideIcons.sparkles, 'Exam Tips', '/app/exam/tips'),
    ];

    final socialItems = [
      (LucideIcons.trophy, 'Leaderboard', '/app/community/leaderboard'),
      (LucideIcons.users, 'Study Groups', '/app/community/study-groups'),
      (LucideIcons.heart, 'Peers', '/app/community/peer-connections'),
      (LucideIcons.messageCircle, 'Community', '/app/community'),
      (LucideIcons.flag, 'Feedback', '/app/community/feedback'),
      (LucideIcons.dollarSign, 'Pricing', '/app/pricing'),
    ];

    final generalItems = [
      (LucideIcons.settings, 'Settings', '/app/settings'),
      (LucideIcons.helpCircle, 'Help', '/app/help'),
      (LucideIcons.messageCircle, 'Discussion', '/app/discussion'),
      (LucideIcons.info, 'About', '/app/about'),
    ];

    return Drawer(
      backgroundColor: bgColor,
      width: 280,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () { context.go('/app/home'); Navigator.pop(context); },
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        gradient: DakkhoColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 18),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: isDark ? DakkhoColors.surfaceLight : DakkhoColors.surfaceLightMode, borderRadius: BorderRadius.circular(8)),
                      child: Icon(LucideIcons.x, size: 16, color: mutedText),
                    ),
                  ),
                ],
              ),
            ),

            // User info
            if (user != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: DakkhoColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: DakkhoColors.primary.withValues(alpha: 0.3), blurRadius: 10)],
                      ),
                      child: user.avatarUrl?.isNotEmpty == true
                          ? ClipOval(child: Image.network(user.avatarUrl!, fit: BoxFit.cover))
                          : Center(child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryText), overflow: TextOverflow.ellipsis),
                          Text(user.technologyName ?? user.technology ?? 'No technology set', style: TextStyle(fontSize: 11, color: mutedText), overflow: TextOverflow.ellipsis),
                          Text(user.instituteName ?? 'No institute set', style: const TextStyle(fontSize: 11, color: DakkhoColors.primary), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(),

            // Scrollable nav
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _sectionLabel('Menu', isDark),
                  ...mainItems.map((item) => _navItem(item.$1, item.$2, item.$3, isDark, primaryText, mutedText, context)),

                  _sectionLabel('Departments', isDark),
                  ...deptItems.map((item) => _navItem(item.$1, item.$2, item.$3, isDark, primaryText, mutedText, context, indent: true)),

                  _sectionLabel('Semesters', isDark),
                  ...semesterItems.map((item) => _navItem(item.$1, item.$2, item.$3, isDark, primaryText, mutedText, context, indent: true)),

                  _sectionLabel('Exams', isDark),
                  ...examItems.map((item) => _navItem(item.$1, item.$2, item.$3, isDark, primaryText, mutedText, context, indent: true)),

                  _sectionLabel('Community', isDark),
                  ...socialItems.map((item) => _navItem(item.$1, item.$2, item.$3, isDark, primaryText, mutedText, context, indent: true)),

                  _sectionLabel('General', isDark),
                  ...generalItems.map((item) => _navItem(item.$1, item.$2, item.$3, isDark, primaryText, mutedText, context)),
                ],
              ),
            ),

            // Logout
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(LucideIcons.logOut, size: 20, color: DakkhoColors.danger),
                      const SizedBox(width: 12),
                      Text('Logout', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.danger)),
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

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: isDark ? DakkhoColors.textMuted : DakkhoColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, String path, bool isDark, Color primaryText, Color mutedText, BuildContext context, {bool indent = false}) {
    final location = GoRouterState.of(context).matchedLocation;
    final isActive = location == path || location.startsWith('$path/');

    return GestureDetector(
      onTap: () {
        context.go(path);
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(left: indent ? 16 : 0, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? DakkhoColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? DakkhoColors.primary : mutedText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: isActive ? DakkhoColors.primary : primaryText,
                ),
              ),
            ),
            if (isActive) Icon(LucideIcons.chevronRight, size: 14, color: DakkhoColors.primary),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 30.ms).slideX(begin: -0.05, end: 0);
  }
}
