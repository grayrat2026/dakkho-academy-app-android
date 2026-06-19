import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// CourseQuizzesPage — MCQ quiz runner.
///
/// Backend reality: No /api/quizzes endpoint exists.
/// This is a self-contained quiz runner with placeholder questions
/// (real questions will come from backend when /api/quizzes is added).
///
/// Two modes:
///   1. Quiz List (default) — shows available quizzes with best score + duration
///   2. Quiz Runner — question-by-question MCQ with explanations
class CourseQuizzesPage extends StatefulWidget {
  const CourseQuizzesPage({super.key, required this.courseId});
  final String courseId;

  @override
  State<CourseQuizzesPage> createState() => _CourseQuizzesPageState();
}

class _CourseQuizzesPageState extends State<CourseQuizzesPage> {
  // Quiz runner state
  int? _activeQuizIndex;
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  int _correctCount = 0;
  bool _showResult = false;

  // Placeholder quizzes (TODO: replace with API call to /api/quizzes)
  final List<Map<String, dynamic>> _quizzes = [
    {
      'title': 'Basic Concepts Quiz',
      'description': 'Test your understanding of fundamental concepts',
      'difficulty': 'easy',
      'durationMinutes': 10,
      'totalQuestions': 3,
      'bestScore': null,
      'questions': [
        {
          'question': 'What is the SI unit of force?',
          'options': ['Joule', 'Newton', 'Watt', 'Pascal'],
          'correctIndex': 1,
          'explanation': 'Newton (N) is the SI unit of force. 1N = 1 kg⋅m/s²',
        },
        {
          'question': 'Which law states "For every action, there is an equal and opposite reaction"?',
          'options': ['First Law', 'Second Law', 'Third Law', 'Law of Gravitation'],
          'correctIndex': 2,
          'explanation': 'Newton\'s Third Law of Motion states that for every action there is an equal and opposite reaction.',
        },
        {
          'question': 'What does F = ma represent?',
          'options': ['Newton\'s First Law', 'Newton\'s Second Law', 'Newton\'s Third Law', 'Hooke\'s Law'],
          'correctIndex': 1,
          'explanation': 'Newton\'s Second Law: Force equals mass times acceleration (F = ma).',
        },
      ],
    },
    {
      'title': 'Application Quiz',
      'description': 'Apply your knowledge to solve problems',
      'difficulty': 'medium',
      'durationMinutes': 15,
      'totalQuestions': 3,
      'bestScore': null,
      'questions': [
        {
          'question': 'A 2 kg object accelerates at 5 m/s². What is the net force?',
          'options': ['2.5 N', '7 N', '10 N', '25 N'],
          'correctIndex': 2,
          'explanation': 'F = ma = 2 kg × 5 m/s² = 10 N',
        },
        {
          'question': 'If you push a wall with 50 N, the wall pushes you back with:',
          'options': ['0 N', '25 N', '50 N', '100 N'],
          'correctIndex': 2,
          'explanation': 'Newton\'s Third Law: the wall pushes back with equal force (50 N).',
        },
        {
          'question': 'An object in motion stays in motion unless acted upon by — this is:',
          'options': ['Friction', 'Inertia', 'Gravity', 'Momentum'],
          'correctIndex': 1,
          'explanation': 'Inertia — the tendency of an object to resist changes in its state of motion (Newton\'s First Law).',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Quiz runner mode
    if (_activeQuizIndex != null && !_showResult) {
      return _buildQuizRunner();
    }

    // Result screen
    if (_showResult) {
      return _buildResultScreen();
    }

    // Quiz list mode
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Quizzes')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quizzes.length,
        itemBuilder: (_, i) {
          final quiz = _quizzes[i];
          return GlassCard(
            onTap: () => setState(() {
              _activeQuizIndex = i;
              _currentQuestion = 0;
              _selectedAnswer = null;
              _showExplanation = false;
              _correctCount = 0;
            }),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _difficultyColor(quiz['difficulty']).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text((quiz['difficulty'] as String).toUpperCase(),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _difficultyColor(quiz['difficulty']))),
                    ),
                    const Spacer(),
                    Icon(LucideIcons.clock, size: 12, color: DakkhoColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${quiz['durationMinutes']}min', style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(quiz['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                const SizedBox(height: 4),
                Text(quiz['description'], style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(LucideIcons.helpCircle, size: 14, color: DakkhoColors.primary),
                    const SizedBox(width: 4),
                    Text('${quiz['totalQuestions']} questions', style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                    const Spacer(),
                    if (quiz['bestScore'] != null) ...[
                      Text('Best: ${quiz['bestScore']}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.success)),
                      const SizedBox(width: 8),
                    ],
                    GradientButton(
                      label: 'Start',
                      icon: LucideIcons.play,
                      onPressed: () => setState(() {
                        _activeQuizIndex = i;
                        _currentQuestion = 0;
                        _selectedAnswer = null;
                        _showExplanation = false;
                        _correctCount = 0;
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 60 * i)).slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildQuizRunner() {
    final quiz = _quizzes[_activeQuizIndex!];
    final questions = (quiz['questions'] as List);
    final q = questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / questions.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Quiz · ${_currentQuestion + 1}/${questions.length}'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => setState(() {
            _activeQuizIndex = null;
          }),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: DakkhoColors.surfaceLight,
              color: DakkhoColors.primary,
              minHeight: 6,
            ),
          ).animate().fadeIn(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Question ${_currentQuestion + 1}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.primary, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(q['question'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary, height: 1.4)),
                    const SizedBox(height: 20),
                    // Options
                    for (var i = 0; i < (q['options'] as List).length; i++) ...[
                      _quizOption(
                        index: i,
                        label: q['options'][i],
                        isSelected: _selectedAnswer == i,
                        isCorrect: i == q['correctIndex'],
                        showResult: _showExplanation,
                        onTap: () {
                          if (_showExplanation) return;
                          setState(() => _selectedAnswer = i);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Explanation
                    if (_showExplanation) ...[
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
                            Row(
                              children: [
                                Icon(LucideIcons.lightbulb, size: 14, color: DakkhoColors.warning),
                                const SizedBox(width: 6),
                                const Text('Explanation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.warning)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(q['explanation'],
                                style: const TextStyle(fontSize: 12, color: DakkhoColors.textPrimary, height: 1.5)),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Bottom action
          Padding(
            padding: const EdgeInsets.all(16),
            child: _showExplanation
                ? GradientButton(
                    label: _currentQuestion < questions.length - 1 ? 'Next Question' : 'See Results',
                    icon: LucideIcons.arrowRight,
                    onPressed: () {
                      if (_selectedAnswer == q['correctIndex']) {
                        // Already counted when revealed
                      }
                      if (_currentQuestion < questions.length - 1) {
                        setState(() {
                          _currentQuestion++;
                          _selectedAnswer = null;
                          _showExplanation = false;
                        });
                      } else {
                        setState(() => _showResult = true);
                      }
                    },
                  )
                : GradientButton(
                    label: 'Submit Answer',
                    icon: LucideIcons.check,
                    isDisabled: _selectedAnswer == null,
                    onPressed: _selectedAnswer == null
                        ? null
                        : () {
                            if (_selectedAnswer == q['correctIndex']) {
                              setState(() => _correctCount++);
                            }
                            setState(() => _showExplanation = true);
                          },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _quizOption({
    required int index,
    required String label,
    required bool isSelected,
    required bool isCorrect,
    required bool showResult,
    required VoidCallback onTap,
  }) {
    Color? bgColor;
    Color? borderColor;
    Color textColor = DakkhoColors.textPrimary;

    if (showResult) {
      if (isCorrect) {
        bgColor = DakkhoColors.success.withValues(alpha: 0.15);
        borderColor = DakkhoColors.success;
        textColor = DakkhoColors.success;
      } else if (isSelected && !isCorrect) {
        bgColor = DakkhoColors.danger.withValues(alpha: 0.15);
        borderColor = DakkhoColors.danger;
        textColor = DakkhoColors.danger;
      }
    } else if (isSelected) {
      bgColor = DakkhoColors.primary.withValues(alpha: 0.15);
      borderColor = DakkhoColors.primary;
      textColor = DakkhoColors.primary;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor ?? DakkhoColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor ?? DakkhoColors.glassCardBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor ?? DakkhoColors.textMuted, width: 1.5),
                color: isSelected || (showResult && isCorrect) ? (borderColor ?? DakkhoColors.primary) : Colors.transparent,
              ),
              child: (isSelected || (showResult && isCorrect))
                  ? const Icon(LucideIcons.check, color: Colors.white, size: 14)
                  : Center(child: Text(String.fromCharCode(65 + index), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
            ),
            if (showResult && isCorrect)
              const Icon(LucideIcons.checkCircle2, color: DakkhoColors.success, size: 16)
            else if (showResult && isSelected && !isCorrect)
              const Icon(LucideIcons.xCircle, color: DakkhoColors.danger, size: 16),
          ],
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.02, 1.02),
      duration: const Duration(milliseconds: 150),
    );
  }

  Widget _buildResultScreen() {
    final quiz = _quizzes[_activeQuizIndex!];
    final questions = (quiz['questions'] as List);
    final percentage = (_correctCount / questions.length * 100).round();
    final passed = percentage >= 60;

    // Save best score
    if (quiz['bestScore'] == null || percentage > (quiz['bestScore'] as num)) {
      quiz['bestScore'] = percentage;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => setState(() {
            _activeQuizIndex = null;
            _showResult = false;
          }),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated trophy or sad face
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: passed
                      ? [DakkhoColors.success, DakkhoColors.accent]
                      : [DakkhoColors.warning, DakkhoColors.danger]),
                ),
                child: Icon(
                  passed ? LucideIcons.trophy : LucideIcons.frown,
                  color: Colors.white, size: 50,
                ),
              ).animate().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: DakkhoAnimations.slow,
                curve: DakkhoAnimations.elastic,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Congratulations!' : 'Keep practicing!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                '$_correctCount out of ${questions.length} correct',
                style: const TextStyle(fontSize: 14, color: DakkhoColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: passed ? DakkhoColors.success : DakkhoColors.warning,
                ),
              ).animate().fadeIn(delay: 200.ms).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: DakkhoAnimations.slow,
                curve: DakkhoAnimations.elastic,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => setState(() {
                      _activeQuizIndex = null;
                      _showResult = false;
                    }),
                    icon: const Icon(LucideIcons.list),
                    label: const Text('Back to quizzes'),
                  ),
                  GradientButton(
                    label: 'Retry',
                    icon: LucideIcons.rotateCw,
                    onPressed: () => setState(() {
                      _currentQuestion = 0;
                      _selectedAnswer = null;
                      _showExplanation = false;
                      _correctCount = 0;
                      _showResult = false;
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    return switch (difficulty.toLowerCase()) {
      'easy' => DakkhoColors.success,
      'medium' => DakkhoColors.warning,
      'hard' => DakkhoColors.danger,
      _ => DakkhoColors.textSecondary,
    };
  }
}
