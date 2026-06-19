import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../data/stores/auth_store.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/loading_skeleton.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? DakkhoColors.textPrimary : DakkhoColors.textPrimaryLight;
    final textSecondary = isDark ? DakkhoColors.textSecondary : DakkhoColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Section — gradient welcome card
              _HeroSection(user: user, isDark: isDark, textPrimary: textPrimary, textSecondary: textSecondary),

              // 2. Continue Watching
              _ContinueWatching(isDark: isDark, textPrimary: textPrimary, textSecondary: textSecondary),

              // 3. Category Pills (department quick links)
              _CategoryPills(isDark: isDark, textPrimary: textPrimary, textSecondary: textSecondary),

              // 4. New Releases (horizontal scroll)
              _NewReleases(isDark: isDark, textPrimary: textPrimary, textSecondary: textSecondary),

              // 5. Live Now
              _LiveNow(isDark: isDark, textPrimary: textPrimary, textSecondary: textSecondary),

              // 6. Trending Courses
              _TrendingCourses(isDark: isDark, textPrimary: textPrimary, textSecondary: textSecondary),

              // 7. Featured Instructors
              _FeaturedInstructors(isDark: isDark, textPrimary: textPrimary, textSecondary: textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Section ───
class _HeroSection extends ConsumerWidget {
  const _HeroSection({required this.user, required this.isDark, required this.textPrimary, required this.textSecondary});
  final User? user;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradient: DakkhoColors.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back,',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(user?.name ?? 'Student',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(user?.instituteName ?? 'Continue learning where you left off',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
        ],
      ),
    ).animate().fadeIn(duration: DakkhoAnimations.slow).slideY(begin: 0.1, end: 0).scale(
      begin: const Offset(0.98, 0.98),
      end: const Offset(1, 1),
      duration: DakkhoAnimations.slow,
    );
  }
}

// ─── Continue Watching ───
class _ContinueWatching extends ConsumerWidget {
  const _ContinueWatching({required this.isDark, required this.textPrimary, required this.textSecondary});
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Row(
            children: [
              Icon(LucideIcons.playCircle, size: 18, color: DakkhoColors.primary),
              const SizedBox(width: 8),
              Text('Continue Watching', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
              const Spacer(),
              TextButton(onPressed: () => context.go('/app/history'), child: const Text('See all')),
            ],
          ),
        ).animate().fadeIn(duration: DakkhoAnimations.normal),
        // Real watch history from API
        FutureBuilder<List<WatchHistoryEntry>>(
          future: ref.read(watchHistoryApiProvider).maybeWhen(
            data: (api) => api.list(limit: 5).then((r) => r.history),
            orElse: () => Future.value(<WatchHistoryEntry>[]),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));
            }
            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return const SizedBox(height: 80, child: Center(child: Text('No videos watched yet', style: TextStyle(fontSize: 13, color: DakkhoColors.textSecondary))));
            }
            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: history.length,
                itemBuilder: (_, i) {
                  final h = history[i];
                  return GlassCard(
                    onTap: () => context.go('/app/video/${h.videoId}/course/${h.courseId}'),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(LucideIcons.playCircle, color: DakkhoColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Expanded(child: Text(h.videoTitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary))),
                          ]),
                          const SizedBox(height: 4),
                          Text(h.courseName, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: textSecondary)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: (h.progress / 100).clamp(0, 1),
                              backgroundColor: DakkhoColors.surfaceLight, color: DakkhoColors.primary, minHeight: 4),
                          const SizedBox(height: 4),
                          Text('${h.progress.toStringAsFixed(0)}% watched',
                              style: const TextStyle(fontSize: 10, color: DakkhoColors.textMuted)),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 80 * i)).slideX(begin: 0.1, end: 0);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Category Pills (Department quick links) ───
class _CategoryPills extends StatelessWidget {
  const _CategoryPills({required this.isDark, required this.textPrimary, required this.textSecondary});
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final depts = [
      ('CSE', '/app/department/cse', 0),
      ('ETE', '/app/department/ete', 1),
      ('EEE', '/app/department/eee', 2),
      ('ME', '/app/department/me', 3),
      ('CE', '/app/department/ce', 4),
      ('Arch', '/app/department/architecture', 5),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Row(children: [
            Icon(LucideIcons.building, size: 18, color: DakkhoColors.primary),
            const SizedBox(width: 8),
            Text('Departments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
          ]),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: depts.length,
            itemBuilder: (_, i) {
              final d = depts[i];
              return GestureDetector(
                onTap: () => context.go(d.$2),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: DakkhoColors.courseGradients[d.$3 % DakkhoColors.courseGradients.length]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(d.$1, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: DakkhoAnimations.normal,
                curve: DakkhoAnimations.elastic,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── New Releases (horizontal scroll of featured courses) ───
class _NewReleases extends ConsumerWidget {
  const _NewReleases({required this.isDark, required this.textPrimary, required this.textSecondary});
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Row(children: [
            Icon(LucideIcons.sparkles, size: 18, color: DakkhoColors.accent),
            const SizedBox(width: 8),
            Text('New Releases', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
          ]),
        ),
        FutureBuilder<List<CourseModel>>(
          future: ref.read(courseApiProvider).maybeWhen(
            data: (api) => api.list(limit: 20).then((r) => r.courses.where((c) => c.isFeatured).take(8).toList()),
            orElse: () => Future.value(<CourseModel>[]),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
            }
            final courses = snapshot.data ?? [];
            if (courses.isEmpty) {
              return const SizedBox(height: 60, child: Center(child: Text('No new releases', style: TextStyle(fontSize: 13, color: DakkhoColors.textSecondary))));
            }
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: courses.length,
                itemBuilder: (_, i) {
                  final c = courses[i];
                  final gradient = DakkhoColors.courseGradients[i % DakkhoColors.courseGradients.length];
                  return GestureDetector(
                    onTap: () => context.go('/app/course/${c.id}'),
                    child: Container(
                      width: 256,
                      margin: const EdgeInsets.only(right: 16),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            Expanded(
                              flex: 5,
                              child: Container(
                                decoration: BoxDecoration(gradient: LinearGradient(colors: gradient)),
                                child: Stack(
                                  children: [
                                    Center(child: Icon(LucideIcons.play, color: Colors.white.withValues(alpha: 0.3), size: 40)),
                                    Positioned(top: 8, left: 8,
                                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: DakkhoColors.accent.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(100)),
                                        child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)))),
                                    Positioned(bottom: 8, right: 8,
                                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4)),
                                        child: Row(children: [
                                          Icon(LucideIcons.clock, size: 10, color: Colors.white),
                                          const SizedBox(width: 2),
                                          Text('${c.duration}m', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                                        ]))),
                                  ],
                                ),
                              ),
                            ),
                            // Info
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                                    const SizedBox(height: 2),
                                    Text(c.instructorName, maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 11, color: textSecondary)),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Icon(LucideIcons.star, size: 12, color: DakkhoColors.warning),
                                      const SizedBox(width: 2),
                                      Text(c.rating.toStringAsFixed(1), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary)),
                                      const SizedBox(width: 8),
                                      Icon(LucideIcons.users, size: 12, color: textSecondary),
                                      const SizedBox(width: 2),
                                      Text('${c.totalStudents}', style: TextStyle(fontSize: 11, color: textSecondary)),
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.1, end: 0);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Live Now ───
class _LiveNow extends ConsumerWidget {
  const _LiveNow({required this.isDark, required this.textPrimary, required this.textSecondary});
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<LiveClass>>(
      future: ref.read(liveClassApiProvider).maybeWhen(
        data: (api) => api.list(),
        orElse: () => Future.value(<LiveClass>[]),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
        final live = snapshot.data ?? [];
        if (live.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: Row(children: [
                Icon(LucideIcons.radio, size: 18, color: DakkhoColors.danger).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: const Duration(seconds: 1)),
                const SizedBox(width: 8),
                Text('Live Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: DakkhoColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                  child: Text('${live.length} LIVE', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: DakkhoColors.danger))),
              ]),
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: live.length,
                itemBuilder: (_, i) {
                  final l = live[i];
                  return GlassCard(
                    onTap: l.meetingUrl != null ? () {} : null,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 180,
                      child: Row(children: [
                        Container(width: 8, height: 8,
                          decoration: const BoxDecoration(color: DakkhoColors.danger, shape: BoxShape.circle)).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                          begin: const Offset(1, 1), end: const Offset(1.4, 1.4), duration: const Duration(milliseconds: 600)),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                          Text('${l.instructorName ?? 'Instructor'} · ${l.durationMinutes}min',
                              style: TextStyle(fontSize: 11, color: textSecondary)),
                        ])),
                        Icon(LucideIcons.radio, color: DakkhoColors.danger, size: 20),
                      ]),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.1, end: 0);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Trending Courses ───
class _TrendingCourses extends ConsumerWidget {
  const _TrendingCourses({required this.isDark, required this.textPrimary, required this.textSecondary});
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Row(children: [
            Icon(LucideIcons.trendingUp, size: 18, color: DakkhoColors.primary),
            const SizedBox(width: 8),
            Text('Trending Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            const Spacer(),
            TextButton(onPressed: () => context.go('/app/explore'), child: const Text('See all')),
          ]),
        ),
        FutureBuilder<List<CourseModel>>(
          future: ref.read(courseApiProvider).maybeWhen(
            data: (api) => api.list(limit: 10).then((r) => r.courses),
            orElse: () => Future.value(<CourseModel>[]),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CourseGridSkeleton(itemCount: 4);
            }
            final courses = snapshot.data ?? [];
            if (courses.isEmpty) {
              return const SizedBox(height: 60, child: Center(child: Text('No courses available', style: TextStyle(fontSize: 13, color: DakkhoColors.textSecondary))));
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.7,
                crossAxisSpacing: 12, mainAxisSpacing: 12,
              ),
              itemCount: courses.length,
              itemBuilder: (_, i) => _CourseCard(course: courses[i], textPrimary: textPrimary, textSecondary: textSecondary)
                  .animate().fadeIn(delay: Duration(milliseconds: 60 * i)).slideY(begin: 0.1, end: 0),
            );
          },
        ),
      ],
    );
  }
}

// ─── Featured Instructors ───
class _FeaturedInstructors extends ConsumerWidget {
  const _FeaturedInstructors({required this.isDark, required this.textPrimary, required this.textSecondary});
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<InstructorModel>>(
      future: ref.read(instructorApiProvider).maybeWhen(
        data: (api) => api.list(limit: 6).then((r) => r.instructors),
        orElse: () => Future.value(<InstructorModel>[]),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
        final instructors = snapshot.data ?? [];
        if (instructors.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: Row(children: [
                Icon(LucideIcons.graduationCap, size: 18, color: DakkhoColors.primary),
                const SizedBox(width: 8),
                Text('Featured Instructors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const Spacer(),
                TextButton(onPressed: () => context.go('/app/instructors'), child: const Text('See all')),
              ]),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: instructors.length,
                itemBuilder: (_, i) {
                  final inst = instructors[i];
                  return GestureDetector(
                    onTap: () => context.go('/app/instructor/${inst.id}'),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: DakkhoColors.primary,
                            backgroundImage: inst.avatarUrl.isNotEmpty ? NetworkImage(inst.avatarUrl) : null,
                            child: inst.avatarUrl.isEmpty
                                ? Text(inst.name.isNotEmpty ? inst.name[0] : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))
                                : null,
                          ),
                          const SizedBox(height: 6),
                          Text(inst.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary)),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).scale(
                    begin: const Offset(0.8, 0.8), end: const Offset(1, 1),
                    duration: DakkhoAnimations.normal, curve: DakkhoAnimations.elastic,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Course Card (used in grid) ───
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.textPrimary, required this.textSecondary});
  final CourseModel course;
  final Color textPrimary;
  final Color textSecondary;

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
                gradient: LinearGradient(
                  colors: DakkhoColors.courseGradientFor(course.id),
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
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
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                  const SizedBox(height: 4),
                  Text(course.instructorName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: textSecondary)),
                  const Spacer(),
                  Row(children: [
                    Icon(LucideIcons.star, size: 12, color: DakkhoColors.warning),
                    const SizedBox(width: 2),
                    Text(course.rating.toStringAsFixed(1), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary)),
                    const Spacer(),
                    Text(course.price == 0 ? 'FREE' : '৳${course.price}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: course.price == 0 ? DakkhoColors.success : DakkhoColors.primary)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
