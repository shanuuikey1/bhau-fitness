import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../../../theme/animations.dart';
import 'section_scaffold.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  static const _features = [
    [Icons.verified_outlined, 'Certified Coaches', 'NSCA & ACE certified trainers on every floor.'],
    [Icons.fitness_center_outlined, 'Premium Equipment', 'Imported strength & cardio machines, serviced weekly.'],
    [Icons.schedule_outlined, 'Flexible Hours', 'Open early, open late — fits around your life.'],
    [Icons.trending_up_outlined, 'Real Results', '92% member retention speaks for itself.'],
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
      childAspectRatio: isDesktop ? 3.6 : 1.1,
      children: List.generate(_features.length, (i) {
        final f = _features[i];
        final icon = f[0] as IconData;
        final title = f[1] as String;
        final desc = f[2] as String;
        return FadeSlideIn(
          delay: Duration(milliseconds: 300 + i * 90),
          child: GlowHoverCard(
            glowColor: BhauColors.cyan,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BhauDecor.card(),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: BhauColors.cyan, size: 22),
                    const SizedBox(height: 8),
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(height: 4),
                    Text(desc,
                        style: BhauText.body(fontSize: 11.0, color: BhauColors.faint),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: Text('ENGINEERED FOR\nTRANSFORMATION', style: BhauText.display(fontSize: 28)),
        ),
        const SizedBox(height: 8),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: AnimatedGradientLine(delay: const Duration(milliseconds: 160), maxWidth: 70),
        ),
        const SizedBox(height: 18),
        FadeSlideIn(
          delay: const Duration(milliseconds: 220),
          child: Text(
            'BHAU FITNESS was built on one idea: a gym should feel as good as the results it '
            "delivers. For 15+ years we've combined serious coaching with a studio environment "
            "that doesn't feel like a chore to walk into.",
            style: BhauText.body(),
          ),
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
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: const BhauImage(url: 'assets/images/about_1.png', height: 280, alignment: Alignment.topCenter),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 160),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: const BhauImage(url: 'assets/images/about_2.jpg', height: 280, alignment: Alignment.center),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 240),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: const BhauImage(url: 'assets/images/about_3.jpg', height: 280, alignment: Alignment.topCenter),
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
                // All three photos, side-by-side scroll strip — keeps every
                // image visible on phone/tablet widths instead of dropping
                // the 2nd and 3rd one like the old single-image layout did.
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      FadeSlideIn(
                        child: const SizedBox(
                          width: 260,
                          child: BhauImage(url: 'assets/images/about_1.png', height: 220, alignment: Alignment.topCenter),
                        ),
                      ),
                      const SizedBox(width: 14),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 80),
                        child: const SizedBox(
                          width: 260,
                          child: BhauImage(url: 'assets/images/about_2.jpg', height: 220, alignment: Alignment.center),
                        ),
                      ),
                      const SizedBox(width: 14),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 160),
                        child: const SizedBox(
                          width: 260,
                          child: BhauImage(url: 'assets/images/about_3.jpg', height: 220, alignment: Alignment.topCenter),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                textColumn,
              ],
            ),
    );
  }
}
