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
import '../../shared/widgets/empty_state.dart';
import '../departments/department_config.dart';

class SemesterPage extends ConsumerStatefulWidget {
  const SemesterPage({super.key, required this.semester});
  final int semester;

  @override
  ConsumerState<SemesterPage> createState() => _SemesterPageState();
}

class _SemesterPageState extends ConsumerState<SemesterPage> {
  @override
  Widget build(BuildContext context) {
    final info = SemesterConfig.all[widget.semester];
    if (info == null) {
      return const EmptyState(icon: LucideIcons.alertCircle, title: 'Semester not found');
    }

    final coursesAsync = ref.watch(courseApiProvider).maybeWhen(
      data: (api) => api.list(limit: 100).then((r) => r.courses.where((c) =>
          c.title.toLowerCase().contains('semester ${widget.semester}') ||
          c.tags.any((t) => t.toLowerCase().contains('semester-${widget.semester}'))).toList()),
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
              gradient: DakkhoColors.primaryGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.period, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(info.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(info.nameBn, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
                ],
              ),
            ).animate().fadeIn(duration: DakkhoAnimations.slow).slideY(begin: 0.1, end: 0),
          ),

          // Subjects list
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(LucideIcons.bookMarked, size: 18, color: DakkhoColors.primary),
                  const SizedBox(width: 8),
                  const Text('Subjects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const Spacer(),
                  Text('${info.subjects.length} subjects',
                      style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final subject = info.subjects[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.go('/app/search/${subject.name}'),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: DakkhoColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(subject.code.substring(subject.code.length - 2),
                                style: const TextStyle(color: DakkhoColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(subject.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Code: ${subject.code}',
                                  style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary, fontFamily: 'monospace')),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: DakkhoColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${subject.credits} cr',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.accent)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1, end: 0),
                );
              },
              childCount: info.subjects.length,
            ),
          ),

          // Recommended courses section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Icon(LucideIcons.lightbulb, size: 18, color: DakkhoColors.warning),
                  const SizedBox(width: 8),
                  const Text('Recommended Courses',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                ],
              ),
            ),
          ),

          FutureBuilder<List<CourseModel>>(
            future: coursesAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())));
              }
              final courses = snapshot.data ?? [];
              if (courses.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: LucideIcons.bookX,
                    title: 'No recommended courses',
                    subtitle: 'Courses tagged for this semester will appear here.',
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      onTap: () => context.go('/app/course/${courses[i].id}'),
                      child: Row(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: DakkhoColors.courseGradientFor(courses[i].id)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(courses[i].title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text('${courses[i].instructorName} · ${courses[i].totalVideos} videos',
                                    style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1, end: 0),
                  ),
                  childCount: courses.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
