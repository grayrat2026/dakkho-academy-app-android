import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});
  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  String _search = '';
  String? _expandedCategory;
  final Set<int> _expandedQuestions = {};

  static const _categories = [
    {
      'category': 'Getting Started',
      'icon': LucideIcons.rocket,
      'questions': [
        {'q': 'How do I create an account?', 'a': 'Tap "Sign Up" on the login screen. You\'ll need to provide your email, password, name, institute, and technology. We\'ll send an OTP to verify your email.'},
        {'q': 'How do I enroll in a course?', 'a': 'Browse courses from the Explore page or Home page. Tap a course to see its details. If it\'s free, tap "Enroll for Free". If paid, tap "Enroll" to proceed to checkout via PipraPay.'},
        {'q': 'Can I preview a course before enrolling?', 'a': 'Yes! Many courses have preview videos marked with an "eye" icon. Watch these for free to decide if the course is right for you.'},
        {'q': 'How do I verify my email?', 'a': 'After signup, you\'ll receive an OTP via email. Enter the 6-digit code in the verification screen. If you didn\'t receive it, tap "Resend OTP".'},
      ],
    },
    {
      'category': 'Account & Billing',
      'icon': LucideIcons.creditCard,
      'questions': [
        {'q': 'What payment methods do you accept?', 'a': 'We accept bKash, Nagad, Rocket, and bank cards via PipraPay. Cash-on-delivery is not available for digital courses.'},
        {'q': 'Can I get a refund?', 'a': 'Yes, within 7 days of purchase if you\'ve watched less than 25% of the course. Contact support with your transaction ID to request a refund.'},
        {'q': 'How do I change my password?', 'a': 'Go to Profile → Change Password. Enter your current password and the new one. We recommend using a strong password with at least 12 characters.'},
        {'q': 'How do I delete my account?', 'a': 'Go to Profile → Delete Account. This is a permanent action — all your data will be deleted. You\'ll need to confirm with your password.'},
      ],
    },
    {
      'category': 'Courses & Learning',
      'icon': LucideIcons.bookOpen,
      'questions': [
        {'q': 'Can I download videos for offline viewing?', 'a': 'Yes! Tap the download icon on any enrolled video. Downloads expire after 30 days and are encrypted with your device-bound key for security.'},
        {'q': 'How do I track my progress?', 'a': 'Your progress is automatically tracked. Visit the course page and tap "Progress" to see your stats, streak, and completion percentage.'},
        {'q': 'Can I access courses on multiple devices?', 'a': 'For security reasons, you can only be logged in on ONE device at a time. If you log in on a new device, the previous device will be automatically logged out.'},
        {'q': 'How long do I have access to a course?', 'a': 'Access depends on your package: Single (3 months), Duo (3 months, 2 users), or Lifetime (forever). Check your subscription in Profile → Subscription.'},
      ],
    },
    {
      'category': 'Technical Issues',
      'icon': LucideIcons.wrench,
      'questions': [
        {'q': 'Why is video streaming slow?', 'a': 'Check your internet connection. We recommend at least 4G or Wi-Fi for HD streaming. You can also lower quality in Settings → Video Quality.'},
        {'q': 'Why can\'t I take screenshots?', 'a': 'Screenshots are blocked for content protection. This is to prevent piracy and protect instructor intellectual property. This setting cannot be disabled.'},
        {'q': 'The app keeps crashing, what do I do?', 'a': 'Try: 1) Force close and reopen the app. 2) Clear cache in Settings → Network & Data. 3) Update to the latest version from Play Store. 4) If still crashing, report the issue via Help → Report Issue.'},
        {'q': 'How do I enable push notifications?', 'a': 'Go to Settings → Notifications and toggle "Push Notifications". You may also need to grant permission in your phone\'s Settings → Apps → DAKKHO Academy → Notifications.'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty
        ? _categories
        : _categories.map((cat) {
            final matching = (cat['questions'] as List).where((q) {
              final question = (q as Map)['q'] as String;
              return question.toLowerCase().contains(_search.toLowerCase());
            }).toList();
            return {...cat, 'questions': matching};
          }).where((cat) => (cat['questions'] as List).isNotEmpty).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('FAQ'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search FAQ...',
                prefixIcon: Icon(LucideIcons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? const EmptyState(icon: LucideIcons.searchX, title: 'No results', subtitle: 'Try a different search.')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final cat = filtered[i];
                final questions = (cat['questions'] as List).cast<Map<String, dynamic>>();
                final isExpanded = _expandedCategory == cat['category'];

                return GlassCard(
                  padding: EdgeInsets.zero,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(cat['icon'] as IconData, color: DakkhoColors.primary, size: 22),
                        title: Text(cat['category'] as String,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                        trailing: Icon(
                          isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                          color: DakkhoColors.textSecondary,
                        ),
                        onTap: () => setState(() {
                          _expandedCategory = isExpanded ? null : cat['category'] as String?;
                        }),
                      ),
                      if (isExpanded)
                        ...questions.asMap().entries.map((entry) {
                          final idx = '${i}_${entry.key}';
                          final hashCode = idx.hashCode;
                          final isQExpanded = _expandedQuestions.contains(hashCode);
                          final q = entry.value;
                          return Column(
                            children: [
                              const Divider(height: 1, indent: 16),
                              Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.only(left: 56, right: 16),
                                  title: Text(q['q'] as String,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                                  trailing: Icon(
                                    isQExpanded ? LucideIcons.minus : LucideIcons.plus,
                                    color: DakkhoColors.primary, size: 16,
                                  ),
                                  onExpansionChanged: (expanded) => setState(() {
                                    if (expanded) {
                                      _expandedQuestions.add(hashCode);
                                    } else {
                                      _expandedQuestions.remove(hashCode);
                                    }
                                  }),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
                                      child: Text(q['a'] as String,
                                          style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.6)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.05, end: 0);
              },
            ),
    );
  }
}
