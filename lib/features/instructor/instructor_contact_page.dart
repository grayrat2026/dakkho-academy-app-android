import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

class InstructorContactPage extends ConsumerStatefulWidget {
  const InstructorContactPage({super.key, required this.instructorId});
  final String instructorId;

  @override
  ConsumerState<InstructorContactPage> createState() => _InstructorContactPageState();
}

class _InstructorContactPageState extends ConsumerState<InstructorContactPage> {
  InstructorModel? _instructor;
  bool _isLoading = true;

  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _reason = 'general';
  String _priority = 'medium';
  bool _sending = false;

  static const _reasons = [
    ('general', 'General Question', LucideIcons.helpCircle),
    ('course', 'Course Content', LucideIcons.bookOpen),
    ('assignment', 'Assignment Help', LucideIcons.clipboardCheck),
    ('schedule', 'Schedule Conflict', LucideIcons.calendar),
    ('feedback', 'Feedback', LucideIcons.messageCircle),
    ('other', 'Other', LucideIcons.moreHorizontal),
  ];

  static const _priorities = [
    ('low', 'Low', DakkhoColors.textSecondary),
    ('medium', 'Medium', DakkhoColors.warning),
    ('high', 'High', DakkhoColors.danger),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = await ref.read(instructorApiProvider.future);
      _instructor = await api.get(widget.instructorId);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_subjectController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: DakkhoColors.warning),
      );
      return;
    }

    setState(() => _sending = true);

    // TODO: backend doesn't have /api/instructor-contact endpoint yet
    // Use /api/support/tickets as a fallback for now
    try {
      final supportApi = await ref.read(supportApiProvider.future);
      await supportApi.createTicket(
        name: _instructor?.name ?? 'Student',
        email: _instructor?.email ?? 'student@dakkho.pro.bd',
        subject: '[$_reason] ${_subjectController.text}',
        message: 'To: ${_instructor?.name}\nPriority: $_priority\n\n${_messageController.text}',
      );

      setState(() => _sending = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully! The instructor will reply via email.'),
          backgroundColor: DakkhoColors.success,
        ),
      );
      _subjectController.clear();
      _messageController.clear();
    } catch (e) {
      setState(() => _sending = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e'), backgroundColor: DakkhoColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Contact Instructor')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Contact Instructor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructor header card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: DakkhoColors.primary,
                    backgroundImage: _instructor?.avatarUrl.isNotEmpty == true ? NetworkImage(_instructor!.avatarUrl) : null,
                    child: _instructor?.avatarUrl.isEmpty == true
                        ? Text(_instructor?.name.isNotEmpty == true ? _instructor!.name[0] : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_instructor?.name ?? 'Instructor',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                        Text(_instructor?.specialization ?? '',
                            style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Reason selector
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reason for contact',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _reasons.map((r) {
                      final selected = _reason == r.$1;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(r.$3, size: 14, color: selected ? Colors.white : DakkhoColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(r.$2),
                          ],
                        ),
                        selected: selected,
                        onSelected: (_) => setState(() => _reason = r.$1),
                        selectedColor: DakkhoColors.primary,
                        labelStyle: TextStyle(color: selected ? Colors.white : DakkhoColors.textPrimary, fontSize: 12),
                      ).animate().fadeIn(delay: 50.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: DakkhoAnimations.normal, curve: DakkhoAnimations.elastic);
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Priority selector
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priority',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
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

            const SizedBox(height: 16),

            // Subject
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Subject',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      hintText: 'Brief summary of your message...',
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Message
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Message',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Type your message here...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Send button
            GradientButton(
              label: _sending ? 'Sending...' : 'Send Message',
              icon: LucideIcons.send,
              isLoading: _sending,
              onPressed: _sending ? null : _sendMessage,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
