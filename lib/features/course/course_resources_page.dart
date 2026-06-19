import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

/// CourseResourcesPage — downloadable resources (PDFs, code, images, archives).
/// Backend: TODO — /api/course-resources doesn't exist yet.
class CourseResourcesPage extends StatefulWidget {
  const CourseResourcesPage({super.key, required this.courseId});
  final String courseId;

  @override
  State<CourseResourcesPage> createState() => _CourseResourcesPageState();
}

class _CourseResourcesPageState extends State<CourseResourcesPage> {
  String _filterType = 'all';

  // Sample resources (TODO: replace with API call)
  final List<Map<String, dynamic>> _resources = [
    {'title': 'Lecture 01 — Course Outline.pdf', 'type': 'pdf', 'size': '245 KB', 'downloads': 124, 'url': null},
    {'title': 'Lecture 02 — Newton\'s Laws.pdf', 'type': 'pdf', 'size': '1.2 MB', 'downloads': 89, 'url': null},
    {'title': 'Source Code Examples.zip', 'type': 'archive', 'size': '4.5 MB', 'downloads': 56, 'url': null},
    {'title': 'Lab Sheet 01.pdf', 'type': 'pdf', 'size': '678 KB', 'downloads': 102, 'url': null},
    {'title': 'Diagram — Force Vectors.png', 'type': 'image', 'size': '892 KB', 'downloads': 34, 'url': null},
    {'title': 'Reference Code Snippets.dart', 'type': 'code', 'size': '12 KB', 'downloads': 28, 'url': null},
  ];

  static const _types = ['all', 'pdf', 'code', 'image', 'archive'];

  @override
  Widget build(BuildContext context) {
    final filtered = _filterType == 'all'
        ? _resources
        : _resources.where((r) => r['type'] == _filterType).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Resources')),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _types.length,
              itemBuilder: (_, i) {
                final t = _types[i];
                final selected = _filterType == t;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(t[0].toUpperCase() + t.substring(1)),
                    selected: selected,
                    onSelected: (_) => setState(() => _filterType = t),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 30 * i)).slideX(begin: 0.1, end: 0);
              },
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(icon: LucideIcons.paperclip, title: 'No resources', subtitle: 'No files match this filter.')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final r = filtered[i];
                      return GlassCard(
                        onTap: () {
                          if (r['url'] != null) {
                            launchUrl(Uri.parse(r['url']));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Resource URL not available yet')),
                            );
                          }
                        },
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: _typeColor(r['type']).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_typeIcon(r['type']), color: _typeColor(r['type']), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r['title'],
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text('${r['size']}',
                                          style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary, fontFamily: 'monospace')),
                                      const SizedBox(width: 8),
                                      Icon(LucideIcons.download, size: 10, color: DakkhoColors.textMuted),
                                      const SizedBox(width: 3),
                                      Text('${r['downloads']} downloads',
                                          style: const TextStyle(fontSize: 11, color: DakkhoColors.textMuted)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(LucideIcons.download, color: DakkhoColors.primary, size: 18),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 30 * i)).slideX(begin: 0.05, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) => switch (type) {
    'pdf' => DakkhoColors.danger,
    'code' => DakkhoColors.primary,
    'image' => DakkhoColors.purple,
    'archive' => DakkhoColors.warning,
    _ => DakkhoColors.textSecondary,
  };

  IconData _typeIcon(String type) => switch (type) {
    'pdf' => LucideIcons.fileText,
    'code' => LucideIcons.code,
    'image' => LucideIcons.image,
    'archive' => LucideIcons.archive,
    _ => LucideIcons.file,
  };
}
