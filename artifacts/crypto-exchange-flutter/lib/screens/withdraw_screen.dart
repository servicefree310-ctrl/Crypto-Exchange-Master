import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api.dart';
import '../services/state.dart';
import '../utils/format.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});
  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _coin = 'USDT';
  final _addr = TextEditingController();
  final _amt = TextEditingController();
  bool _busy = false;
  String? _msg;

  // INR
  final _inrAmt = TextEditingController();
  String? _bankId;
  List<dynamic> _banks = [];
  bool _inrBusy = false;
  String? _inrMsg;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    Api.banks().then((b) => mounted ? setState(() => _banks = b) : null);
  }

  Future<void> _withdrawCrypto() async {
    setState(() { _busy = true; _msg = null; });
    try {
      await Api.cryptoWithdrawCreate({'coin': _coin, 'address': _addr.text, 'amount': double.tryParse(_amt.text) ?? 0});
      setState(() => _msg = 'Withdrawal request submitted');
      _amt.clear();
      context.read<WalletsState>().refresh();
    } catch (e) {
      setState(() => _msg = e.toString().replaceAll(RegExp(r'(ApiException)|(\(\d+\):\s*)'), ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _withdrawInr() async {
    setState(() { _inrBusy = true; _inrMsg = null; });
    try {
      await Api.inrWithdrawCreate({'amount': double.tryParse(_inrAmt.text) ?? 0, if (_bankId != null) 'bankId': _bankId});
      setState(() => _inrMsg = 'INR withdrawal submitted');
      _inrAmt.clear();
      context.read<WalletsState>().refresh();
    } catch (e) {
      setState(() => _inrMsg = e.toString().replaceAll(RegExp(r'(ApiException)|(\(\d+\):\s*)'), ''));
    } finally {
      if (mounted) setState(() => _inrBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WalletsState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(controller: _tab, indicatorColor: AppColors.primary, labelColor: AppColors.fg, unselectedLabelColor: AppColors.muted, tabs: const [Tab(text: 'Crypto'), Tab(text: 'INR')]),
      ),
      body: TabBarView(controller: _tab, children: [_crypto(w), _inr(w)]),
    );
  }

  Widget _crypto(WalletsState w) {
    final coins = ['USDT', 'BTC', 'ETH', 'BNB', 'SOL', 'TRX'];
    final bal = w.balanceOf(_coin);
    return ListView(padding: const EdgeInsets.all(16), children: [
      DropdownButtonFormField<String>(
        value: _coin,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: AppColors.fg),
        decoration: const InputDecoration(labelText: 'Coin', labelStyle: TextStyle(color: AppColors.muted), border: OutlineInputBorder()),
        items: coins.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _coin = v ?? _coin),
      ),
      const SizedBox(height: 12),
      TextField(controller: _addr, style: const TextStyle(color: AppColors.fg), decoration: const InputDecoration(labelText: 'Destination address', labelStyle: TextStyle(color: AppColors.muted), border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(
        controller: _amt, keyboardType: TextInputType.number,
        style: const TextStyle(color: AppColors.fg),
        decoration: InputDecoration(labelText: 'Amount', labelStyle: const TextStyle(color: AppColors.muted), border: const OutlineInputBorder(), helperText: 'Available: ${Fmt.num2(bal)} $_coin', helperStyle: const TextStyle(color: AppColors.muted)),
      ),
      const SizedBox(height: 16),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(vertical: 14)),
        onPressed: _busy ? null : _withdrawCrypto,
        child: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit Withdrawal', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      if (_msg != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_msg!, textAlign: TextAlign.center, style: TextStyle(color: _msg!.contains('submitted') ? AppColors.success : AppColors.danger))),
    ]);
  }

  Widget _inr(WalletsState w) {
    final inrBal = w.balanceOf('INR');
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (_banks.isNotEmpty) DropdownButtonFormField<String>(
        value: _bankId,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: AppColors.fg),
        hint: const Text('Select Bank', style: TextStyle(color: AppColors.muted)),
        decoration: const InputDecoration(border: OutlineInputBorder()),
        items: _banks.map<DropdownMenuItem<String>>((b) => DropdownMenuItem(value: b['id'].toString(), child: Text('${b['bankName'] ?? ''} •••${(b['accountNumber'] ?? '').toString().substring(((b['accountNumber'] ?? '').toString().length - 4).clamp(0, 999))}'))).toList(),
        onChanged: (v) => setState(() => _bankId = v),
      ),
      if (_banks.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No bank added. Add from Account → Banks first.', style: TextStyle(color: AppColors.muted))),
      const SizedBox(height: 12),
      TextField(
        controller: _inrAmt, keyboardType: TextInputType.number,
        style: const TextStyle(color: AppColors.fg),
        decoration: InputDecoration(labelText: 'Amount (INR)', labelStyle: const TextStyle(color: AppColors.muted), border: const OutlineInputBorder(), prefixText: '₹ ', helperText: 'Available: ₹${Fmt.num2(inrBal)}', helperStyle: const TextStyle(color: AppColors.muted)),
      ),
      const SizedBox(height: 16),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(vertical: 14)),
        onPressed: _inrBusy ? null : _withdrawInr,
        child: _inrBusy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit Withdrawal', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      if (_inrMsg != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_inrMsg!, textAlign: TextAlign.center, style: TextStyle(color: _inrMsg!.contains('submitted') ? AppColors.success : AppColors.danger))),
    ]);
  }
}
