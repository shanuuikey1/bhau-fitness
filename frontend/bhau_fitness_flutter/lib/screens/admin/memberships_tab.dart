import 'package:flutter/material.dart';
import '../../models/admin_overview.dart';
import '../../models/plan.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class AdminMembershipsTab extends StatefulWidget {
  const AdminMembershipsTab({super.key});

  @override
  State<AdminMembershipsTab> createState() => _AdminMembershipsTabState();
}

class _AdminMembershipsTabState extends State<AdminMembershipsTab> {
  final _adminService = AdminService();
  final _authService = AuthService();
  List<Plan> _plans = [];
  List<AdminMemberSummary> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _authService.fetchPlans(),
        _adminService.fetchMembers(),
      ]);
      if (mounted) {
        setState(() {
          _plans = results[0] as List<Plan>;
          _members = results[1] as List<AdminMemberSummary>;
        });
      }
    } catch (_) {
      // Empty list below covers a failed load.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Active members grouped by their current plan name.
  Map<String, List<AdminMemberSummary>> get _membersByPlan {
    final map = <String, List<AdminMemberSummary>>{};
    for (final m in _members) {
      if (m.planName == null || m.membershipStatus != 'Active') continue;
      map.putIfAbsent(m.planName!, () => []).add(m);
    }
    return map;
  }

  /// Total active MRR — same "Total active MRR" line the HTML injects above
  /// its memberships view, computed here as Σ(active members × their plan price).
  double get _totalActiveMrr {
    var total = 0.0;
    for (final entry in _membersByPlan.entries) {
      final matches = _plans.where((p) => p.name == entry.key);
      if (matches.isNotEmpty) total += matches.first.price * entry.value.length;
    }
    return total;
  }

  Future<void> _openPlanDialog({Plan? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(text: existing?.price.toStringAsFixed(0) ?? '');
    final durationCtrl = TextEditingController(text: existing?.durationDays.toString() ?? '30');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BhauColors.bg1,
        title: Text(existing == null ? 'New Plan' : 'Edit Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₹/month)')),
            const SizedBox(height: 12),
            TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (days)')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(priceCtrl.text) ?? 0;
              final duration = int.tryParse(durationCtrl.text) ?? 30;
              try {
                if (existing == null) {
                  await _adminService.createPlan(
                      name: nameCtrl.text.trim(), price: price, durationDays: duration, description: descCtrl.text.trim());
                } else {
                  await _adminService.updatePlan(
                      id: existing.id, name: nameCtrl.text.trim(), price: price, durationDays: duration, isActive: true, description: descCtrl.text.trim());
                }
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e'), backgroundColor: BhauColors.bad));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPlanDialog(),
        backgroundColor: BhauColors.lime,
        foregroundColor: BhauColors.bg,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                children: [
                  Text('PLANS', style: BhauText.eyebrow()),
                  const SizedBox(height: 12),
                  ..._plans.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BhauDecor.card(radius: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text('₹${p.price.toStringAsFixed(0)}/month · ${p.durationDays} days',
                                        style: BhauText.body(fontSize: 12, color: BhauColors.faint)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: BhauColors.cyan, size: 20),
                                onPressed: () => _openPlanDialog(existing: p),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                  Text('MEMBERS BY PLAN', style: BhauText.eyebrow()),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: BhauText.body(fontSize: 13, color: BhauColors.faint),
                      children: [
                        const TextSpan(text: 'Total active MRR: '),
                        TextSpan(
                          text: '₹${_totalActiveMrr.toStringAsFixed(0)}',
                          style: const TextStyle(color: BhauColors.lime, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildMembersByPlan(),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildMembersByPlan() {
    final grouped = _membersByPlan;
    if (grouped.isEmpty) {
      return [Text('No active memberships yet.', style: BhauText.body(fontSize: 13))];
    }
    return grouped.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BhauDecor.card(radius: 14),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: BhauColors.cyan,
          collapsedIconColor: BhauColors.muted,
          title: Row(
            children: [
              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: BhauColors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${entry.value.length}',
                    style: const TextStyle(color: BhauColors.cyan, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          children: entry.value
              .map((m) => ListTile(
                    dense: true,
                    title: Text(m.fullName, style: const TextStyle(fontSize: 13.5)),
                    subtitle: Text(m.email, style: BhauText.body(fontSize: 11.5, color: BhauColors.faint)),
                    trailing: Text(m.memberCode, style: BhauText.mono(fontSize: 10.5, color: BhauColors.cyan)),
                  ))
              .toList(),
        ),
      );
    }).toList();
  }
}
