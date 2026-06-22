import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../landing_data.dart';
import 'section_scaffold.dart';

class ProgramsSection extends StatelessWidget {
  const ProgramsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'PROGRAMS',
            title: 'TRAIN WITH PURPOSE',
            subtitle: 'Six programs, one goal — getting you to the result you actually want.',
          ),
          ResponsiveGrid(
            tabletColumns: 2,
            desktopColumns: 3,
            children: [
              for (final p in programs)
                Container(
                  decoration: BhauDecor.card(),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BhauImage(url: p.image, height: 160, radius: BorderRadius.zero),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: BhauColors.cyan.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(p.weeks, style: BhauText.mono(fontSize: 10)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(p.level, style: BhauText.mono(fontSize: 10, color: BhauColors.muted)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(p.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(p.desc, style: BhauText.body(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
