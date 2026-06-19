import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

class WatchHistoryPage extends ConsumerStatefulWidget {
  const WatchHistoryPage({super.key});
  @override
  ConsumerState<WatchHistoryPage> createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends ConsumerState<WatchHistoryPage> {
  List<WatchHistoryEntry> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = await ref.read(watchHistoryApiProvider.future);
      final result = await api.list(limit: 100);
      setState(() {
        _history = result.history;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Watch History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear history?'),
                    content: const Text('This will permanently delete all watch history.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
                    ],
                  ),
                );
                if (confirm == true) {
                  final api = await ref.read(watchHistoryApiProvider.future);
                  await api.clear();
                  _load();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const EmptyState(icon: LucideIcons.history, title: 'No watch history', subtitle: 'Videos you watch will appear here.')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (_, i) {
                    final h = _history[i];
                    return GlassCard(
                      onTap: () => context.go('/app/video/${h.videoId}/course/${h.courseId}'),
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: DakkhoColors.courseGradientFor(h.videoId)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(LucideIcons.play, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h.videoTitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text(h.courseName, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: (h.progress / 100).clamp(0, 1),
                                  backgroundColor: DakkhoColors.surfaceLight,
                                  color: DakkhoColors.primary,
                                  minHeight: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 30 * i)).slideX(begin: 0.05, end: 0);
                  },
                ),
    );
  }
}
