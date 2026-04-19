import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});
  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  Map<String, dynamic>? _kyc;
  bool _loading = true;
  bool _busy = false;
  String? _msg;

  final _name = TextEditingController();
  final _pan = TextEditingController();
  final _aadhaar = TextEditingController();
  final _dob = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.kycMy();
      if (r is Map) {
        _kyc = Map<String, dynamic>.from(r);
        _name.text = _kyc?['fullName']?.toString() ?? '';
        _pan.text = _kyc?['panNumber']?.toString() ?? '';
        _aadhaar.text = _kyc?['aadhaarNumber']?.toString() ?? '';
        _dob.text = _kyc?['dob']?.toString() ?? '';
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    setState(() { _busy = true; _msg = null; });
    try {
      await Api.kycSubmit({'fullName': _name.text, 'panNumber': _pan.text, 'aadhaarNumber': _aadhaar.text, 'dob': _dob.text});
      setState(() => _msg = 'KYC submitted. Awaiting review.');
      _load();
    } catch (e) {
      setState(() => _msg = e.toString().replaceAll(RegExp(r'(ApiException)|(\(\d+\):\s*)'), ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = (_kyc?['status'] ?? 'not_submitted').toString();
    final color = status == 'approved' ? AppColors.success : status == 'rejected' ? AppColors.danger : AppColors.accent;
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Verification', style: TextStyle(fontWeight: FontWeight.w800))),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) :
        ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.4))),
            child: Row(children: [
              Icon(status == 'approved' ? Icons.verified : Icons.pending_actions, color: color),
              const SizedBox(width: 10),
              Text('Status: ${status.toUpperCase()}', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
            ]),
          ),
          const SizedBox(height: 16),
          TextField(controller: _name, style: const TextStyle(color: AppColors.fg), decoration: const InputDecoration(labelText: 'Full Name (as per PAN)', labelStyle: TextStyle(color: AppColors.muted), border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _pan, style: const TextStyle(color: AppColors.fg), decoration: const InputDecoration(labelText: 'PAN Number', labelStyle: TextStyle(color: AppColors.muted), border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _aadhaar, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.fg), decoration: const InputDecoration(labelText: 'Aadhaar Number', labelStyle: TextStyle(color: AppColors.muted), border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _dob, style: const TextStyle(color: AppColors.fg), decoration: const InputDecoration(labelText: 'DOB (YYYY-MM-DD)', labelStyle: TextStyle(color: AppColors.muted), border: OutlineInputBorder())),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _busy || status == 'approved' ? null : _submit,
            child: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(status == 'approved' ? 'Already Verified' : 'Submit KYC', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          if (_msg != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_msg!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.accent))),
        ]),
    );
  }
}
