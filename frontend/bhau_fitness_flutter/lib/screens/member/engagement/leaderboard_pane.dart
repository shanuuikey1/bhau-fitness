import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/engagement_provider.dart';
import '../../../theme/app_theme.dart';

class LeaderboardPane extends StatelessWidget {
  const LeaderboardPane({super.key});

  static const _medalColors = [Color(0xFFFFD24A), Color(0xFFCFD8E3), Color(0xFFE0A06A)];

  @override
  Widget build(BuildContext context) {
    final myName = context.watch<AuthProvider>().profile?.fullName.split(' ').first ?? 'You';
    final entries = context.watch<EngagementProvider>().leaderboard(myName);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final e = entries[i];
        final isMe = e['me'] == true;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMe ? BhauColors.cyan.withValues(alpha: 0.07) : BhauColors.bg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isMe ? BhauColors.cyan : BhauColors.line),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text('${i + 1}',
                    textAlign: TextAlign.center,
                    style: BhauText.display(fontSize: 16, color: i < 3 ? _medalColors[i] : BhauColors.faint)),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 16,
                backgroundColor: BhauColors.cyan,
                child: Text((e['name'] as String)[0],
                    style: const TextStyle(color: BhauColors.bg, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(e['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5))),
              Text('${e['points']} pts', style: BhauText.display(fontSize: 14, color: BhauColors.lime)),
            ],
          ),
        );
      },
    );
  }
}
