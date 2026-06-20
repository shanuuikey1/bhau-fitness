import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CtaSection extends StatelessWidget {
  final VoidCallback onJoin;
  const CtaSection({super.key, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BhauColors.line2),
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [BhauColors.cyan.withValues(alpha: 0.14), BhauColors.bg2],
          ),
        ),
        child: Column(
          children: [
            Text('START YOUR\nTRANSFORMATION', textAlign: TextAlign.center, style: BhauText.display(fontSize: 30)),
            const SizedBox(height: 14),
            Text(
              'Join hundreds of members who stopped waiting for "someday" — your first class is on us.',
              textAlign: TextAlign.center,
              style: BhauText.body(),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: onJoin,
              style: ElevatedButton.styleFrom(backgroundColor: BhauColors.lime, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: const Text('Join BHAU Fitness'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live "Open now / Closed" pill, computed from the current time against the
/// gym's hours (Mon–Sat 5AM–11PM, closed Sunday) — mirrors the HTML's #openNow.
class _OpenNowBadge extends StatelessWidget {
  const _OpenNowBadge();

  bool get _isOpen {
    final now = DateTime.now();
    if (now.weekday == DateTime.sunday) return false;
    return now.hour >= 5 && now.hour < 23;
  }

  @override
  Widget build(BuildContext context) {
    final open = _isOpen;
    final color = open ? BhauColors.ok : BhauColors.bad;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(open ? 'Open now' : 'Closed',
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: BhauColors.line))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: BhauColors.cyanLimeGradient),
                alignment: Alignment.center,
                child: const Text('B', style: TextStyle(color: BhauColors.bg, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              Text('BHAU FITNESS', style: BhauText.display(fontSize: 17)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Premium fitness studio in Parasia, Chhindwara. Where strength meets luxury.',
            style: BhauText.body(fontSize: 12.5, color: BhauColors.faint),
          ),
          const SizedBox(height: 24),
          Text('PARASIA, CHHINDWARA, MADHYA PRADESH', style: BhauText.mono(fontSize: 10.5, color: BhauColors.faint)),
          const SizedBox(height: 6),
          Text('MON–SAT · 5AM – 11PM', style: BhauText.mono(fontSize: 10.5, color: BhauColors.faint)),
          const SizedBox(height: 12),
          const _OpenNowBadge(),
          const SizedBox(height: 22),
          const Divider(color: BhauColors.line),
          const SizedBox(height: 14),
          Text('© ${DateTime.now().year} BHAU FITNESS. All rights reserved.',
              style: BhauText.body(fontSize: 11, color: BhauColors.faint)),
        ],
      ),
    );
  }
}
