import 'package:flutter/material.dart';
import '../../../services/external_links.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../../../theme/widgets.dart';
import '../../../theme/animations.dart';
import '../../../brand_config.dart';

class CtaSection extends StatelessWidget {
  final VoidCallback onJoin;
  const CtaSection({super.key, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: ContentMaxWidth(
        maxWidth: 900,
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
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
            ShaderMask(
              shaderCallback: (b) => BhauColors.cyanLimeGradient.createShader(b),
              child: Text('START YOUR\nTRANSFORMATION',
                  textAlign: TextAlign.center,
                  style: BhauText.display(fontSize: 30, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Text(
              'Join hundreds of members who stopped waiting for "someday" — your first class is on us.',
              textAlign: TextAlign.center,
              style: BhauText.body(),
            ),
            const SizedBox(height: 32),
            HoverScale(
              scale: 1.05,
              child: ShimmerSweep(
                child: ElevatedButton(
                  onPressed: onJoin,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: BhauColors.lime,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                  child: Text(activeTenant.ctaJoinLabel),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    ),
    );
  }
}

/// Live "Open now / Closed" pill, computed from the current time against the
/// gym's hours (Mon–Sat 5AM–11PM, closed Sunday) — mirrors the HTML's #openNow.
class _OpenNowBadge extends StatelessWidget {
  const _OpenNowBadge();

  bool get _isOpen => activeTenant.isOpenNow;

  @override
  Widget build(BuildContext context) {
    final open = _isOpen;
    final color = open ? BhauColors.ok : BhauColors.bad;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulsingDot(color: color, size: 8),
        const SizedBox(width: 8),
        Text(open ? 'Open now' : 'Closed',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
      ],
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const HexagonLogo(size: 32),
            const SizedBox(width: 10),
            Text(activeTenant.brandName, style: BhauText.display(fontSize: 17)),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Premium fitness studio in ${activeTenant.locationEyebrow}. ${activeTenant.tagline.toLowerCase()}.',
          style: BhauText.body(fontSize: 12.5, color: BhauColors.faint),
        ),
      ],
    );

    final hours = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(activeTenant.address, style: BhauText.mono(fontSize: 10.5, color: BhauColors.faint)),
        const SizedBox(height: 6),
        Text(activeTenant.hoursLabel, style: BhauText.mono(fontSize: 10.5, color: BhauColors.faint)),
        const SizedBox(height: 12),
        const _OpenNowBadge(),
      ],
    );

    final contact = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('CONTACT', style: BhauText.mono(fontSize: 10.5, color: BhauColors.faint, weight: FontWeight.w700)),
        const SizedBox(height: 10),
        _ContactLink(icon: Icons.call_outlined, label: BhauContact.phone, onTap: BhauContact.openPhone),
        _ContactLink(icon: Icons.chat_outlined, label: 'WhatsApp us', onTap: BhauContact.openWhatsApp),
        _ContactLink(icon: Icons.mail_outline, label: BhauContact.email, onTap: BhauContact.openEmail),
        _ContactLink(icon: Icons.camera_alt_outlined, label: '@${BhauContact.instagram}', onTap: BhauContact.openInstagram),
      ],
    );

    final isDesktop = Breakpoints.isDesktop(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: BhauColors.line))),
      child: ContentMaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MapCard(),
            const SizedBox(height: 32),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: brand),
                  Expanded(child: hours),
                  Expanded(child: contact),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [brand, const SizedBox(height: 24), hours, const SizedBox(height: 24), contact],
              ),
            const SizedBox(height: 22),
            const Divider(color: BhauColors.line),
            const SizedBox(height: 14),
            Text(activeTenant.copyrightLine,
                style: BhauText.body(fontSize: 11, color: BhauColors.faint)),
          ],
        ),
      ),
    );
  }
}

/// Stand-in for the HTML's embedded Google Maps `<iframe>` (`.map-card`) —
/// Flutter has no equivalent of a live map embed without a Maps SDK/API key,
/// so this opens the same location in the device's/browser's Maps app.
class _MapCard extends StatelessWidget {
  const _MapCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: BhauContact.openMaps,
      child: HoverScale(
        scale: 1.02,
        child: Container(
          // Explicit width is required here: the Stack below has only one
          // non-positioned child (the center icon), so without a fixed width
          // the whole card collapses to that icon's intrinsic ~56px width
          // instead of filling the available row — exactly the squished,
          // narrow-and-tall card you saw.
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D2730), Color(0xFF0A1116)],
            ),
            border: Border.all(color: BhauColors.line2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 56, color: BhauColors.cyan),
              Positioned(
                left: 16, bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: BhauColors.lime, size: 16),
                      const SizedBox(width: 6),
                      Text(activeTenant.mapLabel,
                          style: BhauText.body(fontSize: 11.5, color: BhauColors.ink)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactLink extends StatefulWidget {
  const _ContactLink({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_ContactLink> createState() => _ContactLinkState();
}

class _ContactLinkState extends State<_ContactLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _isHovered ? BhauColors.cyan : BhauColors.faint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 15, color: color),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: BhauText.body(fontSize: 12.5, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
