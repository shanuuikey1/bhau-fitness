import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../landing_data.dart';
import 'section_scaffold.dart';

/// "Member Transformations" — the before/after grid from the HTML, with the
/// same draggable comparison slider (drag to wipe between before and after).
class TransformationsSection extends StatelessWidget {
  const TransformationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'REAL PEOPLE',
            title: 'MEMBER TRANSFORMATIONS',
            subtitle: 'Drag the slider to see the difference our programs make.',
          ),
          ...transformations.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _BeforeAfterCard(item: t),
              )),
        ],
      ),
    );
  }
}

class _BeforeAfterCard extends StatefulWidget {
  final Transformation item;
  const _BeforeAfterCard({required this.item});

  @override
  State<_BeforeAfterCard> createState() => _BeforeAfterCardState();
}

class _BeforeAfterCardState extends State<_BeforeAfterCard> {
  // 0..1 fraction: how much of the "after" image is revealed from the left.
  double _split = 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BhauDecor.card(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                void updateFromX(double dx) =>
                    setState(() => _split = (dx / width).clamp(0.0, 1.0));

                return GestureDetector(
                  onHorizontalDragUpdate: (d) => updateFromX(d.localPosition.dx),
                  onTapDown: (d) => updateFromX(d.localPosition.dx),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Before (full width, underneath).
                      Image.network(widget.item.before, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(color: BhauColors.bg3)),
                      // After (clipped to the left portion, on top).
                      ClipRect(
                        clipper: _LeftClipper(_split),
                        child: Image.network(widget.item.after, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const ColoredBox(color: BhauColors.bg3)),
                      ),
                      // Corner labels.
                      Positioned(
                        bottom: 14, left: 14,
                        child: _label('AFTER'),
                      ),
                      Positioned(
                        bottom: 14, right: 14,
                        child: _label('BEFORE'),
                      ),
                      // Divider bar + handle.
                      Positioned(
                        left: width * _split - 1.5,
                        top: 0, bottom: 0,
                        child: Container(width: 3, color: BhauColors.cyan),
                      ),
                      Positioned(
                        left: width * _split - 20,
                        top: 0, bottom: 0,
                        child: Center(
                          child: Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: BhauColors.cyan),
                            child: const Icon(Icons.unfold_more, color: BhauColors.bg, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 3),
                Text('Transformation over ${widget.item.weeks}',
                    style: BhauText.body(fontSize: 12.5, color: BhauColors.faint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text, style: BhauText.mono(fontSize: 10, color: BhauColors.ink, weight: FontWeight.w700)),
      );
}

/// Clips its child to the left [fraction] of the available width — used to
/// reveal the "after" image up to the slider position.
class _LeftClipper extends CustomClipper<Rect> {
  final double fraction;
  _LeftClipper(this.fraction);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftClipper oldClipper) => oldClipper.fraction != fraction;
}
