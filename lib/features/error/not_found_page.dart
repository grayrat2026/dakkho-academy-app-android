import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/gradient_button.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

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
                const Icon(LucideIcons.frown, size: 64, color: DakkhoColors.primary),
                const SizedBox(height: 16),
                const Text(
                  '404',
                  style: TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Page not found',
                  style: TextStyle(fontSize: 18, color: DakkhoColors.textSecondary),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Go Home',
                  icon: LucideIcons.home,
                  onPressed: () => context.go('/app/home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
