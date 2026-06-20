import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late String _goal;
  bool _editing = false;

  static const _goals = [
    {'key': 'lose', 'label': 'Lose Fat'},
    {'key': 'muscle', 'label': 'Build Muscle'},
    {'key': 'fit', 'label': 'Get Fit'},
    {'key': 'strength', 'label': 'Strength'},
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().profile;
    _nameCtrl = TextEditingController(text: profile?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: profile?.phone ?? '');
    _goal = profile?.goal ?? 'fit';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      goal: _goal,
    );
    if (ok && mounted) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_editing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _editing = true)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 72, height: 72,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: BhauColors.bg2),
                    alignment: Alignment.center,
                    child: Text(
                      (profile?.fullName.isNotEmpty == true ? profile!.fullName[0] : '?').toUpperCase(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: BhauColors.cyan),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(profile?.memberCode ?? '',
                      style: const TextStyle(color: BhauColors.faint, fontFamily: 'monospace')),
                ),
                const SizedBox(height: 24),
                if (auth.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BhauColors.bad.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(auth.errorMessage!, style: const TextStyle(color: BhauColors.bad)),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _nameCtrl,
                  enabled: _editing,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: profile?.email ?? '',
                  enabled: false, // email is the login identity — not editable here
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  enabled: _editing,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (v) =>
                      (v == null || v.trim().length < 10) ? 'Enter a valid phone number' : null,
                ),
                const SizedBox(height: 16),
                const Text('Goal', style: TextStyle(color: BhauColors.muted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _goals.map((g) {
                    final selected = _goal == g['key'];
                    return ChoiceChip(
                      label: Text(g['label']!),
                      selected: selected,
                      onSelected: _editing ? (_) => setState(() => _goal = g['key']!) : null,
                      selectedColor: BhauColors.cyan.withValues(alpha: 0.2),
                    );
                  }).toList(),
                ),
                if (_editing) ...[
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _save,
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: BhauColors.bg))
                        : const Text('Save Changes'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
