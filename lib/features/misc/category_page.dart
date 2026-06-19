import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key, required this.categoryId});
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Category')),
      body: EmptyState(
        icon: LucideIcons.folderTree,
        title: 'Category',
        subtitle: 'Category landing + course filter. ID: $categoryId',
      ),
    );
  }
}
