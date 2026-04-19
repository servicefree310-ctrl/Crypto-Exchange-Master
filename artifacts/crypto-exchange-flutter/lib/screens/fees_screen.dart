import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api.dart';
import '../utils/format.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});
  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  Map<String, dynamic>? _my;
  List<dynamic> _tiers = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Future.wait([Api.feesMy(), Api.feesTiers()]);
      _my = r[0] is Map ? Map<String, dynamic>.from(r[0] as Map) : null;
      _tiers = (r[1] is List ? r[1] : []) as List;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fees & VIP', style: TextStyle(fontWeight: FontWeight.w800))),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) :
        ListView(padding: const EdgeInsets.all(12), children: [
          if (_my != null) Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFFC55A00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('VIP Tier', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text('Tier ${_my!['tier'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('30d Volume: \$${Fmt.compact(Fmt.parseNum(_my!['volume30d']))}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _stat('Maker', '${(Fmt.parseNum(_my!['maker']) * 100).toStringAsFixed(3)}%')),
                Expanded(child: _stat('Taker', '${(Fmt.parseNum(_my!['taker']) * 100).toStringAsFixed(3)}%')),
                Expanded(child: _stat('Earned', Fmt.money(Fmt.parseNum(_my!['commissionEarned'])))),
              ]),
            ]),
          ),
          const SizedBox(height: 18),
          if (_tiers.isNotEmpty) const Padding(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6), child: Text('All Tiers', style: TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700))),
          ..._tiers.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              CircleAvatar(radius: 16, backgroundColor: AppColors.accent.withValues(alpha: 0.18), child: Text('${t['tier']}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tier ${t['tier']}', style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700)),
                Text('Min vol: \$${Fmt.compact(Fmt.parseNum(t['minVolume']))}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('M ${(Fmt.parseNum(t['maker']) * 100).toStringAsFixed(3)}%', style: const TextStyle(color: AppColors.success, fontSize: 12)),
                Text('T ${(Fmt.parseNum(t['taker']) * 100).toStringAsFixed(3)}%', style: const TextStyle(color: AppColors.danger, fontSize: 12)),
              ]),
            ]),
          )),
        ]),
    );
  }

  Widget _stat(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
  ]);
}
