import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BhauColors.bg1,
      appBar: AppBar(
        backgroundColor: BhauColors.bg2,
        title: const Text(
          'AI COACH',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: BhauColors.cyan,
          labelColor: BhauColors.cyan,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center), text: 'WORKOUT'),
            Tab(icon: Icon(Icons.restaurant), text: 'DIET'),
            Tab(icon: Icon(Icons.lightbulb), text: 'TIPS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AiWorkoutTab(),
          AiDietTab(),
          AiTipsTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WORKOUT TAB
// ─────────────────────────────────────────────────────────────────────────────
class AiWorkoutTab extends StatefulWidget {
  const AiWorkoutTab({super.key});

  @override
  State<AiWorkoutTab> createState() => _AiWorkoutTabState();
}

class _AiWorkoutTabState extends State<AiWorkoutTab> {
  final _api = ApiService();
  String _goal = 'WeightLoss';
  String _level = 'Beginner';
  final _weightController = TextEditingController(text: '70');
  bool _loading = false;
  Map<String, dynamic>? _plan;

  Future<void> _generate() async {
    final weight = double.tryParse(_weightController.text) ?? 70;
    setState(() => _loading = true);
    try {
      final res = await _api.getWorkoutPlan({
        'goal': _goal,
        'weightKg': weight,
        'heightCm': 170.0,
        'experienceLevel': _level,
      });
      setState(() => _plan = res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate plan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormCard(),
          const SizedBox(height: 20),
          if (_loading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(BhauColors.cyan)),
              ),
            )
          else if (_plan != null)
            _buildPlanList()
          else
            _buildEmptyState('Generate your personalized 7-day workout routine above!'),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      color: BhauColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Customize Your Routine',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _goal,
              dropdownColor: BhauColors.bg2,
              decoration: const InputDecoration(labelText: 'Fitness Goal'),
              items: const [
                DropdownMenuItem(value: 'WeightLoss', child: Text('Weight Loss')),
                DropdownMenuItem(value: 'MuscleGain', child: Text('Muscle Gain')),
                DropdownMenuItem(value: 'Endurance', child: Text('Endurance')),
                DropdownMenuItem(value: 'Flexibility', child: Text('Flexibility')),
              ],
              onChanged: (val) => setState(() => _goal = val!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _level,
                    dropdownColor: BhauColors.bg2,
                    decoration: const InputDecoration(labelText: 'Experience'),
                    items: const [
                      DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                      DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                      DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
                    ],
                    onChanged: (val) => setState(() => _level = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generate,
              style: ElevatedButton.styleFrom(backgroundColor: BhauColors.cyan),
              child: const Text('GENERATE WORKOUT PLAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanList() {
    final days = _plan!['days'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.verified, color: BhauColors.cyan, size: 20),
            const SizedBox(width: 8),
            Text(
              '${_plan!['goal']} Plan (${_plan!['duration']})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...days.map((day) => _buildDayCard(day)),
      ],
    );
  }

  Widget _buildDayCard(dynamic day) {
    final name = day['dayName'] as String;
    final focus = day['focus'] as String;
    final exercises = day['exercises'] as List;

    return Card(
      color: BhauColors.bg2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: BhauColors.cyan)),
        subtitle: Text(focus, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        collapsedIconColor: Colors.white70,
        iconColor: BhauColors.cyan,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: exercises.map((ex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.adjust, size: 14, color: BhauColors.warn),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(
                              '${ex['sets']} sets × ${ex['reps']} reps • Rest: ${ex['restSeconds']}s',
                              style: const TextStyle(fontSize: 11, color: Colors.white60),
                            ),
                            if (ex['notes'] != null && ex['notes'].toString().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                ex['notes'],
                                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: BhauColors.cyan.withOpacity(0.8)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIET TAB
// ─────────────────────────────────────────────────────────────────────────────
class AiDietTab extends StatefulWidget {
  const AiDietTab({super.key});

  @override
  State<AiDietTab> createState() => _AiDietTabState();
}

class _AiDietTabState extends State<AiDietTab> {
  final _api = ApiService();
  String _goal = 'WeightLoss';
  final _weightController = TextEditingController(text: '70');
  final _heightController = TextEditingController(text: '170');
  bool _loading = false;
  Map<String, dynamic>? _plan;

  Future<void> _generate() async {
    final weight = double.tryParse(_weightController.text) ?? 70;
    final height = double.tryParse(_heightController.text) ?? 170;
    setState(() => _loading = true);
    try {
      final res = await _api.getDietPlan({
        'goal': _goal,
        'weightKg': weight,
        'heightCm': height,
        'experienceLevel': 'Beginner',
      });
      setState(() => _plan = res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate plan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormCard(),
          const SizedBox(height: 20),
          if (_loading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(BhauColors.cyan)),
              ),
            )
          else if (_plan != null)
            _buildPlanDetails()
          else
            _buildEmptyState('Generate your daily meal schedule and macro targets above!'),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      color: BhauColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Customize Your Nutrition',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _goal,
              dropdownColor: BhauColors.bg2,
              decoration: const InputDecoration(labelText: 'Fitness Goal'),
              items: const [
                DropdownMenuItem(value: 'WeightLoss', child: Text('Weight Loss')),
                DropdownMenuItem(value: 'MuscleGain', child: Text('Muscle Gain')),
                DropdownMenuItem(value: 'Endurance', child: Text('Endurance')),
                DropdownMenuItem(value: 'Flexibility', child: Text('Flexibility')),
              ],
              onChanged: (val) => setState(() => _goal = val!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generate,
              style: ElevatedButton.styleFrom(backgroundColor: BhauColors.cyan),
              child: const Text('GENERATE DIET PLAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetails() {
    final meals = _plan!['meals'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMacrosSummaryCard(),
        const SizedBox(height: 20),
        const Text(
          'Daily Meal Schedule',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 12),
        ...meals.map((meal) => _buildMealCard(meal)),
      ],
    );
  }

  Widget _buildMacrosSummaryCard() {
    return Card(
      color: BhauColors.bg2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: BhauColors.cyan, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Target: ${_plan!['dailyCalories']} kcal / day',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem('PROTEIN', '${_plan!['dailyProteinG']}g', Colors.redAccent),
                _buildMacroItem('CARBS', '${_plan!['dailyCarbsG']}g', BhauColors.cyan),
                _buildMacroItem('FATS', '${_plan!['dailyFatG']}g', BhauColors.warn),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildMealCard(dynamic meal) {
    final type = meal['mealType'] as String;
    final name = meal['name'] as String;
    final desc = meal['description'] as String;
    final cals = meal['calories'] as int;

    return Card(
      color: BhauColors.bg2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: BhauColors.cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BhauColors.cyan),
                  ),
                ),
                Text(
                  '$cals kcal',
                  style: TextStyle(fontWeight: FontWeight.bold, color: BhauColors.warn),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMiniMacro('P: ${meal['proteinG']}g'),
                const SizedBox(width: 8),
                _buildMiniMacro('C: ${meal['carbsG']}g'),
                const SizedBox(width: 8),
                _buildMiniMacro('F: ${meal['fatG']}g'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMacro(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(fontSize: 9, color: Colors.white60)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIPS TAB
// ─────────────────────────────────────────────────────────────────────────────
class AiTipsTab extends StatefulWidget {
  const AiTipsTab({super.key});

  @override
  State<AiTipsTab> createState() => _AiTipsTabState();
}

class _AiTipsTabState extends State<AiTipsTab> {
  final _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _tip;

  @override
  void initState() {
    super.initState();
    _fetchTip();
  }

  Future<void> _fetchTip() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getMotivationalTip();
      setState(() => _tip = res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tip: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: _loading
            ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(BhauColors.cyan))
            : _tip != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BhauColors.cyan.withOpacity(0.1),
                          border: Border.all(color: BhauColors.cyan, width: 1.5),
                        ),
                        child: Icon(Icons.lightbulb_outline, size: 48, color: BhauColors.cyan),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _tip!['category'].toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: BhauColors.warn,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '"${_tip!['tip']}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      OutlinedButton.icon(
                        onPressed: _fetchTip,
                        icon: Icon(Icons.refresh, color: BhauColors.cyan),
                        label: Text('GET ANOTHER TIP', style: TextStyle(color: BhauColors.cyan)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: BhauColors.cyan),
                        ),
                      ),
                    ],
                  )
                : const Text('Failed to load tip.', style: TextStyle(color: Colors.white60)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
Widget _buildEmptyState(String message) {
  return Card(
    color: BhauColors.bg2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          const Icon(Icons.bolt, size: 48, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white60, height: 1.4),
          ),
        ],
      ),
    ),
  );
}
