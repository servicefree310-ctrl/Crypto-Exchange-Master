import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api.dart';
import '../services/state.dart';
import '../utils/format.dart';

class EarnScreen extends StatefulWidget {
  const EarnScreen({super.key});
  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<dynamic> _products = [];
  List<dynamic> _positions = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await Future.wait([Api.earnProducts(), Api.earnPositions()]);
      _products = r[0]; _positions = r[1];
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _subscribe(dynamic p) async {
    final amtCtrl = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('Subscribe ${p['coin'] ?? ''}', style: const TextStyle(color: AppColors.fg)),
      content: TextField(controller: amtCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.fg), decoration: InputDecoration(labelText: 'Amount', helperText: 'APR ${Fmt.parseNum(p['apr'])}%', helperStyle: const TextStyle(color: AppColors.muted), labelStyle: const TextStyle(color: AppColors.muted))),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Subscribe'))],
    ));
    if (ok != true) return;
    try {
      await Api.earnSubscribe({'productId': p['id'], 'amount': double.tryParse(amtCtrl.text) ?? 0});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscribed')));
      context.read<WalletsState>().refresh();
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _redeem(dynamic id) async {
    try { await Api.earnRedeem(id); _load(); context.read<WalletsState>().refresh(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earn', style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(controller: _tab, indicatorColor: AppColors.primary, labelColor: AppColors.fg, unselectedLabelColor: AppColors.muted, tabs: const [Tab(text: 'Products'), Tab(text: 'My Positions')]),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) :
        TabBarView(controller: _tab, children: [_productList(), _positionsList()]),
    );
  }

  Widget _productList() => _products.isEmpty
      ? const Center(child: Text('No earn products', style: TextStyle(color: AppColors.muted)))
      : ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: _products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) {
            final p = _products[i];
            final apr = Fmt.parseNum(p['apr']);
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                CircleAvatar(radius: 20, backgroundColor: AppColors.accent.withValues(alpha: 0.18), child: Text((p['coin'] ?? '').toString().substring(0, ((p['coin'] ?? '').toString().length).clamp(0, 2)), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${p['coin'] ?? ''} • ${p['durationDays'] ?? 'Flexible'} ${p['durationDays'] != null ? 'd' : ''}', style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('APR', style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                  Text('${apr.toStringAsFixed(2)}%', style: const TextStyle(color: AppColors.success, fontSize: 18, fontWeight: FontWeight.w800)),
                ])),
                FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () => _subscribe(p), child: const Text('Subscribe')),
              ]),
            );
          },
        );

  Widget _positionsList() => _positions.isEmpty
      ? const Center(child: Text('No active positions', style: TextStyle(color: AppColors.muted)))
      : ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: _positions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) {
            final p = _positions[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${p['coin'] ?? ''} • ${Fmt.num2(Fmt.parseNum(p['amount']))}', style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Earned: ${Fmt.num2(Fmt.parseNum(p['accruedInterest']))}', style: const TextStyle(color: AppColors.success, fontSize: 11)),
                ])),
                OutlinedButton(onPressed: () => _redeem(p['id']), child: const Text('Redeem')),
              ]),
            );
          },
        );
}
