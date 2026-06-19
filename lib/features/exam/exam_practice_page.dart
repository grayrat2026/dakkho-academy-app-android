import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// ExamPracticePage — configurable practice quiz runner.
/// User selects subject + difficulty + question count, then runs through MCQs.
class ExamPracticePage extends StatefulWidget {
  const ExamPracticePage({super.key});
  @override
  State<ExamPracticePage> createState() => _ExamPracticePageState();
}

class _ExamPracticePageState extends State<ExamPracticePage> {
  String? _selectedSubject;
  String _difficulty = 'medium';
  int _questionCount = 10;
  bool _started = false;

  final _subjects = ['Mathematics', 'Physics', 'Digital Electronics', 'Programming', 'Networks', 'Database'];

  @override
  Widget build(BuildContext context) {
    if (_started) {
      return _PracticeRunner(
        subject: _selectedSubject!,
        difficulty: _difficulty,
        questionCount: _questionCount,
        onExit: () => setState(() => _started = false),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Practice Quiz')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Intro card
          GlassCard(
            padding: const EdgeInsets.all(20),
            gradient: DakkhoColors.primaryGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.pencil, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text('Configure Your Quiz', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Practice with sample questions similar to exam format. Get instant feedback and explanations.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.5)),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 16),

          // Subject selection
          _sectionHeader('Subject', LucideIcons.bookOpen),
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _subjects.map((s) {
                final selected = _selectedSubject == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedSubject = s),
                  selectedColor: DakkhoColors.primary,
                  labelStyle: TextStyle(color: selected ? Colors.white : DakkhoColors.textPrimary, fontSize: 12),
                ).animate().fadeIn(delay: 50.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: DakkhoAnimations.normal, curve: DakkhoAnimations.elastic);
              }).toList(),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Difficulty
          _sectionHeader('Difficulty', LucideIcons.gauge),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _radioOption('easy', 'Easy', 'Basic concepts, simple calculations', DakkhoColors.success),
                const Divider(height: 1, indent: 56),
                _radioOption('medium', 'Medium', 'Standard exam-level questions', DakkhoColors.warning),
                const Divider(height: 1, indent: 56),
                _radioOption('hard', 'Hard', 'Complex problems, multi-step', DakkhoColors.danger),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Question count
          _sectionHeader('Number of Questions', LucideIcons.helpCircle),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Questions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                    Text('$_questionCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: DakkhoColors.primary)),
                  ],
                ),
                Slider(
                  value: _questionCount.toDouble(),
                  min: 5, max: 30, divisions: 5,
                  activeColor: DakkhoColors.primary,
                  onChanged: (v) => setState(() => _questionCount = v.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('5', style: TextStyle(fontSize: 10, color: DakkhoColors.textMuted)),
                    Text('30', style: TextStyle(fontSize: 10, color: DakkhoColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 14, color: DakkhoColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Est. time: ${(_questionCount * 1.5).round()} minutes',
                        style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          GradientButton(
            label: 'Start Quiz',
            icon: LucideIcons.play,
            isDisabled: _selectedSubject == null,
            onPressed: _selectedSubject == null ? null : () => setState(() => _started = true),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
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

  Widget _radioOption(String value, String title, String subtitle, Color color) {
    final selected = _difficulty == value;
    return RadioListTile<String>(
      value: value, groupValue: _difficulty,
      onChanged: (v) => setState(() => _difficulty = v ?? 'medium'),
      title: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
      activeColor: DakkhoColors.primary,
      dense: true,
    );
  }
}

class _PracticeRunner extends StatefulWidget {
  const _PracticeRunner({
    required this.subject, required this.difficulty, required this.questionCount, required this.onExit,
  });
  final String subject;
  final String difficulty;
  final int questionCount;
  final VoidCallback onExit;

  @override
  State<_PracticeRunner> createState() => _PracticeRunnerState();
}

class _PracticeRunnerState extends State<_PracticeRunner> {
  int _currentQ = 0;
  int? _selected;
  bool _showResult = false;
  int _correct = 0;
  bool _finished = false;

  // Sample questions (TODO: replace with /api/practice-questions)
  final _questions = [
    {
      'q': 'What is the binary equivalent of decimal 25?',
      'options': ['11001', '11010', '11011', '11100'],
      'correct': 0,
      'explanation': '25 = 16 + 8 + 1 = 2^4 + 2^3 + 2^0 = 11001 in binary.',
    },
    {
      'q': 'Which gate produces a 1 only when all inputs are 1?',
      'options': ['OR', 'AND', 'NOT', 'XOR'],
      'correct': 1,
      'explanation': 'AND gate outputs 1 only when ALL inputs are 1. Otherwise outputs 0.',
    },
    {
      'q': 'What is 2^5 in decimal?',
      'options': ['10', '25', '32', '64'],
      'correct': 2,
      'explanation': '2^5 = 2 × 2 × 2 × 2 × 2 = 32.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildSummary();
    final q = _questions[_currentQ % _questions.length];
    final progress = (_currentQ + 1) / widget.questionCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Question ${_currentQ + 1}/${widget.questionCount}'),
        leading: IconButton(icon: const Icon(LucideIcons.x), onPressed: widget.onExit),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: progress, backgroundColor: DakkhoColors.surfaceLight, color: DakkhoColors.primary, minHeight: 6),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.subject, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                    Text('${widget.difficulty.toUpperCase()} · $_correct correct',
                        style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Q${_currentQ + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.primary, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(q['q'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary, height: 1.4)),
                    const SizedBox(height: 20),
                    for (var i = 0; i < (q['options'] as List).length; i++) ...[
                      _option(i, (q['options'] as List)[i], q['correct'] as int),
                      const SizedBox(height: 8),
                    ],
                    if (_showResult) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DakkhoColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: DakkhoColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(LucideIcons.lightbulb, size: 14, color: DakkhoColors.warning),
                              const SizedBox(width: 6),
                              const Text('Explanation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.warning)),
                            ]),
                            const SizedBox(height: 6),
                            Text(q['explanation'] as String, style: const TextStyle(fontSize: 12, color: DakkhoColors.textPrimary, height: 1.5)),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _showResult
                ? GradientButton(
                    label: _currentQ < widget.questionCount - 1 ? 'Next Question' : 'See Results',
                    icon: LucideIcons.arrowRight,
                    onPressed: () {
                      if (_currentQ < widget.questionCount - 1) {
                        setState(() { _currentQ++; _selected = null; _showResult = false; });
                      } else {
                        setState(() => _finished = true);
                      }
                    },
                  )
                : GradientButton(
                    label: 'Submit',
                    icon: LucideIcons.check,
                    isDisabled: _selected == null,
                    onPressed: _selected == null ? null : () {
                      if (_selected == q['correct']) _correct++;
                      setState(() => _showResult = true);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _option(int i, String label, int correct) {
    final isSelected = _selected == i;
    final showCorrect = _showResult && i == correct;
    final showWrong = _showResult && isSelected && i != correct;

    Color? bg, border, text;
    if (showCorrect) {
      bg = DakkhoColors.success.withValues(alpha: 0.15);
      border = DakkhoColors.success;
      text = DakkhoColors.success;
    } else if (showWrong) {
      bg = DakkhoColors.danger.withValues(alpha: 0.15);
      border = DakkhoColors.danger;
      text = DakkhoColors.danger;
    } else if (isSelected) {
      bg = DakkhoColors.primary.withValues(alpha: 0.15);
      border = DakkhoColors.primary;
      text = DakkhoColors.primary;
    }

    return InkWell(
      onTap: _showResult ? null : () => setState(() => _selected = i),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg ?? DakkhoColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border ?? DakkhoColors.glassCardBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: border ?? DakkhoColors.textMuted, width: 1.5),
                color: (isSelected || showCorrect) ? (border ?? DakkhoColors.primary) : Colors.transparent,
              ),
              child: (isSelected || showCorrect)
                  ? const Icon(LucideIcons.check, color: Colors.white, size: 14)
                  : Center(child: Text(String.fromCharCode(65 + i), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: text ?? DakkhoColors.textPrimary))),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final percentage = (_correct / widget.questionCount * 100).round();
    final passed = percentage >= 60;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Practice Complete'), leading: IconButton(icon: const Icon(LucideIcons.x), onPressed: widget.onExit)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: passed ? [DakkhoColors.success, DakkhoColors.accent] : [DakkhoColors.warning, DakkhoColors.danger]),
                ),
                child: Icon(passed ? LucideIcons.trophy : LucideIcons.target, color: Colors.white, size: 50),
              ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: DakkhoAnimations.slow, curve: DakkhoAnimations.elastic),
              const SizedBox(height: 24),
              Text(passed ? 'Well done!' : 'Keep practicing!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
              const SizedBox(height: 8),
              Text('$_correct / ${widget.questionCount} correct', style: const TextStyle(fontSize: 14, color: DakkhoColors.textSecondary)),
              const SizedBox(height: 32),
              Text('$percentage%', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: passed ? DakkhoColors.success : DakkhoColors.warning)),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Practice Again',
                icon: LucideIcons.rotateCw,
                onPressed: widget.onExit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
