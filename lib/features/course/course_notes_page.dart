import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/empty_state.dart';

/// CourseNotesPage — personal color-coded sticky notes linked to course videos.
///
/// Backend reality: No /api/notes endpoint exists yet.
/// Storage: SharedPreferences (per-course). TODO: migrate to backend when added.
class CourseNotesPage extends StatefulWidget {
  const CourseNotesPage({super.key, required this.courseId});
  final String courseId;

  @override
  State<CourseNotesPage> createState() => _CourseNotesPageState();
}

class _CourseNotesPageState extends State<CourseNotesPage> {
  // In-memory for now — TODO: persist to SharedPreferences
  final List<Map<String, dynamic>> _notes = [];
  final _textController = TextEditingController();
  String _selectedColor = 'yellow';

  static const _colors = {
    'yellow': Color(0xFFFFF7C2),
    'green': Color(0xFFC8F7C5),
    'blue': Color(0xFFC5E0F7),
    'pink': Color(0xFFF7C5E0),
    'purple': Color(0xFFE0C5F7),
  };

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Notes')),
      body: Column(
        children: [
          // Note composer
          GlassCard(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('New note', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write a note about this course...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                // Color picker
                Row(
                  children: [
                    for (final entry in _colors.entries) ...[
                      GestureDetector(
                        onTap: () => setState(() => _selectedColor = entry.key),
                        child: Container(
                          width: 28, height: 28,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == entry.key ? DakkhoColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ).animate(target: _selectedColor == entry.key ? 1 : 0).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.15, 1.15),
                        duration: const Duration(milliseconds: 150),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Add note',
                  icon: LucideIcons.plus,
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      _notes.insert(0, {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'text': text,
                        'color': _selectedColor,
                        'createdAt': DateTime.now().toIso8601String(),
                      });
                      _textController.clear();
                    });
                  },
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          // Notes list
          Expanded(
            child: _notes.isEmpty
                ? const EmptyState(
                    icon: LucideIcons.stickyNote,
                    title: 'No notes yet',
                    subtitle: 'Add your first note above.',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _notes.length,
                    itemBuilder: (_, i) {
                      final note = _notes[i];
                      final color = _colors[note['color']]!;
                      return Dismissible(
                        key: ValueKey(note['id']),
                        direction: DismissDirection.up,
                        onDismissed: (_) => setState(() => _notes.removeAt(i)),
                        background: Container(
                          decoration: BoxDecoration(
                            color: DakkhoColors.danger,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Icon(LucideIcons.trash2, color: Colors.white)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note['text'],
                                style: const TextStyle(fontSize: 12, color: Color(0xFF333333), height: 1.4),
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(LucideIcons.clock, size: 10, color: Colors.black45),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(note['createdAt']),
                                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 40 * i)).scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1, 1),
                        duration: DakkhoAnimations.normal,
                        curve: DakkhoAnimations.elastic,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    final dt = DateTime.parse(iso);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
