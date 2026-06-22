import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_theme.dart';
import 'section_scaffold.dart';

class BmiSection extends StatefulWidget {
  const BmiSection({super.key});

  @override
  State<BmiSection> createState() => _BmiSectionState();
}

class _BmiSectionState extends State<BmiSection> {
  final _heightCtrl = TextEditingController(text: '175');
  final _weightCtrl = TextEditingController(text: '70');
  final _ageCtrl = TextEditingController(text: '28');
  String _gender = 'male';

  // Activity multipliers — same five tiers and values as the HTML's
  // #bmiActivity select (Sedentary..Athlete), default Moderate (1.55).
  static const _activityLevels = [
    {'value': 1.2, 'label': 'Sedentary — little/no exercise'},
    {'value': 1.375, 'label': 'Light — 1–3 days/week'},
    {'value': 1.55, 'label': 'Moderate — 3–5 days/week'},
    {'value': 1.725, 'label': 'Active — 6–7 days/week'},
    {'value': 1.9, 'label': 'Athlete — 2x/day training'},
  ];
  double _activity = 1.55;

  double? _bmi;
  int? _idealLow;
  int? _idealHigh;
  double? _bmr;
  double? _tdee;
  String _category = '';
  Color _categoryColor = BhauColors.cyan;

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    final heightCm = double.tryParse(_heightCtrl.text);
    final weightKg = double.tryParse(_weightCtrl.text);
    final age = double.tryParse(_ageCtrl.text);
    if (heightCm == null || weightKg == null || heightCm <= 0) return;

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    // Ideal weight range from the healthy BMI band (18.5-24.9), same as HTML.
    final idealLow = (18.5 * heightM * heightM).round();
    final idealHigh = (24.9 * heightM * heightM).round();

    String category;
    Color color;
    if (bmi < 18.5) {
      category = 'Underweight';
      color = BhauColors.cyan;
    } else if (bmi < 25) {
      category = 'Normal Weight';
      color = BhauColors.ok;
    } else if (bmi < 30) {
      category = 'Overweight';
      color = BhauColors.warn;
    } else {
      category = 'Obese';
      color = BhauColors.bad;
    }

    double? bmr;
    double? tdee;
    // BMR/TDEE/calorie goals require age, same gate as the HTML calculator.
    if (age != null && age >= 10) {
      bmr = _gender == 'male'
          ? (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5
          : (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
      tdee = bmr * _activity;
    }

    setState(() {
      _bmi = bmi;
      _idealLow = idealLow;
      _idealHigh = idealHigh;
      _bmr = bmr;
      _tdee = tdee;
      _category = category;
      _categoryColor = color;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bhau_metrics', '{'
          '"bmi":${bmi.toStringAsFixed(1)},"category":"$category",'
          '"idealLow":$idealLow,"idealHigh":$idealHigh,'
          '"height":$heightCm,"weight":$weightKg,"age":${age ?? 'null'},"gender":"$_gender",'
          '"bmr":${bmr?.round()},"tdee":${tdee?.round()}'
          '}');
    } catch (_) {
      // Non-critical — the AI Coach pane reads this opportunistically.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'FREE TOOL',
            title: 'BMI CALCULATOR',
            subtitle: 'Get your BMI, daily calorie targets & ideal weight range in seconds.',
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BhauDecor.card(radius: 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _numField('Height (cm)', _heightCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _numField('Weight (kg)', _weightCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _numField('Age', _ageCtrl)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _gender,
                          dropdownColor: BhauColors.bg2,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: const [
                            DropdownMenuItem(value: 'male', child: Text('Male')),
                            DropdownMenuItem(value: 'female', child: Text('Female')),
                          ],
                          onChanged: (v) => setState(() => _gender = v ?? 'male'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<double>(
                    initialValue: _activity,
                    dropdownColor: BhauColors.bg2,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Activity Level'),
                    items: _activityLevels
                        .map((a) => DropdownMenuItem(
                              value: a['value'] as double,
                              child: Text(a['label'] as String, style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _activity = v ?? 1.55),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(backgroundColor: BhauColors.cyan),
                    child: const Text('Calculate My Metrics'),
                  ),
                  if (_bmi != null) ...[
                    const SizedBox(height: 22),
                    const Divider(color: BhauColors.line),
                    const SizedBox(height: 18),
                    Text(_bmi!.toStringAsFixed(1), style: BhauText.display(fontSize: 44)),
                    const SizedBox(height: 4),
                    Text(_category, style: TextStyle(color: _categoryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_bmr != null) _resultStat('BMR', '${_bmr!.round()}', 'kcal at rest'),
                        if (_tdee != null) _resultStat('TDEE', '${_tdee!.round()}', 'kcal to maintain'),
                        _resultStat('Ideal Weight', '$_idealLow–$_idealHigh kg', 'healthy range'),
                      ],
                    ),
                    if (_tdee != null) ...[
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(child: _goalCard('Fat Loss', '${(_tdee! - 500).round()}', BhauColors.cyan)),
                          const SizedBox(width: 10),
                          Expanded(child: _goalCard('Maintain', '${_tdee!.round()}', BhauColors.lime)),
                          const SizedBox(width: 10),
                          Expanded(child: _goalCard('Muscle Gain', '${(_tdee! + 300).round()}', BhauColors.warn)),
                        ],
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text('Add your age to unlock BMR, TDEE & calorie goals.',
                            style: BhauText.body(fontSize: 12, color: BhauColors.faint)),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _resultStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: BhauText.mono(fontSize: 10, color: BhauColors.faint)),
        const SizedBox(height: 6),
        Text(value, style: BhauText.display(fontSize: 18), textAlign: TextAlign.center),
        Text(unit, style: BhauText.body(fontSize: 9.5, color: BhauColors.faint)),
      ],
    );
  }

  Widget _goalCard(String label, String kcal, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: BhauText.mono(fontSize: 9.5, color: color)),
          const SizedBox(height: 4),
          Text(kcal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('kcal/day', style: BhauText.body(fontSize: 9, color: BhauColors.faint)),
        ],
      ),
    );
  }
}
