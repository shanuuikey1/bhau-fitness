import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/plan.dart';
import '../../services/auth_service.dart';
import '../../services/external_links.dart';
import '../../theme/app_theme.dart';
import '../../theme/responsive.dart';
import '../../theme/widgets.dart';
import '../../theme/animations.dart';
import '../../brand_config.dart';
import '../login_screen.dart';
import '../register_screen.dart';
import 'sections/about_section.dart';
import 'sections/bmi_section.dart';
import 'sections/cta_footer_section.dart';
import 'sections/equipment_section.dart';
import 'sections/faq_section.dart';
import 'sections/hero_section.dart';
import 'sections/plans_section.dart';
import 'sections/programs_section.dart';
import 'sections/schedule_preview_section.dart';
import 'sections/testimonials_section.dart';
import 'sections/trainers_section.dart';
import 'sections/transformations_section.dart';

/// The public marketing site, ported from bhau_fitness_v3.html — the true
/// entry point for logged-out visitors, with Login/Register reached via CTA
/// buttons (mirroring the HTML's modal auth, just as full screens here).
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollCtrl = ScrollController();
  final _programsKey = GlobalKey();
  final _scheduleKey = GlobalKey();
  final _plansKey = GlobalKey();
  final _trainersKey = GlobalKey();
  final _faqKey = GlobalKey();
  bool _scrolled = false;
  
  Plan? _cheapestPlan;

  // Rotating "social proof" toast — same 7 demo events/timings as the HTML's
  // `SP` array (shown after 14s, every 32s, for 6s each, desktop only).
  static const _socialProofEvents = [
    ('Aarti', 'Chhindwara', 'started a free trial'),
    ('Rohit', 'Parasia', 'joined the Premium plan'),
    ('Sneha', 'Chhindwara', 'booked a HIIT class'),
    ('Vikas', 'Parasia', 'completed a 30-day streak'),
    ('Pooja', 'Chhindwara', 'upgraded to Elite'),
    ('Manish', 'Junnardeo', 'booked a free session'),
    ('Kavya', 'Chhindwara', 'started Body Transformation'),
  ];
  Timer? _toastTimer;
  int _toastIndex = 0;
  (String, String, String)? _visibleToast;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final scrolled = _scrollCtrl.offset > 12;
      if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    });
    
    _loadCheapestPlan();
    _toastTimer = Timer(const Duration(seconds: 14), _cycleSocialProof);
  }

  void _cycleSocialProof() {
    if (!mounted) return;
    if (Breakpoints.isTablet(context)) {
      final event = _socialProofEvents[_toastIndex % _socialProofEvents.length];
      _toastIndex++;
      setState(() => _visibleToast = event);
      Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _visibleToast = null);
      });
    }
    _toastTimer = Timer(const Duration(seconds: 32), _cycleSocialProof);
  }

  

  Future<void> _loadCheapestPlan() async {
    try {
      final plans = await AuthService().fetchPlans();
      if (plans.isEmpty || !mounted) return;
      plans.sort((a, b) => a.price.compareTo(b.price));
      setState(() => _cheapestPlan = plans.first);
    } catch (_) {
      // Sticky CTA simply doesn't show a plan if this fails.
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _toastTimer?.cancel();
    super.dispose();
  }

  void _goLogin() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  void _goRegister() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    }
  }

  void _scrollToTop() => _scrollCtrl.animateTo(0,
      duration: const Duration(milliseconds: 400), curve: Curves.easeOut);

  Widget _navLink(String label, GlobalKey key) => AnimatedNavLink(
        label: label,
        onPressed: () => _scrollTo(key),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Positioned.fill gives the scroll view TIGHT constraints (exactly
          // the stack size). As a plain non-positioned child it got loose
          // constraints, which broke mouse-wheel scrolling on Flutter web.
          Positioned.fill(
            child: Scrollbar(
            controller: _scrollCtrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeroSection(onJoin: _goRegister, onExplore: () => _scrollTo(_plansKey)),
                const TickerBand(),
                const StatsBand(),
                const AboutSection(),
                KeyedSubtree(key: _programsKey, child: const ProgramsSection()),
                const EquipmentSection(),
                const TransformationsSection(),
                const TestimonialsSection(),
                const BmiSection(),
                KeyedSubtree(
                  key: _scheduleKey,
                  child: SchedulePreviewSection(onJoin: _goRegister),
                ),
                KeyedSubtree(
                  key: _plansKey,
                  child: PlansSection(onSelectPlan: (_) => _goRegister()),
                ),
                KeyedSubtree(key: _trainersKey, child: const TrainersSection()),
                KeyedSubtree(key: _faqKey, child: const FaqSection()),
                CtaSection(onJoin: _goRegister),
                const FooterSection(),
              ],
            ),
            ),
          ),
          ),
          // Pinned to the top edge only. As a non-positioned Stack child the
          // nav's inner Align (ContentMaxWidth) expanded to fill the WHOLE
          // screen, sitting invisibly over the page and swallowing mouse-wheel
          // scroll. Constraining it to top/left/right makes it size to its own
          // height so the scroll view beneath receives wheel events.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: RepaintBoundary(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: _scrolled ? 12 : 18),
                decoration: BoxDecoration(
                  color: _scrolled ? BhauColors.bg.withValues(alpha: 0.92) : Colors.transparent,
                  border: _scrolled ? const Border(bottom: BorderSide(color: BhauColors.line)) : null,
                ),
            child: SafeArea(
              bottom: false,
              child: ContentMaxWidth(
                child: Row(
                children: [
                  const HexagonLogo(size: 44),
                  const SizedBox(width: 14),
                  Text(activeTenant.brandName, style: BhauText.display(fontSize: 22)),
                  const Spacer(),
                  if (Breakpoints.isDesktop(context)) ...[
                    _navLink('Programs', _programsKey),
                    _navLink('Schedule', _scheduleKey),
                    _navLink('Membership', _plansKey),
                    _navLink('Trainers', _trainersKey),
                    _navLink('FAQ', _faqKey),
                    const SizedBox(width: 12),
                  ] else
                    PopupMenuButton<GlobalKey>(
                      icon: const Icon(Icons.menu, color: BhauColors.ink, size: 22),
                      color: BhauColors.bg1,
                      onSelected: _scrollTo,
                      itemBuilder: (_) => [
                        PopupMenuItem(value: _programsKey, child: const Text('Programs')),
                        PopupMenuItem(value: _scheduleKey, child: const Text('Schedule')),
                        PopupMenuItem(value: _plansKey, child: const Text('Membership')),
                        PopupMenuItem(value: _trainersKey, child: const Text('Trainers')),
                        PopupMenuItem(value: _faqKey, child: const Text('FAQ')),
                      ],
                    ),
                  _HoverColorTextButton(
                    label: 'Log In',
                    onPressed: _goLogin,
                    baseColor: BhauColors.ink,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(width: 8),
                   HoverScale(
                    scale: 1.05,
                    child: ShimmerSweep(
                      child: ElevatedButton(
                        onPressed: _goRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BhauColors.lime,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Join Now', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
          ),
          ),
          // Scroll progress bar — thin gradient line at the very top
          Positioned(
            top: 0, left: 0, right: 0,
            child: ScrollProgressBar(controller: _scrollCtrl),
          ),
          // Back-to-top sits bottom-LEFT in the HTML (.back-top), WhatsApp
          // float sits bottom-right (.wa-float) — kept on opposite corners
          // here too so they never collide with the sticky mobile CTA.
          if (_scrolled)
            Positioned(
              left: 18,
              bottom: !Breakpoints.isTablet(context) && _cheapestPlan != null ? 78 : 18,
              child: SafeArea(
                child: HoverScale(
                  scale: 1.08,
                  child: FloatingActionButton.small(
                    onPressed: _scrollToTop,
                    backgroundColor: BhauColors.bg2,
                    foregroundColor: BhauColors.muted,
                    tooltip: 'Back to top',
                    child: const Icon(Icons.arrow_upward),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 18,
            bottom: !Breakpoints.isTablet(context) && _cheapestPlan != null ? 78 : 18,
            child: SafeArea(
              child: _WhatsAppButton(onTap: () => BhauContact.openWhatsApp()),
            ),
          ),
          if (!Breakpoints.isTablet(context) && _cheapestPlan != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _StickyMobileCta(plan: _cheapestPlan!, onJoin: _goRegister),
              ),
            ),
          
          if (_visibleToast != null)
            Positioned(
              left: 28,
              bottom: 88,
              child: SafeArea(
                child: _SocialProofToast(event: _visibleToast!, onDismiss: () => setState(() => _visibleToast = null)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Mirrors the HTML's `.wa-float` — fixed green circular WhatsApp deep link.
class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      scale: 1.08,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF25D366).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: Image.asset(
                'assets/images/whatsapp_logo.png',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mirrors the HTML's `.sticky-cta` — mobile-only fixed bar showing the
/// cheapest plan + a Join button, always visible on phone widths.
class _StickyMobileCta extends StatelessWidget {
  const _StickyMobileCta({required this.plan, required this.onJoin});
  final Plan plan;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: BhauColors.bg.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: BhauColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(plan.name.toUpperCase(), style: BhauText.mono(fontSize: 10.5, color: BhauColors.cyan, weight: FontWeight.w700)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('₹${plan.price.toStringAsFixed(0)}', style: BhauText.display(fontSize: 22, color: BhauColors.lime)),
                    const SizedBox(width: 3),
                    Text('/month', style: BhauText.body(fontSize: 11, color: BhauColors.faint)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: BhauColors.lime,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('Join Now', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}



/// Mirrors the HTML's `.sp-toast` — a tasteful, infrequent recent-activity
/// notification. Same 7 demo events/timing as the HTML's `SP` array.
class _SocialProofToast extends StatelessWidget {
  const _SocialProofToast({required this.event, required this.onDismiss});
  final (String, String, String) event;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final (name, city, action) = event;
    final agoMin = 2 + (DateTime.now().millisecond % 22);
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.fromLTRB(12, 12, 28, 12),
      decoration: BoxDecoration(
        color: BhauColors.bg1.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BhauColors.line2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 12))],
      ),
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: BhauColors.cyanLimeGradient),
                alignment: Alignment.center,
                child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF04222B))),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$name from $city', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                    Text.rich(
                      TextSpan(
                        style: BhauText.body(fontSize: 11, color: BhauColors.muted),
                        children: [
                          TextSpan(text: action),
                          TextSpan(text: ' · $agoMin min ago', style: const TextStyle(color: BhauColors.faint)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: -4, right: -16,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16, color: BhauColors.faint),
              onPressed: onDismiss,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverColorTextButton extends StatefulWidget {
  const _HoverColorTextButton({
    required this.label,
    required this.onPressed,
    this.baseColor = BhauColors.muted,
    this.hoverColor = BhauColors.cyan,
    this.fontSize = 13.5,
    this.fontWeight = FontWeight.w500,
  });
  final String label;
  final VoidCallback onPressed;
  final Color baseColor;
  final Color hoverColor;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  State<_HoverColorTextButton> createState() => _HoverColorTextButtonState();
}

class _HoverColorTextButtonState extends State<_HoverColorTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            color: _isHovered ? widget.hoverColor : widget.baseColor,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
