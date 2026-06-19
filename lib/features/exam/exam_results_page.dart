import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

/// ExamResultsPage — per-semester GPA + subject grade breakdown.
/// Backend: TODO — /api/exam-results doesn't exist yet. In-memory sample data.
class ExamResultsPage extends StatefulWidget {
  const ExamResultsPage({super.key});
  @override
  State<ExamResultsPage> createState() => _ExamResultsPageState();
}

class _ExamResultsPageState extends State<ExamResultsPage> {
  int _selectedSemester = 4;

  final Map<int, Map<String, dynamic>> _results = {
    4: {
      'gpa': 3.75,
      'grade': 'A',
      'rank': 12,
      'totalStudents': 87,
      'subjects': [
        {'code': '61041', 'name': 'Mathematics-IV', 'marks': 82, 'grade': 'A+', 'gp': 4.0},
        {'code': '61042', 'name': 'Strength of Materials', 'marks': 75, 'grade': 'A', 'gp': 3.75},
        {'code': '61043', 'name': 'Electronics-II', 'marks': 78, 'grade': 'A', 'gp': 3.75},
        {'code': '61044', 'name': 'Digital Electronics', 'marks': 88, 'grade': 'A+', 'gp': 4.0},
        {'code': '61045', 'name': 'Measurement & Instrumentation', 'marks': 68, 'grade': 'A-', 'gp': 3.5},
        {'code': '61046', 'name': 'Engineering Economy', 'marks': 72, 'grade': 'A', 'gp': 3.75},
      ],
    },
    3: {
      'gpa': 3.50,
      'grade': 'A',
      'rank': 18,
      'totalStudents': 92,
      'subjects': [
        {'code': '61031', 'name': 'Mathematics-III', 'marks': 78, 'grade': 'A', 'gp': 3.75},
        {'code': '61032', 'name': 'Engineering Mechanics', 'marks': 72, 'grade': 'A', 'gp': 3.75},
        {'code': '61033', 'name': 'Thermodynamics', 'marks': 65, 'grade': 'A-', 'gp': 3.5},
        {'code': '61034', 'name': 'Materials Science', 'marks': 80, 'grade': 'A', 'gp': 3.75},
        {'code': '61035', 'name': 'Electrical Circuits', 'marks': 75, 'grade': 'A', 'gp': 3.75},
        {'code': '61036', 'name': 'Electronics-I', 'marks': 82, 'grade': 'A+', 'gp': 4.0},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final result = _results[_selectedSemester];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Exam Results'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var s = 1; s <= 8; s++) ...[
                    FilterChip(
                      label: Text('Sem $s'),
                      selected: _selectedSemester == s,
                      onSelected: (_) => setState(() => _selectedSemester = s),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      body: result == null
          ? const EmptyState(icon: LucideIcons.fileBarChart, title: 'No results', subtitle: 'Results for this semester haven\'t been published yet.')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // GPA hero card
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  gradient: DakkhoColors.primaryGradient,
                  child: Column(
                    children: [
                      Text('Semester $_selectedSemester GPA',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text((result['gpa'] as num).toStringAsFixed(2),
                          style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Grade ${result['grade']}',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.trophy, color: Colors.white.withValues(alpha: 0.85), size: 16),
                          const SizedBox(width: 6),
                          Text('Rank ${result['rank']} of ${result['totalStudents']}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                const SizedBox(height: 16),

                // Subject breakdown
                _sectionHeader('Subject Breakdown', LucideIcons.list),
                ...((result['subjects'] as List).cast<Map<String, dynamic>>().asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  final marks = (s['marks'] as num).toInt();
                  final grade = s['grade'] as String;
                  return GlassCard(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: _gradeColor(grade).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(grade, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _gradeColor(grade))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Code: ${s['code']} · GP: ${s['gp']}',
                                  style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary, fontFamily: 'monospace')),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$marks', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: DakkhoColors.textPrimary)),
                            const Text('/ 100', style: TextStyle(fontSize: 10, color: DakkhoColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.05, end: 0);
                })),

                const SizedBox(height: 16),

                // Trend indicator (compared to last semester)
                if (_selectedSemester > 1 && _results.containsKey(_selectedSemester - 1)) ...[
                  _sectionHeader('Trend', LucideIcons.trendingUp),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(_trendIcon(result['gpa'] as num, _results[_selectedSemester - 1]!['gpa'] as num),
                            color: _trendColor(result['gpa'] as num, _results[_selectedSemester - 1]!['gpa'] as num), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _trendText(result['gpa'] as num, _results[_selectedSemester - 1]!['gpa'] as num),
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _trendColor(result['gpa'] as num, _results[_selectedSemester - 1]!['gpa'] as num)),
                              ),
                              Text('vs Semester ${_selectedSemester - 1} GPA ${(_results[_selectedSemester - 1]!['gpa'] as num).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                ],
              ],
            ),
    );
  }

  Widget _sectionHeader(String text, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 16, color: DakkhoColors.primary),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
      ],
    ),
  );

  Color _gradeColor(String grade) => switch (grade) {
    'A+' => DakkhoColors.success,
    'A' => DakkhoColors.primary,
    'A-' => DakkhoColors.accent,
    'B+' => DakkhoColors.warning,
    'B' => DakkhoColors.warning,
    _ => DakkhoColors.danger,
  };

  IconData _trendIcon(num current, num previous) {
    if (current > previous) return LucideIcons.trendingUp;
    if (current < previous) return LucideIcons.trendingDown;
    return LucideIcons.minus;
  }

  Color _trendColor(num current, num previous) {
    if (current > previous) return DakkhoColors.success;
    if (current < previous) return DakkhoColors.danger;
    return DakkhoColors.textSecondary;
  }

  String _trendText(num current, num previous) {
    final diff = (current - previous).abs();
    if (current > previous) return '↑ Up ${diff.toStringAsFixed(2)} points';
    if (current < previous) return '↓ Down ${diff.toStringAsFixed(2)} points';
    return 'No change';
  }
}
