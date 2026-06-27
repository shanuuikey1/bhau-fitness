import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../theme/widgets.dart';
import 'member/member_shell.dart';
import 'login_screen.dart';
import 'landing/landing_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String _goal = 'lose';

  static const _goals = [
    {'key': 'lose', 'label': 'Lose Fat', 'icon': '🔥'},
    {'key': 'muscle', 'label': 'Build Muscle', 'icon': '💪'},
    {'key': 'fit', 'label': 'Get Fit', 'icon': '⚡'},
    {'key': 'strength', 'label': 'Strength', 'icon': '🏋️'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
      goal: _goal,
    );
    if (ok && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MemberShell()),
        (route) => false,
      );
    }
  }

  Widget _backButton() {
    return Positioned(
      top: 16,
      left: 16,
      child: SafeArea(
        child: HoverScale(
          scale: 1.08,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: BhauColors.bg3.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(color: BhauColors.line2),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LandingScreen()),
                    );
                  }
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: BhauColors.ink,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = Breakpoints.isDesktop(context);

    final form = _form(auth);

    if (!isDesktop) {
      return Scaffold(
        backgroundColor: BhauColors.bg,
        body: Stack(
          children: [
            // Ambient radial background glow
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      BhauColors.cyan.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: GlowCard(
                    maxWidth: 460,
                    color: BhauColors.cyan,
                    child: form,
                  ),
                ),
              ),
            ),
            _backButton(),
          ],
        ),
      );
    }

    // Desktop: full-bleed split with an angled (chevron) divider between the
    // motivational photo on the left and the auth form on the right.
    final w = MediaQuery.of(context).size.width;
    final photoW = w * 0.52;
    return Scaffold(
      backgroundColor: BhauColors.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: BhauColors.bg)),
          // Ambient radial background glow behind the registration card
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.6, 0.0),
                  radius: 1.2,
                  colors: [
                    BhauColors.cyan.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Left photo panel, clipped to the chevron shape.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: photoW,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipPath(
                  clipper: _ChevronClipper(),
                  child: Image.asset(
                    'assets/images/landing_hero.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _ChevronLinePainter()),
                ),
              ],
            ),
          ),
          // Right form panel.
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: w * 0.50,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: GlowCard(
                  maxWidth: 480,
                  color: BhauColors.cyan,
                  child: form,
                ),
              ),
            ),
          ),
          _backButton(),
        ],
      ),
    );
  }



  Widget _form(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const HexagonLogo(size: 56),
          const SizedBox(height: 12),
          const Center(child: BrandWordmark(fontSize: 28)),
          const SizedBox(height: 20),
          Text(
            'Create Membership',
            textAlign: TextAlign.center,
            style: BhauText.display(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            'Join the elite league and start your transformation',
            textAlign: TextAlign.center,
            style: BhauText.body(fontSize: 13.5),
          ),
          const SizedBox(height: 24),
          if (auth.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BhauColors.bad.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: BhauColors.bad.withValues(alpha: 0.3)),
              ),
              child: Text(
                auth.errorMessage!,
                style: const TextStyle(color: BhauColors.bad, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            "What's your main fitness goal?",
            style: GoogleFonts.inter(
              color: BhauColors.muted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: _goals.map((g) {
              final selected = _goal == g['key'];
              return GestureDetector(
                onTap: () => setState(() => _goal = g['key']!),
                child: HoverScale(
                  scale: 1.05,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected
                          ? BhauColors.cyan.withValues(alpha: 0.08)
                          : BhauColors.bg3.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? BhauColors.cyan : BhauColors.line,
                        width: selected ? 1.5 : 1.0,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: BhauColors.cyan.withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 0,
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(g['icon']!, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          g['label']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected ? BhauColors.ink : BhauColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline, color: BhauColors.faint, size: 20),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone_outlined, color: BhauColors.faint, size: 20),
            ),
            validator: (v) =>
                (v == null || v.trim().length < 10) ? 'Enter a valid phone number' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline, color: BhauColors.faint, size: 20),
            ),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline, color: BhauColors.faint, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: BhauColors.faint,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
          ),
          const SizedBox(height: 24),
          HoverScale(
            scale: 1.04,
            child: GradientButton(
              gradient: const LinearGradient(colors: [BhauColors.cyanDeep, BhauColors.cyan]),
              onPressed: auth.isLoading ? null : _submit,
              child: auth.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: BhauColors.bg,
                      ),
                    )
                  : const Text('Create Membership'),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text("Already have an account?  ", style: BhauText.body(fontSize: 13.5)),
                GestureDetector(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Log in',
                        style: TextStyle(
                          color: BhauColors.cyan,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: BhauColors.cyan),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChevronClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    const base = 70.0;
    const reach = 58.0;
    final midY = h * 0.45;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(w - base, 0)
      ..lineTo(w - base + reach, midY)
      ..lineTo(w - base, h)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ChevronLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const base = 70.0;
    const reach = 58.0;
    final midY = h * 0.45;
    final path = Path()
      ..moveTo(w - base, 0)
      ..lineTo(w - base + reach, midY)
      ..lineTo(w - base, h);

    final glow = Paint()
      ..color = BhauColors.cyan.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final line = Paint()
      ..color = BhauColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
