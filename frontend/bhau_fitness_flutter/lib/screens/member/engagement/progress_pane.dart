import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/workout_log.dart';
import '../../../providers/engagement_provider.dart';
import '../../../services/portal_service.dart';
import '../../../theme/app_theme.dart';

class ProgressPane extends StatefulWidget {
  const ProgressPane({super.key});

  @override
  State<ProgressPane> createState() => _ProgressPaneState();
}

class _ProgressPaneState extends State<ProgressPane> {
  final _portalService = PortalService();
  final _weightCtrl = TextEditingController();
  List<WorkoutLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final logs = await _portalService.fetchWorkoutLogs();
      if (mounted) setState(() => _logs = logs);
    } catch (_) {
      // Chart below just renders empty — no need for a blocking error here.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  /// Total sets×reps×weight per day, most recent 7 days that have a log.
  Map<DateTime, double> get _volumeByDay {
    final map = <DateTime, double>{};
    for (final log in _logs) {
      final day = DateTime(log.loggedDate.year, log.loggedDate.month, log.loggedDate.day);
      map[day] = (map[day] ?? 0) + (log.sets * log.reps * log.weightKg);
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return Map.fromEntries(sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted);
  }

  @override
  Widget build(BuildContext context) {
    final engagement = context.watch<EngagementProvider>();
    final volume = _volumeByDay;
    final weights = engagement.weightEntries;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          title: 'TRAINING VOLUME',
          subtitle: 'sets × reps × kg, last 7 logged days',
          child: _loading
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
              : volume.isEmpty
                  ? _empty('Log a workout in the dashboard to see volume here.')
                  : _barChart(volume.values.toList(), volume.keys.map((d) => '${d.day}/${d.month}').toList()),
        ),
        const SizedBox(height: 16),
        _card(
          title: 'WEIGHT TREND',
          subtitle: 'tracked on this device',
          child: Column(
            children: [
              weights.isEmpty
                  ? _empty('No weight entries yet — add one below.')
                  : _barChart(
                      weights.map((e) => e.value).toList(),
                      weights.map((e) => '${e.key.day}/${e.key.month}').toList(),
                    ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final kg = double.tryParse(_weightCtrl.text);
                      if (kg == null) return;
                      context.read<EngagementProvider>().addWeightEntry(kg);
                      _weightCtrl.clear();
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BhauDecor.card(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BhauText.eyebrow()),
          const SizedBox(height: 2),
          Text(subtitle, style: BhauText.mono(fontSize: 10.5, color: BhauColors.faint)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _empty(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(text, style: BhauText.body(fontSize: 13)),
      );

  Widget _barChart(List<double> values, List<String> labels) {
    final maxVal = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final heightFraction = maxVal == 0 ? 0.0 : values[i] / maxVal;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 70 * heightFraction.clamp(0.05, 1.0),
                    decoration: BoxDecoration(
                      gradient: BhauColors.cyanLimeGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(labels[i], style: BhauText.mono(fontSize: 8.5, color: BhauColors.faint)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
