import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';

/// SignupPage — 4-step wizard (Phase 2 deliverable, stubbed for Phase 1)
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DakkhoColors.bgDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.userPlus, size: 64, color: DakkhoColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  '4-step wizard with OTP + institute + technology picker (Phase 2)',
                  style: TextStyle(color: DakkhoColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
