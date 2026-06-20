import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_shell.dart';
import '../landing/landing_screen.dart';
import '../profile_screen.dart';
import 'dashboard_tab.dart';
import 'engagement_tab.dart';
import 'schedule_tab.dart';

/// Replaces the old single-screen HomeScreen — the logged-in member's home,
/// with a bottom-nav shell mirroring the HTML site's member portal sections.
class MemberShell extends StatefulWidget {
  const MemberShell({super.key});

  @override
  State<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends State<MemberShell> {
  int _index = 0;

  static const _titles = ['Dashboard', 'Schedule', 'Engagement', 'Profile'];

  static const _tabs = [
    DashboardTab(),
    ScheduleTab(),
    EngagementTab(),
    ProfileScreen(),
  ];

  Future<void> _signOut() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Profile already renders its own AppBar (with the edit action), so the
    // shell-level AppBar would double up — skip it on that tab.
    final showShellAppBar = _index != 3;
    final isAdmin = context.watch<AuthProvider>().profile?.isAdmin ?? false;

    return Scaffold(
      appBar: showShellAppBar
          ? AppBar(
              title: Text(_titles[_index]),
              actions: [
                if (isAdmin)
                  IconButton(
                    tooltip: 'Admin Panel',
                    icon: const Icon(Icons.shield_outlined, color: BhauColors.lime),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminShell()),
                    ),
                  ),
                IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
              ],
            )
          : null,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: BhauColors.bg1,
        indicatorColor: BhauColors.cyan.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard, color: BhauColors.cyan), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today, color: BhauColors.cyan), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events, color: BhauColors.cyan), label: 'Engage'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: BhauColors.cyan), label: 'Profile'),
        ],
      ),
    );
  }
}
