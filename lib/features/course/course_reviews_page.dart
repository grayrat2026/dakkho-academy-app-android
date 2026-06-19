import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// CourseReviewsPage — course rating breakdown + reviews.
/// Backend: TODO — /api/course-reviews doesn't exist yet.
/// Shows the rating summary (from course.rating field) + static placeholder reviews.
class CourseReviewsPage extends ConsumerStatefulWidget {
  const CourseReviewsPage({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<CourseReviewsPage> createState() => _CourseReviewsPageState();
}

class _CourseReviewsPageState extends ConsumerState<CourseReviewsPage> {
  CourseModel? _course;
  bool _isLoading = true;
  bool _showWriteReview = false;
  int _myRating = 5;
  final _reviewController = TextEditingController();

  // Placeholder reviews (TODO: replace with API call)
  final List<Map<String, dynamic>> _reviews = [
    {
      'author': 'Rahim Ahmed',
      'avatar': null,
      'rating': 5,
      'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'comment': 'Excellent course! The instructor explains complex topics very clearly.',
      'helpful': 12,
    },
    {
      'author': 'Taslima Khatun',
      'avatar': null,
      'rating': 4,
      'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'comment': 'Very helpful. Would love more practice problems though.',
      'helpful': 5,
    },
    {
      'author': 'Karim Uddin',
      'avatar': null,
      'rating': 5,
      'date': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
      'comment': 'Best physics course I\'ve taken. Highly recommend!',
      'helpful': 8,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    try {
      final api = await ref.read(courseApiProvider.future);
      _course = (await api.get(widget.courseId)).course;
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Reviews')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Reviews'),
        actions: [
          IconButton(
            icon: Icon(_showWriteReview ? LucideIcons.x : LucideIcons.plus),
            onPressed: () => setState(() => _showWriteReview = !_showWriteReview),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Rating summary
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(_course?.rating.toStringAsFixed(1) ?? '0.0',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (i) => Icon(
                          LucideIcons.star,
                          color: i < (_course?.rating.round() ?? 0) ? DakkhoColors.warning : DakkhoColors.surfaceLighter,
                          size: 18,
                          fill: i < (_course?.rating.round() ?? 0) ? 1.0 : 0.0,
                        )),
                      ),
                      const SizedBox(height: 4),
                      Text('${_course?.totalReviews ?? 0} reviews',
                          style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          // Write review form
          if (_showWriteReview) ...[
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Write a review', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) => GestureDetector(
                      onTap: () => setState(() => _myRating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(LucideIcons.star,
                            size: 32,
                            color: i < _myRating ? DakkhoColors.warning : DakkhoColors.surfaceLighter,
                            fill: i < _myRating ? 1.0 : 0.0),
                      ),
                    ).animate(target: i < _myRating ? 1 : 0).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: const Duration(milliseconds: 150),
                    )),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Share your thoughts about this course...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: 'Submit Review',
                    icon: LucideIcons.send,
                    onPressed: () {
                      final comment = _reviewController.text.trim();
                      if (comment.isEmpty) return;
                      setState(() {
                        _reviews.insert(0, {
                          'author': 'You',
                          'avatar': null,
                          'rating': _myRating,
                          'date': DateTime.now().toIso8601String(),
                          'comment': comment,
                          'helpful': 0,
                        });
                        _reviewController.clear();
                        _showWriteReview = false;
                        _myRating = 5;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review submitted!'), backgroundColor: DakkhoColors.success),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          ],

          const SizedBox(height: 16),

          // Reviews list
          ..._reviews.map((r) => GlassCard(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: DakkhoColors.primary,
                      child: Text((r['author'] as String)[0],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['author'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                          Row(
                            children: [
                              ...List.generate(5, (i) => Icon(LucideIcons.star,
                                  size: 12,
                                  color: i < (r['rating'] as int) ? DakkhoColors.warning : DakkhoColors.surfaceLighter,
                                  fill: i < (r['rating'] as int) ? 1.0 : 0.0)),
                              const SizedBox(width: 8),
                              Text(_formatTime(r['date']),
                                  style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(r['comment'],
                    style: const TextStyle(fontSize: 13, color: DakkhoColors.textPrimary, height: 1.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => r['helpful']++),
                      child: Row(
                        children: [
                          Icon(LucideIcons.thumbsUp, size: 12, color: DakkhoColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('Helpful (${r['helpful']})',
                              style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideX(begin: 0.05, end: 0)),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    final dt = DateTime.parse(iso);
    final diff = DateTime.now().difference(dt);
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
