import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

/// RoadmapPage — product roadmap with released/in-progress/planned features + voting.
/// Backend: TODO — /api/roadmap doesn't exist yet. In-memory sample data.
class RoadmapPage extends StatefulWidget {
  const RoadmapPage({super.key});
  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _allFeatures = [
    // Released
    {'title': 'Single-Device Login', 'description': 'Anti-piracy: only one device can be logged in at a time.', 'status': 'released', 'votes': 0, 'releaseDate': 'v1.0.0', 'hasVoted': false},
    {'title': 'Encrypted Downloads', 'description': 'AES-256-GCM encrypted video downloads with 30-day TTL.', 'status': 'released', 'votes': 0, 'releaseDate': 'v1.0.0', 'hasVoted': false},
    {'title': 'Glassmorphism UI', 'description': 'Modern glassmorphism dark theme with Framer Motion animations.', 'status': 'released', 'votes': 0, 'releaseDate': 'v1.0.0', 'hasVoted': false},
    // In Progress
    {'title': 'iOS App', 'description': 'Native iOS app using the same Flutter codebase.', 'status': 'in_progress', 'votes': 87, 'releaseDate': 'Q3 2026', 'hasVoted': false},
    {'title': 'Offline Flashcards', 'description': 'Create and study flashcards offline, sync when online.', 'status': 'in_progress', 'votes': 42, 'releaseDate': 'Q2 2026', 'hasVoted': true},
    {'title': 'AI Tutor', 'description': 'Personalized AI tutor that answers your subject questions 24/7.', 'status': 'in_progress', 'votes': 64, 'releaseDate': 'Q3 2026', 'hasVoted': false},
    // Planned
    {'title': 'Live Group Classes', 'description': 'Join small-group live classes with instructor interaction.', 'status': 'planned', 'votes': 35, 'releaseDate': 'Q4 2026', 'hasVoted': false},
    {'title': 'Course Certificates with QR Verification', 'description': 'Certificates with QR codes that employers can scan to verify.', 'status': 'planned', 'votes': 28, 'releaseDate': 'Q4 2026', 'hasVoted': false},
    {'title': 'Parent Dashboard', 'description': 'Parents can track their child\'s learning progress.', 'status': 'planned', 'votes': 19, 'releaseDate': '2027', 'hasVoted': false},
    {'title': 'Apple Watch App', 'description': 'Track study streak and get notifications from your wrist.', 'status': 'planned', 'votes': 11, 'releaseDate': '2027', 'hasVoted': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterBy(String status) =>
      _allFeatures.where((f) => f['status'] == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Product Roadmap'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Released (${_filterBy('released').length})'),
            Tab(text: 'In Progress (${_filterBy('in_progress').length})'),
            Tab(text: 'Planned (${_filterBy('planned').length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_filterBy('released'), DakkhoColors.success, LucideIcons.checkCircle),
          _buildList(_filterBy('in_progress'), DakkhoColors.primary, LucideIcons.loader),
          _buildList(_filterBy('planned'), DakkhoColors.warning, LucideIcons.clock),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> features, Color color, IconData icon) {
    if (features.isEmpty) {
      return const EmptyState(icon: LucideIcons.map, title: 'Nothing here yet');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: features.length,
      itemBuilder: (_, i) {
        final f = features[i];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status icon
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(f['description'], style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.5)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(LucideIcons.tag, size: 12, color: DakkhoColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(f['releaseDate'], style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary, fontFamily: 'monospace')),
                      ],
                    ),
                  ],
                ),
              ),
              // Vote button (only for in_progress + planned)
              if (f['status'] != 'released')
                GestureDetector(
                  onTap: () => setState(() {
                    f['hasVoted'] = !f['hasVoted'];
                    f['votes'] += f['hasVoted'] ? 1 : -1;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: f['hasVoted'] ? DakkhoColors.primary : DakkhoColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: f['hasVoted'] ? DakkhoColors.primary : DakkhoColors.glassCardBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(LucideIcons.chevronUp, size: 14, color: f['hasVoted'] ? Colors.white : DakkhoColors.textSecondary),
                        Text('${f['votes']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: f['hasVoted'] ? Colors.white : DakkhoColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.05, end: 0);
      },
    );
  }
}
