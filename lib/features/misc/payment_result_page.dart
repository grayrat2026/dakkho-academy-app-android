import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/stores/auth_store.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../data/api/auth_api.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// PaymentResultPage — post-payment callback page.
///
/// After PipraPay redirect, the URL contains ?pp_id=XXX (the PipraPay transaction ID).
/// This page:
///   1. Reads pp_id from the URL (via GoRouter query param)
///   2. Calls POST /api/payments/verify { pp_id } to verify the payment
///   3. Polls every 3 seconds for up to 60 seconds (PipraPay webhooks can be delayed)
///   4. Shows success / pending / failed state with appropriate CTA
///   5. On success: triggers cache invalidation so user sees "enrolled" immediately
class PaymentResultPage extends ConsumerStatefulWidget {
  const PaymentResultPage({super.key, this.ppId, this.paymentId});
  final String? ppId;
  final int? paymentId;

  @override
  ConsumerState<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends ConsumerState<PaymentResultPage> {
  String _status = 'verifying';  // verifying | pending | completed | failed
  String? _errorMessage;
  int _pollCount = 0;
  String? _enrolledCourseId;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    if (widget.ppId == null && widget.paymentId == null) {
      setState(() {
        _status = 'failed';
        _errorMessage = 'No payment ID found in URL. Please contact support.';
      });
      return;
    }

    try {
      final api = await ref.read(paymentApiProvider.future);
      final result = await api.verify(ppId: widget.ppId, paymentId: widget.paymentId);

      setState(() {
        _status = result.status;
        _enrolledCourseId = result.enrolledCourseId;
        if (result.status == 'failed') {
          _errorMessage = result.message ?? 'Payment failed. Please try again.';
        }
      });

      // If pending, poll again after 3 seconds (max 20 attempts = 60 seconds)
      if (result.status == 'pending' && _pollCount < 20) {
        _pollCount++;
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) _verify();
      }

      // If completed, refresh user + enrollment caches
      if (result.status == 'completed' || result.status == 'verified') {
        await _onPaymentSuccess();
      }
    } catch (e) {
      setState(() {
        _status = 'failed';
        _errorMessage = 'Verification error: $e';
      });
    }
  }

  Future<void> _onPaymentSuccess() async {
    // Refresh user (to get updated packages)
    try {
      final authApi = await ref.read(authApiProvider.future);
      final user = await authApi.me();
      if (user != null) {
        await ref.read(authProvider.notifier).refreshUser(user);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DakkhoColors.bgDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_status) {
      case 'verifying':
        return _buildVerifying();
      case 'pending':
        return _buildPending();
      case 'completed':
      case 'verified':
        return _buildSuccess();
      case 'failed':
        return _buildFailed();
      default:
        return _buildVerifying();
    }
  }

  Widget _buildVerifying() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 80, height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(DakkhoColors.primary),
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        const Text('Verifying Payment...',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('Please wait while we confirm your payment with PipraPay.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: DakkhoColors.textSecondary)),
        const SizedBox(height: 16),
        if (widget.ppId != null)
          Text('Transaction ID: ${widget.ppId}',
              style: const TextStyle(fontSize: 11, color: DakkhoColors.textMuted, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildPending() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: DakkhoColors.warning.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.clock, color: DakkhoColors.warning, size: 48),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(1, 1), end: const Offset(1.1, 1.1),
          duration: const Duration(seconds: 1),
        ),
        const SizedBox(height: 24),
        const Text('Payment Pending',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('Your payment is being processed. This usually takes 1-5 minutes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: DakkhoColors.textSecondary, height: 1.5)),
        const SizedBox(height: 16),
        Text('Attempt $_pollCount of 20',
            style: const TextStyle(fontSize: 11, color: DakkhoColors.textMuted)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => context.go('/app/home'),
              icon: const Icon(LucideIcons.home, size: 16),
              label: const Text('Go Home'),
            ),
            const SizedBox(width: 12),
            GradientButton(
              label: 'Check Again',
              icon: LucideIcons.refreshCw,
              onPressed: () {
                setState(() {
                  _status = 'verifying';
                  _pollCount = 0;
                });
                _verify();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            gradient: DakkhoColors.accentGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.check, color: Colors.white, size: 56),
        ).animate().scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: DakkhoAnimations.slow,
          curve: DakkhoAnimations.elastic,
        ),
        const SizedBox(height: 24),
        const Text('Payment Successful!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary))
            .animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        const Text('You\'re now enrolled. Start learning right away!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: DakkhoColors.textSecondary, height: 1.5))
            .animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

        if (widget.ppId != null) ...[
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Transaction Receipt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                const SizedBox(height: 8),
                _receiptRow('Transaction ID', widget.ppId!),
                _receiptRow('Status', 'Completed'),
                _receiptRow('Date', DateTime.now().toString().substring(0, 16)),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
        ],

        const SizedBox(height: 32),
        // Confetti effect (simple visual burst)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(LucideIcons.partyPopper, color: [DakkhoColors.warning, DakkhoColors.accent, DakkhoColors.primary, DakkhoColors.purple, DakkhoColors.danger][i], size: 20),
          ).animate(delay: Duration(milliseconds: 800 + i * 100)).scale(
            begin: const Offset(0, 0),
            end: const Offset(1.2, 1.2),
            duration: const Duration(milliseconds: 400),
            curve: DakkhoAnimations.elastic,
          )),
        ),
        const SizedBox(height: 24),

        GradientButton(
          label: _enrolledCourseId != null ? 'Start Learning' : 'Go to My Courses',
          icon: LucideIcons.play,
          onPressed: () {
            if (_enrolledCourseId != null) {
              context.go('/app/course/$_enrolledCourseId');
            } else {
              context.go('/app/my-courses');
            }
          },
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        TextButton(onPressed: () => context.go('/app/home'), child: const Text('Back to Home')),
      ],
    );
  }

  Widget _buildFailed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            gradient: DakkhoColors.dangerGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.x, color: Colors.white, size: 56),
        ).animate().scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: DakkhoAnimations.slow,
          curve: DakkhoAnimations.elastic,
        ),
        const SizedBox(height: 24),
        const Text('Payment Failed',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? 'Your payment could not be processed. Please try again or contact support.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: DakkhoColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 32),
        GradientButton(
          label: 'Try Again',
          icon: LucideIcons.rotateCw,
          gradient: DakkhoColors.dangerGradient,
          onPressed: () => context.go('/app/explore'),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context.go('/app/help/contact-support'),
          icon: const Icon(LucideIcons.headphones, size: 14),
          label: const Text('Contact Support'),
        ),
      ],
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
