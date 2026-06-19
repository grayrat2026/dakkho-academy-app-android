import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DakkhoColors.bgDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(LucideIcons.keyRound, size: 64, color: DakkhoColors.primary),
              SizedBox(height: 16),
              Text('Forgot Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
              SizedBox(height: 8),
              Text('OTP-based password reset (Phase 2)', style: TextStyle(color: DakkhoColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
