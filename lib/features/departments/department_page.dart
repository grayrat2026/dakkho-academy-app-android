import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/empty_state.dart';
import 'department_config.dart';

class DepartmentPage extends ConsumerStatefulWidget {
  const DepartmentPage({super.key, required this.departmentKey});
  final String departmentKey;

  @override
  ConsumerState<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends ConsumerState<DepartmentPage> {
  @override
  Widget build(BuildContext context) {
    final info = DepartmentConfig.all[widget.departmentKey];
    if (info == null) {
      return const EmptyState(icon: LucideIcons.alertCircle, title: 'Department not found');
    }

    final coursesAsync = ref.watch(courseApiProvider).maybeWhen(
      data: (api) => api.list(technology: info.slug, limit: 20).then((r) => r.courses),
      orElse: () => Future.value(<CourseModel>[]),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: GlassCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              gradient: LinearGradient(
                colors: [
                  _parseColor(info.color),
                  _parseColor(info.color).withValues(alpha: 0.6),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(info.icon, style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info.shortName,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                            const SizedBox(height: 4),
                            Text(info.name,
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(info.nameBn,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(info.description,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, height: 1.5)),
                ],
              ),
            ).animate().fadeIn(duration: DakkhoAnimations.slow).slideY(begin: 0.1, end: 0),
          ),

          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(LucideIcons.bookOpen, size: 18, color: DakkhoColors.primary),
                  const SizedBox(width: 8),
                  const Text('Courses in this Department',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/app/explore'),
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
          ),

          // Courses grid
          FutureBuilder<List<CourseModel>>(
            future: coursesAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: CourseGridSkeleton(itemCount: 4));
              }
              final courses = snapshot.data ?? [];
              if (courses.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: LucideIcons.bookX,
                    title: 'No courses yet',
                    subtitle: 'New courses for this department are coming soon.',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _CourseCard(course: courses[i]).animate().fadeIn(delay: Duration(milliseconds: 60 * i)).slideY(begin: 0.1, end: 0),
                    childCount: courses.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Color _parseColor(String hex) => Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
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
          // Thumbnail
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: DakkhoColors.courseGradientFor(course.id),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: course.thumbnailUrl.isNotEmpty
                  ? Image.network(course.thumbnailUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(LucideIcons.bookOpen, color: Colors.white.withValues(alpha: 0.5), size: 32),
                      ))
                  : Center(child: Icon(LucideIcons.bookOpen, color: Colors.white.withValues(alpha: 0.5), size: 32)),
            ),
          ),
          // Body
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(course.instructorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(LucideIcons.star, size: 12, color: DakkhoColors.warning),
                      const SizedBox(width: 2),
                      Text(course.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                      const Spacer(),
                      Text(course.price == 0 ? 'FREE' : '৳${course.price}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: course.price == 0 ? DakkhoColors.success : DakkhoColors.primary,
                          )),
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
