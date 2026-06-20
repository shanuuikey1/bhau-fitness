import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'section_scaffold.dart';

class BmiSection extends StatefulWidget {
  const BmiSection({super.key});

  @override
  State<BmiSection> createState() => _BmiSectionState();
}

class _BmiSectionState extends State<BmiSection> {
  final _heightCtrl = TextEditingController(text: '170');
  final _weightCtrl = TextEditingController(text: '70');
  final _ageCtrl = TextEditingController(text: '28');
  String _gender = 'male';

  double? _bmi;
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

  void _calculate() {
    final heightCm = double.tryParse(_heightCtrl.text);
    final weightKg = double.tryParse(_weightCtrl.text);
    final age = double.tryParse(_ageCtrl.text);
    if (heightCm == null || weightKg == null || age == null || heightCm <= 0) return;

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    // Mifflin-St Jeor — same formula the HTML's BMI calculator uses.
    final bmr = _gender == 'male'
        ? (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5
        : (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    final tdee = bmr * 1.45; // moderate activity multiplier

    String category;
    Color color;
    if (bmi < 18.5) {
      category = 'Underweight';
      color = BhauColors.cyan;
    } else if (bmi < 25) {
      category = 'Healthy Weight';
      color = BhauColors.ok;
    } else if (bmi < 30) {
      category = 'Overweight';
      color = BhauColors.warn;
    } else {
      category = 'Obese';
      color = BhauColors.bad;
    }

    setState(() {
      _bmi = bmi;
      _bmr = bmr;
      _tdee = tdee;
      _category = category;
      _categoryColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'FREE TOOL',
            title: 'KNOW YOUR NUMBERS',
            subtitle: 'BMI, BMR & daily calorie target — calculated instantly, no account needed.',
          ),
          Container(
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
                        value: _gender,
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
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(backgroundColor: BhauColors.cyan),
                  child: const Text('Calculate'),
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
                      _resultStat('BMR', '${_bmr!.round()}', 'kcal/day'),
                      _resultStat('TDEE', '${_tdee!.round()}', 'kcal/day'),
                    ],
                  ),
                ],
              ],
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
        Text(value, style: BhauText.display(fontSize: 22)),
        Text(unit, style: BhauText.body(fontSize: 10, color: BhauColors.faint)),
      ],
    );
  }
}
