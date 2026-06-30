import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';

// =============================================================================
// ANIMATION ENGINE — Premium motion primitives for every section.
// =============================================================================

// ─── Scroll-Reveal: FadeSlideIn ──────────────────────────────────────────────
/// Wraps [child] so it fades + slides up from [offsetY] pixels below
/// when it first enters the viewport. Safe to nest anywhere.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 620),
    this.offsetY = 36.0,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 400),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return IgnorePointer(
          ignoring: !_ctrl.isCompleted,
          child: child,
        );
      },
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}

// ─── Staggered Children ──────────────────────────────────────────────────────
/// Plays each child's FadeSlideIn with an incrementing [staggerMs] delay,
/// creating the cascading "waterfall" reveal effect.
class StaggeredList extends StatelessWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.staggerMs = 80,
    this.baseDelay = Duration.zero,
    this.offsetY = 28.0,
  });

  final List<Widget> children;
  final int staggerMs;
  final Duration baseDelay;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++)
          FadeSlideIn(
            delay: baseDelay + Duration(milliseconds: i * staggerMs),
            offsetY: offsetY,
            child: children[i],
          ),
      ],
    );
  }
}

// ─── Animated Counter ────────────────────────────────────────────────────────
/// Counts up from 0 to [target] (an int parsed from the string, e.g. "5000+").
/// Preserves any trailing non-numeric suffix like "+" or "%".
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 1600),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutExpo,
  });

  final String value;   // e.g. "5000+", "40+", "15+", "12"
  final TextStyle style;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  late final int _target;
  late final String _suffix;

  @override
  void initState() {
    super.initState();
    // Parse "5000+" → target=5000, suffix="+"
    final match = RegExp(r'^(\d+)(.*)$').firstMatch(widget.value.trim());
    _target = match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
    _suffix = match?.group(2) ?? '';

    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: widget.curve);

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final current = (_anim.value * _target).round();
        return Text('$current$_suffix', style: widget.style);
      },
    );
  }
}

// ─── Pulsing Glow Dot ────────────────────────────────────────────────────────
/// A dot that radiates two ripple rings — used for the "Open Now" badge
/// and any "live" status indicator.
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key, this.color = BhauColors.ok, this.size = 8.0});
  final Color color;
  final double size;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 3,
      height: widget.size * 3,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return CustomPaint(
            painter: _PulsePainter(
              progress: _ctrl.value,
              color: widget.color,
              dotSize: widget.size,
            ),
          );
        },
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double dotSize;
  _PulsePainter({required this.progress, required this.color, required this.dotSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Ripple ring
    final rippleRadius = dotSize / 2 + (size.width / 2 - dotSize / 2) * progress;
    final rippleOpacity = (1.0 - progress).clamp(0.0, 1.0);
    canvas.drawCircle(
      center,
      rippleRadius,
      Paint()
        ..color = color.withValues(alpha: rippleOpacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Solid dot
    canvas.drawCircle(
      center,
      dotSize / 2,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.progress != progress;
}

// ─── Shimmer Sweep Button ────────────────────────────────────────────────────
/// Wraps [child] in a shimmer sweep that plays every [interval] — premium CTA feel.
class ShimmerSweep extends StatefulWidget {
  const ShimmerSweep({
    super.key,
    required this.child,
    this.interval = const Duration(seconds: 3),
    this.sweepColor = Colors.white,
    this.borderRadius = 12.0,
  });

  final Widget child;
  final Duration interval;
  final Color sweepColor;
  final double borderRadius;

  @override
  State<ShimmerSweep> createState() => _ShimmerSweepState();
}

class _ShimmerSweepState extends State<ShimmerSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    _scheduleNext();
  }

  void _scheduleNext() {
    Future.delayed(widget.interval, () {
      if (!mounted) return;
      _ctrl.forward(from: 0).then((_) {
        if (mounted) _scheduleNext();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              child!,
              if (_ctrl.isAnimating)
                Positioned.fill(
                  child: FractionalTranslation(
                    translation: Offset(-1.5 + _anim.value * 3, 0),
                    child: Transform(
                      transform: Matrix4.skewX(-0.3),
                      child: Container(
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.sweepColor.withValues(alpha: 0.0),
                              widget.sweepColor.withValues(alpha: 0.28),
                              widget.sweepColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ─── Floating Particle Field ─────────────────────────────────────────────────
/// Renders [count] softly-glowing particles that drift around slowly —
/// placed behind the hero section for depth and life.
class ParticleField extends StatefulWidget {
  const ParticleField({
    super.key,
    this.count = 22,
    this.color = BhauColors.cyan,
  });

  final int count;
  final Color color;

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;
  final _rand = math.Random(42);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(widget.count, (i) => _Particle.random(_rand));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              progress: _ctrl.value,
              color: widget.color,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double x, y, size, speed, phase;
  _Particle({required this.x, required this.y, required this.size,
      required this.speed, required this.phase});

  factory _Particle.random(math.Random r) => _Particle(
        x: r.nextDouble(),
        y: r.nextDouble(),
        size: 1.2 + r.nextDouble() * 2.2,
        speed: 0.3 + r.nextDouble() * 0.7,
        phase: r.nextDouble() * math.pi * 2,
      );
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({required this.particles, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed + p.phase / (math.pi * 2)) % 1.0;
      final dy = (t * size.height * 1.2) - size.height * 0.1;
      final dx = p.x * size.width +
          math.sin(t * math.pi * 2 + p.phase) * 30;
      final opacity = math.sin(t * math.pi).clamp(0.0, 1.0) * 0.45;

      final paint = Paint()..color = color.withValues(alpha: opacity);
      if (!kIsWeb) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      }

      canvas.drawCircle(
        Offset(dx, dy),
        // Draw slightly larger soft circles on Web since they don't have blur
        kIsWeb ? p.size * 1.6 : p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ─── Scroll Progress Bar ─────────────────────────────────────────────────────
/// A thin cyan line at the very top of the screen that grows as the
/// user scrolls down — a subtle but powerful premium signal.
class ScrollProgressBar extends StatelessWidget {
  const ScrollProgressBar({super.key, required this.controller});
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        double fraction = 0;
        try {
          if (controller.hasClients &&
              controller.position.maxScrollExtent > 0) {
            fraction = (controller.offset /
                    controller.position.maxScrollExtent)
                .clamp(0.0, 1.0);
          }
        } catch (_) {
          fraction = 0;
        }
        if (fraction <= 0) return const SizedBox.shrink();
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 2.5,
                width: w * fraction,
                decoration: const BoxDecoration(
                  gradient: BhauColors.cyanLimeGradient,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Animated Nav Underline ───────────────────────────────────────────────────
/// A text button whose underline draws itself from left→right on hover.
class AnimatedNavLink extends StatefulWidget {
  const AnimatedNavLink({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback onPressed;

  @override
  State<AnimatedNavLink> createState() => _AnimatedNavLinkState();
}

class _AnimatedNavLinkState extends State<AnimatedNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: _hovered ? BhauColors.ink : BhauColors.muted,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 1.5,
                width: _hovered ? 24.0 : 0.0,
                decoration: const BoxDecoration(
                  gradient: BhauColors.cyanLimeGradient,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Glow Card ───────────────────────────────────────────────────────────────
/// A card that smoothly animates a cyan glow on hover — premium lift effect.
class GlowHoverCard extends StatefulWidget {
  const GlowHoverCard({
    super.key,
    required this.child,
    this.glowColor = BhauColors.cyan,
    this.scale = 1.03,
    this.borderRadius = 18.0,
  });

  final Widget child;
  final Color glowColor;
  final double scale;
  final double borderRadius;

  @override
  State<GlowHoverCard> createState() => _GlowHoverCardState();
}

class _GlowHoverCardState extends State<GlowHoverCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) => Transform.scale(
          scale: 1.0 + (_anim.value * (widget.scale - 1.0)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: _anim.value * 0.3),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

// ─── Gradient Line Divider ────────────────────────────────────────────────────
/// An animated gradient underline that draws itself from left→right on reveal.
class AnimatedGradientLine extends StatefulWidget {
  const AnimatedGradientLine({
    super.key,
    this.delay = const Duration(milliseconds: 400),
    this.height = 2.0,
    this.maxWidth = 80.0,
  });

  final Duration delay;
  final double height;
  final double maxWidth;

  @override
  State<AnimatedGradientLine> createState() => _AnimatedGradientLineState();
}

class _AnimatedGradientLineState extends State<AnimatedGradientLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          height: widget.height,
          width: widget.maxWidth * _ctrl.value,
          decoration: const BoxDecoration(
            gradient: BhauColors.cyanLimeGradient,
          ),
        ),
      ),
    );
  }
}
