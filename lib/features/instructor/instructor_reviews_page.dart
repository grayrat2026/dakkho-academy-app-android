import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

class InstructorReviewsPage extends ConsumerStatefulWidget {
  const InstructorReviewsPage({super.key, required this.instructorId});
  final String instructorId;

  @override
  ConsumerState<InstructorReviewsPage> createState() => _InstructorReviewsPageState();
}

class _InstructorReviewsPageState extends ConsumerState<InstructorReviewsPage> {
  InstructorModel? _instructor;
  bool _isLoading = true;
  String _sortBy = 'recent';

  // Placeholder reviews (TODO: replace with API when /api/instructor-reviews added)
  final List<Map<String, dynamic>> _reviews = [
    {
      'author': 'Rahim Ahmed',
      'rating': 5,
      'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'comment': 'Great instructor! Explains complex concepts very clearly.',
      'helpful': 8,
      'course': 'Physics 1st Paper',
    },
    {
      'author': 'Taslima Khatun',
      'rating': 4,
      'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'comment': 'Very knowledgeable. Would love more practice problems.',
      'helpful': 3,
      'course': 'Digital Electronics',
    },
    {
      'author': 'Karim Uddin',
      'rating': 5,
      'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'comment': 'Excellent teaching style. Highly recommended!',
      'helpful': 12,
      'course': 'Power Electronics',
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = await ref.read(instructorApiProvider.future);
      _instructor = await api.get(widget.instructorId);
    } catch (_) {}
    setState(() => _isLoading = false);
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

    final sorted = List<Map<String, dynamic>>.from(_reviews)..sort((a, b) {
      switch (_sortBy) {
        case 'helpful': return (b['helpful'] as int).compareTo(a['helpful'] as int);
        case 'highest': return (b['rating'] as int).compareTo(a['rating'] as int);
        default: return (b['date'] as String).compareTo(a['date'] as String);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Reviews'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(label: const Text('Recent'), selected: _sortBy == 'recent',
                      onSelected: (_) => setState(() => _sortBy = 'recent')),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Most Helpful'), selected: _sortBy == 'helpful',
                      onSelected: (_) => setState(() => _sortBy = 'helpful')),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Highest'), selected: _sortBy == 'highest',
                      onSelected: (_) => setState(() => _sortBy = 'highest')),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_instructor != null)
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
                        Text('${_instructor!.totalStudents} students taught',
                            style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
          const SizedBox(height: 16),
          ...sorted.map((r) => GlassCard(
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
                const SizedBox(height: 8),
                if (r['course'] != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: DakkhoColors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(r['course'],
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: DakkhoColors.purple)),
                  ),
                  const SizedBox(height: 8),
                ],
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
          if (_reviews.isEmpty)
            const EmptyState(icon: LucideIcons.messageCircle, title: 'No reviews yet'),
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
