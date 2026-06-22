import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../../../theme/widgets.dart';
import 'section_scaffold.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onJoin;
  final VoidCallback onExplore;
  const HeroSection({super.key, required this.onJoin, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);
    final content = _HeroText(onJoin: onJoin, onExplore: onExplore, isDesktop: isDesktop);

    // Full-bleed background photo behind the whole hero, same as the HTML's
    // `.hero-video-wrap` (a gym photo with a dark gradient overlay for text
    // legibility) — on every screen size, not just desktop.
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/landing_hero.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  BhauColors.bg.withValues(alpha: 0.55),
                  BhauColors.bg.withValues(alpha: 0.88),
                  BhauColors.bg,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24, isDesktop ? 70 : 90, 24, 50),
          child: ContentMaxWidth(
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: content),
                      const Spacer(flex: 1),
                    ],
                  )
                : content,
          ),
        ),
      ],
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.onJoin, required this.onExplore, required this.isDesktop});

  final VoidCallback onJoin;
  final VoidCallback onExplore;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              SizedBox(
                width: 240,
                child: GradientButton(
                  onPressed: onJoin,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Start Your Transformation'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 16, color: BhauColors.bg),
                    ],
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: onExplore,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Explore Programs'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 44),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _hstatCard(Icons.groups_outlined, '5000+', 'ACTIVE MEMBERS'),
              _hstatCard(Icons.calendar_today_outlined, '40+', 'WEEKLY CLASSES'),
              _hstatCard(Icons.star_outline, '15+', 'YEARS STRONG'),
              _hstatCard(Icons.monitor_heart_outlined, '12', 'EXPERT TRAINERS'),
            ],
          ),
        ],
    );
  }

  Widget _hstatCard(IconData icon, String n, String l) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: BhauColors.bg2.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BhauColors.line2),
      ),
      child: Column(
        children: [
          Icon(icon, color: BhauColors.lime, size: 22),
          const SizedBox(height: 8),
          Text(n, style: BhauText.display(fontSize: 24)),
          const SizedBox(height: 2),
          Text(l, style: BhauText.mono(fontSize: 9.5, color: BhauColors.faint), textAlign: TextAlign.center),
        ],
      ),
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
      ['98%', 'Member Retention'],
      ['24/7', 'Gym Access'],
      ['100+', 'Equipment Stations'],
      ['1:1', 'Personal Coaching'],
    ];
    final isTablet = Breakpoints.isTablet(context);
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BhauColors.line)),
      ),
      child: ContentMaxWidth(
        child: GridView.count(
        crossAxisCount: isTablet ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: isTablet ? 1.9 : 1.6,
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
      ),
    );
  }
}
