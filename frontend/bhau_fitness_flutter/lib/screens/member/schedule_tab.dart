import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/booking.dart';
import '../../models/class_session.dart';
import '../../services/portal_service.dart';
import '../../theme/app_theme.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  final _portalService = PortalService();
  List<ClassSession> _classes = [];
  List<Booking> _myBookings = [];
  bool _loading = true;
  int? _actingClassId;
  Set<int> _waitlisted = {};

  @override
  void initState() {
    super.initState();
    _load();
    _loadWaitlist();
  }

  Future<void> _loadWaitlist() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _waitlisted = (prefs.getStringList('bhau_waitlist') ?? []).map(int.parse).toSet());
    }
  }

  // Same local-only concept as the HTML's `joinWaitlist()` — there's no
  // backend table for this, it just remembers interest on this device.
  Future<void> _toggleWaitlist(int classId) async {
    setState(() {
      if (_waitlisted.contains(classId)) {
        _waitlisted.remove(classId);
      } else {
        _waitlisted.add(classId);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bhau_waitlist', _waitlisted.map((i) => i.toString()).toList());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _portalService.fetchClasses(),
        _portalService.fetchMyBookings(),
      ]);
      setState(() {
        _classes = results[0] as List<ClassSession>;
        _myBookings = results[1] as List<Booking>;
      });
    } catch (_) {
      // The empty-state copy below covers a failed load too — pull to retry.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Next upcoming calendar date that falls on this class's weekly day-of-week.
  DateTime _nextOccurrence(int isoDayOfWeek) {
    final now = DateTime.now();
    final todayIso = now.weekday; // Dart's DateTime.weekday is already 1=Mon..7=Sun
    var diff = isoDayOfWeek - todayIso;
    if (diff < 0) diff += 7;
    return DateTime(now.year, now.month, now.day).add(Duration(days: diff));
  }

  Booking? _bookingFor(ClassSession c, DateTime date) {
    for (final b in _myBookings) {
      if (b.classSessionId == c.id &&
          b.classDate.year == date.year &&
          b.classDate.month == date.month &&
          b.classDate.day == date.day) {
        return b;
      }
    }
    return null;
  }

  Future<void> _book(ClassSession c, DateTime date) async {
    setState(() => _actingClassId = c.id);
    try {
      final booking = await _portalService.bookClass(classSessionId: c.id, classDate: date);
      setState(() => _myBookings = [..._myBookings, booking]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booked ${c.title}!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not book: $e'), backgroundColor: BhauColors.bad));
      }
    } finally {
      if (mounted) setState(() => _actingClassId = null);
    }
  }

  Future<void> _cancel(Booking booking) async {
    setState(() => _actingClassId = booking.classSessionId);
    try {
      await _portalService.cancelBooking(booking.id);
      setState(() => _myBookings.removeWhere((b) => b.id == booking.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not cancel: $e'), backgroundColor: BhauColors.bad));
      }
    } finally {
      if (mounted) setState(() => _actingClassId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _load,
      child: _classes.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                SizedBox(height: 80),
                Center(child: Text("Couldn't load the schedule. Pull down to retry.", style: TextStyle(color: BhauColors.muted))),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _classes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final c = _classes[i];
                final date = _nextOccurrence(c.dayOfWeek);
                final booking = _bookingFor(c, date);
                final isFull = c.isFull;
                final isActing = _actingClassId == c.id;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BhauDecor.card(border: booking != null ? BhauColors.cyan : null),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(weekdayNames[c.dayOfWeek].substring(0, 3).toUpperCase(),
                                style: BhauText.mono(fontSize: 10.5, color: BhauColors.cyan, weight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(c.startTimeShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 3),
                            Text('${c.trainerName} · ${c.level}',
                                style: BhauText.body(fontSize: 12, color: BhauColors.faint)),
                            const SizedBox(height: 3),
                            Text('${c.bookedCount}/${c.capacity} booked',
                                style: BhauText.mono(fontSize: 10.5, color: BhauColors.faint)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      isActing
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : booking != null
                              ? OutlinedButton(
                                  onPressed: () => _cancel(booking),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: BhauColors.bad,
                                    side: const BorderSide(color: BhauColors.bad),
                                  ),
                                  child: const Text('Cancel'),
                                )
                              : isFull
                                  ? OutlinedButton(
                                      onPressed: () => _toggleWaitlist(c.id),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _waitlisted.contains(c.id) ? BhauColors.lime : BhauColors.faint,
                                        side: BorderSide(color: _waitlisted.contains(c.id) ? BhauColors.lime : BhauColors.line2),
                                      ),
                                      child: Text(_waitlisted.contains(c.id) ? 'On Waitlist ✓' : 'Join Waitlist'),
                                    )
                                  : ElevatedButton(
                                      onPressed: () => _book(c, date),
                                      style: ElevatedButton.styleFrom(backgroundColor: BhauColors.cyan),
                                      child: const Text('Book'),
                                    ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
