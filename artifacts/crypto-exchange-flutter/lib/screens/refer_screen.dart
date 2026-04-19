import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api.dart';
import '../services/state.dart';
import '../utils/format.dart';

class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});
  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { final r = await Api.referStats(); if (r is Map) _stats = Map<String, dynamic>.from(r); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    final code = (_stats?['code'] ?? user?['referralCode'] ?? user?['refCode'] ?? '').toString();
    final invited = Fmt.parseNum(_stats?['totalReferrals'] ?? _stats?['count']);
    final earned = Fmt.parseNum(_stats?['totalCommission'] ?? _stats?['earned']);
    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn', style: TextStyle(fontWeight: FontWeight.w800))),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) :
        ListView(padding: const EdgeInsets.all(14), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Earn 30% commission', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Invite friends to ZEBVIX and earn on their trading fees', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Expanded(child: Text(code.isEmpty ? '—' : code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 2))),
                  IconButton(icon: const Icon(Icons.copy, color: Colors.white), onPressed: code.isEmpty ? null : () { Clipboard.setData(ClipboardData(text: code)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _stat('Invited', invited.toStringAsFixed(0), Icons.people, AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: _stat('Earned', '\$${Fmt.num2(earned)}', Icons.payments, AppColors.success)),
          ]),
        ]),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(color: AppColors.fg, fontSize: 18, fontWeight: FontWeight.w800)),
    ]),
  );
}
