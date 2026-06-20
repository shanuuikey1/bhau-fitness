import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/engagement_provider.dart';
import '../../../theme/app_theme.dart';

class HabitsPane extends StatelessWidget {
  const HabitsPane({super.key});

  @override
  Widget build(BuildContext context) {
    final engagement = context.watch<EngagementProvider>();
    final doneCount = engagement.habitsToday.values.where((v) => v).length;
    final total = engagement.habitKeys.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BhauDecor.card(radius: 14),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: BhauColors.cyan, width: 3),
                ),
                alignment: Alignment.center,
                child: Text('${engagement.streakDays}', style: BhauText.display(fontSize: 18)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔥 Day streak', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('$doneCount / $total habits done today', style: BhauText.body(fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...engagement.habitKeys.map((key) {
          final done = engagement.habitsToday[key] ?? false;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => context.read<EngagementProvider>().toggleHabit(key),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: done ? BhauColors.ok.withValues(alpha: 0.08) : BhauColors.bg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: done ? BhauColors.ok.withValues(alpha: 0.3) : BhauColors.line),
                ),
                child: Row(
                  children: [
                    Icon(done ? Icons.check_circle : Icons.circle_outlined,
                        color: done ? BhauColors.ok : BhauColors.faint, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        engagement.habitLabel(key),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: done ? BhauColors.muted : BhauColors.ink,
                          decoration: done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
