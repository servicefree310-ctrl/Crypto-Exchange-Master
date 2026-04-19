import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api.dart';
import '../utils/format.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _orders = await Api.myOrders(); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _cancel(dynamic id) async {
    try { await Api.cancelOrder(id); _load(); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w800)), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) :
        _orders.isEmpty ? const Center(child: Text('No orders yet', style: TextStyle(color: AppColors.muted))) :
        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: _orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) {
            final o = _orders[i];
            final side = (o['side'] ?? '').toString().toLowerCase();
            final isBuy = side == 'buy';
            final status = (o['status'] ?? '').toString();
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: (isBuy ? AppColors.success : AppColors.danger).withValues(alpha: 0.18), borderRadius: BorderRadius.circular(4)),
                  child: Text(side.toUpperCase(), style: TextStyle(color: isBuy ? AppColors.success : AppColors.danger, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o['symbol']?.toString() ?? '', style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${o['type'] ?? ''} · ${Fmt.num2(Fmt.parseNum(o['quantity']))} @ ${Fmt.num2(Fmt.parseNum(o['price']))}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(status, style: TextStyle(color: status == 'filled' ? AppColors.success : status == 'cancelled' ? AppColors.muted : AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                  if (status == 'open' || status == 'partial' || status == 'pending') TextButton(onPressed: () => _cancel(o['id']), child: const Text('Cancel', style: TextStyle(color: AppColors.danger, fontSize: 11))),
                ]),
              ]),
            );
          },
        ),
    );
  }
}
