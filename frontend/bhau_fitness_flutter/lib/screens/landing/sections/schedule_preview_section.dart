import 'package:flutter/material.dart';
import '../../../models/class_session.dart';
import '../../../services/portal_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/responsive.dart';
import '../../../theme/widgets.dart';
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

enum _ScheduleView { list, calendar }

class _SchedulePreviewSectionState extends State<SchedulePreviewSection> {
  final _portalService = PortalService();
  List<ClassSession> _classes = [];
  bool _loading = true;
  int _selectedDay = 1; // ISO 1=Mon..7=Sun
  String _selectedType = 'All';
  _ScheduleView _view = _ScheduleView.list;

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
    final types = ['All', ..._classes.map((c) => c.type).toSet()];
    final typeFiltered = _selectedType == 'All' ? _classes : _classes.where((c) => c.type == _selectedType).toList();
    final daysWithClasses = typeFiltered.map((c) => c.dayOfWeek).toSet();
    final dayClasses = typeFiltered.where((c) => c.dayOfWeek == _selectedDay).toList()
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
            Column(
              children: [
                for (int i = 0; i < 4; i++)
                  const Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ShimmerCard(height: 72, radius: 14),
                  ),
              ],
            )
          else if (_classes.isEmpty)
            Text('Schedule unavailable right now.', style: BhauText.body())
          else ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        final w = bounds.width;
                        final leftStop = w > 0 ? 16.0 / w : 0.0;
                        final rightStop = w > 0 ? (w - 16.0) / w : 1.0;
                        return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: const [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                          stops: [0.0, leftStop, rightStop, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(left: 8, right: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: types.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final type = types[i];
                          final selected = type == _selectedType;
                          return ChoiceChip(
                            label: Text(type),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedType = type),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            labelStyle: TextStyle(
                              color: selected ? BhauColors.bg : BhauColors.ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            selectedColor: BhauColors.lime,
                            backgroundColor: BhauColors.bg2,
                            side: BorderSide(color: selected ? BhauColors.lime : BhauColors.line),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _ViewToggle(
                  view: _view,
                  onChanged: (v) => setState(() => _view = v),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_view == _ScheduleView.calendar)
              _CalendarGrid(
                countsByDay: {
                  for (var d = 1; d <= 7; d++) d: typeFiltered.where((c) => c.dayOfWeek == d).length,
                },
                selectedDay: _selectedDay,
                onDaySelected: (d) => setState(() => _selectedDay = d),
              )
            else
              SizedBox(
                height: 46,
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    final w = bounds.width;
                    final leftStop = w > 0 ? 16.0 / w : 0.0;
                    final rightStop = w > 0 ? (w - 16.0) / w : 1.0;
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: const [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                      stops: [0.0, leftStop, rightStop, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 8, right: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final day = i + 1;
                      final selected = day == _selectedDay;
                      final has = daysWithClasses.contains(day);
                      return ChoiceChip(
                        label: Text(weekdayNames[day]),
                        selected: selected,
                        onSelected: has ? (_) => setState(() => _selectedDay = day) : null,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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
              ),
            const SizedBox(height: 16),
            if (dayClasses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No classes on ${weekdayNames[_selectedDay]}.', style: BhauText.body(fontSize: 13)),
              )
            else
              ResponsiveGrid(
                tabletColumns: 2,
                desktopColumns: 2,
                spacing: 10,
                runSpacing: 10,
                children: [for (final c in dayClasses) _classRow(c)],
              ),
          ],
        ],
      ),
    );
  }

  Widget _classRow(ClassSession c) {
    return HoverScale(
      scale: 1.02,
      child: Container(
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
            HoverScale(
              scale: 1.06,
              child: TextButton(
                onPressed: widget.onJoin,
                child: const Text('Join to book', style: TextStyle(color: BhauColors.cyan, fontSize: 12.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.view, required this.onChanged});
  final _ScheduleView view;
  final ValueChanged<_ScheduleView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: BhauColors.bg2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BhauColors.line),
      ),
      child: Row(
        children: [
          _toggleBtn(Icons.view_list, _ScheduleView.list),
          _toggleBtn(Icons.calendar_view_week, _ScheduleView.calendar),
        ],
      ),
    );
  }

  Widget _toggleBtn(IconData icon, _ScheduleView v) {
    final selected = v == view;
    return InkWell(
      onTap: () => onChanged(v),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 30,
        decoration: BoxDecoration(
          color: selected ? BhauColors.cyan.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: selected ? BhauColors.cyan : BhauColors.faint),
      ),
    );
  }
}

/// Weekly Mon-Sun grid with a dot/count per day — stand-in for the HTML's
/// `.cal-grid` / `renderCalendar()`. Tapping a day filters the list below it.
class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.countsByDay, required this.selectedDay, required this.onDaySelected});
  final Map<int, int> countsByDay;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var d = 1; d <= 7; d++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => onDaySelected(d),
                child: HoverScale(
                  scale: 1.05,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: d == selectedDay ? BhauColors.cyan.withValues(alpha: 0.12) : BhauColors.bg2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: d == selectedDay ? BhauColors.cyan : BhauColors.line),
                    ),
                    child: Column(
                      children: [
                        Text(weekdayNames[d].substring(0, 3).toUpperCase(),
                            style: BhauText.mono(fontSize: 9, color: BhauColors.faint)),
                        const SizedBox(height: 6),
                        if ((countsByDay[d] ?? 0) > 0)
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: BhauColors.lime),
                          )
                        else
                          const SizedBox(height: 6),
                        const SizedBox(height: 4),
                        Text('${countsByDay[d] ?? 0}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
