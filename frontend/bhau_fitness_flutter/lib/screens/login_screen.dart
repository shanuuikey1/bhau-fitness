import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../theme/widgets.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'member/member_shell.dart';

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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = Breakpoints.isDesktop(context);

    final form = _form(auth);

    if (!isDesktop) {
      return Scaffold(
        backgroundColor: BhauColors.bg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: form,
              ),
            ),
          ),
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: form,
                ),
              ),
            ),
          ),
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
          Center(
            child: Image.asset('assets/images/brand_logo.png', height: 76),
          ),
          const SizedBox(height: 16),
          const Center(child: BrandWordmark(fontSize: 34)),
          const SizedBox(height: 6),
          Center(
            child: Text('STRONGER EVERYDAY',
                style: BhauText.mono(fontSize: 12, color: BhauColors.faint, letterSpacing: 4)),
          ),
          const SizedBox(height: 28),
          Text('Welcome back', textAlign: TextAlign.center, style: BhauText.display(fontSize: 24)),
          const SizedBox(height: 6),
          Text('Log in to continue your fitness journey',
              textAlign: TextAlign.center, style: BhauText.body(fontSize: 14)),
          const SizedBox(height: 28),
          if (auth.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BhauColors.bad.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: BhauColors.bad.withValues(alpha: 0.3)),
              ),
              child: Text(auth.errorMessage!, style: const TextStyle(color: BhauColors.bad)),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline, color: BhauColors.faint),
            ),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline, color: BhauColors.faint),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                    color: BhauColors.faint),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
          ),
          const SizedBox(height: 24),
          GradientButton(
            onPressed: auth.isLoading ? null : _submit,
            child: auth.isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: BhauColors.bg))
                : const Text('Log In'),
          ),
          const SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              child: Text('Forgot password?',
                  style: TextStyle(
                    color: BhauColors.lime,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    decorationColor: BhauColors.lime,
                  )),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text("New here?  ", style: BhauText.body(fontSize: 14)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Create a free account',
                          style: TextStyle(
                              color: BhauColors.lime, fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 16, color: BhauColors.lime),
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
