import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../data/stores/auth_store.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Welcome Header ───
            GlassCard(
              padding: const EdgeInsets.all(20),
              gradient: DakkhoColors.primaryGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.name ?? 'Student',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.instituteName ?? 'Continue learning where you left off',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: DakkhoAnimations.slow, curve: DakkhoAnimations.easeOut)
                .slideY(begin: 0.1, end: 0, duration: DakkhoAnimations.slow, curve: DakkhoAnimations.easeOut)
                .scale(
                  begin: const Offset(0.98, 0.98),
                  end: const Offset(1, 1),
                  duration: DakkhoAnimations.slow,
                ),

            const SizedBox(height: 24),

            // ─── Continue Watching Section (Phase 3) ───
            _SectionHeader(title: 'Continue Watching', icon: LucideIcons.playCircle),
            const SizedBox(height: 12),
            const CourseGridSkeleton(itemCount: 2),

            const SizedBox(height: 24),

            // ─── Trending Courses (Phase 3) ───
            _SectionHeader(title: 'Trending Courses', icon: LucideIcons.trendingUp),
            const SizedBox(height: 12),
            const CourseGridSkeleton(itemCount: 4),

            const SizedBox(height: 24),

            // ─── Departments (Phase 3) ───
            _SectionHeader(title: 'Departments', icon: LucideIcons.building2),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (_, i) => _DepartmentChip(index: i),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Coming Soon Hint ───
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(LucideIcons.sparkles, color: DakkhoColors.primary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Phase 1 Complete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: DakkhoColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Real course data, video player, downloads, and more arrive in Phase 3+.',
                          style: TextStyle(
                            fontSize: 13,
                            color: DakkhoColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: DakkhoColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontFamilyFallback: ['NotoSansBengali'],
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DakkhoColors.textPrimary,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text('See all'),
        ),
      ],
    ).animate().fadeIn(duration: DakkhoAnimations.normal).slideX(begin: -0.05, end: 0);
  }
}

class _DepartmentChip extends StatelessWidget {
  const _DepartmentChip({required this.index});
  final int index;

  static const _depts = ['CSE', 'ETE', 'EEE', 'ME', 'CE', 'Architecture'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: DakkhoColors.courseGradients[index % DakkhoColors.courseGradients.length],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          _depts[index],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: DakkhoAnimations.normal)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: DakkhoAnimations.normal,
          curve: DakkhoAnimations.elastic,
        );
  }
}
