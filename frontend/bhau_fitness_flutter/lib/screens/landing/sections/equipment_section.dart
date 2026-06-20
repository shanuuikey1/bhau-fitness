import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: equipmentImages.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _openLightbox(context, equipmentImages[i]),
              child: BhauImage(url: equipmentImages[i], radius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
