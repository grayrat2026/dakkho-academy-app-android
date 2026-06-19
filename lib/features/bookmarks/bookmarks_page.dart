import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Bookmarks')),
      body: const EmptyState(
        icon: LucideIcons.bookmark,
        title: 'Bookmarks',
        subtitle: 'Bookmarked courses. Uses bookmarkProvider.',
      ),
    );
  }
}
