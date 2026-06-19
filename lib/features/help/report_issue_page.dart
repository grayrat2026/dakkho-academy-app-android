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

class ReportIssuePage extends ConsumerStatefulWidget {
  const ReportIssuePage({super.key});
  @override
  ConsumerState<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends ConsumerState<ReportIssuePage> {
  final _titleController = TextEditingController();
  final _reproController = TextEditingController();
  final _expectedController = TextEditingController();
  final _actualController = TextEditingController();
  String _severity = 'medium';
  String _type = 'bug';
  bool _isSubmitting = false;

  static const _types = [
    ('bug', 'Bug', LucideIcons.bug),
    ('crash', 'App Crash', LucideIcons.alertOctagon),
    ('glitch', 'Visual Glitch', LucideIcons.eye),
    ('performance', 'Performance', LucideIcons.gauge),
    ('security', 'Security Issue', LucideIcons.shield),
  ];

  static const _severities = [
    ('low', 'Low', DakkhoColors.textSecondary, 'Minor — barely noticeable'),
    ('medium', 'Medium', DakkhoColors.warning, 'Noticeable — affects experience'),
    ('high', 'High', DakkhoColors.danger, 'Severe — blocks usage'),
  ];

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title'), backgroundColor: DakkhoColors.warning),
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
        subject: '[BUG-$_type-$_severity] ${_titleController.text}',
        message: '''
Type: $_type
Severity: $_severity

Steps to reproduce:
${_reproController.text}

Expected behavior:
${_expectedController.text}

Actual behavior:
${_actualController.text}

App version: ${const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0')}
Flavor: ${const String.fromEnvironment('APP_FLAVOR', defaultValue: 'prod')}
Platform: Android
''',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bug report submitted! Thank you.'), backgroundColor: DakkhoColors.success),
      );
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
    _titleController.dispose();
    _reproController.dispose();
    _expectedController.dispose();
    _actualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Report Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(LucideIcons.bug, color: DakkhoColors.danger, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Report a Bug', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                        Text('Help us fix issues faster', style: TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Type
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Issue Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _types.map((t) {
                      final selected = _type == t.$1;
                      return ChoiceChip(
                        label: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(t.$3, size: 14, color: selected ? Colors.white : DakkhoColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(t.$2),
                        ]),
                        selected: selected,
                        onSelected: (_) => setState(() => _type = t.$1),
                        selectedColor: DakkhoColors.danger,
                        labelStyle: TextStyle(color: selected ? Colors.white : DakkhoColors.textPrimary, fontSize: 12),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Severity
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Severity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 12),
                  Column(
                    children: _severities.map((s) {
                      return RadioListTile<String>(
                        value: s.$1, groupValue: _severity,
                        onChanged: (v) => setState(() => _severity = v ?? 'medium'),
                        title: Row(
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: s.$3, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(s.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            Text(s.$4, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                          ],
                        ),
                        activeColor: DakkhoColors.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Title
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Issue Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Brief summary of the issue'),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Steps to reproduce
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Steps to Reproduce', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reproController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: '1. Open the app\n2. Tap on...\n3. See error',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Expected vs Actual
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Expected', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.success)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _expectedController,
                          maxLines: 3,
                          decoration: const InputDecoration(hintText: 'What should happen'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Actual', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DakkhoColors.danger)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _actualController,
                          maxLines: 3,
                          decoration: const InputDecoration(hintText: 'What actually happens'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            GradientButton(
              label: _isSubmitting ? 'Submitting...' : 'Submit Report',
              icon: LucideIcons.send,
              gradient: DakkhoColors.dangerGradient,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
