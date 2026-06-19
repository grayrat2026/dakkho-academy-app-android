import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// FeedbackPage — feedback + feature requests + bug reports with voting.
/// Backend: TODO — /api/feedback doesn't exist yet. In-memory sample data.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _feedbackController = TextEditingController();
  int _rating = 5;

  final List<Map<String, dynamic>> _featureRequests = [
    {'title': 'Dark mode for video player', 'description': 'A dedicated dark theme for the video player would be great for night-time studying.', 'votes': 24, 'status': 'planned', 'hasVoted': false},
    {'title': 'Offline flashcards', 'description': 'Ability to create and study flashcards offline, syncing when online.', 'votes': 18, 'status': 'in_progress', 'hasVoted': true},
    {'title': 'Course comparison tool', 'description': 'Compare two courses side-by-side to decide which one to enroll in.', 'votes': 12, 'status': 'under_review', 'hasVoted': false},
    {'title': 'Apple Watch app', 'description': 'Get notifications and track study streak from Apple Watch.', 'votes': 5, 'status': 'released', 'hasVoted': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Feedback'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Feedback'),
            Tab(text: 'Feature Requests'),
            Tab(text: 'Bug Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedbackTab(),
          _buildFeatureRequestsTab(),
          _buildBugReportsTab(),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          gradient: DakkhoColors.primaryGradient,
          child: Column(
            children: [
              const Icon(LucideIcons.messageCircle, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              const Text('How was your experience?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Your feedback helps us improve DAKKHO Academy.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        const SizedBox(height: 16),
        // Star rating
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Rate us', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(LucideIcons.star, size: 40,
                        color: i < _rating ? DakkhoColors.warning : DakkhoColors.surfaceLighter,
                        fill: i < _rating ? 1.0 : 0.0),
                  ).animate(target: i < _rating ? 1 : 0).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: const Duration(milliseconds: 150),
                  ),
                )),
              ),
              const SizedBox(height: 4),
              Text(_ratingLabel(_rating), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DakkhoColors.warning)),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        // Feedback text
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Your feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Tell us what you think...'),
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: 'Submit Feedback',
                icon: LucideIcons.send,
                onPressed: () {
                  if (_feedbackController.text.trim().isEmpty) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: DakkhoColors.success),
                  );
                  _feedbackController.clear();
                  setState(() => _rating = 5);
                },
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildFeatureRequestsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _featureRequests.length,
      itemBuilder: (_, i) {
        final f = _featureRequests[i];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vote button
              GestureDetector(
                onTap: () => setState(() {
                  f['hasVoted'] = !f['hasVoted'];
                  f['votes'] += f['hasVoted'] ? 1 : -1;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: f['hasVoted'] ? DakkhoColors.primary : DakkhoColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: f['hasVoted'] ? DakkhoColors.primary : DakkhoColors.glassCardBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(LucideIcons.chevronUp, size: 16, color: f['hasVoted'] ? Colors.white : DakkhoColors.textSecondary),
                      Text('${f['votes']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: f['hasVoted'] ? Colors.white : DakkhoColors.textPrimary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(f['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary))),
                        _statusBadge(f['status'] as String),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(f['description'], style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildBugReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 40),
        const Center(child: Icon(LucideIcons.bug, size: 64, color: DakkhoColors.danger)).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: DakkhoAnimations.slow, curve: DakkhoAnimations.elastic),
        const SizedBox(height: 16),
        const Center(child: Text('Found a bug?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary))),
        const SizedBox(height: 8),
        const Center(child: Text('Help us fix it by reporting the issue.', style: TextStyle(fontSize: 13, color: DakkhoColors.textSecondary))),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Report a Bug',
          icon: LucideIcons.bug,
          gradient: DakkhoColors.dangerGradient,
          onPressed: () {}, // Navigate to /app/help/report-issue
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
      ],
    );
  }

  String _ratingLabel(int r) => switch (r) {
    1 => 'Poor',
    2 => 'Fair',
    3 => 'Good',
    4 => 'Very Good',
    5 => 'Excellent!',
    _ => '',
  };

  Widget _statusBadge(String status) {
    final (label, color) = switch (status) {
      'planned' => ('PLANNED', DakkhoColors.warning),
      'in_progress' => ('IN PROGRESS', DakkhoColors.primary),
      'under_review' => ('UNDER REVIEW', DakkhoColors.purple),
      'released' => ('RELEASED', DakkhoColors.success),
      _ => (status.toUpperCase(), DakkhoColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
    );
  }
}
