import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/api.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _busy = false;
  String? _msg;
  String? _qrSecret;

  Future<void> _enable() async {
    setState(() { _busy = true; _msg = null; });
    try {
      final r = await Api.enable2FA();
      if (r is Map) _qrSecret = (r['secret'] ?? r['otpauth'] ?? '').toString();
      setState(() => _msg = '2FA enabled. Scan secret in your authenticator.');
    } catch (e) {
      setState(() => _msg = e.toString().replaceAll(RegExp(r'(ApiException)|(\(\d+\):\s*)'), ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disable() async {
    final codeCtrl = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('Disable 2FA', style: TextStyle(color: AppColors.fg)),
      content: TextField(controller: codeCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.fg), decoration: const InputDecoration(labelText: '6-digit code', labelStyle: TextStyle(color: AppColors.muted))),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Disable'))],
    ));
    if (ok != true) return;
    setState(() { _busy = true; _msg = null; });
    try {
      await Api.disable2FA(codeCtrl.text);
      setState(() { _msg = '2FA disabled'; _qrSecret = null; });
    } catch (e) {
      setState(() => _msg = e.toString().replaceAll(RegExp(r'(ApiException)|(\(\d+\):\s*)'), ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _revoke() async {
    setState(() { _busy = true; _msg = null; });
    try { await Api.revokeSessions(); setState(() => _msg = 'Other sessions revoked'); }
    catch (e) { setState(() => _msg = e.toString().replaceAll(RegExp(r'(ApiException)|(\(\d+\):\s*)'), '')); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        _card('Two-Factor Authentication', 'Add an extra layer of security with TOTP', [
          if (_qrSecret != null && _qrSecret!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Secret:', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                SelectableText(_qrSecret!, style: const TextStyle(color: AppColors.accent, fontFamily: 'monospace', fontSize: 12)),
                TextButton.icon(icon: const Icon(Icons.copy, size: 14), label: const Text('Copy'), onPressed: () => Clipboard.setData(ClipboardData(text: _qrSecret!))),
              ]),
            ),
          Row(children: [
            Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.success), onPressed: _busy ? null : _enable, child: const Text('Enable'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: _busy ? null : _disable, child: const Text('Disable'))),
          ]),
        ]),
        _card('Sessions', 'Sign out from all other devices', [
          FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.danger), onPressed: _busy ? null : _revoke, child: const Text('Revoke other sessions')),
        ]),
        if (_msg != null) Padding(padding: const EdgeInsets.all(12), child: Text(_msg!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.accent))),
      ]),
    );
  }

  Widget _card(String title, String desc, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(title, style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w800, fontSize: 14)),
      const SizedBox(height: 4),
      Text(desc, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      const SizedBox(height: 10),
      ...children,
    ]),
  );
}
