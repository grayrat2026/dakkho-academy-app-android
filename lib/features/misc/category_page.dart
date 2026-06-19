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

/// CategoryPage — category landing page that filters courses by categoryId.
class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key, required this.categoryId});
  final String categoryId;

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  List<CourseModel> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = await ref.read(courseApiProvider.future);
      final result = await api.list(categoryId: widget.categoryId, limit: 50);
      _courses = result.courses;
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Category')),
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
                  const Icon(LucideIcons.folderTree, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text('Category: ${widget.categoryId}',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${_courses.length} courses available',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                ],
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
          ),

          // Course grid
          if (_isLoading)
            const SliverToBoxAdapter(child: CourseGridSkeleton(itemCount: 4))
          else if (_courses.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(icon: LucideIcons.bookX, title: 'No courses', subtitle: 'No courses in this category yet.'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.7,
                  crossAxisSpacing: 12, mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => GlassCard(
                    onTap: () => context.go('/app/course/${_courses[i].id}'),
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: Container(
                          decoration: BoxDecoration(gradient: LinearGradient(colors: DakkhoColors.courseGradientFor(_courses[i].id))),
                          child: _courses[i].thumbnailUrl.isNotEmpty
                              ? Image.network(_courses[i].thumbnailUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Icon(LucideIcons.bookOpen, color: Colors.white.withValues(alpha: 0.5), size: 32)))
                              : Center(child: Icon(LucideIcons.bookOpen, color: Colors.white.withValues(alpha: 0.5), size: 32)),
                        )),
                        Expanded(flex: 5, child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_courses[i].title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(_courses[i].instructorName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(LucideIcons.star, size: 12, color: DakkhoColors.warning),
                                  const SizedBox(width: 2),
                                  Text(_courses[i].rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                                  const Spacer(),
                                  Text(_courses[i].price == 0 ? 'FREE' : '৳${_courses[i].price}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _courses[i].price == 0 ? DakkhoColors.success : DakkhoColors.primary)),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1, end: 0),
                  childCount: _courses.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
