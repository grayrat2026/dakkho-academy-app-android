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
import '../../shared/widgets/loading_skeleton.dart';

class InstructorCoursesPage extends ConsumerStatefulWidget {
  const InstructorCoursesPage({super.key, required this.instructorId});
  final String instructorId;

  @override
  ConsumerState<InstructorCoursesPage> createState() => _InstructorCoursesPageState();
}

class _InstructorCoursesPageState extends ConsumerState<InstructorCoursesPage> {
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String? _levelFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final courseApi = await ref.read(courseApiProvider.future);
      final result = await courseApi.list(limit: 100);
      _courses = result.courses.where((c) => c.instructorId == widget.instructorId).toList();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _levelFilter == null
        ? _courses
        : _courses.where((c) => c.level == _levelFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Instructor Courses'),
        bottom: _courses.isEmpty ? null : PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(label: const Text('All'), selected: _levelFilter == null,
                      onSelected: (_) => setState(() => _levelFilter = null)),
                  const SizedBox(width: 8),
                  for (final level in ['beginner', 'intermediate', 'advanced', 'expert']) ...[
                    FilterChip(label: Text(level[0].toUpperCase() + level.substring(1)),
                        selected: _levelFilter == level,
                        onSelected: (_) => setState(() => _levelFilter = level)),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? ListView.builder(itemCount: 4, itemBuilder: (_, __) => const ListItemSkeleton())
          : filtered.isEmpty
              ? const EmptyState(icon: LucideIcons.bookX, title: 'No courses found', subtitle: 'Try a different filter.')
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    return GlassCard(
                      onTap: () => context.go('/app/course/${c.id}'),
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: DakkhoColors.courseGradientFor(c.id)),
                              ),
                              child: c.thumbnailUrl.isNotEmpty
                                  ? Image.network(c.thumbnailUrl, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(child: Icon(LucideIcons.bookOpen, color: Colors.white.withValues(alpha: 0.5), size: 32)))
                                  : Center(child: Icon(LucideIcons.bookOpen, color: Colors.white.withValues(alpha: 0.5), size: 32)),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: DakkhoColors.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(c.level.toUpperCase(),
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: DakkhoColors.primary)),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Icon(LucideIcons.star, size: 12, color: DakkhoColors.warning),
                                      const SizedBox(width: 2),
                                      Text(c.rating.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                                      const Spacer(),
                                      Text(c.price == 0 ? 'FREE' : '৳${c.price}',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                              color: c.price == 0 ? DakkhoColors.success : DakkhoColors.primary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1, end: 0);
                  },
                ),
    );
  }
}
