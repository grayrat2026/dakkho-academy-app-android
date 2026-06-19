import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  double _strength(String pwd) {
    double score = 0;
    if (pwd.length >= 8) score += 0.25;
    if (pwd.length >= 12) score += 0.25;
    if (pwd.contains(RegExp(r'[A-Z]'))) score += 0.15;
    if (pwd.contains(RegExp(r'[0-9]'))) score += 0.15;
    if (pwd.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength(_newController.text);
    final strengthLabel = strength < 0.3 ? 'Weak' : (strength < 0.6 ? 'Medium' : 'Strong');
    final strengthColor = strength < 0.3 ? DakkhoColors.danger : (strength < 0.6 ? DakkhoColors.warning : DakkhoColors.success);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _currentController,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.lock, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureCurrent ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                        onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newController,
                    obscureText: _obscureNew,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.lock, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                  ),
                  if (_newController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: strength,
                      backgroundColor: DakkhoColors.surfaceLight,
                      color: strengthColor,
                      minHeight: 4,
                    ),
                    const SizedBox(height: 4),
                    Text(strengthLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: strengthColor)),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Confirm New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.lock, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      errorText: _confirmController.text.isNotEmpty && _confirmController.text != _newController.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            GradientButton(
              label: _isSaving ? 'Updating...' : 'Update Password',
              icon: LucideIcons.key,
              isLoading: _isSaving,
              isDisabled: _newController.text.isEmpty || _confirmController.text != _newController.text,
              onPressed: _isSaving ? null : () async {
                setState(() => _isSaving = true);
                try {
                  final api = await ref.read(profileApiProvider.future);
                  // TODO: backend doesn't have /api/auth/change-password yet — using profile update as fallback
                  await api.update({'currentPassword': _currentController.text, 'newPassword': _newController.text});
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated!'), backgroundColor: DakkhoColors.success),
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
              },
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
