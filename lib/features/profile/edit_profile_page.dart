import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/stores/auth_store.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _semesterController = TextEditingController();
  String? _avatarPath;
  bool _isSaving = false;
  bool _isLoading = true;

  List<Map<String, dynamic>> _institutes = [];
  List<Map<String, dynamic>> _technologies = [];
  int? _selectedInstituteId;
  String? _selectedTechnology;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _bioController.text = user.bio ?? '';
      _semesterController.text = user.semester?.toString() ?? '';
      _selectedInstituteId = user.instituteId;
      _selectedTechnology = user.technology;
    }

    // Load institutes + technologies for dropdowns
    try {
      final instituteApi = await ref.read(instituteApiProvider.future);
      final techApi = await ref.read(technologyApiProvider.future);
      final instResult = await instituteApi.list(limit: 200);
      final techResult = await techApi.list();
      _institutes = instResult.institutes.map((i) => {'id': i.id, 'name': i.name}).toList();
      _technologies = techResult.map((t) => {'id': t.id, 'name': t.name, 'short_code': t.shortCode}).toList();
    } catch (_) {}

    setState(() => _isLoading = false);
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (image != null) {
      setState(() => _avatarPath = image.path);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final api = await ref.read(profileApiProvider.future);
      await api.update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'bio': _bioController.text,
        if (_semesterController.text.isNotEmpty) 'semester': int.tryParse(_semesterController.text),
        if (_selectedInstituteId != null) 'instituteId': _selectedInstituteId,
        if (_selectedTechnology != null) 'technology': _selectedTechnology,
      });

      // Upload avatar if changed
      if (_avatarPath != null) {
        await api.uploadAvatar(_avatarPath!);
      }

      // Refresh user state
      final user = ref.read(authProvider).user;
      if (user != null) {
        await ref.read(authProvider.notifier).refreshUser(user.copyWith(
          name: _nameController.text,
          phone: _phoneController.text,
          bio: _bioController.text,
          semester: int.tryParse(_semesterController.text) ?? user.semester,
          instituteId: _selectedInstituteId ?? user.instituteId,
          technology: _selectedTechnology ?? user.technology,
        ));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!'), backgroundColor: DakkhoColors.success),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: DakkhoColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar picker
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: DakkhoColors.primary,
                      backgroundImage: _avatarPath != null
                          ? FileImage(File(_avatarPath!))
                          : (user?.avatarUrl?.isNotEmpty == true ? NetworkImage(user!.avatarUrl!) : null),
                      child: _avatarPath == null && (user?.avatarUrl?.isEmpty ?? true)
                          ? Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800))
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: DakkhoColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.camera, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1, 1),
                duration: DakkhoAnimations.normal,
                curve: DakkhoAnimations.elastic,
              ),
            ),
            const SizedBox(height: 24),

            // Name
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(prefixIcon: Icon(LucideIcons.user, size: 18)),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Phone
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Phone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(prefixIcon: Icon(LucideIcons.phone, size: 18)),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Institute dropdown
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Institute', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedInstituteId,
                    decoration: const InputDecoration(prefixIcon: Icon(LucideIcons.building, size: 18)),
                    items: _institutes.map((i) => DropdownMenuItem<int>(
                      value: i['id'] as int,
                      child: Text(i['name'] as String, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedInstituteId = v),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Technology dropdown
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Technology', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTechnology,
                    decoration: const InputDecoration(prefixIcon: Icon(LucideIcons.cpu, size: 18)),
                    items: _technologies.map((t) => DropdownMenuItem<String>(
                      value: t['short_code'] as String,
                      child: Text('${t['name']} (${t['short_code']})'),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedTechnology = v),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Semester
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Semester', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _semesterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(prefixIcon: Icon(LucideIcons.bookMarked, size: 18), hintText: '1-8'),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Bio
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bio', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Tell us about yourself...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            GradientButton(
              label: _isSaving ? 'Saving...' : 'Save Changes',
              icon: LucideIcons.check,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
