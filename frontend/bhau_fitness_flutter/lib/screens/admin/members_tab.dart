import 'package:flutter/material.dart';
import '../../models/admin_overview.dart';
import '../../models/plan.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class AdminMembersTab extends StatefulWidget {
  const AdminMembersTab({super.key});

  @override
  State<AdminMembersTab> createState() => _AdminMembersTabState();
}

class _AdminMembersTabState extends State<AdminMembersTab> {
  final _adminService = AdminService();
  final _authService = AuthService();
  final _searchCtrl = TextEditingController();
  List<AdminMemberSummary> _members = [];
  List<Plan> _plans = [];
  bool _loading = true;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
    _loadPlans();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final members = await _adminService.fetchMembers(search: _searchCtrl.text.trim());
      if (mounted) setState(() => _members = members);
    } catch (_) {
      // Empty list + pull-to-refresh covers the failure case here.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _authService.fetchPlans();
      if (mounted) setState(() => _plans = plans);
    } catch (_) {
      // Grant dialog will simply show no plans if this fails.
    }
  }

  Future<void> _runAction(AdminMemberSummary m, Future<void> Function() action, String successMsg) async {
    setState(() => _busyId = m.id);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMsg)));
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: $e'), backgroundColor: BhauColors.bad));
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _promote(AdminMemberSummary m) =>
      _runAction(m, () => _adminService.promoteToAdmin(m.id), '${m.fullName} is now an admin');

  Future<void> _deactivate(AdminMemberSummary m) =>
      _runAction(m, () => _adminService.deactivateMember(m.id), "${m.fullName}'s membership was deactivated");

  Future<void> _grant(AdminMemberSummary m) async {
    if (_plans.isEmpty) return;
    final planId = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: BhauColors.bg1,
        title: Text('Grant a plan to ${m.fullName}'),
        children: _plans
            .map((p) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, p.id),
                  child: Text('${p.name} · ₹${p.price.toStringAsFixed(0)}/month',
                      style: const TextStyle(color: BhauColors.ink)),
                ))
            .toList(),
      ),
    );
    if (planId == null) return;
    await _runAction(m, () => _adminService.grantMembership(userId: m.id, planId: planId),
        'Membership granted to ${m.fullName}');
  }

  void _onMenuSelected(AdminMemberSummary m, String value) {
    switch (value) {
      case 'grant':
        _grant(m);
      case 'deactivate':
        _deactivate(m);
      case 'promote':
        _promote(m);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BhauDecor.card(radius: 10),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: BhauColors.faint),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'New members sign up themselves from the app. Use the menu on each row to '
                    'grant a membership, deactivate one, or promote someone to admin.',
                    style: BhauText.body(fontSize: 11.5, color: BhauColors.faint),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Search by name, email, or member code',
              prefixIcon: Icon(Icons.search, color: BhauColors.faint),
            ),
            onSubmitted: (_) => _load(),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _members.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 60),
                            Center(child: Text('No members found.', style: TextStyle(color: BhauColors.muted))),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: _members.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final m = _members[i];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BhauDecor.card(radius: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                        const SizedBox(height: 2),
                                        Text(m.email, style: BhauText.body(fontSize: 11.5, color: BhauColors.faint)),
                                        const SizedBox(height: 4),
                                        Text(
                                          m.planName != null ? '${m.planName} · ${m.membershipStatus}' : 'No active membership',
                                          style: BhauText.mono(fontSize: 10.5, color: BhauColors.cyan),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _busyId == m.id
                                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                      : PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert, color: BhauColors.muted, size: 20),
                                          color: BhauColors.bg1,
                                          onSelected: (v) => _onMenuSelected(m, v),
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(value: 'grant', child: Text('Grant membership')),
                                            PopupMenuItem(value: 'deactivate', child: Text('Deactivate membership')),
                                            PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                                          ],
                                        ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}
