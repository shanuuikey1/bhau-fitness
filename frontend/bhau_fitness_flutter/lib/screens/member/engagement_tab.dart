import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/engagement_provider.dart';
import '../../theme/app_theme.dart';
import 'engagement/ai_coach_pane.dart';
import 'engagement/badges_pane.dart';
import 'engagement/habits_pane.dart';
import 'engagement/leaderboard_pane.dart';
import 'engagement/progress_pane.dart';
import 'engagement/refer_pane.dart';
import 'engagement/roadmap_pane.dart';

class EngagementTab extends StatefulWidget {
  const EngagementTab({super.key});

  @override
  State<EngagementTab> createState() => _EngagementTabState();
}

class _EngagementTabState extends State<EngagementTab> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Progress', 'Badges', 'Habits', 'Roadmap', 'Leaderboard', 'Refer', 'AI Coach'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = context.watch<EngagementProvider>().points;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text('ENGAGEMENT', style: BhauText.eyebrow()),
              const Spacer(),
              Text('$points', style: BhauText.display(fontSize: 18, color: BhauColors.lime)),
              const SizedBox(width: 4),
              Text('pts', style: BhauText.mono(fontSize: 11, color: BhauColors.faint)),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: BhauColors.cyan,
          unselectedLabelColor: BhauColors.muted,
          indicatorColor: BhauColors.cyan,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
        const Divider(height: 1, color: BhauColors.line),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ProgressPane(),
              BadgesPane(),
              HabitsPane(),
              RoadmapPane(),
              LeaderboardPane(),
              ReferPane(),
              AiCoachPane(),
            ],
          ),
        ),
      ],
    );
  }
}
