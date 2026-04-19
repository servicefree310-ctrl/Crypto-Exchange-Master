import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/state.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  bool _busy = false;
  String? _err;
  bool _hide = true;

  Future<void> _submit() async {
    setState(() { _busy = true; _err = null; });
    try {
      await context.read<AuthState>().login(_email.text.trim(), _pwd.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _err = e.toString().replaceAll('ApiException', '').replaceAll(RegExp(r'\(\d+\):\s*'), ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            Center(child: Container(
              width: 76, height: 76,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(38)),
              child: const Icon(Icons.account_circle, color: AppColors.primary, size: 42),
            )),
            const SizedBox(height: 14),
            const Center(child: Text('Welcome back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.fg))),
            const SizedBox(height: 4),
            const Center(child: Text('Sign in to your ZEBVIX account', style: TextStyle(color: AppColors.muted, fontSize: 13))),
            const SizedBox(height: 24),
            TextField(
              controller: _email,
              style: const TextStyle(color: AppColors.fg),
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined, color: AppColors.muted)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwd,
              obscureText: _hide,
              style: const TextStyle(color: AppColors.fg),
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                suffixIcon: IconButton(icon: Icon(_hide ? Icons.visibility_off : Icons.visibility, color: AppColors.muted), onPressed: () => setState(() => _hide = !_hide)),
              ),
            ),
            if (_err != null) Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_err!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Login', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text("New here? Create account", style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }
}
