import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../data/stores/stores.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialQuery});
  final String? initialQuery;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late TextEditingController _controller;
  List<CourseModel> _courses = [];
  List<InstructorModel> _instructors = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    ref.read(searchProvider.notifier).addRecentSearch(query);
    setState(() => _isLoading = true);
    try {
      final courseApi = await ref.read(courseApiProvider.future);
      final instructorApi = await ref.read(instructorApiProvider.future);
      final c = await courseApi.list(search: query, limit: 20);
      final i = await instructorApi.list(search: query, limit: 10);
      setState(() {
        _courses = c.courses;
        _instructors = i.instructors;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search courses, instructors, videos...',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _courses = [];
                            _instructors = [];
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: _performSearch,
              onChanged: (v) => setState(() {}),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            Expanded(
              child: _courses.isEmpty && _instructors.isEmpty && !_isLoading
                ? _buildEmptyState(searchState)
                : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(SearchState searchState) {
    if (searchState.recentSearches.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.search,
        title: 'Start searching',
        subtitle: 'Find courses, instructors, and videos.',
      );
    }
    return ListView(
      children: [
        Row(
          children: [
            const Icon(LucideIcons.history, size: 16, color: DakkhoColors.textSecondary),
            const SizedBox(width: 8),
            const Text('Recent Searches',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
            const Spacer(),
            TextButton(
              onPressed: () => ref.read(searchProvider.notifier).clearRecentSearches(),
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searchState.recentSearches.map((q) =>
            ActionChip(
              label: Text(q),
              onPressed: () {
                _controller.text = q;
                _performSearch(q);
              },
            ).animate().fadeIn(delay: const Duration(milliseconds: 30)).scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: DakkhoAnimations.fast,
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: [
        if (_instructors.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Instructors',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
          ),
          ..._instructors.map((i) => GlassCard(
            onTap: () => context.go('/app/instructor/${i.id}'),
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: i.avatarUrl.isNotEmpty ? NetworkImage(i.avatarUrl) : null, backgroundColor: DakkhoColors.primary, child: i.avatarUrl.isEmpty ? Text(i.name[0], style: const TextStyle(color: Colors.white)) : null),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(i.name, style: const TextStyle(fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  Text(i.specialization, style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                ])),
                Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
              ],
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 30)).slideX(begin: 0.05, end: 0)),
          const SizedBox(height: 16),
        ],
        if (_courses.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Courses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
          ),
          ..._courses.map((c) => GlassCard(
            onTap: () => context.go('/app/course/${c.id}'),
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: DakkhoColors.courseGradientFor(c.id)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('${c.instructorName} · ${c.totalVideos} videos', style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                ])),
                Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
              ],
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 30)).slideX(begin: 0.05, end: 0)),
        ],
      ],
    );
  }
}
