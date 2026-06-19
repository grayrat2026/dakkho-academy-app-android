import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../features/departments/department_config.dart';

/// AppShell — wraps every authenticated page with TopBar + BottomNav + Sidebar Drawer.
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
            _TopBar(),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: DakkhoColors.glassCardBorder, width: 1)),
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
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(LucideIcons.menu, size: 24, color: DakkhoColors.textPrimary),
          ).animate().fadeIn(duration: DakkhoAnimations.normal).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
            duration: DakkhoAnimations.normal,
          ),
          const SizedBox(width: 12),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: DakkhoColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Text('DAKKHO',
              style: TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: ['NotoSansBengali'],
                fontSize: 18, fontWeight: FontWeight.w800,
                letterSpacing: 0.5, color: DakkhoColors.textPrimary,
              )),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go('/app/search'),
            child: const Icon(LucideIcons.search, size: 22, color: DakkhoColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Stack(
            children: [
              GestureDetector(
                onTap: () => context.go('/app/notifications'),
                child: const Icon(LucideIcons.bell, size: 22, color: DakkhoColors.textSecondary),
              ),
              Positioned(
                right: 0, top: 0,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: DakkhoColors.danger, shape: BoxShape.circle),
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: DakkhoColors.glassSidebar,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: DakkhoColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DAKKHO Academy',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFamilyFallback: ['NotoSansBengali'],
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: DakkhoColors.textPrimary,
                          )),
                      Text('Polytechnic Learning',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFamilyFallback: ['NotoSansBengali'],
                            fontSize: 12, color: DakkhoColors.textSecondary,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            _section('Main', [
              (LucideIcons.home, 'Home', '/app/home'),
              (LucideIcons.compass, 'Explore', '/app/explore'),
              (LucideIcons.search, 'Search', '/app/search'),
              (LucideIcons.bell, 'Notifications', '/app/notifications'),
              (LucideIcons.user, 'Profile', '/app/profile'),
            ], context),

            _section('Learning', [
              (LucideIcons.bookOpen, 'My Courses', '/app/my-courses'),
              (LucideIcons.download, 'Downloads', '/app/downloads'),
              (LucideIcons.history, 'Watch History', '/app/history'),
              (LucideIcons.bookmark, 'Bookmarks', '/app/bookmarks'),
              (LucideIcons.award, 'Certificates', '/app/certificates'),
              (LucideIcons.trophy, 'Achievements', '/app/achievements'),
              (LucideIcons.clipboardCheck, 'Assignments', '/app/assignment'),
              (LucideIcons.messagesSquare, 'Discussion', '/app/discussion'),
              (LucideIcons.radio, 'Live Sessions', '/app/live-sessions'),
            ], context),

            _section('Instructors', [
              (LucideIcons.users, 'All Instructors', '/app/instructors'),
            ], context),

            _section('Departments', [
              for (final entry in DepartmentConfig.all.entries)
                (LucideIcons.building2, entry.value.shortName, '/app/department/${entry.key}'),
            ], context),

            _section('Semesters', [
              for (var i = 1; i <= 8; i++)
                (LucideIcons.calendar, 'Semester $i', '/app/semester/$i'),
            ], context),

            _section('Exam', [
              (LucideIcons.graduationCap, 'Exam Prep', '/app/exam/prep'),
              (LucideIcons.calendarDays, 'Schedule', '/app/exam/schedule'),
              (LucideIcons.fileBarChart, 'Results', '/app/exam/results'),
              (LucideIcons.pencil, 'Practice', '/app/exam/practice'),
              (LucideIcons.lightbulb, 'Tips', '/app/exam/tips'),
            ], context),

            _section('Community', [
              (LucideIcons.trophy, 'Leaderboard', '/app/community/leaderboard'),
              (LucideIcons.users, 'Study Groups', '/app/community/study-groups'),
              (LucideIcons.userPlus, 'Peers', '/app/community/peer-connections'),
              (LucideIcons.messageSquare, 'Community', '/app/community'),
              (LucideIcons.messageCircle, 'Feedback', '/app/community/feedback'),
              (LucideIcons.map, 'Roadmap', '/app/community/roadmap'),
            ], context),

            _section('Account', [
              (LucideIcons.userCog, 'Edit Profile', '/app/profile/edit'),
              (LucideIcons.keyRound, 'Change Password', '/app/profile/change-password'),
              (LucideIcons.barChart3, 'Learning Stats', '/app/profile/learning-stats'),
              (LucideIcons.creditCard, 'Subscription', '/app/profile/subscription'),
              (LucideIcons.gift, 'Referral', '/app/profile/referral'),
              (LucideIcons.alertTriangle, 'Delete Account', '/app/profile/delete-account'),
            ], context),

            _section('Settings', [
              (LucideIcons.settings, 'All Settings', '/app/settings'),
              (LucideIcons.user, 'Account', '/app/settings/account'),
              (LucideIcons.bell, 'Notifications', '/app/settings/notifications'),
              (LucideIcons.shield, 'Privacy', '/app/settings/privacy'),
              (LucideIcons.languages, 'Language', '/app/settings/language'),
              (LucideIcons.palette, 'Theme', '/app/settings/theme'),
              (LucideIcons.download, 'Downloads', '/app/settings/downloads'),
              (LucideIcons.lock, 'Content Protection', '/app/settings/content-protection'),
              (LucideIcons.smartphone, 'Active Sessions', '/app/settings/sessions'),
              (LucideIcons.monitor, 'Video Quality', '/app/settings/video-quality'),
              (LucideIcons.wifi, 'Network & Data', '/app/settings/network-data'),
            ], context),

            _section('Help', [
              (LucideIcons.helpCircle, 'Help Center', '/app/help'),
              (LucideIcons.helpCircle, 'FAQ', '/app/help/faq'),
              (LucideIcons.lifeBuoy, 'Contact Support', '/app/help/contact-support'),
              (LucideIcons.bug, 'Report Issue', '/app/help/report-issue'),
              (LucideIcons.fileText, 'Terms of Service', '/app/help/terms-of-service'),
              (LucideIcons.shieldCheck, 'Privacy Policy', '/app/help/privacy-policy'),
              (LucideIcons.rotateCcw, 'Refund Policy', '/app/help/refund-policy'),
            ], context),

            _section('About', [
              (LucideIcons.info, 'About DAKKHO', '/app/about'),
              (LucideIcons.tag, 'Pricing', '/app/pricing'),
              (LucideIcons.history, 'Changelog', '/app/changelog'),
              (LucideIcons.fileText, 'Terms', '/app/terms'),
              (LucideIcons.shield, 'Privacy', '/app/privacy'),
            ], context),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<(IconData, String, String)> items, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: ['NotoSansBengali'],
                fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 1.5, color: DakkhoColors.textMuted,
              )),
        ),
        for (final item in items)
          _DrawerItem(icon: item.$1, label: item.$2, path: item.$3),
        const SizedBox(height: 8),
      ],
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
    final isActive = location == path || location.startsWith('$path/');

    return ListTile(
      leading: Icon(icon, size: 20,
          color: isActive ? DakkhoColors.primary : DakkhoColors.textSecondary),
      title: Text(label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontFamilyFallback: ['NotoSansBengali'],
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? DakkhoColors.primary : DakkhoColors.textPrimary,
          )),
      onTap: () {
        context.go(path);
        Navigator.of(context).pop();
      },
    );
  }
}
