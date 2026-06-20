import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/engagement_provider.dart';
import '../../../theme/app_theme.dart';

class RoadmapPane extends StatelessWidget {
  const RoadmapPane({super.key});

  @override
  Widget build(BuildContext context) {
    final engagement = context.watch<EngagementProvider>();
    final steps = engagement.roadmapSteps;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (_, i) {
        final done = engagement.roadmapDone.contains(i);
        final isLast = i == steps.length - 1;
        return InkWell(
          onTap: () => context.read<EngagementProvider>().toggleRoadmapStep(i),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: done ? BhauColors.cyanLimeGradient : null,
                      color: done ? null : BhauColors.bg2,
                      border: done ? null : Border.all(color: BhauColors.line2, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: done
                        ? const Icon(Icons.check, size: 16, color: BhauColors.bg)
                        : Text('${i + 1}', style: BhauText.display(fontSize: 13)),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 40, color: done ? BhauColors.cyan : BhauColors.line),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(steps[i][0],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: done ? BhauColors.muted : BhauColors.ink,
                          )),
                      const SizedBox(height: 3),
                      Text(steps[i][1], style: BhauText.body(fontSize: 12, color: BhauColors.faint)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
