import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';

class ReferPane extends StatelessWidget {
  const ReferPane({super.key});

  @override
  Widget build(BuildContext context) {
    final code = context.watch<AuthProvider>().profile?.memberCode ?? 'BHAU-0000';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BhauColors.line2),
            gradient: LinearGradient(
              colors: [BhauColors.cyan.withValues(alpha: 0.08), BhauColors.lime.withValues(alpha: 0.08)],
            ),
          ),
          child: Column(
            children: [
              Text('GIVE A FRIEND A FREE CLASS', style: BhauText.eyebrow(), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('YOUR CODE', style: BhauText.mono(fontSize: 10, color: BhauColors.faint)),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BhauColors.line2, style: BorderStyle.solid),
                  color: BhauColors.bg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(code, style: BhauText.mono(fontSize: 18, weight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Referral code copied')),
                        );
                      },
                      child: const Icon(Icons.copy, size: 16, color: BhauColors.cyan),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _tier('3', 'Friends', '1 Month Free')),
            const SizedBox(width: 10),
            Expanded(child: _tier('5', 'Friends', 'Free PT Session')),
          ],
        ),
      ],
    );
  }

  Widget _tier(String n, String unit, String reward) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BhauDecor.card(radius: 12),
      child: Column(
        children: [
          Text(n, style: BhauText.display(fontSize: 22, color: BhauColors.lime)),
          Text(unit, style: BhauText.mono(fontSize: 10, color: BhauColors.faint)),
          const SizedBox(height: 8),
          Text(reward, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
