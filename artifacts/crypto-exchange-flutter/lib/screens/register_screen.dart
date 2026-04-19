import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pwd = TextEditingController();
  final _ref = TextEditingController();
  bool _busy = false;
  String? _err;

  Future<void> _submit() async {
    setState(() { _busy = true; _err = null; });
    try {
      await context.read<AuthState>().register({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'password': _pwd.text,
        if (_ref.text.trim().isNotEmpty) 'referralCode': _ref.text.trim(),
      });
      if (mounted) { Navigator.popUntil(context, (r) => r.isFirst); }
    } catch (e) {
      setState(() => _err = e.toString().replaceAll('ApiException', '').replaceAll(RegExp(r'\(\d+\):\s*'), ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            const Text('Create your ZEBVIX account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.fg)),
            const SizedBox(height: 4),
            const Text('Start trading in minutes', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 18),
            _field(_name, 'Full name', Icons.person_outline),
            const SizedBox(height: 10),
            _field(_email, 'Email', Icons.email_outlined),
            const SizedBox(height: 10),
            _field(_phone, 'Phone (optional)', Icons.phone_outlined),
            const SizedBox(height: 10),
            _field(_pwd, 'Password', Icons.lock_outline, obscure: true),
            const SizedBox(height: 10),
            _field(_ref, 'Referral code (optional)', Icons.card_giftcard),
            if (_err != null) Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_err!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {bool obscure = false}) =>
      TextField(
        controller: c,
        obscureText: obscure,
        style: const TextStyle(color: AppColors.fg),
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: AppColors.muted), border: const OutlineInputBorder()),
      );
}
