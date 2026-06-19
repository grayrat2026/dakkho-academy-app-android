import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});
  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  String _period = 'weekly';

  @override
  Widget build(BuildContext context) {
    final apiAsync = ref.watch(leaderboardApiProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'daily', label: Text('Daily')),
                ButtonSegment(value: 'weekly', label: Text('Weekly')),
                ButtonSegment(value: 'monthly', label: Text('Monthly')),
                ButtonSegment(value: 'alltime', label: Text('All Time')),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
          ),
        ),
      ),
      body: apiAsync.maybeWhen(
        data: (api) => FutureBuilder<({List<LeaderboardEntry> entries, int? yourRank, int yourXp, String period})>(
          future: api.get(period: _period),
          builder: _buildResults,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyState(icon: LucideIcons.trophy, title: 'Failed to load'),
        orElse: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildResults(BuildContext context, AsyncSnapshot<({List<LeaderboardEntry> entries, int? yourRank, int yourXp, String period})> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return const EmptyState(icon: LucideIcons.trophy, title: 'Failed to load', subtitle: 'Try again later.');
    }
    final entries = snapshot.data?.entries ?? [];
    if (entries.isEmpty) {
      return const EmptyState(icon: LucideIcons.trophy, title: 'No entries yet', subtitle: 'Be the first to earn XP!');
    }
    final yourRank = snapshot.data?.yourRank;
    final yourXp = snapshot.data?.yourXp ?? 0;
    return Column(
            children: [
              if (yourRank != null)
                GlassCard(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  gradient: DakkhoColors.primaryGradient,
                  child: Row(
                    children: [
                      const Icon(LucideIcons.trophy, color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your rank: #$yourRank',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                            Text('$yourXp XP this ${_period == 'alltime' ? 'all time' : _period.replaceAll('ly', '')}',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final e = entries[i];
                    final isTop3 = e.rank <= 3;
                    return GlassCard(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 8),
                      gradient: isTop3
                          ? LinearGradient(colors: [
                              [DakkhoColors.warning, DakkhoColors.accent, DakkhoColors.purple][e.rank - 1],
                              [DakkhoColors.warning, DakkhoColors.accent, DakkhoColors.purple][e.rank - 1].withValues(alpha: 0.6),
                            ])
                          : null,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text('#${e.rank}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isTop3 ? Colors.white : DakkhoColors.textPrimary,
                                )),
                          ),
                          CircleAvatar(
                            backgroundColor: isTop3 ? Colors.white.withValues(alpha: 0.2) : DakkhoColors.primary,
                            child: Text(e.name.isNotEmpty ? e.name[0] : '?',
                                style: TextStyle(color: isTop3 ? Colors.white : Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isTop3 ? Colors.white : DakkhoColors.textPrimary,
                                    )),
                                Text(e.technology,
                                    style: TextStyle(fontSize: 11, color: isTop3 ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary)),
                              ],
                            ),
                          ),
                          Text('${e.xp} XP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isTop3 ? Colors.white : DakkhoColors.primary,
                              )),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.05, end: 0);
                  },
                ),
              ),
            ],
          );
  }
}
