import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../../../theme/widgets.dart';
import '../../../theme/animations.dart';
import '../../../brand_config.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onJoin;
  final VoidCallback onExplore;
  const HeroSection({super.key, required this.onJoin, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);
    final content = _HeroText(onJoin: onJoin, onExplore: onExplore, isDesktop: isDesktop);

    return Stack(
      children: [
        // Background photo
        Positioned.fill(
          child: Image.asset('assets/images/landing_hero.png', fit: BoxFit.cover),
        ),
        // Dark gradient overlay
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
        // Floating particle field for depth
        const Positioned.fill(
          child: RepaintBoundary(
            child: ParticleField(count: 24, color: BhauColors.cyan),
          ),
        ),
        // Lime accent particles
        Positioned.fill(
          child: RepaintBoundary(
            child: ParticleField(count: 10, color: BhauColors.lime),
          ),
        ),
        // Content
        Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            MediaQuery.of(context).padding.top + (isDesktop ? 80 : 120),
            24,
            50,
          ),
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
        // Location eyebrow badge — fade in first
        FadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: Container(
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
                Text(activeTenant.locationEyebrow,
                    style: BhauText.mono(fontSize: 12, color: BhauColors.muted, weight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),

        // Headline — word-by-word stagger
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: Text('WHERE\nSTRENGTH', style: BhauText.display(fontSize: 56)),
        ),
        FadeSlideIn(
          delay: const Duration(milliseconds: 320),
          child: ShaderMask(
            shaderCallback: (bounds) => BhauColors.cyanLimeGradient.createShader(bounds),
            child: Text('MEETS LUXURY', style: BhauText.display(fontSize: 56, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 24),

        // Subtitle
        FadeSlideIn(
          delay: const Duration(milliseconds: 440),
          child: Text(
            'A premium fitness studio built for serious transformation — expert coaching, '
            'top-tier equipment, and a membership experience that feels like it.',
            style: BhauText.body(fontSize: 16),
          ),
        ),
        const SizedBox(height: 32),

        // CTA buttons
        FadeSlideIn(
          delay: const Duration(milliseconds: 560),
          child: Wrap(
            spacing: 16, runSpacing: 16,
            children: [
              HoverScale(
                child: SizedBox(
                  width: 240,
                  child: ShimmerSweep(
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
                ),
              ),
              HoverScale(
                child: SizedBox(
                  width: 240,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: onExplore,
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Explore Programs'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 44),

        // Stat cards with animated counters
        FadeSlideIn(
          delay: const Duration(milliseconds: 680),
          child: Wrap(
            spacing: 14, runSpacing: 14,
            children: [
              _statCard(Icons.groups_outlined,       activeTenant.statMembers,  'ACTIVE MEMBERS',  const Duration(milliseconds: 700)),
              _statCard(Icons.calendar_today_outlined, activeTenant.statClasses, 'WEEKLY CLASSES',  const Duration(milliseconds: 800)),
              _statCard(Icons.star_outline,           activeTenant.statYears,    'YEARS STRONG',    const Duration(milliseconds: 900)),
              _statCard(Icons.monitor_heart_outlined, activeTenant.statTrainers, 'EXPERT TRAINERS', const Duration(milliseconds: 1000)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, Duration delay) {
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
          AnimatedCounter(
            value: value,
            style: BhauText.display(fontSize: 24),
            delay: delay,
          ),
          const SizedBox(height: 2),
          Text(label,
              style: BhauText.mono(fontSize: 9.5, color: BhauColors.faint),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Ticker Band ─────────────────────────────────────────────────────────────
// Continuously auto-scrolling marquee (left-drifting), like the HTML site's
// CSS-animated ticker. Two copies of one "set" sit side by side; translating
// left by exactly one set's width and then looping the animation makes the
// seam invisible, so it reads as an endless scroll.
class TickerBand extends StatefulWidget {
  const TickerBand({super.key});

  @override
  State<TickerBand> createState() => _TickerBandState();
}

class _TickerBandState extends State<TickerBand> with SingleTickerProviderStateMixin {
  static const _items = [
    'NO EXCUSES', 'JOIN TODAY', 'TRANSFORM', 'STRENGTH MEETS LUXURY',
    'TRAIN HARD', 'RESULTS GUARANTEED',
  ];
  static const _itemStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: BhauColors.faint,
    letterSpacing: 2,
  );
  static const _sepStyle = TextStyle(
      color: BhauColors.cyan, fontSize: 14, fontWeight: FontWeight.w700);
  static const _spacing = 24.0;
  static const _pixelsPerSecond = 45.0;

  late final AnimationController _ctrl;
  late final double _setWidth;

  @override
  void initState() {
    super.initState();
    _setWidth = _measureSetWidth();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_setWidth / _pixelsPerSecond * 1000).round()),
    )..repeat();
  }

  double _measureSetWidth() {
    double width = 0;
    for (final item in _items) {
      width += _textWidth(item, _itemStyle) + _spacing;
      width += _textWidth('//', _sepStyle) + _spacing;
    }
    return width;
  }

  double _textWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _buildSet() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _items.expand((t) => [
        Padding(
          padding: const EdgeInsets.only(right: _spacing),
          child: Text(t, style: _itemStyle),
        ),
        Padding(
          padding: const EdgeInsets.only(right: _spacing),
          child: Text('//', style: _sepStyle),
        ),
      ]).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.symmetric(horizontal: BorderSide(color: BhauColors.line)),
          color: const Color(0x06FFFFFF),
        ),
        child: ClipRect(
          child: SizedBox(
            height: 20,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) => OverflowBox(
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: Offset(-_ctrl.value * _setWidth, 0),
                  // Three copies back-to-back: enough overlap that even very
                  // wide screens never see a gap while the seam scrolls by.
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildSet(), _buildSet(), _buildSet()],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stats Band ───────────────────────────────────────────────────────────────
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
    return FadeSlideIn(
      delay: const Duration(milliseconds: 200),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: BhauColors.line)),
        ),
        child: ContentMaxWidth(
          child: GridView.count(
            crossAxisCount: isTablet ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isTablet ? 1.9 : 1.6,
            children: List.generate(stats.length, (i) {
              final s = stats[i];
              return FadeSlideIn(
                delay: Duration(milliseconds: 100 + i * 80),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: BhauColors.line, width: 0.5)),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedCounter(
                        value: s[0],
                        style: BhauText.display(fontSize: 30),
                        delay: Duration(milliseconds: 200 + i * 80),
                      ),
                      const SizedBox(height: 6),
                      Text(s[1], style: BhauText.body(fontSize: 12.5)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
