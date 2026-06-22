import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../landing_data.dart';
import 'section_scaffold.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'SUCCESS STORIES',
            title: 'WHAT MEMBERS SAY',
            subtitle: 'Real people. Real results. Real transformations.',
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: _RatingPill(),
          ),
          ResponsiveGrid(
            tabletColumns: 2,
            desktopColumns: 3,
            children: [
              for (final t in testimonials)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BhauDecor.card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: List.generate(5, (_) => const Icon(Icons.star, color: BhauColors.warn, size: 15))),
                      const SizedBox(height: 12),
                      Text('"${t.quote}"', style: BhauText.body(fontSize: 13.5).copyWith(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          CircleAvatar(radius: 18, backgroundImage: NetworkImage(t.image)),
                          const SizedBox(width: 10),
                          Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: BhauColors.lime.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(t.result, style: BhauText.mono(fontSize: 10, color: BhauColors.lime, weight: FontWeight.w700)),
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

class _RatingPill extends StatelessWidget {
  const _RatingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: BhauColors.bg2,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: BhauColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: List.generate(5, (_) => const Icon(Icons.star, color: BhauColors.warn, size: 14))),
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '4.9', style: TextStyle(fontWeight: FontWeight.bold, color: BhauColors.ink)),
                TextSpan(text: ' / 5 · ', style: BhauText.body(fontSize: 13)),
                const TextSpan(text: '200+', style: TextStyle(fontWeight: FontWeight.bold, color: BhauColors.ink)),
                TextSpan(text: ' verified Google reviews', style: BhauText.body(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
