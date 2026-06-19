import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/stores/stores.dart';
import '../../data/models/models.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/empty_state.dart';

class CourseDetailPage extends ConsumerStatefulWidget {
  const CourseDetailPage({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends ConsumerState<CourseDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CourseModel? _course;
  List<InstructorModel> _instructors = [];
  List<VideoModel> _videos = [];
  List<CoursePackage> _packages = [];
  bool _isEnrolled = false;
  String _paymentStatus = 'none'; // ignore: unused_field
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final courseApi = await ref.read(courseApiProvider.future);
      final enrollmentApi = await ref.read(enrollmentApiProvider.future);

      // Fetch course detail + instructors
      final courseResult = await courseApi.get(widget.courseId);
      _course = courseResult.course;
      _instructors = courseResult.instructors;

      // Fetch course videos
      try {
        _videos = await courseApi.videos(widget.courseId);
      } catch (_) {
        _videos = [];
      }

      // Fetch packages
      try {
        final packageApi = await ref.read(packageApiProvider.future);
        _packages = await packageApi.listForCourse(widget.courseId);
      } catch (_) {
        _packages = [];
      }

      // Check enrollment
      final enrollmentResult = await enrollmentApi.check(widget.courseId);
      _isEnrolled = enrollmentResult.enrolled;
      _paymentStatus = enrollmentResult.paymentStatus;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load course: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(),
        body: ListView(
          children: [
            const LoadingSkeleton(width: double.infinity, height: 200),
            const SizedBox(height: 16),
            const LoadingSkeleton(width: double.infinity, height: 24),
            const SizedBox(height: 8),
            const LoadingSkeleton(width: 200, height: 14),
          ],
        ),
      );
    }

    if (_error != null || _course == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(),
        body: EmptyState(icon: LucideIcons.alertCircle, title: 'Failed to load', subtitle: _error ?? 'Unknown error'),
      );
    }

    final course = _course!;
    final isFree = course.price == 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Hero thumbnail
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: DakkhoColors.courseGradientFor(course.id),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: course.thumbnailUrl.isNotEmpty
                      ? Image.network(course.thumbnailUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(child: Icon(LucideIcons.bookOpen, color: Colors.white.withValues(alpha: 0.5), size: 48)))
                      : Center(child: Icon(LucideIcons.bookOpen, color: Colors.white.withValues(alpha: 0.5), size: 48)),
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
                        context.go('/app/home');
                      }
                    },
                  ),
                ),
                // Bookmark button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 8,
                  child: IconButton.filled(
                    icon: Icon(
                      ref.watch(bookmarkProvider).bookmarks.contains(course.id) ? LucideIcons.bookmark : LucideIcons.bookmark,
                      color: Colors.white,
                    ),
                    onPressed: () => ref.read(bookmarkProvider.notifier).toggleBookmark(course.id),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: DakkhoAnimations.slow).scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              duration: DakkhoAnimations.slow,
            ),
          ),

          // Title + meta
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary, height: 1.2)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.star, size: 16, color: DakkhoColors.warning),
                      const SizedBox(width: 4),
                      Text(course.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                      const SizedBox(width: 4),
                      Text('(${course.totalReviews} reviews)', style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                      const SizedBox(width: 12),
                      Icon(LucideIcons.users, size: 14, color: DakkhoColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${course.totalStudents} students', style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _tag(_levelLabel(course.level), LucideIcons.barChart),
                      _tag('${course.totalVideos} videos', LucideIcons.playCircle),
                      _tag('${course.duration ~/ 60}h ${course.duration % 60}m', LucideIcons.clock),
                      _tag(course.language.toUpperCase(), LucideIcons.languages),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Instructors
                  if (_instructors.isNotEmpty)
                    GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              for (var i = 0; i < _instructors.take(3).length; i++)
                                Transform.translate(
                                  offset: Offset(i * 16.0, 0),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: DakkhoColors.primary,
                                    backgroundImage: _instructors[i].avatarUrl.isNotEmpty ? NetworkImage(_instructors[i].avatarUrl) : null,
                                    child: _instructors[i].avatarUrl.isEmpty
                                        ? Text(_instructors[i].name.isNotEmpty ? _instructors[i].name[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_instructors.length == 1) {
                                  context.go('/app/instructor/${_instructors.first.id}');
                                } else {
                                  context.go('/app/instructors');
                                }
                              },
                              child: Text(
                                _instructors.map((i) => i.name).join(', '),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),

          // Enrollment CTA (sticky-ish — appears before tabs)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildEnrollmentCTA(course, isFree),
            ),
          ),

          // Tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GlassCard(
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Curriculum'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'More'),
                  ],
                ),
              ),
            ),
          ),

          // Tab content
          SliverFillRemaining(
            hasScrollBody: true,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(course),
                _buildCurriculumTab(),
                _buildReviewsTab(course),
                _buildMoreTab(course),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: DakkhoColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DakkhoColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: DakkhoColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DakkhoColors.primary)),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: DakkhoAnimations.normal, curve: DakkhoAnimations.elastic);
  }

  Widget _buildEnrollmentCTA(CourseModel course, bool isFree) {
    if (_isEnrolled) {
      return GradientButton(
        label: 'Continue Watching',
        icon: LucideIcons.play,
        onPressed: () {
          if (_videos.isNotEmpty) {
            context.go('/app/video/${_videos.first.id}/course/${course.id}');
          }
        },
      ).animate().fadeIn().slideY(begin: 0.1, end: 0);
    }

    return GradientButton(
      label: isFree ? 'Enroll for Free' : 'Enroll — ৳${course.price}',
      icon: isFree ? LucideIcons.check : LucideIcons.shoppingCart,
      onPressed: () => _showCheckoutSheet(course),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  void _showCheckoutSheet(CourseModel course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: DakkhoColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _CheckoutSheet(
        course: course,
        packages: _packages,
        onPay: (packageId, couponCode) async {
          Navigator.pop(ctx);
          await _initiatePayment(course, packageId, couponCode);
        },
        onEnrollFree: () async {
          Navigator.pop(ctx);
          await _enrollFree(course);
        },
      ),
    );
  }

  Future<void> _initiatePayment(CourseModel course, int packageId, String? coupon) async {
    try {
      final paymentApi = await ref.read(paymentApiProvider.future);
      final result = await paymentApi.create(packageId: packageId, couponCode: coupon?.isEmpty == true ? null : coupon);
      // Open PipraPay checkout URL in Chrome Custom Tab / system browser
      await launchUrl(Uri.parse(result.ppUrl), mode: LaunchMode.externalApplication);
      // After return, user goes to /app/payment-result?pp_id=...
      // The route handler will verify the payment.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    }
  }

  Future<void> _enrollFree(CourseModel course) async {
    try {
      final enrollmentApi = await ref.read(enrollmentApiProvider.future);
      await enrollmentApi.enroll(courseId: course.id);
      // Refresh enrollment status
      final result = await enrollmentApi.check(course.id);
      setState(() {
        _isEnrolled = result.enrolled;
        _paymentStatus = result.paymentStatus;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enrolled successfully!'), backgroundColor: DakkhoColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enrollment failed: $e')),
        );
      }
    }
  }

  Widget _buildOverviewTab(CourseModel course) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Description
        const Text('About this course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
        const SizedBox(height: 8),
        Text(course.description, style: const TextStyle(fontSize: 14, color: DakkhoColors.textSecondary, height: 1.6)),

        if (course.learningItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('What you\'ll learn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
          const SizedBox(height: 12),
          ...course.learningItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.check, color: DakkhoColors.success, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 13, color: DakkhoColors.textPrimary))),
              ],
            ),
          )),
        ],

        const SizedBox(height: 24),
        const Text('Course includes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
        const SizedBox(height: 12),
        _includesRow(LucideIcons.playCircle, '${course.totalVideos} on-demand videos'),
        _includesRow(LucideIcons.clock, '${course.duration ~/ 60}h ${course.duration % 60}min of content'),
        _includesRow(LucideIcons.download, 'Downloadable resources'),
        _includesRow(LucideIcons.award, 'Certificate of completion'),
        _includesRow(LucideIcons.infinity, 'Full lifetime access'),
      ],
    );
  }

  Widget _includesRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: DakkhoColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, color: DakkhoColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildCurriculumTab() {
    if (_videos.isEmpty) {
      return const EmptyState(icon: LucideIcons.listTree, title: 'No videos yet', subtitle: 'Curriculum will be published soon.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videos.length,
      itemBuilder: (_, i) {
        final v = _videos[i];
        final isPreview = v.isPreview;
        final isLocked = !_isEnrolled && !isPreview;

        return GlassCard(
          onTap: () {
            if (isLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enroll to access this video')),
              );
              return;
            }
            context.go('/app/video/${v.id}/course/${widget.courseId}');
          },
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isLocked ? DakkhoColors.surfaceLighter : DakkhoColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isLocked ? LucideIcons.lock : (isPreview ? LucideIcons.eye : LucideIcons.play),
                  color: isLocked ? DakkhoColors.textMuted : DakkhoColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('${i + 1}.', style: const TextStyle(fontSize: 11, color: DakkhoColors.textMuted, fontFamily: 'monospace')),
                        const SizedBox(width: 6),
                        if (v.duration > 0)
                          Text('${v.duration ~/ 60}:${(v.duration % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                        if (isPreview) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: DakkhoColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('PREVIEW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: DakkhoColors.accent)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 30 * i)).slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildReviewsTab(CourseModel course) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rating summary
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(course.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < course.rating.round() ? LucideIcons.star : LucideIcons.star,
                        color: i < course.rating.round() ? DakkhoColors.warning : DakkhoColors.surfaceLighter,
                        size: 18,
                        fill: i < course.rating.round() ? 1.0 : 0.0,
                      )),
                    ),
                    const SizedBox(height: 4),
                    Text('${course.totalReviews} reviews', style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        const SizedBox(height: 16),
        const EmptyState(
          icon: LucideIcons.messageCircle,
          title: 'Reviews coming soon',
          subtitle: 'Be the first to review this course.',
        ),
      ],
    );
  }

  Widget _buildMoreTab(CourseModel course) {
    final subPages = [
      (LucideIcons.listTree, 'Curriculum', '/app/course/${course.id}/curriculum'),
      (LucideIcons.helpCircle, 'Q&A', '/app/course/${course.id}/qa'),
      (LucideIcons.megaphone, 'Announcements', '/app/course/${course.id}/announcements'),
      (LucideIcons.paperclip, 'Resources', '/app/course/${course.id}/resources'),
      (LucideIcons.stickyNote, 'Notes', '/app/course/${course.id}/notes'),
      (LucideIcons.clipboardList, 'Quizzes', '/app/course/${course.id}/quizzes'),
      (LucideIcons.trendingUp, 'Progress', '/app/course/${course.id}/progress'),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (icon, label, path) in subPages)
          GlassCard(
            onTap: () => context.go(path),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(icon, color: DakkhoColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary))),
                Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
              ],
            ),
          ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.05, end: 0),
      ],
    );
  }

  String _levelLabel(String level) {
    return switch (level.toLowerCase()) {
      'beginner' => 'Beginner',
      'intermediate' => 'Intermediate',
      'advanced' => 'Advanced',
      'expert' => 'Expert',
      _ => level,
    };
  }
}

class _CheckoutSheet extends ConsumerStatefulWidget {
  const _CheckoutSheet({
    required this.course,
    required this.packages,
    required this.onPay,
    required this.onEnrollFree,
  });

  final CourseModel course;
  final List<CoursePackage> packages;
  final void Function(int packageId, String? coupon) onPay;
  final VoidCallback onEnrollFree;

  @override
  ConsumerState<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<_CheckoutSheet> {
  CoursePackage? _selectedPackage;
  final _couponController = TextEditingController();
  bool _isValidatingCoupon = false;
  Coupon? _coupon;

  @override
  void initState() {
    super.initState();
    if (widget.packages.isNotEmpty) {
      _selectedPackage = widget.packages.first;
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _validateCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    setState(() => _isValidatingCoupon = true);
    try {
      final api = await ref.read(couponApiProvider.future);
      final coupon = await api.validate(code);
      setState(() {
        _coupon = coupon;
        _isValidatingCoupon = false;
      });
    } catch (_) {
      setState(() => _isValidatingCoupon = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFree = widget.course.price == 0;
    num finalPrice = widget.course.price;
    if (_coupon?.valid == true && _coupon?.coupon != null && _selectedPackage != null) {
      final c = _coupon!.coupon!;
      finalPrice = c.discountType == 'percentage'
          ? _selectedPackage!.price * (1 - c.discountValue / 100)
          : (_selectedPackage!.price - c.discountValue).clamp(0, _selectedPackage!.price);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: DakkhoColors.surfaceLighter, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text('Checkout', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
              const SizedBox(height: 4),
              Text(widget.course.title, style: const TextStyle(fontSize: 13, color: DakkhoColors.textSecondary)),
              const SizedBox(height: 24),

              // Package selection (if multiple)
              if (widget.packages.length > 1) ...[
                const Text('Choose package', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                const SizedBox(height: 12),
                ...widget.packages.map((p) => RadioListTile<CoursePackage>(
                  value: p,
                  groupValue: _selectedPackage,
                  onChanged: (v) => setState(() => _selectedPackage = v),
                  title: Text(_packageLabel(p)),
                  subtitle: Text('৳${p.price} · ${p.durationMonths}mo access'),
                  activeColor: DakkhoColors.primary,
                )),
                const SizedBox(height: 16),
              ] else if (widget.packages.length == 1) ...[
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(LucideIcons.package, color: DakkhoColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_packageLabel(widget.packages.first), style: const TextStyle(fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                            Text('${widget.packages.first.durationMonths} months access', style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text('৳${widget.packages.first.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: DakkhoColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Coupon input (only for paid courses)
              if (!isFree) ...[
                const Text('Coupon code (optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          labelText: 'Enter coupon code',
                          prefixIcon: const Icon(LucideIcons.ticket, size: 18),
                          suffixIcon: _isValidatingCoupon
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : (_coupon?.valid == true ? const Icon(LucideIcons.check, color: DakkhoColors.success) : null),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isValidatingCoupon ? null : _validateCoupon,
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                if (_coupon?.valid == false && _couponController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_coupon?.error ?? 'Invalid coupon', style: const TextStyle(fontSize: 11, color: DakkhoColors.danger)),
                  ),
                const SizedBox(height: 24),
              ],

              // Total
              if (!isFree && _selectedPackage != null)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _priceRow('Original', '৳${_selectedPackage!.price}'),
                      if (_coupon?.valid == true && _coupon?.coupon != null)
                        _priceRow('Discount', '- ৳${(_selectedPackage!.price - finalPrice).toStringAsFixed(0)}', color: DakkhoColors.success),
                      const Divider(),
                      _priceRow('Total', '৳${finalPrice.toStringAsFixed(0)}', isBold: true),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Pay button
              if (isFree)
                GradientButton(
                  label: 'Enroll for Free',
                  icon: LucideIcons.check,
                  gradient: DakkhoColors.accentGradient,
                  onPressed: widget.onEnrollFree,
                )
              else
                GradientButton(
                  label: 'Pay ৳${finalPrice.toStringAsFixed(0)} with PipraPay',
                  icon: LucideIcons.creditCard,
                  onPressed: () {
                    if (_selectedPackage != null) {
                      widget.onPay(_selectedPackage!.id, _couponController.text);
                    }
                  },
                ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.shieldCheck, size: 14, color: DakkhoColors.textSecondary),
                  const SizedBox(width: 4),
                  const Text('Secure payment via PipraPay', style: TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: DakkhoColors.textSecondary, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, color: color ?? DakkhoColors.textPrimary)),
        ],
      ),
    );
  }

  String _packageLabel(CoursePackage p) {
    return switch (p.packageType) {
      'single' => 'Single User',
      'duo' => 'Duo (2 users)',
      'group' => 'Group (${p.maxUsers} users)',
      'lifetime' => 'Lifetime Access',
      _ => p.displayName ?? p.packageType,
    };
  }
}
