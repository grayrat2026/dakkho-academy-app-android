import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// CourseProgressPage — course-specific analytics dashboard.
/// Shows: weekly hours watched chart, daily streak heatmap, video completion stats.
class CourseProgressPage extends ConsumerStatefulWidget {
  const CourseProgressPage({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<CourseProgressPage> createState() => _CourseProgressPageState();
}

class _CourseProgressPageState extends ConsumerState<CourseProgressPage> {
  CourseModel? _course; // ignore: unused_field
  List<VideoModel> _videos = [];
  bool _isLoading = true;
  int _completedCount = 0;
  int _watchedMinutes = 0;
  int _streakDays = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final courseApi = await ref.read(courseApiProvider.future);

      _course = (await courseApi.get(widget.courseId)).course;
      _videos = await courseApi.videos(widget.courseId);

      // Mock progress (TODO: replace with real watch-history data)
      _completedCount = (_videos.length * 0.33).round();
      _watchedMinutes = _videos.take(_completedCount).fold<int>(0, (sum, v) => sum + (v.duration ~/ 60));
      _streakDays = 5;
    } catch (_) {}

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Progress')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final progressPercent = _videos.isNotEmpty ? (_completedCount / _videos.length * 100).round() : 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall progress card
          GlassCard(
            padding: const EdgeInsets.all(20),
            gradient: DakkhoColors.primaryGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Overall Progress', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('$progressPercent%',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progressPercent / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: Colors.white,
                  minHeight: 8,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$_completedCount / ${_videos.length} videos',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                    Text('${_watchedMinutes ~/ 60}h ${_watchedMinutes % 60}m watched',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                  ],
                ),
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
              _StatCard(
                icon: LucideIcons.checkCircle,
                label: 'Completed',
                value: '$_completedCount',
                subtitle: 'videos',
                color: DakkhoColors.success,
              ),
              _StatCard(
                icon: LucideIcons.clock,
                label: 'Watch time',
                value: '${_watchedMinutes}m',
                subtitle: 'total',
                color: DakkhoColors.primary,
              ),
              _StatCard(
                icon: LucideIcons.flame,
                label: 'Streak',
                value: '$_streakDays',
                subtitle: 'days',
                color: DakkhoColors.warning,
              ),
              _StatCard(
                icon: LucideIcons.award,
                label: 'Certificate',
                value: progressPercent == 100 ? 'YES' : '—',
                subtitle: progressPercent == 100 ? 'earned' : 'finish to earn',
                color: DakkhoColors.purple,
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Streak heatmap (last 7 days)
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 16, color: DakkhoColors.primary),
                    const SizedBox(width: 8),
                    const Text('Last 7 days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final day = DateTime.now().subtract(Duration(days: 6 - i));
                    final isWatched = i < 5;  // mock — watched first 5 days
                    final isToday = i == 6;
                    return Column(
                      children: [
                        Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][day.weekday - 1],
                            style: const TextStyle(fontSize: 10, color: DakkhoColors.textSecondary)),
                        const SizedBox(height: 4),
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: isWatched ? DakkhoColors.success : DakkhoColors.surfaceLighter,
                            borderRadius: BorderRadius.circular(6),
                            border: isToday ? Border.all(color: DakkhoColors.primary, width: 2) : null,
                          ),
                          child: isWatched
                              ? const Icon(LucideIcons.check, color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text('${day.day}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isToday ? DakkhoColors.primary : DakkhoColors.textMuted,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                            )),
                      ],
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      curve: DakkhoAnimations.elastic,
                    );
                  }),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Action button — continue learning
          if (_completedCount < _videos.length)
            GradientButton(
              label: 'Continue Watching',
              icon: LucideIcons.play,
              onPressed: () {
                final nextVideo = _videos[_completedCount.clamp(0, _videos.length - 1)];
                context.go('/app/video/${nextVideo.id}/course/${widget.courseId}');
              },
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon, required this.label, required this.value,
    required this.subtitle, required this.color,
  });
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
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(width: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
