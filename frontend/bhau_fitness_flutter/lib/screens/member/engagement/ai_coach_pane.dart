import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_service.dart';

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
  final List<_ChatMsg> _messages = [];
  final _api = ApiService();
  int? _tdee;
  bool _greeted = false;
  bool _isLoading = false;

  // Same three full pre-written questions as the HTML's `.ai-chips`
  // (short button labels, full question text sent as the chat message).
  static const _chips = [
    ('Post leg-day meal?', 'What should I eat after a leg day?'),
    ('20-min home workout', 'Give me a 20-minute fat loss workout I can do at home.'),
    ('Daily protein?', 'How much protein should I eat per day?'),
  ];

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('bhau_metrics');
      if (raw != null) {
        final metrics = jsonDecode(raw) as Map<String, dynamic>;
        _tdee = metrics['tdee'] as int?;
      }
    } catch (_) {
      // No saved BMI metrics yet — coach just won't reference them.
    }
    if (mounted && !_greeted) {
      _greeted = true;
      final name = context.read<AuthProvider>().profile?.fullName.split(' ').first;
      setState(() {
        _messages.add(_ChatMsg(
          "Hey${name != null ? ' $name' : ''}! I'm your BHAU AI coach. Ask me about workouts, meals, or "
          "recovery — I'll tailor it to your goal.",
          false,
        ));
      });
    }
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _inputCtrl.clear();

    setState(() {
      _messages.add(_ChatMsg(trimmed, true));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final goal = context.read<AuthProvider>().profile?.goal ?? 'muscle';
      final response = await _api.post(
        '/aicoach/chat',
        {
          'message': trimmed,
          'goal': goal,
          'tdee': _tdee,
        },
        auth: true,
      );

      final reply = response['response'] as String? ?? 'No response from coach.';
      if (mounted) {
        setState(() {
          _messages.add(_ChatMsg(reply, false));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMsg(
            "Connection to coach lost. Please try again.",
            false,
          ));
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
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
                      label: Text(c.$1, style: const TextStyle(fontSize: 12)),
                      backgroundColor: BhauColors.bg2,
                      side: const BorderSide(color: BhauColors.line),
                      onPressed: () => _send(c.$2),
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
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == _messages.length) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                              decoration: BoxDecoration(
                                color: BhauColors.bg3,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(BhauColors.cyan),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Typing...",
                                    style: TextStyle(
                                      color: BhauColors.ink.withOpacity(0.6),
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

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
