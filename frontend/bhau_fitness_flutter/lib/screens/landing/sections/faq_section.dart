import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../landing_data.dart';
import 'section_scaffold.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          const SectionHeader(eyebrow: 'FAQ', title: 'GOT QUESTIONS?'),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: faqs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final f = faqs[i];
              final isOpen = _open == i;
              return Container(
                decoration: BhauDecor.card(radius: 14),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _open = isOpen ? null : i),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(f.q, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            Icon(
                              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: BhauColors.cyan,
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      firstChild: const SizedBox(width: double.infinity, height: 0),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(f.a, style: BhauText.body(fontSize: 13)),
                        ),
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
