import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/empty_state.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});
  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  String _search = '';
  String? _level;
  final _levels = ['beginner', 'intermediate', 'advanced', 'expert'];

  @override
  Widget build(BuildContext context) {
    final coursesFuture = ref.watch(courseApiProvider).maybeWhen(
      data: (api) => api.list(limit: 50, search: _search.isEmpty ? null : _search, level: _level).then((r) => r.courses),
      orElse: () => Future.value(<CourseModel>[]),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search courses...',
                  prefixIcon: Icon(LucideIcons.search),
                  suffixIcon: Icon(LucideIcons.slidersHorizontal),
                ),
                onChanged: (v) => setState(() => _search = v),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            ),
          ),

          // Level filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _levels.length + 1,
                itemBuilder: (_, i) {
                  final isAll = i == 0;
                  final level = isAll ? null : _levels[i - 1];
                  final selected = _level == level;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(isAll ? 'All' : level![0].toUpperCase() + level.substring(1)),
                      selected: selected,
                      onSelected: (_) => setState(() => _level = selected ? null : level),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.1, end: 0);
                },
              ),
            ),
          ),

          // Courses grid
          FutureBuilder<List<CourseModel>>(
            future: coursesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: CourseGridSkeleton(itemCount: 6));
              }
              final courses = snapshot.data ?? [];
              if (courses.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: LucideIcons.bookX,
                    title: 'No courses found',
                    subtitle: 'Try a different search or filter.',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _CourseCard(course: courses[i]).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1, end: 0),
                    childCount: courses.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final CourseModel course;
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.go('/app/course/${course.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: DakkhoColors.courseGradientFor(course.id)),
              ),
              child: course.thumbnailUrl.isNotEmpty
                  ? Image.network(course.thumbnailUrl, fit: BoxFit.cover,
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
                  Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(course.instructorName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(LucideIcons.star, size: 12, color: DakkhoColors.warning),
                      const SizedBox(width: 2),
                      Text(course.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                      const Spacer(),
                      Text(course.price == 0 ? 'FREE' : '৳${course.price}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                              color: course.price == 0 ? DakkhoColors.success : DakkhoColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
