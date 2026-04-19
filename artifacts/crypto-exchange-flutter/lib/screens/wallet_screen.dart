import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/state.dart';
import '../utils/format.dart';
import 'login_screen.dart';
import 'transfer_screen.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import 'orders_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthState>().isLoggedIn) {
        context.read<WalletsState>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final w = context.watch<WalletsState>();
    final markets = context.watch<MarketsState>();

    if (!auth.isLoggedIn) return _guestView();

    double totalUsd = 0;
    for (final wal in w.wallets) {
      final coin = (wal['coin'] ?? wal['symbol'] ?? '').toString();
      final bal = Fmt.parseNum(wal['balance'] ?? wal['available']);
      if (bal <= 0) continue;
      if (coin == 'USDT' || coin == 'USDC') totalUsd += bal;
      else if (coin == 'INR') totalUsd += bal / 88;
      else {
        final p = markets.priceFor('${coin}USDT');
        if (p > 0) totalUsd += bal * p;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => w.refresh()),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => w.refresh(),
        child: ListView(padding: const EdgeInsets.all(12), children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF0E37C7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Equity', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text('\$${Fmt.num2(totalUsd)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 2),
              Text('≈ ₹${Fmt.num2(totalUsd * 88)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _btn(Icons.add, 'Deposit', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositScreen())))),
                const SizedBox(width: 8),
                Expanded(child: _btn(Icons.remove, 'Withdraw', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen())))),
                const SizedBox(width: 8),
                Expanded(child: _btn(Icons.swap_horiz, 'Transfer', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen())))),
              ]),
            ]),
          ),
          const SizedBox(height: 18),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6), child: Text('Assets', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.fg, fontSize: 14))),
          if (w.loading) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
          ...w.wallets.where((wa) => Fmt.parseNum(wa['balance'] ?? wa['available']) > 0).map((wa) => _walletRow(wa, markets)).toList(),
          if (!w.loading && w.wallets.where((wa) => Fmt.parseNum(wa['balance'] ?? wa['available']) > 0).isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: const Center(child: Column(children: [
                Icon(Icons.account_balance_wallet_outlined, size: 36, color: AppColors.muted),
                SizedBox(height: 8),
                Text('Your wallet is empty', style: TextStyle(color: AppColors.muted)),
                SizedBox(height: 4),
                Text('Tap Deposit to add funds', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              ])),
            ),
        ]),
      ),
    );
  }

  Widget _walletRow(dynamic wa, MarketsState markets) {
    final coin = (wa['coin'] ?? wa['symbol'] ?? '').toString();
    final bal = Fmt.parseNum(wa['balance'] ?? wa['available']);
    final type = (wa['type'] ?? 'spot').toString();
    double usdVal = 0;
    if (coin == 'USDT' || coin == 'USDC') usdVal = bal;
    else if (coin == 'INR') usdVal = bal / 88;
    else { final p = markets.priceFor('${coin}USDT'); if (p > 0) usdVal = bal * p; }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        CircleAvatar(
          radius: 16, backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(coin.length > 2 ? coin.substring(0, 2) : coin, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(coin, style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: AppColors.muted.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3)),
              child: Text(type.toUpperCase(), style: const TextStyle(color: AppColors.muted, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 2),
          Text('≈ \$${Fmt.num2(usdVal)}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        ])),
        Text(Fmt.num2(bal), style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 16),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 10)),
    );
  }

  Widget _guestView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(36)),
              child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 36)),
          const SizedBox(height: 14),
          const Text('Login to view wallet', style: TextStyle(color: AppColors.fg, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
            child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ]),
      )),
    );
  }
}
