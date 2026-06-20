import 'package:flutter/material.dart';
import '../../../models/class_session.dart';
import '../../../services/portal_service.dart';
import '../../../theme/app_theme.dart';
import 'section_scaffold.dart';

/// Public class-schedule preview (HTML's #schedule section) — visitors can
/// browse the weekly timetable before signing up. Booking itself still
/// requires login, so each row shows a "Join to book" prompt via [onJoin].
class SchedulePreviewSection extends StatefulWidget {
  final VoidCallback onJoin;
  const SchedulePreviewSection({super.key, required this.onJoin});

  @override
  State<SchedulePreviewSection> createState() => _SchedulePreviewSectionState();
}

class _SchedulePreviewSectionState extends State<SchedulePreviewSection> {
  final _portalService = PortalService();
  List<ClassSession> _classes = [];
  bool _loading = true;
  int _selectedDay = 1; // ISO 1=Mon..7=Sun

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final classes = await _portalService.fetchClasses();
      if (mounted) setState(() => _classes = classes);
    } catch (_) {
      // Section just shows its empty state if the API is unreachable.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysWithClasses = _classes.map((c) => c.dayOfWeek).toSet();
    final dayClasses = _classes.where((c) => c.dayOfWeek == _selectedDay).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Section(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'WEEKLY SCHEDULE',
            title: 'FIND YOUR CLASS',
            subtitle: 'Browse the timetable — sign up to reserve your spot.',
          ),
          if (_loading)
            const Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())
          else if (_classes.isEmpty)
            Text('Schedule unavailable right now.', style: BhauText.body())
          else ...[
            // Day filter chips (Mon..Sun).
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final day = i + 1;
                  final selected = day == _selectedDay;
                  final has = daysWithClasses.contains(day);
                  return ChoiceChip(
                    label: Text(weekdayNames[day].substring(0, 3)),
                    selected: selected,
                    onSelected: has ? (_) => setState(() => _selectedDay = day) : null,
                    labelStyle: TextStyle(
                      color: selected ? BhauColors.bg : (has ? BhauColors.ink : BhauColors.faint),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    selectedColor: BhauColors.cyan,
                    backgroundColor: BhauColors.bg2,
                    side: BorderSide(color: selected ? BhauColors.cyan : BhauColors.line),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (dayClasses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No classes on ${weekdayNames[_selectedDay]}.', style: BhauText.body(fontSize: 13)),
              )
            else
              ...dayClasses.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _classRow(c),
                  )),
          ],
        ],
      ),
    );
  }

  Widget _classRow(ClassSession c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BhauDecor.card(radius: 14),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(c.startTimeShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${c.trainerName} · ${c.level}',
                    style: BhauText.body(fontSize: 11.5, color: BhauColors.faint)),
              ],
            ),
          ),
          TextButton(
            onPressed: widget.onJoin,
            child: const Text('Join to book', style: TextStyle(color: BhauColors.cyan, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}
