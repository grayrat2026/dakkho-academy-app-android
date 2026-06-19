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

class MyCoursesPage extends ConsumerStatefulWidget {
  const MyCoursesPage({super.key});
  @override
  ConsumerState<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends ConsumerState<MyCoursesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<EnrollmentModel> _enrollments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEnrollments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEnrollments() async {
    try {
      final api = await ref.read(enrollmentApiProvider.future);
      final enrollments = await api.mine();
      setState(() {
        _enrollments = enrollments;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('My Courses')),
        body: ListView.builder(itemCount: 5, itemBuilder: (_, __) => const ListItemSkeleton()),
      );
    }

    final inProgress = _enrollments.where((e) => !e.completed && e.progress > 0).toList();
    final notStarted = _enrollments.where((e) => e.progress == 0).toList();
    final completed = _enrollments.where((e) => e.completed).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Courses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'In Progress (${inProgress.length})'),
            Tab(text: 'Not Started (${notStarted.length})'),
            Tab(text: 'Completed (${completed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(inProgress),
          _buildList(notStarted),
          _buildList(completed),
        ],
      ),
    );
  }

  Widget _buildList(List<EnrollmentModel> enrollments) {
    if (enrollments.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.bookOpen,
        title: 'No courses here',
        subtitle: 'Enroll in courses to see them here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrollments.length,
      itemBuilder: (_, i) {
        final e = enrollments[i];
        return GlassCard(
          onTap: () => context.go('/app/course/${e.courseId}'),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: DakkhoColors.courseGradientFor(e.courseId)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: e.course.thumbnailUrl.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(e.course.thumbnailUrl, fit: BoxFit.cover))
                    : const Icon(LucideIcons.bookOpen, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.course.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (e.progress / 100).clamp(0, 1),
                      backgroundColor: DakkhoColors.surfaceLight,
                      color: e.completed ? DakkhoColors.success : DakkhoColors.primary,
                      minHeight: 4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.completed ? 'Completed ✓' : '${e.progress.toStringAsFixed(0)}% complete',
                      style: TextStyle(
                        fontSize: 11,
                        color: e.completed ? DakkhoColors.success : DakkhoColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 60 * i)).slideX(begin: 0.05, end: 0);
      },
    );
  }
}
