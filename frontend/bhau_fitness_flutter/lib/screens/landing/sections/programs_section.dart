import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: programs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final p = programs[i];
              return Container(
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: BhauColors.cyan.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(p.tag, style: BhauText.mono(fontSize: 10)),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
