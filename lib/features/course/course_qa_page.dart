import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/empty_state.dart';

/// CourseQAPage — Q&A threads for a course.
///
/// Backend reality: /api/support/tickets exists but no /api/course-qa endpoint.
/// For now, uses a Hive-backed local Q&A store (per-course) until backend
/// adds proper course Q&A. Marked as TODO for backend.
class CourseQAPage extends ConsumerStatefulWidget {
  const CourseQAPage({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<CourseQAPage> createState() => _CourseQAPageState();
}

class _CourseQAPageState extends ConsumerState<CourseQAPage> {
  // Local state — TODO: replace with real API when backend adds /api/course-qa
  // For now we keep an in-memory list (would persist to Hive in production).
  final List<Map<String, dynamic>> _questions = [];
  final _questionController = TextEditingController();
  final _answerControllers = <int, TextEditingController>{};
  bool _showAskForm = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _answerControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Q&A'),
        actions: [
          IconButton(
            icon: Icon(_showAskForm ? LucideIcons.x : LucideIcons.plus),
            onPressed: () => setState(() => _showAskForm = !_showAskForm),
          ),
        ],
      ),
      body: Column(
        children: [
          // Ask form
          if (_showAskForm)
            GlassCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Ask a question', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Your question',
                      hintText: 'e.g. How does Newton\'s third law apply here?',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: 'Post Question',
                    icon: LucideIcons.send,
                    onPressed: () {
                      final q = _questionController.text.trim();
                      if (q.isEmpty) return;
                      setState(() {
                        _questions.insert(0, {
                          'id': DateTime.now().millisecondsSinceEpoch,
                          'question': q,
                          'author': 'You',
                          'createdAt': DateTime.now().toIso8601String(),
                          'answers': <Map<String, dynamic>>[],
                          'upvotes': 0,
                        });
                        _questionController.clear();
                        _showAskForm = false;
                      });
                    },
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          // Questions list
          Expanded(
            child: _questions.isEmpty
                ? const EmptyState(
                    icon: LucideIcons.helpCircle,
                    title: 'No questions yet',
                    subtitle: 'Be the first to ask a question about this course.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _questions.length,
                    itemBuilder: (_, i) {
                      final q = _questions[i];
                      final answers = (q['answers'] as List).cast<Map<String, dynamic>>();
                      return GlassCard(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: DakkhoColors.primary,
                                  child: Text(q['author'][0], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 8),
                                Text(q['author'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(LucideIcons.thumbsUp, size: 14, color: DakkhoColors.textSecondary),
                                  onPressed: () => setState(() => q['upvotes']++),
                                ),
                                Text('${q['upvotes']}', style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(q['question'], style: const TextStyle(fontSize: 14, color: DakkhoColors.textPrimary, height: 1.5)),
                            const SizedBox(height: 12),
                            // Answers
                            for (final a in answers) ...[
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(LucideIcons.cornerDownRight, size: 14, color: DakkhoColors.textMuted),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(a['author'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.primary)),
                                          const SizedBox(height: 2),
                                          Text(a['text'], style: const TextStyle(fontSize: 13, color: DakkhoColors.textPrimary, height: 1.4)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Answer input
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _answerControllers.putIfAbsent(q['id'], () => TextEditingController()),
                                    decoration: const InputDecoration(
                                      hintText: 'Write an answer...',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.send, color: DakkhoColors.primary),
                                  onPressed: () {
                                    final ctrl = _answerControllers[q['id']]!;
                                    final text = ctrl.text.trim();
                                    if (text.isEmpty) return;
                                    setState(() {
                                      answers.add({
                                        'author': 'You',
                                        'text': text,
                                        'createdAt': DateTime.now().toIso8601String(),
                                      });
                                      ctrl.clear();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.05, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
