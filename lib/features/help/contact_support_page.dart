import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/stores/auth_store.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

class ContactSupportPage extends ConsumerStatefulWidget {
  const ContactSupportPage({super.key});
  @override
  ConsumerState<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends ConsumerState<ContactSupportPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'technical';
  String _priority = 'medium';
  bool _isSubmitting = false;

  static const _categories = [
    ('technical', 'Technical Issue', LucideIcons.bug),
    ('billing', 'Billing & Payments', LucideIcons.creditCard),
    ('account', 'Account Issue', LucideIcons.user),
    ('course', 'Course Content', LucideIcons.bookOpen),
    ('feature', 'Feature Request', LucideIcons.lightbulb),
    ('other', 'Other', LucideIcons.moreHorizontal),
  ];

  static const _priorities = [
    ('low', 'Low', DakkhoColors.textSecondary, 'General question'),
    ('medium', 'Medium', DakkhoColors.warning, 'Need help soon'),
    ('high', 'High', DakkhoColors.danger, 'Blocking my learning'),
  ];

  Future<void> _submit() async {
    if (_subjectController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: DakkhoColors.warning),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(authProvider).user;
      final api = await ref.read(supportApiProvider.future);
      await api.createTicket(
        name: user?.name ?? 'Student',
        email: user?.email ?? 'unknown@dakkho.pro.bd',
        subject: '[$_category] ${_subjectController.text}',
        message: 'Priority: $_priority\n\n${_messageController.text}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket created! We\'ll reply via email within 24 hours.'),
          backgroundColor: DakkhoColors.success,
        ),
      );
      _subjectController.clear();
      _messageController.clear();
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: DakkhoColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Contact Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(LucideIcons.headphones, color: DakkhoColors.primary, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('We\'re here to help!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                        Text('Average response time: 24 hours', style: TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Category
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _categories.map((c) {
                      final selected = _category == c.$1;
                      return ChoiceChip(
                        label: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(c.$3, size: 14, color: selected ? Colors.white : DakkhoColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(c.$2),
                        ]),
                        selected: selected,
                        onSelected: (_) => setState(() => _category = c.$1),
                        selectedColor: DakkhoColors.primary,
                        labelStyle: TextStyle(color: selected ? Colors.white : DakkhoColors.textPrimary, fontSize: 12),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Priority
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: _priorities.map((p) {
                      final selected = _priority == p.$1;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(width: 8, height: 8, decoration: BoxDecoration(color: p.$3, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(p.$2),
                              ],
                            ),
                            selected: selected,
                            onSelected: (_) => setState(() => _priority = p.$1),
                            selectedColor: p.$3,
                            labelStyle: TextStyle(color: selected ? Colors.white : DakkhoColors.textPrimary, fontSize: 12),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Subject
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Subject', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(hintText: 'Brief summary of your issue'),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Message
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Describe your issue in detail. Include any error messages, screenshots, or steps to reproduce.',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            GradientButton(
              label: _isSubmitting ? 'Submitting...' : 'Submit Ticket',
              icon: LucideIcons.send,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
