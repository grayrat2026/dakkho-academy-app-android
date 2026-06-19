import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/stores/auth_store.dart';
import '../../data/stores/stores.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AppShell — matches dakkho-student-app web AppShell.tsx exactly.
///
/// Layout:
///   - TopBar: fixed top, h-16, glassmorphism, logo + center search + bell + avatar + hamburger
///   - Sidebar: drawer with collapsible sections + user profile + logout
///   - BottomNav: fixed bottom, h-16, glassmorphism, 5 tabs (Home, Explore, Courses, History, Profile)
///   - Main content: pt-16 pb-20, max-w-1400 centered, p-4
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  // BottomNav tabs — EXACT match to web app
  static const _destinations = [
    (icon: LucideIcons.home, label: 'Home', path: '/app/home'),
    (icon: LucideIcons.compass, label: 'Explore', path: '/app/explore'),
    (icon: LucideIcons.bookOpen, label: 'Courses', path: '/app/my-courses'),
    (icon: LucideIcons.clock, label: 'History', path: '/app/history'),
    (icon: LucideIcons.user, label: 'Profile', path: '/app/profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _destinations.indexWhere((d) => location.startsWith(d.path));
    final user = ref.watch(authProvider).user;
    final notifications = ref.watch(notificationProvider).notifications;
    final unreadCount = notifications.where((n) => !n.read).length;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DakkhoColors.glassSidebar : DakkhoColors.glassSidebarLight;
    final borderColor = isDark ? DakkhoColors.glassCardBorder : DakkhoColors.glassCardBorderLight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main content area
          SafeArea(
            child: Column(
              children: [
                // TopBar
                _TopBar(user: user, unreadCount: unreadCount),
                // Content
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
          // BottomNav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
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
                    children: List.generate(_destinations.length, (i) {
                      final d = _destinations[i];
                      final isActive = i == currentIndex.clamp(0, _destinations.length - 1);
                      return GestureDetector(
                        onTap: () => context.go(d.path),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                d.icon,
                                size: 20,
                                color: isActive ? DakkhoColors.primary : (isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight),
                                fill: isActive ? 1.0 : 0.0,
                              ),
                              const SizedBox(height: 2),
                              if (isActive)
                                Text(
                                  d.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: DakkhoColors.primary,
                                  ),
                                ),
                              if (isActive)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 24,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: DakkhoColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                            ],
                          ),
                        ).animate(target: isActive ? 1 : 0).slideY(
                          begin: 0, end: isActive ? -0.1 : 0,
                          duration: const Duration(milliseconds: 200),
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
      drawer: const _AppDrawer(),
    );
  }
}

/// TopBar — matches web TopBar.tsx exactly.
/// Fixed top, h-16, glassmorphism, logo + center search + bell + avatar + hamburger
class _TopBar extends ConsumerWidget {
  const _TopBar({required this.user, required this.unreadCount});
  final User? user;
  final int unreadCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xCC0F172A) : const Color(0xCCFFFFFF);
    final borderColor = isDark ? const Color(0x0DFFFFFF) : const Color(0x80FFFFFF);
    final searchQuery = ref.watch(searchProvider).query;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // LEFT: Hamburger (mobile)
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? DakkhoColors.surfaceLight.withValues(alpha: 0.3) : DakkhoColors.surfaceLightMode.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.menu, size: 20, color: isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight),
                ),
              ),
              const SizedBox(width: 8),

              // Logo image (clickable → home)
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
              ),
              const SizedBox(width: 12),

              // CENTER: Search bar
              Expanded(
                child: GestureDetector(
                  onTap: () => context.go('/app/search'),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? DakkhoColors.surfaceLight.withValues(alpha: 0.3) : DakkhoColors.surfaceLightMode.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.transparent, width: 1),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(LucideIcons.search, size: 16, color: isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            searchQuery.isNotEmpty ? searchQuery : 'Search courses, instructors...',
                            style: TextStyle(
                              fontSize: 13,
                              color: searchQuery.isNotEmpty
                                  ? (isDark ? DakkhoColors.textPrimary : DakkhoColors.textPrimaryLight)
                                  : (isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () => ref.read(searchProvider.notifier).setQuery(''),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(LucideIcons.x, size: 14, color: isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight),
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
                    color: isDark ? DakkhoColors.surfaceLight.withValues(alpha: 0.3) : DakkhoColors.surfaceLightMode.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(child: Icon(LucideIcons.bell, size: 20, color: isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight)),
                      if (unreadCount > 0)
                        Positioned(
                          top: 8, right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: DakkhoColors.danger, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // User avatar
              GestureDetector(
                onTap: () => context.go('/app/profile'),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: DakkhoColors.primary,
                  backgroundImage: user?.avatarUrl?.isNotEmpty == true ? NetworkImage(user!.avatarUrl!) : null,
                  child: user?.avatarUrl?.isEmpty != false
                      ? Text(
                          (user?.name ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sidebar/Drawer — matches web Sidebar.tsx exactly.
/// Collapsible sections: Main, Departments, Semesters, Exam, Social, Account
class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DakkhoColors.glassSidebar : DakkhoColors.glassSidebarLight;
    final user = ref.watch(authProvider).user;

    final mainItems = [
      (LucideIcons.home, 'Home', '/app/home'),
      (LucideIcons.compass, 'Explore', '/app/explore'),
      (LucideIcons.bookOpen, 'My Courses', '/app/my-courses'),
      (LucideIcons.bookmark, 'Bookmarks', '/app/bookmarks'),
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
      (LucideIcons.tag, 'Pricing', '/app/pricing'),
    ];

    final accountItems = [
      (LucideIcons.settings, 'Settings', '/app/settings'),
      (LucideIcons.helpCircle, 'Help', '/app/help'),
      (LucideIcons.info, 'About', '/app/about'),
    ];

    return Drawer(
      backgroundColor: bgColor,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // User profile section at top
            if (user != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: DakkhoColors.primary,
                      backgroundImage: user.avatarUrl?.isNotEmpty == true ? NetworkImage(user.avatarUrl!) : null,
                      child: user.avatarUrl?.isEmpty != false
                          ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                  color: isDark ? DakkhoColors.textPrimary : DakkhoColors.textPrimaryLight)),
                          Text(user.email,
                              style: TextStyle(fontSize: 11, color: isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],

            // Main items
            ...mainItems.map((item) => _DrawerItem(icon: item.$1, label: item.$2, path: item.$3, isDark: isDark)),

            // Departments (collapsible)
            _SectionHeader(title: 'Departments', isDark: isDark),
            ...deptItems.map((item) => _DrawerItem(icon: item.$1, label: item.$2, path: item.$3, isDark: isDark, indent: true)),

            // Semesters
            _SectionHeader(title: 'Semesters', isDark: isDark),
            ...semesterItems.map((item) => _DrawerItem(icon: item.$1, label: item.$2, path: item.$3, isDark: isDark, indent: true)),

            // Exam
            _SectionHeader(title: 'Exam', isDark: isDark),
            ...examItems.map((item) => _DrawerItem(icon: item.$1, label: item.$2, path: item.$3, isDark: isDark, indent: true)),

            // Social
            _SectionHeader(title: 'Community', isDark: isDark),
            ...socialItems.map((item) => _DrawerItem(icon: item.$1, label: item.$2, path: item.$3, isDark: isDark, indent: true)),

            // Account
            _SectionHeader(title: 'Account', isDark: isDark),
            ...accountItems.map((item) => _DrawerItem(icon: item.$1, label: item.$2, path: item.$3, isDark: isDark)),

            // Logout
            const Divider(),
            _DrawerItem(
              icon: LucideIcons.logOut,
              label: 'Logout',
              path: '/logout',
              isDark: isDark,
              iconColor: DakkhoColors.danger,
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: isDark ? DakkhoColors.textMuted : DakkhoColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon, required this.label, required this.path, required this.isDark,
    this.indent = false, this.iconColor, this.onTap,
  });
  final IconData icon;
  final String label;
  final String path;
  final bool isDark;
  final bool indent;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isActive = location == path || location.startsWith('$path/');

    return ListTile(
      leading: Icon(icon, size: 18,
          color: iconColor ?? (isActive ? DakkhoColors.primary : (isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight))),
      title: Padding(
        padding: EdgeInsets.only(left: indent ? 8 : 0),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? DakkhoColors.primary : (isDark ? DakkhoColors.textPrimary : DakkhoColors.textPrimaryLight),
            )),
      ),
      contentPadding: EdgeInsets.only(left: indent ? 36 : 20, right: 16),
      dense: true,
      onTap: onTap ?? () {
        if (path == '/logout') return;
        context.go(path);
        Navigator.of(context).pop();
      },
    );
  }
}
