import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../services/api.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  List<dynamic> _coins = [];
  bool _loading = true;
  String? _err;
  Timer? _timer;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final coins = await ApiService.getCoins();
      if (!mounted) return;
      setState(() {
        _coins = coins;
        _loading = false;
        _err = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _err = e.toString();
      });
    }
  }

  String _fmt(num v) {
    if (v >= 1) return NumberFormat('#,##0.00', 'en_US').format(v);
    return v.toStringAsFixed(5);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _coins.where((c) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return (c['symbol'] ?? '').toString().toLowerCase().contains(q) ||
          (c['name'] ?? '').toString().toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.fg),
              decoration: InputDecoration(
                hintText: 'Search coin (BTC, ETH...)',
                hintStyle: const TextStyle(color: AppColors.muted),
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
          ),
          if (_err != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Error: $_err', style: const TextStyle(color: AppColors.danger)),
            ),
          Expanded(
            child: _loading && _coins.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        final price = double.tryParse('${c['currentPrice'] ?? 0}') ?? 0;
                        final change = double.tryParse('${c['change24h'] ?? 0}') ?? 0;
                        final changeUp = change >= 0;
                        final symbol = c['symbol'] ?? '';
                        final name = c['name'] ?? '';
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              symbol.toString().substring(0, symbol.toString().length > 2 ? 2 : symbol.toString().length),
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11),
                            ),
                          ),
                          title: Text(symbol.toString(), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.fg)),
                          subtitle: Text(name.toString(), style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${_fmt(price)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.fg)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (changeUp ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${changeUp ? '+' : ''}${change.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: changeUp ? AppColors.success : AppColors.danger,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {},
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
