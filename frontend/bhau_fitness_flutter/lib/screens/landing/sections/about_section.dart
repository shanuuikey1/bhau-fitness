import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../../../theme/widgets.dart';
import 'section_scaffold.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  static const _features = [
    ['Certified Coaches', 'NSCA & ACE certified trainers on every floor.'],
    ['Premium Equipment', 'Imported strength & cardio machines, serviced weekly.'],
    ['Flexible Hours', 'Open early, open late — fits around your life.'],
    ['Real Results', '92% member retention speaks for itself.'],
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);
    final featuresGrid = GridView.count(
      crossAxisCount: isDesktop ? 1 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: isDesktop ? 3.6 : 1.4,
      children: _features
          .map((f) => HoverScale(
                scale: 1.03,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BhauDecor.card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.bolt, color: BhauColors.cyan, size: 22),
                      const SizedBox(height: 10),
                      Text(f[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(f[1], style: BhauText.body(fontSize: 11.5, color: BhauColors.faint)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('ENGINEERED FOR\nTRANSFORMATION', style: BhauText.display(fontSize: 28)),
        const SizedBox(height: 16),
        Text(
          'BHAU FITNESS was built on one idea: a gym should feel as good as the results it '
          "delivers. For 15+ years we've combined serious coaching with a studio environment "
          "that doesn't feel like a chore to walk into.",
          style: BhauText.body(),
        ),
        const SizedBox(height: 24),
        if (!isDesktop) featuresGrid,
      ],
    );

    return Section(
      child: isDesktop
          ? ResponsiveRow(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const BhauImage(
                        url: 'assets/images/about_1.png',
                        height: 280,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const BhauImage(
                        url: 'assets/images/about_2.png',
                        height: 280,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const BhauImage(
                        url: 'assets/images/about_3.png',
                        height: 280,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [textColumn, const SizedBox(height: 24), featuresGrid],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BhauImage(
                  url: 'assets/images/about_1.png',
                  height: 220,
                  alignment: Alignment.topCenter,
                ),
                const SizedBox(height: 26),
                textColumn,
              ],
            ),
    );
  }
}
