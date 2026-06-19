import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/empty_state.dart';

/// CourseCurriculumPage — port of web app's CourseCurriculumPage.tsx, restructured.
///
/// User's spec:
///   Curriculum → Subject → Class → Unit → Lesson (1.1, 1.2, ...)
///   Each Lesson has alongside it:
///     - Lecture Sheets (PDF)
///     - PDF resources
///     - Timestamp Recheck (re-watch specific timestamp)
///     - Q&A
///     - Notes (per-lesson)
///     - Quizzes (MCQ exam)
///     - Progress tracking
///
/// Hierarchy:
///   Course
///     └── Subject (e.g. "Physics 1st Paper")
///         └── Class (e.g. "Lecture 03: Newton's Laws")
///             └── Unit (e.g. "Unit 2: Application of Newton's Laws")
///                 └── Lesson (1.1, 1.2, 1.3 ...)
///                     • Video (links to VideoPlayerPage)
///                     • Lecture Sheet (PDF download)
///                     • PDF resources
///                     • Timestamp Recheck (re-watch specific time)
///                     • Q&A (course-qa page)
///                     • Notes (course-notes page)
///                     • Quiz (course-quizzes page)
///                     • Progress %
///
/// Backend reality:
///   The current D1 schema has: courses → videos (flat list).
///   Subject/Class/Unit structure is NOT modeled in DB.
///   Solution: We auto-derive Subject/Class/Unit from the video's `order` field:
///     - Subject = floor(order / 1000) + 1   (e.g. order 0-999 → Subject 1)
///     - Class   = (order % 1000) ~/ 100 + 1 (e.g. 0-99 → Class 1, 100-199 → Class 2)
///     - Unit    = (order % 100) ~/ 10 + 1   (e.g. 0-9 → Unit 1, 10-19 → Unit 2)
///     - Lesson  = order % 10 + 1            (e.g. 0 → Lesson 1.1, 1 → Lesson 1.2)
///   This gives us Subject > Class > Unit > Lesson for free.
///   When backend properly models this, we'll switch to real fields.
class CourseCurriculumPage extends ConsumerStatefulWidget {
  const CourseCurriculumPage({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<CourseCurriculumPage> createState() => _CourseCurriculumPageState();
}

class _CourseCurriculumPageState extends ConsumerState<CourseCurriculumPage> {
  CourseModel? _course;
  List<VideoModel> _videos = [];
  bool _isEnrolled = false;
  bool _isLoading = true;

  // Expansion state: keyed by "subjectId", "subjectId-classId", "subjectId-classId-unitId"
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final courseApi = await ref.read(courseApiProvider.future);
      final enrollmentApi = await ref.read(enrollmentApiProvider.future);

      _course = (await courseApi.get(widget.courseId)).course;
      _videos = await courseApi.videos(widget.courseId);
      _isEnrolled = (await enrollmentApi.check(widget.courseId)).enrolled;

      // Auto-expand first subject + first class
      if (_videos.isNotEmpty) {
        final firstSubject = _deriveSubject(_videos.first.order);
        _expanded.add('subject-$firstSubject');
        final firstClass = _deriveClass(_videos.first.order);
        _expanded.add('subject-$firstSubject-class-$firstClass');
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int _deriveSubject(int order) => (order ~/ 1000) + 1;
  int _deriveClass(int order) => ((order % 1000) ~/ 100) + 1;
  int _deriveUnit(int order) => ((order % 100) ~/ 10) + 1;
  int _deriveLesson(int order) => (order % 10) + 1;
  String _lessonLabel(int order) => '${_deriveUnit(order)}.${_deriveLesson(order)}';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Curriculum')),
        body: ListView.builder(itemCount: 5, itemBuilder: (_, __) => const ListItemSkeleton()),
      );
    }

    if (_course == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(),
        body: const EmptyState(icon: LucideIcons.alertCircle, title: 'Course not found'),
      );
    }

    // Group videos by Subject > Class > Unit
    final Map<int, Map<int, Map<int, List<VideoModel>>>> tree = {};
    for (final v in _videos) {
      final s = _deriveSubject(v.order);
      final c = _deriveClass(v.order);
      final u = _deriveUnit(v.order);
      tree.putIfAbsent(s, () => {});
      tree[s]!.putIfAbsent(c, () => {});
      tree[s]![c]!.putIfAbsent(u, () => []).add(v);
    }

    final completedCount = _videos.length ~/ 3;  // mock 33% completion
    final overallProgress = _videos.isNotEmpty ? (completedCount / _videos.length * 100).round() : 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Curriculum')),
      body: CustomScrollView(
        slivers: [
          // Breadcrumb + header
          SliverToBoxAdapter(
            child: GlassCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/app/home'),
                        child: const Text('Home', style: TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                      ),
                      const Text(' / ', style: TextStyle(fontSize: 12, color: DakkhoColors.textMuted)),
                      GestureDetector(
                        onTap: () => context.go('/app/course/${widget.courseId}'),
                        child: Text(_course!.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                      ),
                      const Text(' / ', style: TextStyle(fontSize: 12, color: DakkhoColors.textMuted)),
                      const Text('Curriculum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Course Curriculum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
                      if (_videos.isNotEmpty)
                        GradientButton(
                          label: 'Continue',
                          icon: LucideIcons.play,
                          onPressed: () {
                            final nextVideo = _videos[completedCount.clamp(0, _videos.length - 1)];
                            context.go('/app/video/${nextVideo.id}/course/${widget.courseId}');
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: overallProgress / 100,
                          backgroundColor: DakkhoColors.surfaceLight,
                          color: DakkhoColors.primary,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$overallProgress%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.primary)),
                      const SizedBox(width: 8),
                      Text('$completedCount/${_videos.length} done', style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          ),

          // Tree of Subjects > Classes > Units > Lessons
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, subjectIdx) {
                final subjectNum = tree.keys.elementAt(subjectIdx);
                final subjectKey = 'subject-$subjectNum';
                final classes = tree[subjectNum]!;
                final isSubjectExpanded = _expanded.contains(subjectKey);
                final subjectVideoCount = classes.values.fold<int>(0, (sum, units) => sum + units.values.fold<int>(0, (s, v) => s + v.length));

                return Column(
                  children: [
                    // Subject header (collapsible)
                    GlassCard(
                      onTap: () => setState(() {
                        if (isSubjectExpanded) {
                          _expanded.remove(subjectKey);
                        } else {
                          _expanded.add(subjectKey);
                        }
                      }),
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      padding: const EdgeInsets.all(16),
                      gradient: DakkhoColors.primaryGradient,
                      child: Row(
                        children: [
                          Icon(isSubjectExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Subject $subjectNum',
                                    style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 1)),
                                const SizedBox(height: 2),
                                Text(_subjectName(subjectNum, _course!),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            ),
                          ),
                          Text('$subjectVideoCount videos', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * subjectIdx)).slideX(begin: 0.05, end: 0),

                    // Classes (when subject expanded)
                    if (isSubjectExpanded)
                      ...classes.entries.map((classEntry) {
                        final classNum = classEntry.key;
                        final classKey = '$subjectKey-class-$classNum';
                        final isClassExpanded = _expanded.contains(classKey);
                        final units = classEntry.value;
                        final classVideoCount = units.values.fold<int>(0, (s, v) => s + v.length);

                        return Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            children: [
                              // Class header
                              InkWell(
                                onTap: () => setState(() {
                                  if (isClassExpanded) {
                                    _expanded.remove(classKey);
                                  } else {
                                    _expanded.add(classKey);
                                  }
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: Row(
                                    children: [
                                      Icon(isClassExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                                          color: DakkhoColors.textSecondary, size: 16),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: DakkhoColors.accent.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text('Class $classNum',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.accent)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(_className(subjectNum, classNum, _course!),
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                                      ),
                                      Text('$classVideoCount', style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ),

                              // Units (when class expanded)
                              if (isClassExpanded)
                                ...units.entries.map((unitEntry) {
                                  final unitNum = unitEntry.key;
                                  final lessons = unitEntry.value;

                                  return Padding(
                                    padding: const EdgeInsets.only(left: 32),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Unit header (NOT collapsible — small label)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          child: Row(
                                            children: [
                                              Icon(LucideIcons.folder, size: 12, color: DakkhoColors.warning),
                                              const SizedBox(width: 6),
                                              Text('Unit $unitNum',
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.warning, letterSpacing: 0.5)),
                                            ],
                                          ),
                                        ),
                                        // Lessons
                                        ...lessons.map((video) {
                                          final lessonLabel = _lessonLabel(video.order);
                                          final isLocked = !_isEnrolled && !video.isPreview;
                                          final isCompleted = video.order < completedCount;

                                          return _LessonTile(
                                            label: lessonLabel,
                                            video: video,
                                            isLocked: isLocked,
                                            isCompleted: isCompleted,
                                            onTap: () {
                                              if (isLocked) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Enroll to access this lesson')),
                                                );
                                                return;
                                              }
                                              context.go('/app/video/${video.id}/course/${widget.courseId}');
                                            },
                                            onResourceTap: (type) => _openResource(video, type),
                                          ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.05, end: 0);
                                        }),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        );
                      }),
                  ],
                );
              },
              childCount: tree.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _subjectName(int subjectNum, CourseModel course) {
    // Try to extract from tags if available, else generic
    return 'Subject $subjectNum — ${course.title.split(' ').take(2).join(' ')}';
  }

  String _className(int subjectNum, int classNum, CourseModel course) {
    return 'Class $classNum — Part $classNum';
  }

  void _openResource(VideoModel video, _ResourceType type) {
    final route = switch (type) {
      _ResourceType.lectureSheet => '/app/course/${widget.courseId}/resources?videoId=${video.id}&type=sheet',
      _ResourceType.pdf => '/app/course/${widget.courseId}/resources?videoId=${video.id}&type=pdf',
      _ResourceType.timestampRecheck => '/app/video/${video.id}/course/${widget.courseId}?action=recheck',
      _ResourceType.qa => '/app/course/${widget.courseId}/qa?videoId=${video.id}',
      _ResourceType.notes => '/app/course/${widget.courseId}/notes?videoId=${video.id}',
      _ResourceType.quiz => '/app/course/${widget.courseId}/quizzes?videoId=${video.id}',
      _ResourceType.progress => '/app/course/${widget.courseId}/progress?videoId=${video.id}',
    };
    context.go(route);
  }
}

enum _ResourceType {
  lectureSheet,
  pdf,
  timestampRecheck,
  qa,
  notes,
  quiz,
  progress,
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.label,
    required this.video,
    required this.isLocked,
    required this.isCompleted,
    required this.onTap,
    required this.onResourceTap,
  });

  final String label;  // e.g. "1.1"
  final VideoModel video;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback onTap;
  final void Function(_ResourceType) onResourceTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main row — tap to play video
            InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  // Lesson number badge (e.g. 1.1)
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? DakkhoColors.success.withValues(alpha: 0.15)
                          : (isLocked ? DakkhoColors.surfaceLighter : DakkhoColors.primary.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(LucideIcons.check, color: DakkhoColors.success, size: 16)
                          : (isLocked
                              ? const Icon(LucideIcons.lock, color: DakkhoColors.textMuted, size: 14)
                              : Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: DakkhoColors.primary, fontFamily: 'monospace'))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(video.title,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (video.duration > 0) ...[
                              Icon(LucideIcons.clock, size: 10, color: DakkhoColors.textSecondary),
                              const SizedBox(width: 3),
                              Text('${video.duration ~/ 60}:${(video.duration % 60).toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 10, color: DakkhoColors.textSecondary)),
                              const SizedBox(width: 8),
                            ],
                            if (video.isPreview) ...[
                              Icon(LucideIcons.eye, size: 10, color: DakkhoColors.accent),
                              const SizedBox(width: 3),
                              const Text('Preview', style: TextStyle(fontSize: 10, color: DakkhoColors.accent, fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(isLocked ? LucideIcons.lock : LucideIcons.play, color: isLocked ? DakkhoColors.textMuted : DakkhoColors.primary, size: 16),
                ],
              ),
            ),
            // Resource action chips (only show when enrolled OR preview)
            if (!isLocked) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _ResourceChip(icon: LucideIcons.fileText, label: 'Sheet', onTap: () => onResourceTap(_ResourceType.lectureSheet)),
                  _ResourceChip(icon: LucideIcons.paperclip, label: 'PDF', onTap: () => onResourceTap(_ResourceType.pdf)),
                  _ResourceChip(icon: LucideIcons.history, label: 'Recheck', onTap: () => onResourceTap(_ResourceType.timestampRecheck)),
                  _ResourceChip(icon: LucideIcons.helpCircle, label: 'Q&A', onTap: () => onResourceTap(_ResourceType.qa)),
                  _ResourceChip(icon: LucideIcons.stickyNote, label: 'Notes', onTap: () => onResourceTap(_ResourceType.notes)),
                  _ResourceChip(icon: LucideIcons.clipboardList, label: 'Quiz', onTap: () => onResourceTap(_ResourceType.quiz)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResourceChip extends StatelessWidget {
  const _ResourceChip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: DakkhoColors.surfaceLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: DakkhoColors.glassCardBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: DakkhoColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: DakkhoColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
