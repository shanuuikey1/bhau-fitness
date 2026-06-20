import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onJoin;
  final VoidCallback onExplore;
  const HeroSection({super.key, required this.onJoin, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 90, 24, 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: BhauColors.line2),
              color: Colors.white.withValues(alpha: 0.03),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: BhauColors.lime, shape: BoxShape.circle),
                ),
                const SizedBox(width: 9),
                Text('PARASIA · CHHINDWARA', style: BhauText.mono(fontSize: 12, color: BhauColors.muted, weight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text('WHERE\nSTRENGTH', style: BhauText.display(fontSize: 56)),
          ShaderMask(
            shaderCallback: (bounds) => BhauColors.cyanLimeGradient.createShader(bounds),
            child: Text('MEETS LUXURY', style: BhauText.display(fontSize: 56, color: Colors.white)),
          ),
          const SizedBox(height: 22),
          Text(
            'A premium fitness studio built for serious transformation — expert coaching, '
            'top-tier equipment, and a membership experience that feels like it.',
            style: BhauText.body(fontSize: 16),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 14, runSpacing: 14,
            children: [
              ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(backgroundColor: BhauColors.lime),
                child: const Text('Start Your Transformation'),
              ),
              OutlinedButton(
                onPressed: onExplore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: BhauColors.ink,
                  side: const BorderSide(color: BhauColors.line2),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Explore Programs'),
              ),
            ],
          ),
          const SizedBox(height: 44),
          Row(
            children: [
              _hstat('500+', 'MEMBERS'),
              const SizedBox(width: 36),
              _hstat('15+', 'YEARS'),
              const SizedBox(width: 36),
              _hstat('4.9', 'RATING', icon: Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hstat(String n, String l, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(n, style: BhauText.display(fontSize: 28)),
            // Anton (the display font) has no glyph for "★" — using a
            // Material icon here instead of the unicode character avoids
            // the missing-glyph "tofu" box some browsers render for it.
            if (icon != null) Icon(icon, size: 20, color: BhauColors.ink),
          ],
        ),
        const SizedBox(height: 4),
        Text(l, style: BhauText.mono(fontSize: 10.5, color: BhauColors.faint)),
      ],
    );
  }
}

class TickerBand extends StatefulWidget {
  const TickerBand({super.key});

  @override
  State<TickerBand> createState() => _TickerBandState();
}

class _TickerBandState extends State<TickerBand> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _items = [
    'NO EXCUSES', 'JOIN TODAY', 'TRANSFORM', 'STRENGTH MEETS LUXURY', 'TRAIN HARD', 'RESULTS GUARANTEED',
  ];

  @override
  void initState() {
    super.initState();
    // Continuous marquee scroll, matching the HTML's `@keyframes scrollx`.
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _row() => Row(
        mainAxisSize: MainAxisSize.min,
        children: _items
            .expand((t) => [
                  Text(t, style: BhauText.display(fontSize: 20, color: BhauColors.faint)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('//', style: BhauText.mono(color: BhauColors.cyan)),
                  ),
                ])
            .toList(),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: BhauColors.line)),
        color: const Color(0x06FFFFFF),
      ),
      child: ClipRect(
        // Lay two identical copies side by side and slide left by one copy's
        // width, then loop — gives a seamless, infinite marquee.
        child: SizedBox(
          height: 28,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return OverflowBox(
                minWidth: 0,
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: FractionalTranslation(
                  translation: Offset(-0.5 * _controller.value, 0),
                  child: child,
                ),
              );
            },
            child: IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [_row(), _row()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatsBand extends StatelessWidget {
  const StatsBand({super.key});

  @override
  Widget build(BuildContext context) {
    const stats = [
      ['92%', 'Member Retention'],
      ['24/7', 'Elite Access'],
      ['40+', 'Equipment Stations'],
      ['15+', 'Years Coaching'],
    ];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BhauColors.line)),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.6,
        children: stats
            .map((s) => Container(
                  decoration: BoxDecoration(border: Border.all(color: BhauColors.line, width: 0.5)),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s[0], style: BhauText.display(fontSize: 30)),
                      const SizedBox(height: 6),
                      Text(s[1], style: BhauText.body(fontSize: 12.5)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
