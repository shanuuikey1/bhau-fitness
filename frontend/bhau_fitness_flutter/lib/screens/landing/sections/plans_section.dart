import 'package:flutter/material.dart';
import '../../../models/plan.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import 'section_scaffold.dart';

/// Shows real plans from the API (`GET /plans` is public, same as the HTML
/// site fetching pricing before login) rather than hardcoded copy, so pricing
/// can never drift between the landing page and the post-login plan picker.
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
            Text("Couldn't load pricing — check your connection and pull to refresh.",
                style: BhauText.body(color: BhauColors.faint), textAlign: TextAlign.center)
          else if (_plans == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: CircularProgressIndicator(),
            )
          else
            ResponsiveGrid(
              tabletColumns: 2,
              desktopColumns: 3,
              children: [
                for (final p in _plans!) Builder(builder: (context) {
                final isFeatured = p.name.toLowerCase() == 'premium';
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: BhauColors.bg2,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isFeatured ? BhauColors.lime.withValues(alpha: 0.45) : BhauColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(color: BhauColors.lime, borderRadius: BorderRadius.circular(100)),
                          child: const Text('MOST POPULAR',
                              style: TextStyle(color: BhauColors.bg, fontWeight: FontWeight.w800, fontSize: 10)),
                        ),
                      Text(p.name.toUpperCase(), style: BhauText.display(fontSize: 22)),
                      const SizedBox(height: 6),
                      Text(p.description ?? '', style: BhauText.body(fontSize: 12.5)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('₹${p.price.toStringAsFixed(0)}', style: BhauText.display(fontSize: 34)),
                          const SizedBox(width: 6),
                          Text('/ ${p.durationDays} days', style: BhauText.body(fontSize: 12, color: BhauColors.faint)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => widget.onSelectPlan(p),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFeatured ? BhauColors.lime : BhauColors.cyan,
                          ),
                          child: const Text('Get Started'),
                        ),
                      ),
                    ],
                  ),
                );
                }),
              ],
            ),
        ],
      ),
    );
  }
}
