import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../theme/widgets.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'member/member_shell.dart';
import 'landing/landing_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    // No "Remember Me" checkbox in this design — sessions always persist.
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text, remember: true);
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
                      BhauColors.lime.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: GlowCard(
                    maxWidth: 440,
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
          // Ambient radial background glow behind the login card
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.6, -0.1),
                  radius: 1.2,
                  colors: [
                    BhauColors.lime.withValues(alpha: 0.07),
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
                    'assets/images/login_hero.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
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
                  maxWidth: 460,
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
          const HexagonLogo(size: 64),
          const SizedBox(height: 12),
          const Center(child: BrandWordmark(fontSize: 30)),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'STRONGER EVERYDAY',
              style: BhauText.mono(
                fontSize: 11,
                color: BhauColors.faint,
                letterSpacing: 3.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome Back',
            textAlign: TextAlign.center,
            style: BhauText.display(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            'Log in to continue your fitness journey',
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
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              labelText: 'Email or Mobile Number',
              prefixIcon: Icon(Icons.person_outline, color: BhauColors.faint, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Enter email or mobile number';
              }
              final isEmail = v.contains('@');
              final isPhone = RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v.trim());
              if (!isEmail && !isPhone) {
                return 'Enter a valid email or mobile number';
              }
              return null;
            },
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
              gradient: BhauColors.cyanLimeGradient,
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
                  : const Text('Log In'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: BhauColors.lime,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  decoration: TextDecoration.underline,
                  decorationColor: BhauColors.lime,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text("New here?  ", style: BhauText.body(fontSize: 13.5)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create a free account',
                        style: TextStyle(
                          color: BhauColors.lime,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: BhauColors.lime),
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

/// Clips the left photo panel into a chevron pointing right at mid-height,
/// matching the angled divider in the reference design.
class _ChevronClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    const base = 70.0; // how far the edge sits in from the right
    const reach = 58.0; // how far the chevron tip pokes back out
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

/// Draws the glowing lime accent line that runs along the chevron edge.
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
      ..color = BhauColors.lime.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final line = Paint()
      ..color = BhauColors.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
