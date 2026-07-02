import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/engagement_provider.dart';
import 'providers/notification_provider.dart';
import 'theme/app_theme.dart';
import 'brand_config.dart';
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
        ChangeNotifierProvider(create: (_) => NotificationProvider()..fetchUnreadCount()),
      ],
      child: MaterialApp(
        title: activeTenant.brandName,
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

class _SplashGateState extends State<SplashGate> with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Start animations
    _bgController.forward();
    _logoController.forward();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    final auth = context.read<AuthProvider>();
    final startTime = DateTime.now();
    
    // Check auto login in parallel
    await auth.tryAutoLogin();
    
    final elapsed = DateTime.now().difference(startTime);
    // Show the splash just long enough to not flash (the web loader has
    // already covered engine startup) — long waits here read as lag.
    final remaining = const Duration(milliseconds: 1100) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;

    // Premium fade transition to next screen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            auth.status == AuthStatus.authenticated
                ? const MemberShell()
                : const LandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BhauColors.bg1,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Ken Burns Zooming Background Image (Fit Guy)
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final scale = 1.0 + (_bgController.value * 0.08);
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Image.asset(
              'assets/images/splash_fit_guy.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Cinematic Gradient Overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                  BhauColors.bg1.withOpacity(0.95),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 3. Premium Animated Logo & Brand Info
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40),

                // Center Brand Logo & Text
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    final opacity = Curves.easeOut.transform(_logoController.value);
                    final scale = 0.85 + (Curves.elasticOut.transform(_logoController.value) * 0.15);
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing Bolt Logo
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BhauColors.bg2.withOpacity(0.85),
                          boxShadow: [
                            BoxShadow(
                              color: BhauColors.cyan.withOpacity(0.25),
                              blurRadius: 30,
                              spreadRadius: 6,
                            ),
                          ],
                          border: Border.all(
                            color: BhauColors.cyan.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.bolt,
                            size: 58,
                            color: BhauColors.cyan,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Brand Name
                      Text(
                        activeTenant.brandName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 7.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      Text(
                        'UNLEASH YOUR BHAU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4.5,
                          color: BhauColors.cyan.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Loading & Subtitle
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sleek neon loading line
                      SizedBox(
                        width: 130,
                        height: 2.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: const LinearProgressIndicator(
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(BhauColors.cyan),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'PREMIUM FITNESS PLATFORM',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
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
