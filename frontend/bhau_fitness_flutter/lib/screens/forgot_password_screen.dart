import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

/// Two-step password reset mirroring the HTML's reset + new-password forms:
/// step 1 requests a code by email, step 2 takes the code + a new password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _codeSent = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      setState(() => _error = 'Enter a valid email.');
      return;
    }
    setState(() { _loading = true; _error = null; _info = null; });
    try {
      await _authService.forgotPassword(_emailCtrl.text.trim());
      setState(() {
        _codeSent = true;
        _info = 'If that email is registered, a reset code is on its way. '
            'Paste it below with your new password.';
      });
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_codeCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Paste the reset code from your email.');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _authService.resetPassword(
        email: _emailCtrl.text.trim(),
        token: _codeCtrl.text.trim(),
        newPassword: _passCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated — please log in.')),
        );
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not reset password. Check the code and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ContentMaxWidth(
            maxWidth: 480,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(_codeSent ? 'Enter your reset code' : 'Forgot your password?',
                  style: BhauText.display(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                _codeSent
                    ? 'Check your inbox for the code we sent, then set a new password.'
                    : "Enter your email and we'll send you a reset code.",
                style: BhauText.body(),
              ),
              const SizedBox(height: 24),
              if (_error != null) _banner(_error!, BhauColors.bad),
              if (_info != null) _banner(_info!, BhauColors.cyan),
              TextField(
                controller: _emailCtrl,
                enabled: !_codeSent,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              if (_codeSent) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(labelText: 'Reset code (from email)'),
                  maxLines: 2,
                  minLines: 1,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: BhauColors.faint),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : (_codeSent ? _resetPassword : _sendCode),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: BhauColors.bg))
                    : Text(_codeSent ? 'Update Password' : 'Send Reset Code'),
              ),
              if (_codeSent)
                TextButton(
                  onPressed: _loading ? null : _sendCode,
                  child: const Text('Resend code'),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _banner(String text, Color color) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 13)),
      );
}
