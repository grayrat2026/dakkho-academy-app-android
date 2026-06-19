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
import '../departments/department_config.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final coursesAsync = ref.watch(courseApiProvider).maybeWhen(
      data: (api) => api.list(limit: 10).then((r) => r.courses),
      orElse: () => Future.value(<CourseModel>[]),
    );
    final liveAsync = ref.watch(liveClassApiProvider).maybeWhen(
      data: (api) => api.list(),
      orElse: () => Future.value(<LiveClass>[]),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: CustomScrollView(
          slivers: [
            // Hero header
            SliverToBoxAdapter(
              child: GlassCard(
                margin: const EdgeInsets.all(16),
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
              ),
            ),

            // Continue Watching (from server watch history)
            SliverToBoxAdapter(child: _SectionHeader(title: 'Continue Watching', icon: LucideIcons.playCircle, onSeeAll: () => context.go('/app/history'))),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: FutureBuilder<List<WatchHistoryEntry>>(
                  future: ref.read(watchHistoryApiProvider).maybeWhen(
                    data: (api) => api.list(limit: 5).then((r) => r.history),
                    orElse: () => Future.value(<WatchHistoryEntry>[]),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final history = snapshot.data ?? [];
                    if (history.isEmpty) {
                      return Center(
                        child: Text('No videos watched yet',
                            style: TextStyle(color: DakkhoColors.textSecondary, fontSize: 13)),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: history.length,
                      itemBuilder: (_, i) {
                        final h = history[i];
                        return _HistoryCard(entry: h).animate().fadeIn(delay: Duration(milliseconds: 80 * i)).slideX(begin: 0.1, end: 0);
                      },
                    );
                  },
                ),
              ),
            ),

            // Departments shortcut
            SliverToBoxAdapter(child: _SectionHeader(title: 'Departments', icon: LucideIcons.building, onSeeAll: () => context.go('/app/department/cse'))),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 8,
                  itemBuilder: (_, i) {
                    final dept = ['cse', 'ete', 'eee', 'me', 'ce', 'architecture', 'textile', 'chemical'][i];
                    final info = DepartmentConfig.all[dept]!;
                    return GestureDetector(
                      onTap: () => context.go('/app/department/$dept'),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: DakkhoColors.courseGradients[i % DakkhoColors.courseGradients.length]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(info.icon, style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text(info.shortName,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
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
            ),

            // Trending Courses
            SliverToBoxAdapter(child: _SectionHeader(title: 'Trending Courses', icon: LucideIcons.trendingUp, onSeeAll: () => context.go('/app/explore'))),
            FutureBuilder<List<CourseModel>>(
              future: coursesAsync,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: CourseGridSkeleton(itemCount: 4));
                }
                final courses = snapshot.data ?? [];
                if (courses.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text('No courses available', style: TextStyle(color: DakkhoColors.textSecondary))),
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

            // Live sessions
            SliverToBoxAdapter(child: _SectionHeader(title: 'Live Sessions', icon: LucideIcons.radio, onSeeAll: () => context.go('/app/live-sessions'))),
            FutureBuilder<List<LiveClass>>(
              future: liveAsync,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())));
                }
                final live = snapshot.data ?? [];
                if (live.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No live sessions scheduled', style: TextStyle(color: DakkhoColors.textSecondary))),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _LiveClassCard(liveClass: live[i]).animate().fadeIn(delay: Duration(milliseconds: 60 * i)).slideX(begin: 0.1, end: 0),
                    childCount: live.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon, this.onSeeAll});
  final String title;
  final IconData icon;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: DakkhoColors.primary),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: ['NotoSansBengali'],
                fontSize: 18, fontWeight: FontWeight.w700,
                color: DakkhoColors.textPrimary,
              )),
          const Spacer(),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      ),
    ).animate().fadeIn(duration: DakkhoAnimations.normal).slideX(begin: -0.05, end: 0);
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});
  final WatchHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.go('/app/video/${entry.videoId}/course/${entry.courseId}'),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.playCircle, color: DakkhoColors.primary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(entry.videoTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(entry.courseName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (entry.progress / 100).clamp(0, 1),
              backgroundColor: DakkhoColors.surfaceLight,
              color: DakkhoColors.primary,
              minHeight: 4,
            ),
            const SizedBox(height: 4),
            Text('${entry.progress.toStringAsFixed(0)}% watched',
                style: const TextStyle(fontSize: 10, color: DakkhoColors.textMuted)),
          ],
        ),
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
                gradient: LinearGradient(
                  colors: DakkhoColors.courseGradientFor(course.id),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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

class _LiveClassCard extends StatelessWidget {
  const _LiveClassCard({required this.liveClass});
  final LiveClass liveClass;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: liveClass.meetingUrl != null ? () {} : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: DakkhoColors.danger, shape: BoxShape.circle),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.4, 1.4),
            duration: const Duration(milliseconds: 800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(liveClass.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                const SizedBox(height: 2),
                Text('${liveClass.instructorName ?? 'Instructor'} · ${liveClass.durationMinutes}min',
                    style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
              ],
            ),
          ),
          Icon(LucideIcons.radio, color: DakkhoColors.danger, size: 20),
        ],
      ),
    );
  }
}

// Need access to DepartmentConfig for the dept chips
