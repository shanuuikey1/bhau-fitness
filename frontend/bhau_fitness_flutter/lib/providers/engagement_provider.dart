import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local (on-device) state for the gamification side of the engagement
/// suite — habits, streak, points, and roadmap progress. None of this is
/// security- or money-sensitive (it mirrors what the HTML site keeps in
/// `localStorage`), so it doesn't need server persistence; it just needs to
/// survive app restarts, which SharedPreferences gives us for free.
class EngagementProvider extends ChangeNotifier {
  static const _habitKeys = ['water', 'workout', 'sleep', 'stretch'];
  static const _habitLabels = {
    'water': 'Drink 8 glasses of water',
    'workout': "Complete today's workout",
    'sleep': 'Sleep 7+ hours',
    'stretch': 'Stretch / mobility work',
  };

  static const _roadmapSteps = [
    ['First Workout', 'Log your very first workout set.'],
    ['3-Day Streak', 'Complete habits for 3 days in a row.'],
    ['First Booking', 'Book your first class.'],
    ['7-Day Streak', 'A full week of consistency.'],
    ['Refer a Friend', 'Share your referral code with someone.'],
    ['30-Day Streak', 'A full month — you have a habit now.'],
  ];

  SharedPreferences? _prefs;
  Map<String, bool> _habitsToday = {};
  int _points = 0;
  int _streakDays = 0;
  String? _lastActiveDate;
  Set<int> _roadmapDone = {};
  List<MapEntry<DateTime, double>> _weightEntries = [];

  Map<String, bool> get habitsToday => _habitsToday;
  int get points => _points;
  int get streakDays => _streakDays;
  Set<int> get roadmapDone => _roadmapDone;
  List<List<String>> get roadmapSteps => _roadmapSteps;
  List<MapEntry<DateTime, double>> get weightEntries => _weightEntries;
  String habitLabel(String key) => _habitLabels[key] ?? key;
  List<String> get habitKeys => _habitKeys;

  List<Map<String, dynamic>> get badges => [
        {'icon': '🔥', 'name': 'On Fire', 'desc': '3-day streak', 'unlocked': _streakDays >= 3},
        {'icon': '💪', 'name': 'Consistent', 'desc': '7-day streak', 'unlocked': _streakDays >= 7},
        {'icon': '🏆', 'name': 'Dedicated', 'desc': '30-day streak', 'unlocked': _streakDays >= 30},
        {'icon': '⭐', 'name': 'Rising Star', 'desc': '100+ points', 'unlocked': _points >= 100},
        {'icon': '👑', 'name': 'Elite', 'desc': '500+ points', 'unlocked': _points >= 500},
      ];

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _points = _prefs!.getInt('eng_points') ?? 0;
    _streakDays = _prefs!.getInt('eng_streak') ?? 0;
    _lastActiveDate = _prefs!.getString('eng_last_active');
    _roadmapDone = (_prefs!.getStringList('eng_roadmap') ?? []).map(int.parse).toSet();
    _weightEntries = (_prefs!.getStringList('eng_weights') ?? []).map((s) {
      final parts = s.split('|');
      return MapEntry(DateTime.parse(parts[0]), double.parse(parts[1]));
    }).toList();

    final today = _todayKey();
    if (_lastActiveDate != today) {
      // New day: reset today's habit checklist. Streak increments are
      // additive only (no break-on-missed-day logic) — same simplicity as
      // the HTML site's own localStorage-based streak counter.
      _habitsToday = {for (final k in _habitKeys) k: false};
    } else {
      final stored = _prefs!.getStringList('eng_habits_$today') ?? [];
      _habitsToday = {for (final k in _habitKeys) k: stored.contains(k)};
    }
    notifyListeners();
  }

  Future<void> toggleHabit(String key) async {
    final wasDone = _habitsToday[key] ?? false;
    _habitsToday[key] = !wasDone;
    final today = _todayKey();
    await _prefs!.setStringList(
      'eng_habits_$today',
      _habitsToday.entries.where((e) => e.value).map((e) => e.key).toList(),
    );

    if (!wasDone) {
      _points += 5;
      await _prefs!.setInt('eng_points', _points);
    }

    final allDone = _habitsToday.values.every((v) => v);
    if (allDone) await _bumpStreakIfNeeded();

    notifyListeners();
  }

  Future<void> _bumpStreakIfNeeded() async {
    final today = _todayKey();
    if (_lastActiveDate == today) return; // already counted today
    _streakDays += 1;
    _lastActiveDate = today;
    await _prefs!.setInt('eng_streak', _streakDays);
    await _prefs!.setString('eng_last_active', today);
  }

  Future<void> toggleRoadmapStep(int index) async {
    if (_roadmapDone.contains(index)) {
      _roadmapDone.remove(index);
    } else {
      _roadmapDone.add(index);
      _points += 20;
      await _prefs!.setInt('eng_points', _points);
    }
    await _prefs!.setStringList('eng_roadmap', _roadmapDone.map((i) => i.toString()).toList());
    notifyListeners();
  }

  Future<void> addWeightEntry(double kg) async {
    final entry = MapEntry(DateTime.now(), kg);
    _weightEntries = [..._weightEntries, entry];
    await _prefs!.setStringList(
      'eng_weights',
      _weightEntries.map((e) => '${e.key.toIso8601String()}|${e.value}').toList(),
    );
    notifyListeners();
  }

  /// Demo leaderboard — the HTML site shows a current-month ranking with no
  /// real social backend either; this blends the real local point total in
  /// with a few static demo members so it doesn't look empty on first run.
  List<Map<String, dynamic>> leaderboard(String myName) {
    final entries = [
      {'name': 'Rohit Sahu', 'points': 480},
      {'name': 'Anjali Verma', 'points': 365},
      {'name': 'Deepak Thakur', 'points': 290},
      {'name': myName, 'points': _points, 'me': true},
      {'name': 'Sneha Patil', 'points': 110},
    ];
    entries.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    return entries;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
