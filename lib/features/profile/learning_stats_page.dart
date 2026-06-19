import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

class LearningStatsPage extends ConsumerStatefulWidget {
  const LearningStatsPage({super.key});
  @override
  ConsumerState<LearningStatsPage> createState() => _LearningStatsPageState();
}

class _LearningStatsPageState extends ConsumerState<LearningStatsPage> {
  String _range = 'week';
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final api = await ref.read(learningStatsApiProvider.future);
      _stats = await api.get(range: _range);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Learning Stats'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'week', label: Text('Week')),
                ButtonSegment(value: 'month', label: Text('Month')),
                ButtonSegment(value: 'year', label: Text('Year')),
              ],
              selected: {_range},
              onSelectionChanged: (s) {
                setState(() => _range = s.first);
                _load();
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const EmptyState(icon: LucideIcons.barChart3, title: 'No data available')
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final overview = (_stats!['overview'] ?? {}) as Map<String, dynamic>;
    final hoursWatched = (overview['hoursWatched'] as num?)?.toInt() ?? 0;
    final coursesEnrolled = (overview['coursesEnrolled'] as num?)?.toInt() ?? 0;
    final certificates = (overview['certificates'] as num?)?.toInt() ?? 0;
    final currentStreak = (overview['currentStreak'] as num?)?.toInt() ?? 0;

    final dailyData = (_stats!['dailyData'] ?? []) as List;
    final subjectProgress = (_stats!['subjectProgress'] ?? []) as List;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero stats card
        GlassCard(
          padding: const EdgeInsets.all(20),
          gradient: DakkhoColors.primaryGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This ${_range == 'week' ? 'week' : _range == 'month' ? 'month' : 'year'}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('$hoursWatched hours watched',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('$currentStreak day streak',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

        const SizedBox(height: 16),

        // Stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _StatCard(icon: LucideIcons.clock, label: 'Hours Watched', value: '$hoursWatched', subtitle: 'hours', color: DakkhoColors.primary),
            _StatCard(icon: LucideIcons.bookOpen, label: 'Courses', value: '$coursesEnrolled', subtitle: 'enrolled', color: DakkhoColors.accent),
            _StatCard(icon: LucideIcons.award, label: 'Certificates', value: '$certificates', subtitle: 'earned', color: DakkhoColors.purple),
            _StatCard(icon: LucideIcons.flame, label: 'Streak', value: '$currentStreak', subtitle: 'days', color: DakkhoColors.warning),
          ],
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 16),

        // Daily activity chart (simple bar chart)
        if (dailyData.isNotEmpty) ...[
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.activity, size: 16, color: DakkhoColors.primary),
                    const SizedBox(width: 8),
                    const Text('Daily Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: dailyData.take(7).toList().asMap().entries.map((entry) {
                      final i = entry.key;
                      final day = entry.value as Map<String, dynamic>;
                      final videos = (day['videos'] as num?)?.toInt() ?? 0;
                      final activities = (day['activities'] as num?)?.toInt() ?? 0;
                      final maxVal = dailyData.fold<int>(0, (max, d) {
                        final v = ((d as Map)['videos'] as num?)?.toInt() ?? 0;
                        final a = (d['activities'] as num?)?.toInt() ?? 0;
                        return (v + a) > max ? (v + a) : max;
                      });
                      final total = videos + activities;
                      final heightPct = maxVal > 0 ? total / maxVal : 0.0;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 80 * heightPct,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [DakkhoColors.primary, DakkhoColors.primary.withValues(alpha: 0.6)],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _dayLabel(DateTime.tryParse(day['date'] as String? ?? '') ?? DateTime.now()),
                                style: const TextStyle(fontSize: 10, color: DakkhoColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.2, end: 0);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
        ],

        // Subject progress
        if (subjectProgress.isNotEmpty) ...[
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.bookMarked, size: 16, color: DakkhoColors.primary),
                    const SizedBox(width: 8),
                    const Text('Subject Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                ...subjectProgress.map((s) {
                  final subject = (s as Map)['subject'] as String? ?? '';
                  final progress = (s['progress'] as num?)?.toDouble() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(subject, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                            Text('${progress.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor: DakkhoColors.surfaceLight,
                          color: DakkhoColors.primary,
                          minHeight: 6,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
        ],
      ],
    );
  }

  String _dayLabel(DateTime dt) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[dt.weekday - 1];
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.subtitle, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(width: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
