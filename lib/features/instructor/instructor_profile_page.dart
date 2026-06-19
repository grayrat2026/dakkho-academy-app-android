import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/empty_state.dart';

/// InstructorProfilePage — student-facing view of an instructor profile.
///
/// Matches the UI of https://dakkho-instructor.pages.dev/profile
/// (student sees a read-only version; no edit buttons).
///
/// Layout:
///   1. Cover photo (gradient fallback)
///   2. Large circular profile picture overlapping cover
///   3. Instructor name + specialization
///   4. Department + rating
///   5. Bio
///   6. Stats row: Students / Courses / Rating
///   7. Social Links (read-only)
///   8. Course grid (their courses)
///   9. Contact button (jumps to /app/instructor/:id/contact)
class InstructorProfilePage extends ConsumerStatefulWidget {
  const InstructorProfilePage({super.key, required this.instructorId});
  final String instructorId;

  @override
  ConsumerState<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends ConsumerState<InstructorProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  InstructorModel? _instructor;
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = await ref.read(instructorApiProvider.future);
      _instructor = await api.get(widget.instructorId);

      // Fetch instructor's courses (filter from course list)
      final courseApi = await ref.read(courseApiProvider.future);
      final allCourses = await courseApi.list(limit: 100);
      _courses = allCourses.courses.where((c) => c.instructorId == widget.instructorId).toList();
    } catch (e) {
      _error = 'Failed to load instructor: $e';
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          children: [
            const LoadingSkeleton(width: double.infinity, height: 180),
            const SizedBox(height: 60),
            const Center(child: LoadingSkeleton(width: 120, height: 120, borderRadius: 60)),
            const SizedBox(height: 16),
            const Center(child: LoadingSkeleton(width: 200, height: 24)),
          ],
        ),
      );
    }

    if (_error != null || _instructor == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(),
        body: EmptyState(icon: LucideIcons.userX, title: 'Instructor not found', subtitle: _error),
      );
    }

    final inst = _instructor!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // ─── Cover photo with back button ───
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Cover image (or gradient fallback)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: inst.coverUrl != null && inst.coverUrl!.isNotEmpty
                        ? null
                        : DakkhoColors.primaryGradient,
                    image: inst.coverUrl != null && inst.coverUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(inst.coverUrl!),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          )
                        : null,
                  ),
                  child: inst.coverUrl != null && inst.coverUrl!.isNotEmpty
                      ? Image.network(inst.coverUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(gradient: DakkhoColors.primaryGradient),
                          ))
                      : null,
                ),
                // Dark gradient overlay (for back button visibility)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: IconButton.filled(
                    icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/app/instructors');
                      }
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(duration: DakkhoAnimations.slow),
          ),

          // ─── Profile picture + name + meta ───
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // White content card with proper top padding for avatar overlap
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: GlassCard(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        // Name
                        Text(
                          inst.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: DakkhoColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Specialization
                        if (inst.specialization.isNotEmpty)
                          Text(
                            inst.specialization,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: DakkhoColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Department (placeholder)
                        Text(
                          'Department: Not specified',
                          style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        // Rating row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (i) => Icon(
                              LucideIcons.star,
                              size: 16,
                              color: i < inst.rating.round() ? DakkhoColors.warning : DakkhoColors.surfaceLighter,
                              fill: i < inst.rating.round() ? 1.0 : 0.0,
                            )),
                            const SizedBox(width: 6),
                            Text(
                              inst.rating > 0 ? '${inst.rating.toStringAsFixed(1)} rating' : 'No rating yet',
                              style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Bio
                        Text(
                          inst.bio.isNotEmpty ? inst.bio : 'No bio available.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: inst.bio.isNotEmpty ? DakkhoColors.textPrimary : DakkhoColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatBlock(value: '${inst.totalStudents}', label: 'Students'),
                            Container(width: 1, height: 32, color: DakkhoColors.glassCardBorder),
                            _StatBlock(value: '${inst.totalCourses}', label: 'Courses'),
                            Container(width: 1, height: 32, color: DakkhoColors.glassCardBorder),
                            _StatBlock(
                              value: inst.rating > 0 ? inst.rating.toStringAsFixed(1) : '—',
                              label: 'Rating',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: GradientButton(
                                label: 'Contact',
                                icon: LucideIcons.mail,
                                onPressed: () => context.go('/app/instructor/${widget.instructorId}/contact'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.go('/app/instructor/${widget.instructorId}/courses'),
                                icon: const Icon(LucideIcons.bookOpen, size: 16),
                                label: const Text('Courses'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: DakkhoColors.textPrimary,
                                  side: const BorderSide(color: DakkhoColors.glassCardBorder, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Avatar (overlapping cover + content card)
                Positioned(
                  top: -50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: DakkhoColors.bgDark, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: DakkhoColors.primary,
                        backgroundImage: inst.avatarUrl.isNotEmpty ? NetworkImage(inst.avatarUrl) : null,
                        child: inst.avatarUrl.isEmpty
                            ? Text(
                                inst.name.isNotEmpty ? inst.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : null,
                      ),
                    ).animate().scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: DakkhoAnimations.slow,
                      curve: DakkhoAnimations.elastic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Social Links ───
          if (inst.socialLinks.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.link, size: 18, color: DakkhoColors.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Social Links',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...inst.socialLinks.map((link) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            if (link.url.isNotEmpty) launchUrl(Uri.parse(link.url));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: DakkhoColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(_socialIcon(link.platform), color: DakkhoColors.primary, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(link.platform,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                                    Text(link.url,
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                                  ],
                                ),
                              ),
                              const Icon(LucideIcons.externalLink, size: 14, color: DakkhoColors.textSecondary),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              ),
            ),

          // ─── Tabs ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GlassCard(
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Courses'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Schedule'),
                  ],
                ),
              ),
            ),
          ),

          // ─── Tab content ───
          SliverFillRemaining(
            hasScrollBody: true,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCoursesTab(),
                _buildReviewsTab(),
                _buildScheduleTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    if (_courses.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.bookX,
        title: 'No courses yet',
        subtitle: 'This instructor hasn\'t published any courses.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _courses.length,
      itemBuilder: (_, i) {
        final course = _courses[i];
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
                      const Spacer(),
                      Row(
                        children: [
                          Icon(LucideIcons.star, size: 12, color: DakkhoColors.warning),
                          const SizedBox(width: 2),
                          Text(course.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
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
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(_instructor!.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (i) => Icon(LucideIcons.star,
                          size: 18,
                          color: i < _instructor!.rating.round() ? DakkhoColors.warning : DakkhoColors.surfaceLighter,
                          fill: i < _instructor!.rating.round() ? 1.0 : 0.0)),
                    ),
                    const SizedBox(height: 4),
                    Text('Based on ${_instructor!.totalStudents} students',
                        style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        const SizedBox(height: 16),
        const EmptyState(
          icon: LucideIcons.messageCircle,
          title: 'No reviews yet',
          subtitle: 'Be the first to review this instructor.',
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    return FutureBuilder<List<LiveClass>>(
      future: ref.read(liveClassApiProvider).maybeWhen(
        data: (api) => api.list().then((list) => list.where((l) => l.instructorId == widget.instructorId).toList()),
        orElse: () => Future.value(<LiveClass>[]),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snapshot.data ?? [];
        if (sessions.isEmpty) {
          return const EmptyState(
            icon: LucideIcons.calendar,
            title: 'No upcoming sessions',
            subtitle: 'This instructor has no scheduled live classes.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (_, i) {
            final s = sessions[i];
            return GlassCard(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: DakkhoColors.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.radio, color: DakkhoColors.danger, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('${s.durationMinutes}min · ${s.scheduledAt}',
                            style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.05, end: 0);
          },
        );
      },
    );
  }

  IconData _socialIcon(String platform) {
    return switch (platform.toLowerCase()) {
      'youtube' => LucideIcons.youtube,
      'twitter' || 'x' => LucideIcons.twitter,
      'linkedin' => LucideIcons.linkedin,
      'facebook' => LucideIcons.facebook,
      'instagram' => LucideIcons.instagram,
      'github' => LucideIcons.github,
      'website' || 'portfolio' => LucideIcons.globe,
      _ => LucideIcons.link,
    };
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: DakkhoColors.primary,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
              fontSize: 11,
              color: DakkhoColors.textSecondary,
              fontWeight: FontWeight.w600,
            )),
      ],
    ).animate().fadeIn(delay: 200.ms).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
      duration: DakkhoAnimations.normal,
      curve: DakkhoAnimations.elastic,
    );
  }
}
