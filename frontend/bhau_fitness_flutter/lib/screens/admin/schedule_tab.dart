import 'package:flutter/material.dart';
import '../../models/class_session.dart';
import '../../services/admin_service.dart';
import '../../services/portal_service.dart';
import '../../theme/app_theme.dart';

class AdminScheduleTab extends StatefulWidget {
  const AdminScheduleTab({super.key});

  @override
  State<AdminScheduleTab> createState() => _AdminScheduleTabState();
}

class _AdminScheduleTabState extends State<AdminScheduleTab> {
  final _portalService = PortalService();
  final _adminService = AdminService();
  List<ClassSession> _classes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final classes = await _portalService.fetchClasses();
      if (mounted) setState(() => _classes = classes);
    } catch (_) {
      // Empty list below covers a failed load.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deactivate(ClassSession c) async {
    try {
      await _adminService.deactivateClass(c.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not remove class: $e'), backgroundColor: BhauColors.bad));
      }
    }
  }

  Future<void> _openCreateDialog() async {
    final titleCtrl = TextEditingController();
    final trainerCtrl = TextEditingController();
    final levelCtrl = TextEditingController(text: 'All Levels');
    final typeCtrl = TextEditingController(text: 'General');
    final durationCtrl = TextEditingController(text: '60');
    final dayLabelCtrl = TextEditingController(text: 'Weekly');
    final capacityCtrl = TextEditingController(text: '20');
    int dayOfWeek = 1;
    TimeOfDay time = const TimeOfDay(hour: 6, minute: 0);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          backgroundColor: BhauColors.bg1,
          title: const Text('New Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                TextField(controller: trainerCtrl, decoration: const InputDecoration(labelText: 'Trainer')),
                const SizedBox(height: 12),
                TextField(controller: levelCtrl, decoration: const InputDecoration(labelText: 'Level')),
                const SizedBox(height: 12),
                TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Type (e.g. Strength, Cardio)')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (min)'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: dayLabelCtrl, decoration: const InputDecoration(labelText: 'Day label'))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: capacityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity')),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: dayOfWeek,
                  dropdownColor: BhauColors.bg2,
                  decoration: const InputDecoration(labelText: 'Day of week'),
                  items: List.generate(7, (i) => i + 1)
                      .map((d) => DropdownMenuItem(value: d, child: Text(weekdayNames[d])))
                      .toList(),
                  onChanged: (v) => setLocalState(() => dayOfWeek = v ?? 1),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text('Start time: ${time.format(context)}')),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: time);
                        if (picked != null) setLocalState(() => time = picked);
                      },
                      child: const Text('Pick'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final startTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
                try {
                  await _adminService.createClass(
                    dayOfWeek: dayOfWeek,
                    startTime: startTime,
                    title: titleCtrl.text.trim(),
                    trainerName: trainerCtrl.text.trim(),
                    level: levelCtrl.text.trim(),
                    type: typeCtrl.text.trim(),
                    durationMin: int.tryParse(durationCtrl.text) ?? 60,
                    dayLabel: dayLabelCtrl.text.trim(),
                    capacity: int.tryParse(capacityCtrl.text) ?? 20,
                  );
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
      ),
    );

    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        backgroundColor: BhauColors.lime,
        foregroundColor: BhauColors.bg,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                itemCount: _classes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final c = _classes[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BhauDecor.card(radius: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(weekdayNames[c.dayOfWeek].substring(0, 3).toUpperCase(),
                                  style: BhauText.mono(fontSize: 10.5, color: BhauColors.cyan, weight: FontWeight.w700)),
                              Text(c.startTimeShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('${c.type} · ${c.durationMin}min · ${c.trainerName}',
                                  style: BhauText.body(fontSize: 11.5, color: BhauColors.faint)),
                              Text('${c.bookedCount}/${c.capacity} booked',
                                  style: BhauText.mono(fontSize: 10, color: BhauColors.faint)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: BhauColors.bad, size: 20),
                          onPressed: () => _deactivate(c),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
