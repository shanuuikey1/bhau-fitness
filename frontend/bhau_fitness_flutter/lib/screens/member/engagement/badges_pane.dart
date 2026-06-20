import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/engagement_provider.dart';
import '../../../theme/app_theme.dart';

class BadgesPane extends StatelessWidget {
  const BadgesPane({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = context.watch<EngagementProvider>().badges;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (_, i) {
        final b = badges[i];
        final unlocked = b['unlocked'] as bool;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          decoration: BhauDecor.card(radius: 14),
          child: Opacity(
            opacity: unlocked ? 1 : 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(b['icon'] as String, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(b['name'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(b['desc'] as String,
                    textAlign: TextAlign.center, style: BhauText.mono(fontSize: 9, color: BhauColors.faint)),
              ],
            ),
          ),
        );
      },
    );
  }
}
