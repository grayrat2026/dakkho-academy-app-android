import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/empty_state.dart';

/// CommunityPage — social feed with posts (like/comment/share/bookmark).
/// Backend: TODO — /api/community-posts doesn't exist yet. In-memory sample data.
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _filter = 'recent';
  final _postController = TextEditingController();
  bool _showComposer = false;

  final List<Map<String, dynamic>> _posts = [
    {
      'author': 'Rahim Ahmed',
      'avatar': null,
      'technology': 'CSE',
      'time': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'content': 'Just finished the Microprocessor course! The section on interrupts was mind-blowing. Anyone else struggling with interrupt handling?',
      'likes': 12,
      'comments': 3,
      'shares': 1,
      'isLiked': false,
      'isBookmarked': false,
    },
    {
      'author': 'Taslima Khatun',
      'avatar': null,
      'technology': 'ETE',
      'time': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      'content': 'Sharing my notes from today\'s Database Management class. Hope this helps others preparing for the exam! 📚',
      'likes': 24,
      'comments': 8,
      'shares': 5,
      'isLiked': true,
      'isBookmarked': true,
    },
    {
      'author': 'Karim Uddin',
      'avatar': null,
      'technology': 'EEE',
      'time': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'content': 'Pro tip: Use the Pomodoro technique (25 min study, 5 min break) for maximum focus. My GPA went up 0.5 after switching to this method!',
      'likes': 45,
      'comments': 12,
      'shares': 18,
      'isLiked': false,
      'isBookmarked': false,
    },
  ];

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<Map<String, dynamic>>.from(_posts)..sort((a, b) {
      if (_filter == 'trending') return (b['likes'] as int).compareTo(a['likes'] as int);
      return (b['time'] as String).compareTo(a['time'] as String);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: Icon(_showComposer ? LucideIcons.x : LucideIcons.plus),
            onPressed: () => setState(() => _showComposer = !_showComposer),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(label: const Text('Recent'), selected: _filter == 'recent', onSelected: (_) => setState(() => _filter = 'recent')),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Trending'), selected: _filter == 'trending', onSelected: (_) => setState(() => _filter = 'trending')),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Composer
          if (_showComposer)
            GlassCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Share something...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _postController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'What\'s on your mind?'),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: 'Post',
                    icon: LucideIcons.send,
                    onPressed: () {
                      if (_postController.text.trim().isEmpty) return;
                      setState(() {
                        _posts.insert(0, {
                          'author': 'You',
                          'avatar': null,
                          'technology': 'CSE',
                          'time': DateTime.now().toIso8601String(),
                          'content': _postController.text,
                          'likes': 0, 'comments': 0, 'shares': 0,
                          'isLiked': false, 'isBookmarked': false,
                        });
                        _postController.clear();
                        _showComposer = false;
                      });
                    },
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          // Posts list
          Expanded(
            child: sorted.isEmpty
                ? const EmptyState(icon: LucideIcons.messageSquare, title: 'No posts yet', subtitle: 'Be the first to post!')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: sorted.length,
                    itemBuilder: (_, i) {
                      final p = sorted[i];
                      return GlassCard(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Author row
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: DakkhoColors.primary,
                                  child: Text((p['author'] as String)[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p['author'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                                      Row(
                                        children: [
                                          Text(p['technology'], style: const TextStyle(fontSize: 11, color: DakkhoColors.primary, fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 6),
                                          Text('· ${_formatTime(p['time'])}', style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(p['isBookmarked'] ? LucideIcons.bookmark : LucideIcons.bookmark, size: 18, color: p['isBookmarked'] ? DakkhoColors.warning : DakkhoColors.textSecondary),
                                  onPressed: () => setState(() => p['isBookmarked'] = !p['isBookmarked']),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Content
                            Text(p['content'], style: const TextStyle(fontSize: 13, color: DakkhoColors.textPrimary, height: 1.5)),
                            const SizedBox(height: 12),
                            // Actions
                            Row(
                              children: [
                                _actionChip(
                                  icon: p['isLiked'] ? LucideIcons.heart : LucideIcons.heart,
                                  label: '${p['likes']}',
                                  color: p['isLiked'] ? DakkhoColors.danger : DakkhoColors.textSecondary,
                                  onTap: () => setState(() {
                                    p['isLiked'] = !p['isLiked'];
                                    p['likes'] += p['isLiked'] ? 1 : -1;
                                  }),
                                ),
                                const SizedBox(width: 16),
                                _actionChip(icon: LucideIcons.messageCircle, label: '${p['comments']}', color: DakkhoColors.textSecondary, onTap: () {}),
                                const SizedBox(width: 16),
                                _actionChip(icon: LucideIcons.share2, label: '${p['shares']}', color: DakkhoColors.textSecondary, onTap: () => setState(() => p['shares']++)),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.05, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _actionChip({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    final dt = DateTime.parse(iso);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
