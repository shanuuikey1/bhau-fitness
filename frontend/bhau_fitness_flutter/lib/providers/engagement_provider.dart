import 'package:flutter/foundation.dart';
import '../services/secure_storage.dart';

/// Local (on-device) state for the gamification side of the engagement
/// suite — habits, streak, points, and roadmap progress. None of this is
/// security- or money-sensitive (it mirrors what the HTML site keeps in
/// `localStorage`), so it doesn't need server persistence; it just needs to
/// survive app restarts, which SharedPreferences gives us for free.
///
/// Habit list, badge set, roadmap copy, and the leaderboard demo roster are
/// copied verbatim from the HTML's `HABIT_DEFS`/`BADGES`/`ROADMAP`/`DEMO`
/// consts so the gamified content matches the original site exactly, even
/// though (same as the HTML) none of it is backend-persisted.
class EngagementProvider extends ChangeNotifier {
  static const _habitKeys = ['steps', 'water', 'protein', 'sleep', 'train', 'nosugar'];
  static const _habitLabels = {
    'steps': '10,000 steps',
    'water': '2L water',
    'protein': 'Hit protein goal',
    'sleep': '7+ hrs sleep',
    'train': 'Train today',
    'nosugar': 'No added sugar',
  };
  static const _habitIcons = {
    'steps': '🚶',
    'water': '💧',
    'protein': '🍗',
    'sleep': '😴',
    'train': '🏋️',
    'nosugar': '🚫',
  };

  static const _roadmapSteps = [
    ['Fitness Assessment', 'Body metrics, goals & baseline measured'],
    ['Custom Plan Built', 'Training + nutrition tailored to your goal'],
    ['First 4 Weeks', 'Build the habit, learn the movements'],
    ['Week 8 Check-in', 'Measure progress, adjust the plan'],
    ['Week 12 Milestone', 'Visible results & new personal records'],
    ['Transformation', 'Goal reached — time to set the next one'],
  ];

  static const _leaderboardDemo = [
    {'name': 'Vikram S.', 'points': 920},
    {'name': 'Priya N.', 'points': 870},
    {'name': 'Arjun M.', 'points': 805},
    {'name': 'Sneha P.', 'points': 760},
    {'name': 'Rohit K.', 'points': 690},
    {'name': 'Kavya R.', 'points': 635},
    {'name': 'Manish T.', 'points': 580},
  ];

  final SecureStorage _secureStorage = SecureStorage();
  Map<String, bool> _habitsToday = {};
  int _manualPoints = 0;
  int _streakDays = 0;
  String? _lastActiveDate;
  Set<int> _roadmapDone = {};
  List<MapEntry<DateTime, double>> _weightEntries = [];
  bool _hasGoal = false;

  // Live signals pushed in from the dashboard once it fetches real data —
  // these feed both badge unlock checks and the activity-score formula,
  // mirroring the HTML's `activityScore()` which reads `workouts.length`,
  // `waterIntake`, and `profile.streak` from elsewhere on the page.
  int _workoutCount = 0;
  int _bookingCount = 0;
  int _waterGlassesToday = 0;

  Map<String, bool> get habitsToday => _habitsToday;
  int get streakDays => _streakDays;
  Set<int> get roadmapDone => _roadmapDone;
  List<List<String>> get roadmapSteps => _roadmapSteps;
  List<MapEntry<DateTime, double>> get weightEntries => _weightEntries;
  String habitLabel(String key) => _habitLabels[key] ?? key;
  String habitIcon(String key) => _habitIcons[key] ?? '✓';
  List<String> get habitKeys => _habitKeys;

  int get habitsDoneToday => _habitsToday.values.where((v) => v).length;

  /// Same composite formula as the HTML's `activityScore()`: streak*10 +
  /// workouts*5 + today's-habits*8 + weight-logs*3 + manually-earned points
  /// (habit toggles +5, roadmap steps +20 — there's no server-side "points"
  /// column here, so manual points stand in for the HTML's `profile.points`).
  int get score =>
      _streakDays * 10 + _workoutCount * 5 + habitsDoneToday * 8 + _weightEntries.length * 3 + _manualPoints;

  void setLiveSignals({required int workoutCount, required int bookingCount, required int waterGlassesToday}) {
    _workoutCount = workoutCount;
    _bookingCount = bookingCount;
    _waterGlassesToday = waterGlassesToday;
    notifyListeners();
  }

  void setHasGoal(bool value) {
    _hasGoal = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> get badges => [
        {'icon': '🎯', 'name': 'Goal Setter', 'desc': 'Pick a goal', 'unlocked': _hasGoal},
        {'icon': '💪', 'name': 'First Lift', 'desc': 'Log 1 workout', 'unlocked': _workoutCount >= 1},
        {'icon': '🔥', 'name': '10 Workouts', 'desc': 'Log 10 workouts', 'unlocked': _workoutCount >= 10},
        {'icon': '💧', 'name': 'Hydrated', 'desc': 'Hit 8 glasses', 'unlocked': _waterGlassesToday >= 8},
        {'icon': '📅', 'name': 'Class Booker', 'desc': 'Book a class', 'unlocked': _bookingCount >= 1},
        {'icon': '⚖️', 'name': 'Tracker', 'desc': 'Log weight 3x', 'unlocked': _weightEntries.length >= 3},
        {'icon': '🌅', 'name': 'Habit Hero', 'desc': 'All daily habits', 'unlocked': habitsDoneToday == _habitKeys.length},
        {'icon': '⚡', 'name': '7-Day Streak', 'desc': '7-day streak', 'unlocked': _streakDays >= 7},
        {'icon': '🏆', 'name': '30-Day Streak', 'desc': '30-day streak', 'unlocked': _streakDays >= 30},
        {'icon': '👑', 'name': 'Centurion', 'desc': '100-day streak', 'unlocked': _streakDays >= 100},
      ];

  Future<void> load() async {
    // SecureStorage does not require initialization
    _manualPoints = await _secureStorage.readInt('eng_points') ?? 0;
    _streakDays = await _secureStorage.readInt('eng_streak') ?? 0;
    _lastActiveDate = await _secureStorage.read('eng_last_active');
    _hasGoal = await _secureStorage.readBool('eng_has_goal') ?? false;
    _roadmapDone = (await _secureStorage.readStringList('eng_roadmap')).map(int.parse).toSet();
    _weightEntries = (await _secureStorage.readStringList('eng_weights')).map((s) {
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
      final stored = await _secureStorage.readStringList('eng_habits_$today');
      _habitsToday = {for (final k in _habitKeys) k: stored.contains(k)};
    }
    notifyListeners();
  }

  Future<void> toggleHabit(String key) async {
    final wasDone = _habitsToday[key] ?? false;
    _habitsToday[key] = !wasDone;
    final today = _todayKey();
    await _secureStorage.writeStringList(
      'eng_habits_$today',
      _habitsToday.entries.where((e) => e.value).map((e) => e.key).toList(),
    );

    if (!wasDone) {
      _manualPoints += 5;
      await _secureStorage.writeInt('eng_points', _manualPoints);
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
    await _secureStorage.writeInt('eng_streak', _streakDays);
    await _secureStorage.write(key: 'eng_last_active', value: today);
  }

  Future<void> toggleRoadmapStep(int index) async {
    if (_roadmapDone.contains(index)) {
      _roadmapDone.remove(index);
    } else {
      _roadmapDone.add(index);
      _manualPoints += 20;
      await _secureStorage.writeInt('eng_points', _manualPoints);
    }
    await _secureStorage.writeStringList('eng_roadmap', _roadmapDone.map((i) => i.toString()).toList());
    notifyListeners();
  }

  Future<void> addWeightEntry(double kg) async {
    final entry = MapEntry(DateTime.now(), kg);
    _weightEntries = [..._weightEntries, entry];
    await _secureStorage.writeStringList(
      'eng_weights',
      _weightEntries.map((e) => '${e.key.toIso8601String()}|${e.value}').toList(),
    );
    notifyListeners();
  }

  /// Demo leaderboard — the HTML site shows a current-month ranking with no
  /// real social backend either; this blends the real live `score` in with
  /// the same 7 static demo names/points the HTML hardcodes.
  List<Map<String, dynamic>> leaderboard(String myName) {
    final entries = [
      ..._leaderboardDemo,
      {'name': myName, 'points': score, 'me': true},
    ];
    entries.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    return entries;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
