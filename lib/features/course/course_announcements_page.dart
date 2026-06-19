import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

/// CourseAnnouncementsPage — instructor announcements feed.
/// Backend: TODO — /api/course-announcements doesn't exist yet.
/// In-memory state for now.
class CourseAnnouncementsPage extends StatefulWidget {
  const CourseAnnouncementsPage({super.key, required this.courseId});
  final String courseId;

  @override
  State<CourseAnnouncementsPage> createState() => _CourseAnnouncementsPageState();
}

class _CourseAnnouncementsPageState extends State<CourseAnnouncementsPage> {
  // Sample announcements (TODO: replace with API call)
  final List<Map<String, dynamic>> _announcements = [
    {
      'title': 'New video uploaded: Introduction to Newton\'s Laws',
      'message': 'A new video has been added to Unit 2. Make sure to watch it before next class.',
      'type': 'update',
      'author': 'Instructor',
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'isPinned': true,
      'likes': 12,
    },
    {
      'title': 'Quiz reminder: Basic Concepts Quiz due Friday',
      'message': 'Don\'t forget to complete the quiz by Friday 11:59 PM. It covers Units 1-2.',
      'type': 'urgent',
      'author': 'Instructor',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'isPinned': false,
      'likes': 5,
    },
    {
      'title': 'Welcome to the course!',
      'message': 'Welcome everyone! I\'m excited to have you in this course. Please introduce yourself in the Q&A section.',
      'type': 'info',
      'author': 'Instructor',
      'createdAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'isPinned': false,
      'likes': 28,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final sorted = List<Map<String, dynamic>>.from(_announcements)
      ..sort((a, b) {
        if (a['isPinned'] && !b['isPinned']) return -1;
        if (!a['isPinned'] && b['isPinned']) return 1;
        return (b['createdAt'] as String).compareTo(a['createdAt'] as String);
      });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Announcements')),
      body: sorted.isEmpty
          ? const EmptyState(icon: LucideIcons.megaphone, title: 'No announcements', subtitle: 'Check back later for updates.')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (_, i) {
                final a = sorted[i];
                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  gradient: a['isPinned']
                      ? const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)])
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _typeColor(a['type']).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_typeIcon(a['type']), size: 11, color: _typeColor(a['type'])),
                                const SizedBox(width: 4),
                                Text((a['type'] as String).toUpperCase(),
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _typeColor(a['type']))),
                              ],
                            ),
                          ),
                          if (a['isPinned']) ...[
                            const SizedBox(width: 8),
                            const Icon(LucideIcons.pin, size: 12, color: DakkhoColors.warning),
                          ],
                          const Spacer(),
                          Text(_formatTime(a['createdAt']),
                              style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(a['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text(a['message'], style: const TextStyle(fontSize: 13, color: DakkhoColors.textSecondary, height: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(LucideIcons.user, size: 12, color: DakkhoColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(a['author'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DakkhoColors.textSecondary)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => a['likes']++),
                            child: Row(
                              children: [
                                Icon(LucideIcons.heart, size: 12, color: DakkhoColors.danger),
                                const SizedBox(width: 4),
                                Text('${a['likes']}', style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1, end: 0);
              },
            ),
    );
  }

  Color _typeColor(String type) => switch (type) {
    'urgent' => DakkhoColors.danger,
    'achievement' => DakkhoColors.purple,
    'update' => DakkhoColors.primary,
    _ => DakkhoColors.textSecondary,
  };

  IconData _typeIcon(String type) => switch (type) {
    'urgent' => LucideIcons.alertTriangle,
    'achievement' => LucideIcons.trophy,
    'update' => LucideIcons.refreshCw,
    _ => LucideIcons.info,
  };

  String _formatTime(String iso) {
    final dt = DateTime.parse(iso);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
