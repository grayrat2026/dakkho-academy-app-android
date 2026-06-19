import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// MaintenancePage — maintenance-mode screen with countdown + email-notify signup.
class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});
  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final _emailController = TextEditingController();
  bool _subscribed = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DakkhoColors.bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    gradient: DakkhoColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.wrench, color: Colors.white, size: 56),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).rotate(
                  begin: -0.1, end: 0.1,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                ),

                const SizedBox(height: 32),

                const Text('Under Maintenance',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),

                const SizedBox(height: 8),

                const Text('We\'re upgrading DAKKHO Academy to serve you better.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: DakkhoColors.textSecondary, height: 1.5)),

                const SizedBox(height: 24),

                // Countdown
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Estimated time remaining', style: TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _countdownBlock('1', 'Hour'),
                          Container(width: 1, height: 36, color: DakkhoColors.glassCardBorder, margin: const EdgeInsets.symmetric(horizontal: 16)),
                          _countdownBlock('45', 'Min'),
                          Container(width: 1, height: 36, color: DakkhoColors.glassCardBorder, margin: const EdgeInsets.symmetric(horizontal: 16)),
                          _countdownBlock('30', 'Sec'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                const SizedBox(height: 24),

                // Email signup
                if (!_subscribed) ...[
                  const Text('Get notified when we\'re back',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'your@email.com',
                              prefixIcon: Icon(LucideIcons.mail, size: 18),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GradientButton(
                          label: 'Notify',
                          icon: LucideIcons.bell,
                          onPressed: () {
                            if (_emailController.text.contains('@')) {
                              setState(() => _subscribed = true);
                            }
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DakkhoColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: DakkhoColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.checkCircle, color: DakkhoColors.success, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('We\'ll email you when DAKKHO is back online!',
                              style: TextStyle(fontSize: 13, color: DakkhoColors.success, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: DakkhoAnimations.elastic),
                ],

                const SizedBox(height: 32),

                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _countdownBlock(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: DakkhoColors.primary)),
        Text(label, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
      ],
    );
  }
}
