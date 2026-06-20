import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final scrolled = _scrollCtrl.offset > 12;
      if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: _scrolled ? 12 : 18),
            decoration: BoxDecoration(
              color: _scrolled ? BhauColors.bg.withValues(alpha: 0.92) : Colors.transparent,
              border: _scrolled ? const Border(bottom: BorderSide(color: BhauColors.line)) : null,
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: BhauColors.cyanLimeGradient),
                    alignment: Alignment.center,
                    child: const Text('B', style: TextStyle(color: BhauColors.bg, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 10),
                  Text('BHAU FITNESS', style: BhauText.display(fontSize: 16)),
                  const Spacer(),
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
                  TextButton(
                    onPressed: _goLogin,
                    child: const Text('Log In', style: TextStyle(color: BhauColors.ink)),
                  ),
                  ElevatedButton(
                    onPressed: _goRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BhauColors.lime,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Join Now', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
          if (_scrolled)
            Positioned(
              right: 18,
              bottom: 18,
              child: SafeArea(
                child: FloatingActionButton.small(
                  onPressed: _scrollToTop,
                  backgroundColor: BhauColors.cyan,
                  foregroundColor: BhauColors.bg,
                  tooltip: 'Back to top',
                  child: const Icon(Icons.arrow_upward),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
