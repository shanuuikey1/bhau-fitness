import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../../../theme/widgets.dart';
import '../landing_data.dart';
import 'section_scaffold.dart';

class TrainersSection extends StatelessWidget {
  const TrainersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          const SectionHeader(eyebrow: 'THE TEAM', title: 'TRAIN WITH THE BEST'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Breakpoints.isDesktop(context)
                  ? 4
                  : Breakpoints.isTablet(context)
                      ? 3
                      : 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: trainers.length,
            itemBuilder: (_, i) {
              final t = trainers[i];
              return GestureDetector(
                onTap: () => _showTrainerModal(context, t),
                child: HoverScale(
                  scale: 1.03,
                  child: Container(
                    decoration: BhauDecor.card(),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: BhauImage(url: t.image, height: double.infinity, radius: BorderRadius.zero, alignment: Alignment.topCenter)),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                              const SizedBox(height: 3),
                              Text(t.spec, style: BhauText.mono(fontSize: 9.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTrainerModal(BuildContext context, TrainerItem t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BhauColors.bg1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BhauImage(url: t.image, height: 200, radius: BorderRadius.zero),
            ),
            const SizedBox(height: 16),
            Text(t.name, style: BhauText.display(fontSize: 24)),
            const SizedBox(height: 4),
            Text(t.spec, style: BhauText.mono(fontSize: 12)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: t.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: BhauColors.bg3,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: BhauColors.line),
                        ),
                        child: Text(tag, style: const TextStyle(fontSize: 11.5, color: BhauColors.muted)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 18),
            Text('CERTIFICATIONS', style: BhauText.mono(fontSize: 10, color: BhauColors.faint)),
            const SizedBox(height: 8),
            ...t.certs.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, size: 16, color: BhauColors.cyan),
                      const SizedBox(width: 8),
                      Text(c, style: BhauText.body(fontSize: 13)),
                    ],
                  ),
                )),
            const SizedBox(height: 14),
            const Divider(color: BhauColors.line),
            const SizedBox(height: 14),
            Row(
              children: [
                _metaCol('EXPERIENCE', t.exp),
                const SizedBox(width: 32),
                _metaCol('INSTAGRAM', '@${t.instagram}', color: BhauColors.cyan),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _metaCol(String label, String value, {Color color = BhauColors.ink}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: BhauText.mono(fontSize: 9.5, color: BhauColors.faint)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ],
      );
}
