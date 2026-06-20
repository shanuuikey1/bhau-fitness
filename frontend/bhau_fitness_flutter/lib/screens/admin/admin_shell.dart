import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'members_tab.dart';
import 'memberships_tab.dart';
import 'overview_tab.dart';
import 'schedule_tab.dart';

/// Only reachable from MemberShell when the logged-in member's role is
/// "Admin" — see the shield icon in MemberShell's app bar.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _titles = ['Overview', 'Members', 'Memberships', 'Schedule'];

  static const _tabs = [
    AdminOverviewTab(),
    AdminMembersTab(),
    AdminMembershipsTab(),
    AdminScheduleTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin · ${_titles[_index]}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: BhauColors.bg1,
        indicatorColor: BhauColors.lime.withValues(alpha: 0.18),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: BhauColors.lime), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people, color: BhauColors.lime), label: 'Members'),
          NavigationDestination(icon: Icon(Icons.card_membership_outlined), selectedIcon: Icon(Icons.card_membership, color: BhauColors.lime), label: 'Plans'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event, color: BhauColors.lime), label: 'Schedule'),
        ],
      ),
    );
  }
}
