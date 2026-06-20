import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
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
            eyebrow: 'REAL RESULTS',
            title: 'OUR MEMBERS SPEAK',
            subtitle: '4.9-star average across 300+ verified reviews.',
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: testimonials.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final t = testimonials[i];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BhauDecor.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: List.generate(5, (_) => const Icon(Icons.star, color: BhauColors.warn, size: 15))),
                    const SizedBox(height: 12),
                    Text('"${t.quote}"', style: BhauText.body(fontSize: 13.5).copyWith(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 14),
                    Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
