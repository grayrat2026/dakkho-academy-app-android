import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/dakkho_theme.dart';
import 'glass_card.dart';

/// LoadingSkeleton — shimmer placeholder for loading state.
///
/// Matches the web app's `.shimmer` CSS animation.
/// Conditionally rendered based on network quality:
///   - Fast (WiFi/4G/5G): no skeleton — data loads instantly from cache
///   - Slow (3G/2G): skeleton shown while data loads
///   - Offline: skeleton shown briefly before falling back to cached data
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.margin,
  });

  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? DakkhoColors.surfaceLight : const Color(0xFFE2E8F0),
      highlightColor: isDark ? DakkhoColors.surfaceLighter : const Color(0xFFF1F5F9),
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? DakkhoColors.surfaceLight : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for a course card (used in course list loading state)
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          const LoadingSkeleton(
            width: double.infinity,
            height: 120,
            borderRadius: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LoadingSkeleton(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                const LoadingSkeleton(width: 200, height: 12),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const LoadingSkeleton(width: 24, height: 24, borderRadius: 12),
                    const SizedBox(width: 8),
                    const LoadingSkeleton(width: 80, height: 10),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const LoadingSkeleton(width: 60, height: 18, borderRadius: 9),
                    const Spacer(),
                    const LoadingSkeleton(width: 40, height: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for a list item
class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const LoadingSkeleton(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                LoadingSkeleton(width: double.infinity, height: 14),
                SizedBox(height: 6),
                LoadingSkeleton(width: 200, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid of course card skeletons (for Home + Explore pages)
class CourseGridSkeleton extends StatelessWidget {
  const CourseGridSkeleton({
    super.key,
    this.itemCount = 6,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const CourseCardSkeleton(),
    );
  }
}
