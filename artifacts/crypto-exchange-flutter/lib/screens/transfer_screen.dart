import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api.dart';
import '../services/state.dart';
import '../utils/format.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});
  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String _from = 'spot';
  String _to = 'futures';
  String _coin = 'USDT';
  final _amt = TextEditingController();
  bool _busy = false;
  String? _msg;

  Future<void> _go() async {
    setState(() { _busy = true; _msg = null; });
    try {
      await Api.transfer({'from': _from, 'to': _to, 'coin': _coin, 'amount': double.tryParse(_amt.text) ?? 0});
      setState(() => _msg = 'Transfer successful');
      _amt.clear();
      context.read<WalletsState>().refresh();
    } catch (e) {
      setState(() => _msg = e.toString().replaceAll('ApiException', '').replaceAll(RegExp(r'\(\d+\):\s*'), ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WalletsState>();
    final coins = <String>{...w.wallets.map((x) => (x['coin'] ?? x['symbol']).toString())}.where((s) => s.isNotEmpty).toList();
    if (coins.isEmpty) coins.addAll(['USDT', 'INR', 'BTC']);
    if (!coins.contains(_coin)) _coin = coins.first;

    final bal = w.balanceOf(_coin, type: _from);
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Column(children: [
            Row(children: [
              Expanded(child: _walletPicker('From', _from, (v) => setState(() => _from = v))),
              IconButton(icon: const Icon(Icons.swap_horiz, color: AppColors.primary), onPressed: () { final t = _from; setState(() { _from = _to; _to = t; }); }),
              Expanded(child: _walletPicker('To', _to, (v) => setState(() => _to = v))),
            ]),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _coin,
              dropdownColor: AppColors.card,
              style: const TextStyle(color: AppColors.fg),
              decoration: const InputDecoration(labelText: 'Coin', border: OutlineInputBorder(), labelStyle: TextStyle(color: AppColors.muted)),
              items: coins.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _coin = v ?? _coin),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amt,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.fg),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: const TextStyle(color: AppColors.muted),
                border: const OutlineInputBorder(),
                helperText: 'Available: ${Fmt.num2(bal)} $_coin',
                helperStyle: const TextStyle(color: AppColors.muted),
                suffixIcon: TextButton(onPressed: () => _amt.text = bal.toStringAsFixed(6), child: const Text('MAX', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800))),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _busy ? null : _go,
              child: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm Transfer', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            if (_msg != null) Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_msg!, textAlign: TextAlign.center, style: TextStyle(color: _msg == 'Transfer successful' ? AppColors.success : AppColors.danger)),
            ),
          ]),
        ),
      ])),
    );
  }

  Widget _walletPicker(String label, String val, ValueChanged<String> onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      const SizedBox(height: 4),
      DropdownButtonFormField<String>(
        value: val,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700),
        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
        items: const [
          DropdownMenuItem(value: 'spot', child: Text('Spot')),
          DropdownMenuItem(value: 'futures', child: Text('Futures')),
          DropdownMenuItem(value: 'earn', child: Text('Earn')),
        ],
        onChanged: (v) => v == null ? null : onChange(v),
      ),
    ]);
  }
}
