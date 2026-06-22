import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/engagement_provider.dart';
import 'theme/app_theme.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/member/member_shell.dart';

/// Enables scrolling by mouse drag and trackpad in addition to the default
/// wheel/touch, so desktop-web visitors can always scroll the page.
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BhauFitnessApp());
}

class BhauFitnessApp extends StatelessWidget {
  const BhauFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EngagementProvider()..load()),
      ],
      child: MaterialApp(
        title: 'BHAU FITNESS',
        debugShowCheckedModeBanner: false,
        theme: buildBhauTheme(),
        scrollBehavior: _AppScrollBehavior(),
        home: const SplashGate(),
        // NOTE: width-capping is done per-screen via ContentMaxWidth (each
        // landing section, and the member/admin shells, center their own
        // content). We deliberately do NOT wrap the whole app in a
        // Center/ConstrainedBox here — doing so gave the root its content
        // loose constraints, which broke mouse-wheel scrolling on web.
      ),
    );
  }
}

/// Shown briefly on app launch while we check for a stored login session,
/// then routes straight to Home (if logged in) or the public Landing page
/// (if not) — so returning members never have to log in again unless their
/// token expired, and new visitors see the marketing site first.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.tryAutoLogin();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => auth.status == AuthStatus.authenticated
              ? const MemberShell()
              : const LandingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'BHAU FITNESS',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ),
    );
  }
}
