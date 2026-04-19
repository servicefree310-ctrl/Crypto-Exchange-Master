import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/state.dart';
import '../utils/format.dart';
import 'trade_screen.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});
  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MarketsState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => m.refresh())],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.fg,
          unselectedLabelColor: AppColors.muted,
          tabs: const [Tab(text: 'All'), Tab(text: 'INR'), Tab(text: 'USDT')],
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            onChanged: (v) => setState(() => _q = v),
            style: const TextStyle(color: AppColors.fg),
            decoration: InputDecoration(
              hintText: 'Search BTC, ETH, SOL...',
              hintStyle: const TextStyle(color: AppColors.muted),
              prefixIcon: const Icon(Icons.search, color: AppColors.muted),
              filled: true, fillColor: AppColors.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
        ),
        if (m.error != null) Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Error: ${m.error}', style: const TextStyle(color: AppColors.danger)),
        ),
        Expanded(child: TabBarView(controller: _tab, children: [
          _list(m, ''),
          _list(m, 'INR'),
          _list(m, 'USDT'),
        ])),
      ]),
    );
  }

  Widget _list(MarketsState m, String quote) {
    final src = quote.isEmpty ? m.coins : m.pairs.where((p) => (p['quoteCoin'] ?? p['quote'] ?? '') == quote).toList();
    final filtered = src.where((c) {
      if (_q.isEmpty) return true;
      final q = _q.toLowerCase();
      return (c['symbol'] ?? '').toString().toLowerCase().contains(q) ||
          (c['name'] ?? '').toString().toLowerCase().contains(q) ||
          (c['baseCoin'] ?? '').toString().toLowerCase().contains(q);
    }).toList();

    if (m.loading && filtered.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (filtered.isEmpty) {
      return const Center(child: Text('No markets', style: TextStyle(color: AppColors.muted)));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => m.refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
        itemBuilder: (_, i) {
          final c = filtered[i];
          final isPair = quote.isNotEmpty;
          final symbol = isPair ? (c['symbol'] ?? '${c['baseCoin']}${c['quoteCoin']}').toString() : (c['symbol'] ?? '').toString();
          final base = (c['baseCoin'] ?? c['symbol'] ?? '').toString();
          final name = (c['name'] ?? '').toString();
          final price = Fmt.parseNum(c['lastPrice'] ?? c['currentPrice'] ?? c['price']);
          final change = Fmt.parseNum(c['change24h'] ?? c['priceChangePercent']);
          final vol = Fmt.parseNum(c['quoteVolume24h'] ?? c['volume24h']);
          final up = change >= 0;
          final pricePrefix = isPair ? (c['quoteCoin'] == 'INR' ? '₹' : '') : '\$';
          final priceSuffix = isPair && c['quoteCoin'] != 'INR' ? ' ${c['quoteCoin']}' : '';

          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TradeScreen(symbol: symbol))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    base.length > 2 ? base.substring(0, 2) : base,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(symbol, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.fg, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(name.isEmpty ? 'Vol ${Fmt.compact(vol)}' : name, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('$pricePrefix${Fmt.num2(price)}$priceSuffix', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.fg, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (up ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(Fmt.pct(change), style: TextStyle(color: up ? AppColors.success : AppColors.danger, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }
}
