import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../../../theme/widgets.dart';
import '../landing_data.dart';
import 'section_scaffold.dart';

class EquipmentSection extends StatelessWidget {
  const EquipmentSection({super.key});

  void _openLightbox(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: BhauColors.ink),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          const SectionHeader(eyebrow: 'THE STUDIO', title: 'EQUIPMENT THAT DELIVERS'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Breakpoints.isDesktop(context)
                  ? 5
                  : Breakpoints.isTablet(context)
                      ? 4
                      : 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: equipment.length,
            itemBuilder: (_, i) {
              final e = equipment[i];
              return GestureDetector(
                onTap: () => _openLightbox(context, e.image),
                child: HoverScale(
                  scale: 1.05,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        BhauImage(url: e.image, radius: BorderRadius.zero),
                        Positioned(
                          left: 0, right: 0, bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: BhauColors.ink)),
                                Text(e.category, style: BhauText.mono(fontSize: 9.5, color: BhauColors.muted)),
                              ],
                            ),
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
}
