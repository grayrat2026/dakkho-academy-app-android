import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// PricingPage — Free / Pro / Premium plan comparison with monthly/annual toggle.
class PricingPage extends StatefulWidget {
  const PricingPage({super.key});
  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  bool _annual = false;

  final _plans = [
    {
      'name': 'Free',
      'monthlyPrice': 0,
      'annualPrice': 0,
      'color': DakkhoColors.textSecondary,
      'features': ['Access to free preview videos', 'Browse all courses', 'Community access', 'Basic progress tracking'],
      'limitations': ['No paid course access', 'No downloads', 'No certificates', 'Ads'],
      'cta': 'Current Plan',
      'isCurrent': true,
    },
    {
      'name': 'Pro',
      'monthlyPrice': 299,
      'annualPrice': 2990,  // ~17% savings
      'color': DakkhoColors.primary,
      'features': ['All Free features', 'Access to ALL paid courses', 'Encrypted downloads', 'Certificates of completion', 'Priority support', 'No ads'],
      'limitations': [],
      'cta': 'Upgrade to Pro',
      'isCurrent': false,
    },
    {
      'name': 'Premium',
      'monthlyPrice': 499,
      'annualPrice': 4990,
      'color': DakkhoColors.purple,
      'features': ['All Pro features', 'Priority live class access', '1-on-1 instructor sessions (2/month)', 'Early access to new courses', 'Custom study plans', 'Dedicated support line'],
      'limitations': [],
      'cta': 'Go Premium',
      'isCurrent': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Pricing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Toggle
          Center(
            child: GlassCard(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _toggleOption('Monthly', !_annual),
                  _toggleOption('Annual', _annual),
                ],
              ),
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          if (_annual)
            Center(child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: DakkhoColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: const Text('Save ~17% annually', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.success)),
              ),
            )).animate().fadeIn(),

          const SizedBox(height: 24),

          // Plans
          ..._plans.map((p) => GlassCard(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            gradient: (p['name'] == 'Pro') ? LinearGradient(colors: [DakkhoColors.primary, DakkhoColors.primaryDark]) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p['name'] as String,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                            color: (p['name'] == 'Pro') ? Colors.white : DakkhoColors.textPrimary)),
                    if (p['name'] == 'Pro')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                        child: const Text('POPULAR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('৳${_annual ? p['annualPrice'] : p['monthlyPrice']}',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900,
                            color: (p['name'] == 'Pro') ? Colors.white : (p['color'] as Color))),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('/ ${_annual ? 'year' : 'month'}',
                          style: TextStyle(fontSize: 12, color: (p['name'] == 'Pro') ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Features
                ...((p['features'] as List).map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(LucideIcons.check, size: 14, color: (p['name'] == 'Pro') ? Colors.white : DakkhoColors.success),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f as String,
                          style: TextStyle(fontSize: 12, color: (p['name'] == 'Pro') ? Colors.white : DakkhoColors.textPrimary, height: 1.4))),
                    ],
                  ),
                ))),
                if ((p['limitations'] as List).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...((p['limitations'] as List).map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.x, size: 14, color: DakkhoColors.danger),
                        const SizedBox(width: 8),
                        Expanded(child: Text(l as String, style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.4))),
                      ],
                    ),
                  ))),
                ],
                const SizedBox(height: 20),
                if (p['isCurrent'] == true)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: DakkhoColors.surfaceLight, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: DakkhoColors.glassCardBorder),
                    ),
                    child: Center(child: Text(p['cta'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary))),
                  )
                else
                  GradientButton(
                    label: p['cta'] as String,
                    icon: LucideIcons.arrowRight,
                    gradient: (p['name'] == 'Pro') ? DakkhoColors.accentGradient : DakkhoColors.primaryGradient,
                    onPressed: () => context.go('/app/explore'),
                  ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0)),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _annual = label == 'Annual'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? DakkhoColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : DakkhoColors.textSecondary)),
      ),
    );
  }
}
