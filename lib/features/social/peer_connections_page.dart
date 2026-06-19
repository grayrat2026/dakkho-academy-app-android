import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/empty_state.dart';

/// PeerConnectionsPage — peer suggestions + connected peers list.
/// Backend: TODO — /api/peer-connections doesn't exist yet. In-memory sample data.
class PeerConnectionsPage extends StatefulWidget {
  const PeerConnectionsPage({super.key});
  @override
  State<PeerConnectionsPage> createState() => _PeerConnectionsPageState();
}

class _PeerConnectionsPageState extends State<PeerConnectionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _suggestions = [
    {'name': 'Rahim Ahmed', 'technology': 'CSE', 'institute': 'DPI', 'mutualCourses': 3, 'avatar': null},
    {'name': 'Taslima Khatun', 'technology': 'ETE', 'institute': 'DPI', 'mutualCourses': 2, 'avatar': null},
    {'name': 'Karim Uddin', 'technology': 'CSE', 'institute': 'BPI', 'mutualCourses': 1, 'avatar': null},
  ];

  final List<Map<String, dynamic>> _connected = [
    {'name': 'Sadia Islam', 'technology': 'CSE', 'institute': 'DPI', 'mutualCourses': 5, 'avatar': null},
    {'name': 'Hasan Mahmud', 'technology': 'EEE', 'institute': 'KPI', 'mutualCourses': 2, 'avatar': null},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Peers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Suggestions (${_suggestions.length})'),
            Tab(text: 'Connected (${_connected.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_suggestions, isSuggestion: true),
          _buildList(_connected, isSuggestion: false),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> peers, {required bool isSuggestion}) {
    if (peers.isEmpty) {
      return EmptyState(
        icon: LucideIcons.userPlus,
        title: isSuggestion ? 'No suggestions' : 'No connections yet',
        subtitle: isSuggestion ? 'Check back later for peer suggestions.' : 'Connect with peers to study together.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: peers.length,
      itemBuilder: (_, i) {
        final p = peers[i];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: DakkhoColors.primary,
                backgroundImage: p['avatar'] != null ? NetworkImage(p['avatar']) : null,
                child: p['avatar'] == null ? Text(p['name'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(LucideIcons.cpu, size: 11, color: DakkhoColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${p['technology']} · ${p['institute']}', style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.bookOpen, size: 11, color: DakkhoColors.accent),
                        const SizedBox(width: 4),
                        Text('${p['mutualCourses']} mutual courses', style: const TextStyle(fontSize: 11, color: DakkhoColors.accent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSuggestion)
                GradientButton(
                  label: 'Connect',
                  icon: LucideIcons.userPlus,
                  onPressed: () {
                    setState(() {
                      _suggestions.removeAt(i);
                      _connected.insert(0, p);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Connected with ${p['name']}!'), backgroundColor: DakkhoColors.success),
                    );
                  },
                )
              else
                IconButton(
                  icon: const Icon(LucideIcons.messageCircle, color: DakkhoColors.primary),
                  onPressed: () => context.go('/app/discussion'),
                ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.05, end: 0);
      },
    );
  }
}
