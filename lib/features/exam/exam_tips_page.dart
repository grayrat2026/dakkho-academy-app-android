import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

/// ExamTipsPage — tabbed study + exam strategies.
/// Backend: /api/exam-tips returns tips data.
class ExamTipsPage extends ConsumerStatefulWidget {
  const ExamTipsPage({super.key});
  @override
  ConsumerState<ExamTipsPage> createState() => _ExamTipsPageState();
}

class _ExamTipsPageState extends ConsumerState<ExamTipsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _tips;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = await ref.read(examTipsApiProvider.future);
      _tips = await api.get();
    } catch (_) {
      // Use fallback tips if API fails
      _tips = _fallbackTips;
    }
    setState(() => _isLoading = false);
  }

  static const _fallbackTips = {
    'study': [
      {'title': 'Active Recall', 'description': 'Instead of re-reading, test yourself by trying to recall key concepts from memory. This strengthens long-term retention.'},
      {'title': 'Spaced Repetition', 'description': 'Review material at increasing intervals (1 day, 3 days, 1 week, 2 weeks). Use flashcards for formulas and definitions.'},
      {'title': 'Pomodoro Technique', 'description': 'Study for 25 minutes, take a 5-minute break. After 4 cycles, take a longer 15-30 minute break.'},
      {'title': 'Teach to Learn', 'description': 'Explain concepts out loud as if teaching someone else. Gaps in your explanation reveal what you don\'t understand.'},
      {'title': 'Practice Problems', 'description': 'Solve past exam questions and textbook problems. Active problem-solving beats passive reading every time.'},
    ],
    'timeManagement': [
      {'title': 'Create a Schedule', 'description': 'Block out specific times for each subject. Be realistic — leave buffer time for unexpected delays.'},
      {'title': 'Prioritize by Weight', 'description': 'Spend more time on high-mark topics and subjects you\'re weak in. Don\'t just study what you already know.'},
      {'title': 'Use Deadlines', 'description': 'Set mini-deadlines for each topic. "Finish Chapter 3 by Tuesday" beats "study Chapter 3 soon".'},
      {'title': 'Avoid Multitasking', 'description': 'Focus on ONE subject at a time. Context-switching between subjects reduces retention by 40%.'},
      {'title': 'Sleep Matters', 'description': 'Get 7-8 hours of sleep, especially before exams. Memory consolidation happens during REM sleep.'},
    ],
    'mistakes': [
      {'title': 'Cramming the Night Before', 'description': 'Last-minute cramming overloads working memory. Start reviewing at least 3-5 days before the exam.'},
      {'title': 'Skipping Practice', 'description': 'Reading notes isn\'t enough. Without solving problems, you won\'t recognize question patterns in the exam.'},
      {'title': 'Ignoring Weak Subjects', 'description': 'It\'s tempting to study what you\'re good at. But weak subjects are where you can gain the most marks.'},
      {'title': 'Not Reading Instructions', 'description': 'Many students lose marks by not reading "answer ALL parts" or "show your working". Always read instructions twice.'},
      {'title': 'Panic During Exam', 'description': 'If you blank out, take 3 deep breaths. Move to an easier question. Confidence returns as you solve problems.'},
    ],
    'wellness': [
      {'title': 'Stay Hydrated', 'description': 'Dehydration reduces cognitive performance by 10-15%. Drink 8 glasses of water daily, especially during study sessions.'},
      {'title': 'Exercise Daily', 'description': 'Even 20 minutes of walking boosts memory and reduces stress. Exercise increases BDNF, a protein that grows new neurons.'},
      {'title': 'Eat Brain Food', 'description': 'Omega-3 (fish, walnuts), antioxidants (berries, dark chocolate), and complex carbs (oats, brown rice) fuel your brain.'},
      {'title': 'Take Real Breaks', 'description': 'During breaks, step away from screens. Look outside, stretch, or chat with friends. Scrolling social media isn\'t a real break.'},
      {'title': 'Manage Stress', 'description': 'Try 4-7-8 breathing: inhale 4 sec, hold 7 sec, exhale 8 sec. Repeat 4 times. This activates your parasympathetic nervous system.'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Exam Tips')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Exam Tips'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(LucideIcons.bookOpen, size: 14), text: 'Study Strategies'),
            Tab(icon: Icon(LucideIcons.clock, size: 14), text: 'Time Management'),
            Tab(icon: Icon(LucideIcons.alertTriangle, size: 14), text: 'Common Mistakes'),
            Tab(icon: Icon(LucideIcons.heart, size: 14), text: 'Wellness'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _tipsList('study', LucideIcons.bookOpen, DakkhoColors.primary),
          _tipsList('timeManagement', LucideIcons.clock, DakkhoColors.warning),
          _tipsList('mistakes', LucideIcons.alertTriangle, DakkhoColors.danger),
          _tipsList('wellness', LucideIcons.heart, DakkhoColors.accent),
        ],
      ),
    );
  }

  Widget _tipsList(String key, IconData icon, Color color) {
    final tips = (_tips?[key] as List?) ?? (_fallbackTips[key] as List);
    if (tips.isEmpty) {
      return const EmptyState(icon: LucideIcons.lightbulb, title: 'No tips available');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tips.length,
      itemBuilder: (_, i) {
        final tip = tips[i] as Map<String, dynamic>;
        return GlassCard(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, color: color, size: 18),
                    Positioned(
                      bottom: 2, right: 4,
                      child: Text('${i + 1}', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: color)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(tip['description'] as String, style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.05, end: 0);
      },
    );
  }
}
