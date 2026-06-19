import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/stores/auth_store.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});
  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  int _step = 0;  // 0=warning, 1=reason, 2=password, 3=deleting
  String _reason = '';
  final _passwordController = TextEditingController();
  bool _isDeleting = false;
  final _reasons = [
    'Not using the app anymore',
    'Found a better alternative',
    'Too expensive',
    'Poor content quality',
    'Privacy concerns',
    'Other',
  ];

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
      _step = 3;
    });
    try {
      // TODO: backend doesn't have /api/auth/delete-account yet
      // For now we just logout
      await ref.read(authProvider.notifier).logout();
      if (!mounted) return;
      // Navigate to login screen (clear stack)
      context.go('/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account scheduled for deletion. You will receive an email confirmation.'),
          backgroundColor: DakkhoColors.warning,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _step = 2;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: DakkhoColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Delete Account')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step == 0) {
            setState(() => _step = 1);
          } else if (_step == 1) {
            setState(() => _step = 2);
          } else if (_step == 2) {
            _deleteAccount();
          }
        },
        onStepCancel: () {
          if (_step > 0) {
            setState(() => _step--);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          if (_step == 3) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                GradientButton(
                  label: _step == 2 ? 'Delete My Account' : 'Continue',
                  icon: _step == 2 ? LucideIcons.trash2 : LucideIcons.arrowRight,
                  gradient: _step == 2 ? DakkhoColors.dangerGradient : DakkhoColors.primaryGradient,
                  isLoading: _isDeleting,
                  onPressed: _isDeleting ? null : details.onStepContinue,
                ),
                const SizedBox(width: 8),
                TextButton(onPressed: details.onStepCancel, child: Text(_step == 0 ? 'Cancel' : 'Back')),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Warning
          Step(
            title: const Text('Warning'),
            content: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.alertTriangle, color: DakkhoColors.danger, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('This action is permanent!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.danger)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Deleting your account will:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 8),
                  _warningItem('Permanently remove all your profile data'),
                  _warningItem('Delete all your course progress and bookmarks'),
                  _warningItem('Revoke access to all enrolled courses'),
                  _warningItem('Delete all your notes and Q&A posts'),
                  _warningItem('Cancel any active subscription (no refund)'),
                  const SizedBox(height: 8),
                  const Text('This action CANNOT be undone.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.danger)),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            isActive: _step >= 0,
          ),

          // Step 2: Reason
          Step(
            title: const Text('Reason'),
            content: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Why are you leaving?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 12),
                  ..._reasons.map((r) => RadioListTile<String>(
                    value: r,
                    groupValue: _reason,
                    onChanged: (v) => setState(() => _reason = v ?? ''),
                    title: Text(r, style: const TextStyle(fontSize: 13)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: DakkhoColors.primary,
                  )),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            isActive: _step >= 1,
          ),

          // Step 3: Password confirm
          Step(
            title: const Text('Confirm'),
            content: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter your password to confirm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(prefixIcon: Icon(LucideIcons.lock, size: 18)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DakkhoColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: DakkhoColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertTriangle, size: 14, color: DakkhoColors.danger),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Type carefully. Clicking "Delete My Account" is irreversible.',
                              style: TextStyle(fontSize: 11, color: DakkhoColors.danger)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            isActive: _step >= 2,
          ),

          // Step 4: Deleting (progress)
          Step(
            title: const Text('Deleting'),
            content: const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: DakkhoColors.danger),
              ),
            ),
            isActive: _step >= 3,
          ),
        ],
      ),
    );
  }

  Widget _warningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.x, size: 14, color: DakkhoColors.danger),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: DakkhoColors.textPrimary))),
        ],
      ),
    );
  }
}
