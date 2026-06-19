import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';

/// AppShell — wraps every authenticated page with TopBar + BottomNav.
///
/// Material 3 NavigationBar with 5 destinations:
///   Home, Explore, Search, Downloads, Profile
///
/// Sidebar (NavigationDrawer) opens from the top-left hamburger menu and
/// shows ALL routes (~80+) grouped by section.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    (icon: LucideIcons.home, label: 'Home', path: '/app/home'),
    (icon: LucideIcons.compass, label: 'Explore', path: '/app/explore'),
    (icon: LucideIcons.search, label: 'Search', path: '/app/search'),
    (icon: LucideIcons.download, label: 'Downloads', path: '/app/downloads'),
    (icon: LucideIcons.user, label: 'Profile', path: '/app/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _destinations.indexWhere((d) => location.startsWith(d.path));

    return Scaffold(
      backgroundColor: DakkhoColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ───
            _TopBar(),

            // ─── Page Content ───
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
      // ─── Bottom Navigation ───
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: DakkhoColors.glassCardBorder, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: DakkhoColors.glassSidebar,
          indicatorColor: DakkhoColors.primary.withValues(alpha: 0.15),
          selectedIndex: currentIndex.clamp(0, _destinations.length - 1),
          onDestinationSelected: (i) => context.go(_destinations[i].path),
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon, size: 22),
                selectedIcon: Icon(d.icon, size: 24, color: DakkhoColors.primary),
                label: d.label,
              ),
          ],
        ),
      ),
      // ─── Sidebar (Drawer) ───
      drawer: const _AppDrawer(),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      borderRadius: 16,
      child: Row(
        children: [
          // Hamburger menu
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(LucideIcons.menu, size: 24, color: DakkhoColors.textPrimary),
          )
              .animate()
              .fadeIn(duration: DakkhoAnimations.normal)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: DakkhoAnimations.normal,
              ),

          const SizedBox(width: 12),

          // Logo + App Name
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: DakkhoColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Text(
            'DAKKHO',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontFamilyFallback: ['NotoSansBengali'],
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: DakkhoColors.textPrimary,
            ),
          ),

          const Spacer(),

          // Search icon
          GestureDetector(
            onTap: () => context.go('/app/search'),
            child: const Icon(LucideIcons.search, size: 22, color: DakkhoColors.textSecondary),
          ),
          const SizedBox(width: 16),

          // Notification bell (with red badge)
          Stack(
            children: [
              GestureDetector(
                onTap: () => context.go('/app/notifications'),
                child: const Icon(LucideIcons.bell, size: 22, color: DakkhoColors.textSecondary),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: DakkhoColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: const Duration(seconds: 2),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  static const _sections = [
    {
      'title': 'Main',
      'items': [
        (LucideIcons.home, 'Home', '/app/home'),
        (LucideIcons.compass, 'Explore', '/app/explore'),
        (LucideIcons.search, 'Search', '/app/search'),
        (LucideIcons.bell, 'Notifications', '/app/notifications'),
        (LucideIcons.user, 'Profile', '/app/profile'),
      ],
    },
    {
      'title': 'Learning',
      'items': [
        (LucideIcons.bookOpen, 'My Courses', '/app/my-courses'),
        (LucideIcons.download, 'Downloads', '/app/downloads'),
        (LucideIcons.history, 'Watch History', '/app/history'),
        (LucideIcons.bookmark, 'Bookmarks', '/app/bookmarks'),
        (LucideIcons.award, 'Certificates', '/app/certificates'),
        (LucideIcons.trophy, 'Achievements', '/app/achievements'),
      ],
    },
    {
      'title': 'Account',
      'items': [
        (LucideIcons.settings, 'Settings', '/app/settings'),
        (LucideIcons.smartphone, 'Device Binding', '/app/device'),
        (LucideIcons.shieldCheck, '2FA', '/app/2fa'),
        (LucideIcons.helpCircle, 'Help', '/app/help'),
        (LucideIcons.logOut, 'Logout', '/logout'),
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: DakkhoColors.glassSidebar,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: DakkhoColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'DAKKHO Academy',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontFamilyFallback: ['NotoSansBengali'],
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: DakkhoColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Polytechnic Learning',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontFamilyFallback: ['NotoSansBengali'],
                          fontSize: 12,
                          color: DakkhoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // Sections
            for (final section in _sections) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  section['title'] as String,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontFamilyFallback: ['NotoSansBengali'],
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: DakkhoColors.textMuted,
                  ),
                ),
              ),
              for (final item in section['items'] as List)
                _DrawerItem(
                  icon: (item as (IconData, String, String)).$1,
                  label: item.$2,
                  path: item.$3,
                ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.icon, required this.label, required this.path});
  final IconData icon;
  final String label;
  final String path;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isActive = location == path;

    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: isActive ? DakkhoColors.primary : DakkhoColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: ['NotoSansBengali'],
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? DakkhoColors.primary : DakkhoColors.textPrimary,
        ),
      ),
      onTap: () {
        if (path == '/logout') {
          // TODO: Trigger logout flow
          return;
        }
        context.go(path);
        Navigator.of(context).pop();
      },
    );
  }
}
