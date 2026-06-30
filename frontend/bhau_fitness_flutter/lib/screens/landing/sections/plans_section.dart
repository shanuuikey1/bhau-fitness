import 'package:flutter/material.dart';
import '../../../models/plan.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../../../theme/widgets.dart';
import '../../../theme/animations.dart';
import 'section_scaffold.dart';

class PlansSection extends StatefulWidget {
  final void Function(Plan plan) onSelectPlan;
  const PlansSection({super.key, required this.onSelectPlan});

  @override
  State<PlansSection> createState() => _PlansSectionState();
}

class _PlansSectionState extends State<PlansSection> {
  final _authService = AuthService();
  List<Plan>? _plans;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final plans = await _authService.fetchPlans();
      if (mounted) setState(() => _plans = plans);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  List<String> _getFeatures(String planName) {
    final name = planName.toLowerCase();
    if (name.contains('basic')) {
      return [
        'Unlimited gym floor access',
        'Standard locker & shower access',
        'Customized workout template',
        'Free high-speed Wi-Fi',
      ];
    } else if (name.contains('premium')) {
      return [
        'Everything in Basic plan',
        '4 personal training sessions/month',
        'Custom nutrition & diet guide',
        'Access to all group classes',
        'Biweekly progress tracking',
      ];
    } else if (name.contains('elite') || name.contains('gold') || name.contains('vip')) {
      return [
        'Everything in Premium plan',
        'Unlimited 1-on-1 personal training',
        '24/7 direct coach WhatsApp access',
        'Premium recovery lounge access',
        'Complimentary protein shake/day',
      ];
    }
    return [
      'Unlimited gym floor access',
      'Personal trainer consultation',
      'Locker room & shower access',
      'Free fitness assessment',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'MEMBERSHIP',
            title: 'PICK YOUR PLAN',
            subtitle: '30-day money-back guarantee on every plan.',
          ),
          if (_failed)
            FadeSlideIn(
              child: Text("Couldn't load pricing — check your connection.",
                  style: BhauText.body(color: BhauColors.faint), textAlign: TextAlign.center),
            )
          else if (_plans == null)
            ResponsiveGrid(
              tabletColumns: 2,
              desktopColumns: 3,
              children: [for (int i = 0; i < 3; i++) const ShimmerCard(height: 380, radius: 18)],
            )
          else
            ResponsiveGrid(
              tabletColumns: 2,
              desktopColumns: 3,
              children: List.generate(_plans!.length, (idx) {
                final p = _plans![idx];
                final isFeatured = p.name.toLowerCase() == 'premium';

                final cardContent = Container(
                  padding: const EdgeInsets.all(24),
                  decoration: isFeatured
                      ? null
                      : BoxDecoration(
                          color: BhauColors.bg2,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: BhauColors.line),
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: BhauColors.lime, borderRadius: BorderRadius.circular(100)),
                          child: const Text('MOST POPULAR',
                              style: TextStyle(
                                  color: BhauColors.bg, fontWeight: FontWeight.w800, fontSize: 10)),
                        ),
                      Text(p.name.toUpperCase(), style: BhauText.display(fontSize: 22)),
                      const SizedBox(height: 6),
                      Text(p.description ?? '', style: BhauText.body(fontSize: 12.5)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) => BhauColors.cyanLimeGradient.createShader(b),
                            child: Text('₹${p.price.toStringAsFixed(0)}',
                                style: BhauText.display(fontSize: 34, color: Colors.white)),
                          ),
                          const SizedBox(width: 6),
                          Text('/ ${p.durationDays} days',
                              style: BhauText.body(fontSize: 12, color: BhauColors.faint)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: isFeatured
                            ? ShimmerSweep(
                                child: ElevatedButton(
                                  onPressed: () => widget.onSelectPlan(p),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: BhauColors.lime),
                                  child: const Text('Get Started'),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () => widget.onSelectPlan(p),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: BhauColors.cyan),
                                child: const Text('Get Started'),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Divider(
                          color: isFeatured
                              ? BhauColors.lime.withValues(alpha: 0.15)
                              : BhauColors.line),
                      const SizedBox(height: 16),
                      ..._getFeatures(p.name).map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: isFeatured ? BhauColors.lime : BhauColors.cyan,
                                    size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(f,
                                      style: BhauText.body(
                                          fontSize: 12.5, color: BhauColors.ink)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                );

                return FadeSlideIn(
                  delay: Duration(milliseconds: 200 + idx * 120),
                  child: isFeatured
                      ? _PulsingGlowCard(child: cardContent)
                      : GlowHoverCard(
                          glowColor: BhauColors.cyan,
                          child: cardContent,
                        ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

/// The featured plan card pulses its lime glow continuously.
class _PulsingGlowCard extends StatefulWidget {
  const _PulsingGlowCard({required this.child});
  final Widget child;

  @override
  State<_PulsingGlowCard> createState() => _PulsingGlowCardState();
}

class _PulsingGlowCardState extends State<_PulsingGlowCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: BhauColors.lime.withValues(alpha: _glow.value * 0.45),
              blurRadius: 32,
              spreadRadius: 0,
            ),
          ],
        ),
        child: GlowCard(
          padding: EdgeInsets.zero,
          color: BhauColors.lime,
          child: widget.child,
        ),
      ),
      child: widget.child,
    );
  }
}
