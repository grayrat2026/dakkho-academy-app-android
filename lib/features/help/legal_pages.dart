import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';

/// Shared layout for long-form legal/policy pages.
/// Used by: TermsOfServicePage, PrivacyPolicyPage, RefundPolicyPage.
class PolicyPageTemplate extends StatelessWidget {
  const PolicyPageTemplate({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
    this.accentColor = DakkhoColors.primary,
  });

  final String title;
  final String lastUpdated;
  final List<PolicySection> sections;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(title)),
      body: Row(
        children: [
          // Sticky section navigation (landscape/tablet only)
          if (MediaQuery.of(context).size.width > 700)
            Container(
              width: 240,
              color: DakkhoColors.bgDark,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sections.length,
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: InkWell(
                      onTap: () => Scrollable.ensureVisible(
                        context,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text('${i + 1}',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accentColor)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                sections[i].title,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 30 * i)).slideX(begin: 0.1, end: 0);
                },
              ),
            ),

          // Main content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sections.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 16),
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text('Last updated: $lastUpdated',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0);
                }
                final section = sections[i - 1];
                return GlassCard(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('$i',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: accentColor)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(section.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...section.paragraphs.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(p, style: const TextStyle(fontSize: 13, color: DakkhoColors.textSecondary, height: 1.6)),
                      )),
                      if (section.bullets.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...section.bullets.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 6, left: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(LucideIcons.dot, color: accentColor, size: 18),
                              const SizedBox(width: 4),
                              Expanded(child: Text(b, style: const TextStyle(fontSize: 12, color: DakkhoColors.textPrimary, height: 1.5))),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.05, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PolicySection {
  const PolicySection({required this.title, required this.paragraphs, this.bullets = const []});
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}

// ─────────────────────────────────────────────────────────────
// Terms of Service
// ─────────────────────────────────────────────────────────────
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PolicyPageTemplate(
      title: 'Terms of Service',
      lastUpdated: 'June 19, 2026',
      sections: [
        PolicySection(
          title: 'Acceptance of Terms',
          paragraphs: [
            'By creating an account or using DAKKHO Academy ("we", "us", "our"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, please do not use our services.',
            'These Terms constitute a legally binding agreement between you and DAKKHO Academy. We may update these Terms from time to time, and we will notify you of any significant changes via email or in-app notification.',
          ],
        ),
        PolicySection(
          title: 'Eligibility',
          paragraphs: [
            'You must be at least 16 years old to use DAKKHO Academy. By using our services, you represent and warrant that you meet this age requirement and have the legal capacity to enter into these Terms.',
            'DAKKHO Academy is designed for polytechnic students in Bangladesh. While anyone can use the platform, content is specifically tailored to the Bangladeshi polytechnic curriculum.',
          ],
        ),
        PolicySection(
          title: 'Account Registration',
          paragraphs: [
            'To access most features, you must register for an account. You agree to:',
          ],
          bullets: [
            'Provide accurate, current, and complete information',
            'Maintain the security of your password',
            'Notify us immediately of any unauthorized access',
            'Be responsible for all activities under your account',
            'Use only ONE device at a time (single-device login is enforced)',
          ],
        ),
        PolicySection(
          title: 'Acceptable Use',
          paragraphs: [
            'You agree NOT to:',
          ],
          bullets: [
            'Share your account credentials with others',
            'Attempt to bypass our content protection measures',
            'Record, screenshot, or redistribute course content',
            'Use the service for any illegal or unauthorized purpose',
            'Interfere with the proper functioning of the service',
            'Attempt to reverse engineer or extract video streams',
          ],
        ),
        PolicySection(
          title: 'Paid Courses & Payments',
          paragraphs: [
            'Some courses require payment. All payments are processed through PipraPay, our third-party payment processor. By making a purchase, you agree to PipraPay\'s terms as well.',
            'Upon successful payment, you will be granted access to the purchased course for the duration specified in your package (typically 3 months for standard packages, lifetime for lifetime packages).',
          ],
        ),
        PolicySection(
          title: 'Refund Policy',
          paragraphs: [
            'We offer a 7-day refund window for paid courses, provided you have watched less than 25% of the course content. See our full Refund Policy for details.',
          ],
        ),
        PolicySection(
          title: 'Content Ownership',
          paragraphs: [
            'All course content, including videos, PDFs, and other materials, is the intellectual property of DAKKHO Academy and our instructors. You may not:',
          ],
          bullets: [
            'Distribute, copy, or reproduce content without permission',
            'Use content for commercial purposes other than personal learning',
            'Modify, adapt, or create derivative works',
            'Remove any copyright or proprietary notices',
          ],
        ),
        PolicySection(
          title: 'Content Protection',
          paragraphs: [
            'We employ various technical measures to protect content, including:',
          ],
          bullets: [
            'Single-device login enforcement',
            'Screenshot and screen recording block (FLAG_SECURE)',
            'AES-256-GCM encryption for downloaded videos',
            '5-minute rotating HLS stream tokens',
            '7-day cooldown on device switches',
          ],
        ),
        PolicySection(
          title: 'Termination',
          paragraphs: [
            'We reserve the right to suspend or terminate your account if you violate these Terms. You may delete your account at any time from Settings → Account → Delete Account.',
            'Upon termination, all your data will be permanently deleted within 30 days, except where retention is required by law.',
          ],
        ),
        PolicySection(
          title: 'Disclaimer',
          paragraphs: [
            'DAKKHO Academy is provided "as is" without warranties of any kind. We do not guarantee that the service will be uninterrupted, secure, or error-free.',
            'We are not responsible for any academic outcomes resulting from the use of our platform. Course completion does not guarantee academic success.',
          ],
        ),
        PolicySection(
          title: 'Contact',
          paragraphs: [
            'If you have questions about these Terms, please contact us at:',
          ],
          bullets: [
            'Email: legal@dakkho.pro.bd',
            'Support: support@dakkho.pro.bd',
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Privacy Policy
// ─────────────────────────────────────────────────────────────
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PolicyPageTemplate(
      title: 'Privacy Policy',
      lastUpdated: 'June 19, 2026',
      accentColor: DakkhoColors.accent,
      sections: [
        PolicySection(
          title: 'Introduction',
          paragraphs: [
            'DAKKHO Academy ("we", "us", "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your personal information when you use our mobile application and services.',
            'By using DAKKHO Academy, you consent to the data practices described in this policy.',
          ],
        ),
        PolicySection(
          title: 'Information We Collect',
          paragraphs: [
            'We collect the following types of information:',
          ],
          bullets: [
            'Account information: name, email, password (hashed), phone (optional)',
            'Profile information: institute, technology, semester, bio, avatar',
            'Learning data: course progress, watch history, bookmarks, notes',
            'Device information: device UUID (app-generated), device model, Android version',
            'Usage data: features used, time spent, errors encountered',
            'Payment data: processed by PipraPay — we do NOT store card details',
          ],
        ),
        PolicySection(
          title: 'How We Use Your Information',
          paragraphs: [
            'We use your information to:',
          ],
          bullets: [
            'Provide and improve our educational services',
            'Track your learning progress and recommend relevant courses',
            'Process payments and manage subscriptions',
            'Send notifications about new courses, live sessions, and announcements',
            'Enforce single-device login and content protection',
            'Respond to support requests and resolve issues',
            'Comply with legal obligations',
          ],
        ),
        PolicySection(
          title: 'Data Storage & Security',
          paragraphs: [
            'Your data is stored securely using industry-standard practices:',
          ],
          bullets: [
            'Database: Cloudflare D1 (SQLite) with encryption at rest',
            'File storage: Cloudflare R2 with private access controls',
            'Authentication tokens: Android Keystore-backed secure storage',
            'Downloaded videos: AES-256-GCM encrypted with device-bound keys',
            'All data in transit: HTTPS with certificate pinning (planned)',
            'No data is stored on third-party servers (no Firebase, no analytics)',
          ],
        ),
        PolicySection(
          title: 'Single-Device Login',
          paragraphs: [
            'For content protection, we enforce single-device login. This means:',
          ],
          bullets: [
            'Only one device can be logged into your account at a time',
            'When you log in on a new device, the previous device is automatically logged out',
            'Your device UUID (stored in Android Keystore) identifies your device',
            'Previous device\'s local data (downloads, cache) is wiped on next sync',
          ],
        ),
        PolicySection(
          title: 'Data Sharing',
          paragraphs: [
            'We do NOT sell or rent your personal data. We share data only with:',
          ],
          bullets: [
            'PipraPay: for payment processing (transaction ID, amount)',
            'OneSignal: for push notifications (player ID, device info)',
            'Resend: for transactional emails (email, name)',
            'Cloudflare: for content delivery and database hosting',
            'Law enforcement: when required by Bangladeshi law',
          ],
        ),
        PolicySection(
          title: 'Your Rights',
          paragraphs: [
            'Under the Bangladesh Digital Security Act and general data protection principles, you have the right to:',
          ],
          bullets: [
            'Access your personal data (request a copy)',
            'Correct inaccurate data',
            'Delete your account and all associated data',
            'Opt out of marketing communications',
            'Object to processing of your data',
            'Data portability (export your data in JSON format)',
          ],
        ),
        PolicySection(
          title: 'Data Retention',
          paragraphs: [
            'We retain your data for as long as your account is active. After account deletion:',
          ],
          bullets: [
            'Profile and account data: deleted within 30 days',
            'Course progress and watch history: deleted within 30 days',
            'Payment records: retained for 7 years for tax compliance (anonymized)',
            'Support tickets: retained for 1 year for quality assurance',
            'Downloaded videos: immediately deleted from your device',
          ],
        ),
        PolicySection(
          title: 'Children\'s Privacy',
          paragraphs: [
            'DAKKHO Academy is intended for polytechnic students aged 16 and above. We do not knowingly collect data from children under 16. If we become aware that we have collected such data, we will delete it immediately.',
          ],
        ),
        PolicySection(
          title: 'Cookies & Tracking',
          paragraphs: [
            'Our mobile app does not use cookies. We use OneSignal for push notifications, which assigns a unique player ID to your device for delivering notifications.',
          ],
        ),
        PolicySection(
          title: 'Changes to This Policy',
          paragraphs: [
            'We may update this Privacy Policy from time to time. We will notify you of significant changes via email or in-app notification at least 30 days before the changes take effect.',
          ],
        ),
        PolicySection(
          title: 'Contact',
          paragraphs: [
            'For privacy-related questions or to exercise your data rights, contact us at:',
          ],
          bullets: [
            'Email: privacy@dakkho.pro.bd',
            'Data Protection Officer: dpo@dakkho.pro.bd',
            'Mailing address: DAKKHO Academy, Dhaka, Bangladesh',
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Refund Policy
// ─────────────────────────────────────────────────────────────
class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PolicyPageTemplate(
      title: 'Refund Policy',
      lastUpdated: 'June 19, 2026',
      accentColor: DakkhoColors.warning,
      sections: [
        PolicySection(
          title: 'Refund Eligibility',
          paragraphs: [
            'We want you to be satisfied with your purchase. If you\'re not, we offer refunds under the following conditions:',
          ],
          bullets: [
            'Refund request must be made within 7 days of purchase',
            'You must have watched less than 25% of the course content',
            'The course must not be marked as "completed"',
            'The refund request must be made via the same email used for purchase',
          ],
        ),
        PolicySection(
          title: 'Non-Refundable Cases',
          paragraphs: [
            'The following are NOT eligible for refunds:',
          ],
          bullets: [
            'Courses purchased more than 7 days ago',
            'Courses where 25% or more content has been watched',
            'Courses purchased with a discount coupon (50%+ off)',
            'Subscription packages (single/duo/group) after 7 days',
            'Lifetime access packages (final sale)',
            'Courses that have been completed',
            'Account ban due to Terms of Service violation',
          ],
        ),
        PolicySection(
          title: 'How to Request a Refund',
          paragraphs: [
            'To request a refund:',
          ],
          bullets: [
            'Go to Help → Contact Support',
            'Select "Billing & Payments" as category',
            'Select "High" priority',
            'Include your transaction ID (found in Profile → Subscription)',
            'State the reason for refund',
            'Submit the ticket — we\'ll respond within 24 hours',
          ],
        ),
        PolicySection(
          title: 'Processing Time',
          paragraphs: [
            'Once approved, refunds are processed as follows:',
          ],
          bullets: [
            'bKash: 3-5 business days',
            'Nagad: 3-5 business days',
            'Rocket: 5-7 business days',
            'Bank cards: 7-14 business days',
          ],
        ),
        PolicySection(
          title: 'Refund Method',
          paragraphs: [
            'Refunds are issued to the original payment method. We do not offer refunds to different payment methods or accounts.',
            'If the original payment method is no longer valid, please contact support for alternative arrangements.',
          ],
        ),
        PolicySection(
          title: 'Partial Refunds',
          paragraphs: [
            'In some cases, we may offer partial refunds:',
          ],
          bullets: [
            'If you\'ve watched 25-50% of the course: 50% refund',
            'If technical issues prevented you from accessing the course: 100% refund',
            'If the course was significantly different from its description: 100% refund',
          ],
        ),
        PolicySection(
          title: 'Subscription Cancellation',
          paragraphs: [
            'If you have an active subscription and want to cancel:',
          ],
          bullets: [
            'You can cancel anytime from Profile → Subscription',
            'You retain access until the end of your billing period',
            'No prorated refunds for partial months',
            'Lifetime subscriptions cannot be cancelled (already paid in full)',
          ],
        ),
        PolicySection(
          title: 'Dispute Resolution',
          paragraphs: [
            'If you\'re not satisfied with our refund decision, you can:',
          ],
          bullets: [
            'Email: disputes@dakkho.pro.bd to escalate',
            'Contact Bangladesh Consumer Protection Agency',
            'File a complaint with your bank (for card payments)',
          ],
        ),
        PolicySection(
          title: 'Contact',
          paragraphs: [
            'For refund-related questions, contact us at:',
          ],
          bullets: [
            'Email: refunds@dakkho.pro.bd',
            'Support ticket: Help → Contact Support → Billing & Payments',
          ],
        ),
      ],
    );
  }
}
