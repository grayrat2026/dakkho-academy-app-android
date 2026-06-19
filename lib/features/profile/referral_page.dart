import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/stores/auth_store.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/empty_state.dart';

class ReferralPage extends ConsumerWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final referralCode = 'DAKKHO-${user?.id.substring(0, 6).toUpperCase() ?? 'XXXXXX'}';
    final referralLink = 'https://dakkho-student.pages.dev/signup?ref=$referralCode';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Referral Program')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero card
          GlassCard(
            padding: const EdgeInsets.all(24),
            gradient: DakkhoColors.primaryGradient,
            child: Column(
              children: [
                const Icon(LucideIcons.gift, color: Colors.white, size: 56)
                    .animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: DakkhoAnimations.slow, curve: DakkhoAnimations.elastic),
                const SizedBox(height: 16),
                const Text('Invite friends, earn rewards!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Get ৳50 credit for every friend who enrolls in a paid course using your referral link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 16),

          // Referral code + link
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.ticket, size: 18, color: DakkhoColors.primary),
                    const SizedBox(width: 8),
                    const Text('Your Referral Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DakkhoColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DakkhoColors.primary.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          referralCode,
                          style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800,
                            color: DakkhoColors.primary, fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.copy, color: DakkhoColors.primary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: referralCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code copied!'), backgroundColor: DakkhoColors.success),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(LucideIcons.link, size: 18, color: DakkhoColors.primary),
                    const SizedBox(width: 8),
                    const Text('Referral Link', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DakkhoColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          referralLink,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary, fontFamily: 'monospace'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.copy, color: DakkhoColors.primary, size: 16),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: referralLink));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copied!'), backgroundColor: DakkhoColors.success),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Share Referral Link',
                  icon: LucideIcons.share2,
                  onPressed: () {
                    // TODO: Use share_plus package when added
                    Clipboard.setData(ClipboardData(text: 'Join me on DAKKHO Academy! Use my referral link: $referralLink'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Referral message copied to clipboard!'), backgroundColor: DakkhoColors.success),
                    );
                  },
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Reward tiers
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.trophy, size: 18, color: DakkhoColors.warning),
                    const SizedBox(width: 8),
                    const Text('Reward Tiers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                _rewardRow(1, '1st referral', '৳50 credit'),
                _rewardRow(2, '5 referrals', '৳300 credit + 1 month free'),
                _rewardRow(3, '10 referrals', '৳700 credit + 3 months free'),
                _rewardRow(4, '25 referrals', '৳2000 credit + 1 year free'),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Activity (empty)
          const EmptyState(
            icon: LucideIcons.users,
            title: 'No referrals yet',
            subtitle: 'Share your link to start earning rewards!',
          ),
        ],
      ),
    );
  }

  Widget _rewardRow(int idx, String milestone, String reward) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: DakkhoColors.warning,
            child: Text('$idx', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(milestone, style: const TextStyle(fontSize: 13, color: DakkhoColors.textPrimary, fontWeight: FontWeight.w500)),
          ),
          Text(reward, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.warning)),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * idx)).slideX(begin: 0.05, end: 0);
  }
}
