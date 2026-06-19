import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiAsync = ref.watch(achievementsApiProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Achievements')),
      body: apiAsync.maybeWhen(
        data: (api) => FutureBuilder<({List<Achievement> achievements, int totalXp, int unlockedCount, int totalCount})>(
          future: api.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            if (data == null) {
              return const EmptyState(icon: LucideIcons.trophy, title: 'Failed to load');
            }
            final achievements = data.achievements;
            final totalXp = data.totalXp;
            final unlockedCount = data.unlockedCount;
            final totalCount = data.totalCount;
            if (achievements.isEmpty) {
              return const EmptyState(icon: LucideIcons.trophy, title: 'No achievements yet');
            }
          return CustomScrollView(
            slivers: [
              // Stats header
              SliverToBoxAdapter(
                child: GlassCard(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  gradient: DakkhoColors.primaryGradient,
                  child: Row(
                    children: [
                      const Icon(LucideIcons.trophy, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$totalXp XP', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                            Text('$unlockedCount / $totalCount unlocked',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: totalCount > 0 ? unlockedCount / totalCount : 0,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              color: Colors.white,
                              minHeight: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
              ),

              // Achievement grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final a = achievements[i];
                      return GlassCard(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: a.unlocked ? DakkhoColors.warning.withValues(alpha: 0.15) : DakkhoColors.surfaceLighter,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_iconFor(a.icon),
                                  color: a.unlocked ? DakkhoColors.warning : DakkhoColors.textMuted, size: 24),
                            ),
                            const SizedBox(height: 6),
                            Text(a.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: a.unlocked ? DakkhoColors.textPrimary : DakkhoColors.textMuted,
                                )),
                            const SizedBox(height: 2),
                            Text('+${a.xp} XP',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: a.unlocked ? DakkhoColors.success : DakkhoColors.textMuted,
                                )),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 30 * i)).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: DakkhoAnimations.normal,
                        curve: DakkhoAnimations.elastic,
                      );
                    },
                    childCount: achievements.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyState(icon: LucideIcons.trophy, title: 'Failed to load'),
        orElse: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  IconData _iconFor(String name) {
    return switch (name.toLowerCase()) {
      'award' || 'trophy' => LucideIcons.trophy,
      'star' => LucideIcons.star,
      'flame' || 'fire' => LucideIcons.flame,
      'book' || 'book_open' => LucideIcons.bookOpen,
      'target' => LucideIcons.target,
      'rocket' => LucideIcons.rocket,
      'crown' => LucideIcons.crown,
      'medal' => LucideIcons.medal,
      _ => LucideIcons.award,
    };
  }
}
