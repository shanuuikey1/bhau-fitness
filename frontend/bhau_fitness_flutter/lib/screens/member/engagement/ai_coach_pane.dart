import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Canned/rule-based responder — no live LLM integration is in scope here,
/// same spirit as the HTML site's "AI Coach" chips (nutrition/workout/recovery
/// tips), just without a real backend call behind it.
class AiCoachPane extends StatefulWidget {
  const AiCoachPane({super.key});

  @override
  State<AiCoachPane> createState() => _AiCoachPaneState();
}

class _ChatMsg {
  final String text;
  final bool isUser;
  _ChatMsg(this.text, this.isUser);
}

class _AiCoachPaneState extends State<AiCoachPane> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMsg> _messages = [
    _ChatMsg("Hey! I'm your BHAU coach. Ask me about nutrition, workouts, or recovery.", false),
  ];

  static const _chips = ['Nutrition tips', 'Workout advice', 'Recovery help', 'Motivation'];

  String _respond(String input) {
    final q = input.toLowerCase();
    if (q.contains('nutrition') || q.contains('diet') || q.contains('eat')) {
      return 'Aim for ~1.6–2g of protein per kg of bodyweight, prioritize whole foods, '
          "and don't fear carbs around your training sessions — they fuel performance.";
    }
    if (q.contains('workout') || q.contains('exercise') || q.contains('train')) {
      return "Progressive overload is king — add a little weight or a rep each week. "
          'Pair compound lifts (squat, deadlift, bench, row) with 2-3 accessory movements.';
    }
    if (q.contains('recover') || q.contains('sore') || q.contains('rest') || q.contains('sleep')) {
      return 'Recovery is where the gains actually happen — aim for 7-9 hours of sleep, '
          'stay hydrated, and take at least one full rest day between hard sessions on the same muscle group.';
    }
    if (q.contains('motivat') || q.contains('tired') || q.contains('lazy')) {
      return "Showing up on the hard days is the whole game. You don't need to feel motivated — "
          'just get through the warm-up, momentum usually takes care of the rest.';
    }
    return "Good question! For anything specific, ask me about nutrition, workouts, or recovery — "
        "that's where I'm most useful right now.";
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(text.trim(), true));
      _messages.add(_ChatMsg(_respond(text), false));
    });
    _inputCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
      children: [
        Wrap(
          spacing: 8,
          children: _chips
              .map((c) => ActionChip(
                    label: Text(c, style: const TextStyle(fontSize: 12)),
                    backgroundColor: BhauColors.bg2,
                    side: const BorderSide(color: BhauColors.line),
                    onPressed: () => _send(c),
                  ))
              .toList(),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Container(
            decoration: BhauDecor.card(radius: 14),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(14),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      return Align(
                        alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: m.isUser ? BhauColors.cyan : BhauColors.bg3,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(m.text,
                              style: TextStyle(
                                color: m.isUser ? BhauColors.bg : BhauColors.ink,
                                fontSize: 13.5,
                                fontWeight: m.isUser ? FontWeight.w600 : FontWeight.normal,
                              )),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: BhauColors.line))),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputCtrl,
                          decoration: const InputDecoration(hintText: 'Ask your coach...'),
                          onSubmitted: _send,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: BhauColors.cyan),
                        onPressed: () => _send(_inputCtrl.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}
