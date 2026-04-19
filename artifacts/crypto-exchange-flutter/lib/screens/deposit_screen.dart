import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/api.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});
  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _coin = 'USDT';
  String? _network;
  Map<String, dynamic>? _addr;
  bool _busy = false;
  String? _err;

  // INR side
  final _inrAmt = TextEditingController();
  String? _gw;
  bool _inrBusy = false;
  String? _inrMsg;
  List<dynamic> _gateways = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadAddr();
    Api.gateways().then((g) => mounted ? setState(() => _gateways = g) : null);
  }

  Future<void> _loadAddr() async {
    setState(() { _busy = true; _err = null; });
    try {
      final r = await Api.depositAddress(_coin, _network);
      _addr = r is Map ? Map<String, dynamic>.from(r) : null;
    } catch (e) {
      _err = e.toString().replaceAll(RegExp(r'(ApiException)|(\(\d+\):\s*)'), '');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _payInr() async {
    setState(() { _inrBusy = true; _inrMsg = null; });
    try {
      await Api.inrDepositCreate({'amount': double.tryParse(_inrAmt.text) ?? 0, if (_gw != null) 'gatewayId': _gw});
      setState(() => _inrMsg = 'INR deposit request created');
      _inrAmt.clear();
    } catch (e) {
      setState(() => _inrMsg = e.toString().replaceAll(RegExp(r'(ApiException)|(\(\d+\):\s*)'), ''));
    } finally {
      if (mounted) setState(() => _inrBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit', style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(controller: _tab, indicatorColor: AppColors.primary, labelColor: AppColors.fg, unselectedLabelColor: AppColors.muted, tabs: const [Tab(text: 'Crypto'), Tab(text: 'INR')]),
      ),
      body: TabBarView(controller: _tab, children: [_crypto(), _inr()]),
    );
  }

  Widget _crypto() {
    final coins = ['USDT', 'BTC', 'ETH', 'BNB', 'SOL', 'TRX'];
    return ListView(padding: const EdgeInsets.all(16), children: [
      DropdownButtonFormField<String>(
        value: _coin,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: AppColors.fg),
        decoration: const InputDecoration(labelText: 'Coin', labelStyle: TextStyle(color: AppColors.muted), border: OutlineInputBorder()),
        items: coins.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) { if (v != null) { setState(() => _coin = v); _loadAddr(); } },
      ),
      const SizedBox(height: 16),
      if (_busy) const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.primary))),
      if (_err != null) Text(_err!, style: const TextStyle(color: AppColors.danger)),
      if (_addr != null) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Deposit Address', style: TextStyle(color: AppColors.muted, fontSize: 11)),
            const SizedBox(height: 6),
            SelectableText(_addr?['address']?.toString() ?? '—', style: const TextStyle(color: AppColors.fg, fontFamily: 'monospace', fontSize: 13)),
            const SizedBox(height: 8),
            if (_addr?['network'] != null) Text('Network: ${_addr!['network']}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () { Clipboard.setData(ClipboardData(text: _addr?['address']?.toString() ?? '')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address copied'))); },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Text('• Send only $_coin to this address.\n• Min deposit may apply.\n• Funds credited after network confirmations.',
            style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ],
    ]);
  }

  Widget _inr() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            controller: _inrAmt, keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.fg),
            decoration: const InputDecoration(labelText: 'Amount (INR)', labelStyle: TextStyle(color: AppColors.muted), border: OutlineInputBorder(), prefixText: '₹ '),
          ),
          const SizedBox(height: 12),
          if (_gateways.isNotEmpty) DropdownButtonFormField<String>(
            value: _gw,
            dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.fg),
            hint: const Text('Select Gateway', style: TextStyle(color: AppColors.muted)),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _gateways.map<DropdownMenuItem<String>>((g) => DropdownMenuItem(value: g['id'].toString(), child: Text((g['displayName'] ?? g['name'] ?? '').toString()))).toList(),
            onChanged: (v) => setState(() => _gw = v),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _inrBusy ? null : _payInr,
            child: _inrBusy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Deposit Request', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          if (_inrMsg != null) Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_inrMsg!, textAlign: TextAlign.center, style: TextStyle(color: _inrMsg!.contains('successful') || _inrMsg!.contains('created') ? AppColors.success : AppColors.danger)),
          ),
        ]),
      ),
    ]);
  }
}
