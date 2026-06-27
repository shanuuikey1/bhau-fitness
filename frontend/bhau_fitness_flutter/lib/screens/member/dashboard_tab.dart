import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/membership.dart';
import '../../models/plan.dart';
import '../../models/water_log.dart';
import '../../models/workout_log.dart';
import '../../providers/auth_provider.dart';
import '../../providers/engagement_provider.dart';
import '../../services/auth_service.dart';
import '../../services/portal_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/responsive.dart';

/// Exercise names grouped by body part for the workout-log autocomplete —
/// same categorized list as the HTML's `EXERCISES` map.
const _exercisesByCategory = {
  'Chest': ['Barbell Bench Press', 'Dumbbell Bench Press', 'Incline Bench Press', 'Incline Dumbbell Press', 'Decline Bench Press', 'Dumbbell Flyes', 'Cable Crossover', 'Push-ups', 'Chest Dips', 'Pec Deck Machine'],
  'Back': ['Deadlift', 'Pull-ups', 'Chin-ups', 'Lat Pulldown', 'Barbell Row', 'Dumbbell Row', 'Seated Cable Row', 'T-Bar Row', 'Hyperextensions', 'Face Pulls'],
  'Shoulders': ['Overhead Press', 'Dumbbell Shoulder Press', 'Arnold Press', 'Lateral Raises', 'Front Raises', 'Rear Delt Flyes', 'Barbell Shrugs', 'Upright Row'],
  'Legs': ['Back Squat', 'Front Squat', 'Leg Press', 'Walking Lunges', 'Romanian Deadlift', 'Leg Extension', 'Leg Curl', 'Standing Calf Raise', 'Bulgarian Split Squat', 'Hip Thrust', 'Goblet Squat'],
  'Arms': ['Barbell Curl', 'Dumbbell Curl', 'Hammer Curl', 'Preacher Curl', 'Cable Curl', 'Tricep Pushdown', 'Skull Crushers', 'Close-Grip Bench Press', 'Tricep Dips', 'Overhead Tricep Extension'],
  'Core': ['Plank', 'Crunches', 'Russian Twists', 'Hanging Leg Raise', 'Cable Woodchoppers', 'Ab Wheel Rollout', 'Side Plank', 'Mountain Climbers'],
  'Cardio': ['Treadmill Running', 'Cycling', 'Rowing Machine', 'Jump Rope', 'Stair Climber', 'Elliptical'],
  'Functional': ['Kettlebell Swing', 'Battle Ropes', 'Box Jump', 'Burpees', "Farmer's Walk", 'Sled Push', 'Wall Balls'],
};

/// Flattened (name, category) pairs, same shape as the HTML's `EX_FLAT`.
final _exerciseEntries = _exercisesByCategory.entries
    .expand((e) => e.value.map((name) => (name: name, category: e.key)))
    .toList();

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _authService = AuthService();
  final _portalService = PortalService();

  Membership? _membership;
  List<Plan> _plans = [];
  WaterLog? _water;
  List<WorkoutLog> _recentWorkouts = [];
  int _bookingsCount = 0;
  bool _loading = true;
  int? _joiningPlanId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _authService.fetchMyMembership(),
        _authService.fetchPlans(),
        _portalService.fetchTodayWater(),
        _portalService.fetchWorkoutLogs(),
        _portalService.fetchMyBookings(),
      ]);
      final allWorkouts = results[3] as List<WorkoutLog>;
      final water = results[2] as WaterLog;
      final bookingsCount = (results[4] as List).length;
      setState(() {
        _membership = results[0] as Membership?;
        _plans = results[1] as List<Plan>;
        _water = water;
        _recentWorkouts = allWorkouts.take(5).toList();
        _bookingsCount = bookingsCount;
      });
      if (mounted) {
        final engagement = context.read<EngagementProvider>();
        engagement.setLiveSignals(
          workoutCount: allWorkouts.length,
          bookingCount: bookingsCount,
          waterGlassesToday: water.glassCount,
        );
        final goal = context.read<AuthProvider>().profile?.goal;
        engagement.setHasGoal(goal != null && goal.isNotEmpty);
      }
    } catch (_) {
      // Swallow — each card below handles its own null/empty state, and the
      // pull-to-refresh lets the member retry without a blocking error banner.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setWater(int count) async {
    final clamped = count.clamp(0, 8);
    setState(() => _water = WaterLog(logDate: _water?.logDate ?? DateTime.now(), glassCount: clamped));
    try {
      await _portalService.setTodayWater(clamped);
    } catch (_) {
      // Best-effort — local optimistic update already shown; a failed sync
      // will just be corrected on next pull-to-refresh.
    }
  }

  Future<void> _joinPlan(Plan plan) async {
    setState(() => _joiningPlanId = plan.id);
    try {
      final membership = await _authService.joinPlan(plan.id);
      setState(() => _membership = membership);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome to the ${plan.name} plan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not join plan: $e'), backgroundColor: BhauColors.bad));
      }
    } finally {
      if (mounted) setState(() => _joiningPlanId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?.fullName.split(' ').first ?? 'Champion';
    final streak = context.watch<EngagementProvider>().streakDays;

    return RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                ContentMaxWidth(
                  maxWidth: 900,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Welcome back, $name', style: BhauText.display(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text("Here's where things stand today.", style: BhauText.body()),
                        const SizedBox(height: 20),
                        _membership != null ? _passCard(_membership!, streak) : _noMembershipCard(),
                        const SizedBox(height: 20),
                        _waterCard(),
                        const SizedBox(height: 20),
                        _recentWorkoutsCard(),
                        if (_membership == null) ...[
                          const SizedBox(height: 28),
                          Text('Choose Your Plan', style: BhauText.display(fontSize: 18)),
                          const SizedBox(height: 12),
                          ..._plans.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _planCard(p),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _passCard(Membership m, int streak) {
    final df = DateFormat('d MMM yyyy');
    final isActive = m.status == 'Active';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BhauDecor.gradientPass(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MEMBERSHIP PASS', style: BhauText.eyebrow()),
          const SizedBox(height: 6),
          Text(m.planName.toUpperCase(), style: BhauText.display(fontSize: 26, color: BhauColors.cyan)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isActive ? BhauColors.ok : BhauColors.bad).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(m.status,
                    style: TextStyle(color: isActive ? BhauColors.ok : BhauColors.bad, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Text('₹${m.planPrice.toStringAsFixed(0)}/month', style: BhauText.body()),
            ],
          ),
          const SizedBox(height: 14),
          Text('VALID UNTIL ${df.format(m.endDate)}',
              style: BhauText.mono(fontSize: 10, color: BhauColors.faint)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat('DAYS LEFT', '${m.daysRemaining}', color: BhauColors.lime),
              _miniStat('CLASSES BOOKED', '$_bookingsCount'),
              _miniStat('DAY STREAK', '$streak', color: BhauColors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, {Color color = BhauColors.ink}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: BhauText.mono(fontSize: 10, color: BhauColors.faint)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _noMembershipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BhauDecor.card(radius: 18),
      child: const Column(
        children: [
          Icon(Icons.fitness_center, color: BhauColors.faint, size: 32),
          SizedBox(height: 10),
          Text('No active membership yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          Text('Pick a plan below to get started.', style: TextStyle(color: BhauColors.muted), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _planCard(Plan plan) {
    final isCurrentPlan = _membership?.planName == plan.name && _membership?.status == 'Active';
    final isJoining = _joiningPlanId == plan.id;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BhauColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isCurrentPlan ? BhauColors.lime : BhauColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('₹${plan.price.toStringAsFixed(0)}/month · ${plan.durationDays} days',
                    style: const TextStyle(color: BhauColors.muted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          isCurrentPlan
              ? const Text('Current', style: TextStyle(color: BhauColors.lime, fontWeight: FontWeight.bold))
              : ElevatedButton(
                  onPressed: isJoining ? null : () => _joinPlan(plan),
                  child: isJoining
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: BhauColors.bg))
                      : const Text('Join'),
                ),
        ],
      ),
    );
  }

  Widget _waterCard() {
    final count = _water?.glassCount ?? 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BhauDecor.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: BhauColors.cyan, size: 18),
              const SizedBox(width: 8),
              Text('HYDRATION TODAY', style: BhauText.eyebrow()),
              const Spacer(),
              Text('$count / 8', style: BhauText.display(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: List.generate(8, (i) {
              final filled = i < count;
              // Tapping a filled glass empties it and everything after it;
              // tapping an empty glass fills it and everything before it.
              return GestureDetector(
                onTap: () => _setWater(filled ? i : i + 1),
                child: Container(
                  width: 30, height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: filled ? BhauColors.cyan : BhauColors.line2, width: 2),
                    color: filled ? BhauColors.cyan.withValues(alpha: 0.15) : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _recentWorkoutsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BhauDecor.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('RECENT WORKOUTS', style: BhauText.eyebrow()),
              const Spacer(),
              InkWell(
                onTap: _openLogWorkoutDialog,
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 16, color: BhauColors.lime),
                    SizedBox(width: 4),
                    Text('Log', style: TextStyle(color: BhauColors.lime, fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentWorkouts.isEmpty)
            Text('No workouts logged yet — tap "Log" to add your first one.', style: BhauText.body(fontSize: 13))
          else
            ..._recentWorkouts.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(w.exercise, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
                      Text('${w.sets}×${w.reps} · ${w.weightKg.toStringAsFixed(0)}kg',
                          style: BhauText.mono(fontSize: 11, color: BhauColors.faint)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Future<void> _openLogWorkoutDialog() async {
    var exerciseText = '';
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '10');
    final weightCtrl = TextEditingController(text: '0');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BhauColors.bg1,
        title: const Text('Log a Workout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Autocomplete<({String name, String category})>(
              displayStringForOption: (o) => o.name,
              optionsBuilder: (value) => value.text.isEmpty
                  ? const Iterable.empty()
                  : _exerciseEntries.where((e) => e.name.toLowerCase().contains(value.text.toLowerCase())).take(8),
              onSelected: (s) => exerciseText = s.name,
              fieldViewBuilder: (context, controller, focusNode, onSubmit) => TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(labelText: 'Exercise'),
                onChanged: (v) => exerciseText = v,
              ),
              optionsViewBuilder: (context, onSelected, options) => Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: BhauColors.bg2,
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, i) {
                        final o = options.elementAt(i);
                        return ListTile(
                          dense: true,
                          title: Text(o.name, style: const TextStyle(fontSize: 13)),
                          trailing: Text(o.category, style: BhauText.mono(fontSize: 10, color: BhauColors.faint)),
                          onTap: () => onSelected(o),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: setsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sets'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: repsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps'))),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (exerciseText.trim().isEmpty) return;
              try {
                await _portalService.addWorkoutLog(
                  exercise: exerciseText.trim(),
                  sets: int.tryParse(setsCtrl.text) ?? 1,
                  reps: int.tryParse(repsCtrl.text) ?? 1,
                  weightKg: double.tryParse(weightCtrl.text) ?? 0,
                );
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not log workout: $e'), backgroundColor: BhauColors.bad));
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
}
