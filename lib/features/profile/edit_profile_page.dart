import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: const EmptyState(
        icon: LucideIcons.userCog,
        title: 'Edit Profile',
        subtitle: 'Form to edit name, phone, bio, avatar.',
      ),
    );
  }
}
