import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin_overview.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  final _adminService = AdminService();
  AdminOverview? _overview;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final overview = await _adminService.fetchOverview();
      if (mounted) setState(() => _overview = overview);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load overview: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: BhauColors.bad)));
    }
    final o = _overview!;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _kpi('Total Members', '${o.totalMembers}', Icons.people_outline),
              _kpi('Active Memberships', '${o.activeMemberships}', Icons.card_membership_outlined),
              _kpi('MRR', currency.format(o.monthlyRecurringRevenue), Icons.payments_outlined),
              _kpi('Active Classes', '${o.activeClasses}', Icons.event_outlined),
            ],
          ),
          const SizedBox(height: 24),
          Text('PLAN DISTRIBUTION', style: BhauText.eyebrow()),
          const SizedBox(height: 12),
          if (o.planDistribution.isEmpty)
            Text('No active memberships yet.', style: BhauText.body())
          else
            ...o.planDistribution.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(width: 90, child: Text(p.planName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: o.activeMemberships == 0 ? 0 : p.memberCount / o.activeMemberships,
                            minHeight: 10,
                            backgroundColor: BhauColors.bg2,
                            color: BhauColors.cyan,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${p.memberCount}', style: BhauText.mono(fontSize: 12)),
                    ],
                  ),
                )),
          const SizedBox(height: 24),
          Text('RECENT SIGNUPS', style: BhauText.eyebrow()),
          const SizedBox(height: 12),
          if (o.recentSignups.isEmpty)
            Text('No signups yet.', style: BhauText.body())
          else
            ...o.recentSignups.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
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
                          ],
                        ),
                      ),
                      Text(m.memberCode, style: BhauText.mono(fontSize: 11, color: BhauColors.cyan)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _kpi(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BhauDecor.card(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BhauColors.cyan, size: 20),
          const Spacer(),
          Text(value, style: BhauText.display(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: BhauText.body(fontSize: 11.5, color: BhauColors.faint)),
        ],
      ),
    );
  }
}
