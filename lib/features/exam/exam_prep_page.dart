import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../shared/widgets/glass_card.dart';

/// ExamPrepPage — dashboard showing subject progress + upcoming exam countdown + quick links.
/// Backend: /api/exam-tips returns tips; subject progress derives from /api/student/learning-stats.
class ExamPrepPage extends ConsumerStatefulWidget {
  const ExamPrepPage({super.key});
  @override
  ConsumerState<ExamPrepPage> createState() => _ExamPrepPageState();
}

class _ExamPrepPageState extends ConsumerState<ExamPrepPage> {
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _tips;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final statsApi = await ref.read(learningStatsApiProvider.future);
      final tipsApi = await ref.read(examTipsApiProvider.future);
      _stats = await statsApi.get(range: 'month');
      _tips = await tipsApi.get();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Exam Prep')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final subjects = (_stats?['subjectProgress'] ?? []) as List;
    final overview = (_stats?['overview'] ?? {}) as Map<String, dynamic>;
    final hoursStudied = (overview['hoursWatched'] as num?)?.toInt() ?? 0;
    final streak = (overview['currentStreak'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Exam Prep')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero countdown card (next exam: mock in 30 days)
          GlassCard(
            padding: const EdgeInsets.all(24),
            gradient: DakkhoColors.dangerGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.alertCircle, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text('Next Exam', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('30 days',
                    style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
                Text('Final Exam · Semester 5',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _countdownBlock('30', 'Days', Colors.white)),
                    Container(width: 1, height: 36, color: Colors.white30),
                    Expanded(child: _countdownBlock('12', 'Hours', Colors.white)),
                    Container(width: 1, height: 36, color: Colors.white30),
                    Expanded(child: _countdownBlock('45', 'Minutes', Colors.white)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 16),

          // Quick stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _quickStat(LucideIcons.clock, 'Hours Studied', '$hoursStudied', 'this month', DakkhoColors.primary),
              _quickStat(LucideIcons.flame, 'Streak', '$streak', 'days', DakkhoColors.warning),
              _quickStat(LucideIcons.bookOpen, 'Subjects', '${subjects.length}', 'in progress', DakkhoColors.accent),
              _quickStat(LucideIcons.target, 'Avg Score', '78%', 'practice quizzes', DakkhoColors.purple),
            ],
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Subject progress
          if (subjects.isNotEmpty) ...[
            _sectionHeader('Subject Progress', LucideIcons.barChart3),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: subjects.map((s) {
                  final subject = (s as Map)['subject'] as String? ?? '';
                  final progress = (s['progress'] as num?)?.toDouble() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(subject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                            Text('${progress.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor: DakkhoColors.surfaceLight,
                          color: _progressColor(progress),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
          ],

          // Quick links
          _sectionHeader('Quick Actions', LucideIcons.zap),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _actionCard('Practice Quiz', LucideIcons.pencilLine, '/app/exam/practice', DakkhoColors.primary),
              _actionCard('Exam Schedule', LucideIcons.calendarDays, '/app/exam/schedule', DakkhoColors.accent),
              _actionCard('My Results', LucideIcons.fileBarChart, '/app/exam/results', DakkhoColors.purple),
              _actionCard('Study Tips', LucideIcons.lightbulb, '/app/exam/tips', DakkhoColors.warning),
            ],
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _countdownBlock(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.85), fontSize: 11)),
      ],
    );
  }

  Widget _quickStat(IconData icon, String label, String value, String subtitle, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: DakkhoColors.textSecondary, fontWeight: FontWeight.w600)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                    const SizedBox(width: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: DakkhoColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(String label, IconData icon, String route, Color color) {
    return GlassCard(
      onTap: () => context.go(route),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
          ),
          Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 16),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: DakkhoColors.primary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
        ],
      ),
    );
  }

  Color _progressColor(double progress) {
    if (progress < 30) return DakkhoColors.danger;
    if (progress < 70) return DakkhoColors.warning;
    return DakkhoColors.success;
  }
}
